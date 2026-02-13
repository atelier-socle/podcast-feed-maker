import Foundation

/// Validates feed URLs by performing HTTP HEAD requests.
///
/// `NetworkValidator` checks that artwork, enclosure, and other URLs
/// referenced in a podcast feed are reachable and return expected content types.
///
/// All checks use HEAD requests to avoid downloading full media files.
///
/// ## Usage
///
/// ```swift
/// let validator = NetworkValidator()
/// let results = try await validator.checkAllURLs(feed)
/// for result in results {
///     print("\(result.severity): \(result.message)")
/// }
/// ```
///
/// - Important: Network-dependent. Use with care in test environments.
public struct NetworkValidator: Sendable {

    /// The URL session used for HEAD requests.
    let session: URLSession

    /// The timeout interval per request, in seconds.
    let timeout: TimeInterval

    /// Maximum number of concurrent requests.
    let maxConcurrency: Int

    /// Creates a new network validator.
    ///
    /// - Parameters:
    ///   - session: The URL session to use. Defaults to `.shared`.
    ///   - timeout: Timeout per request in seconds. Defaults to `10`.
    ///   - maxConcurrency: Maximum concurrent requests. Defaults to `5`.
    public init(
        session: URLSession = .shared,
        timeout: TimeInterval = 10,
        maxConcurrency: Int = 5
    ) {
        self.session = session
        self.timeout = timeout
        self.maxConcurrency = maxConcurrency
    }

    // MARK: - Public API

    /// Checks artwork URLs in the feed.
    ///
    /// Validates the channel-level `itunes:image` and any item-level artwork URLs.
    ///
    /// - Parameter feed: The feed to check.
    /// - Returns: Validation results for each artwork URL.
    public func checkArtwork(_ feed: PodcastFeed) async throws -> [ValidationResult] {
        let urls = extractArtworkURLs(from: feed)
        return await checkURLs(urls)
    }

    /// Checks enclosure URLs in the feed.
    ///
    /// Validates that each item's enclosure URL is reachable and returns
    /// the expected content type.
    ///
    /// - Parameter feed: The feed to check.
    /// - Returns: Validation results for each enclosure URL.
    public func checkEnclosures(_ feed: PodcastFeed) async throws -> [ValidationResult] {
        let entries = extractEnclosureEntries(from: feed)
        return await checkURLs(entries)
    }

    /// Checks all URLs referenced in the feed.
    ///
    /// Combines artwork, enclosure, and other URL checks.
    ///
    /// - Parameter feed: The feed to check.
    /// - Returns: Combined validation results.
    public func checkAllURLs(_ feed: PodcastFeed) async throws -> [ValidationResult] {
        let entries = extractAllURLEntries(from: feed)
        return await checkURLs(entries)
    }

    // MARK: - URL Extraction

    /// A URL to check, with metadata for result reporting.
    struct URLEntry: Sendable {
        let url: URL
        let field: String
        let expectedType: String?
    }

    func extractArtworkURLs(from feed: PodcastFeed) -> [URLEntry] {
        guard let channel = feed.channel else { return [] }
        var entries: [URLEntry] = []

        if let imageURL = channel.itunesImage {
            entries.append(
                URLEntry(
                    url: imageURL,
                    field: "channel.itunesImage",
                    expectedType: nil
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let imageURL = item.itunesImage {
                entries.append(
                    URLEntry(
                        url: imageURL,
                        field: "channel.items[\(idx)].itunesImage",
                        expectedType: nil
                    ))
            }
        }

        return entries
    }

    func extractEnclosureEntries(from feed: PodcastFeed) -> [URLEntry] {
        guard let channel = feed.channel else { return [] }
        var entries: [URLEntry] = []

        for (idx, item) in channel.items.enumerated() {
            if let enclosure = item.enclosure {
                entries.append(
                    URLEntry(
                        url: enclosure.url,
                        field: "channel.items[\(idx)].enclosure.url",
                        expectedType: enclosure.type
                    ))
            }
        }

        return entries
    }

    func extractAllURLEntries(from feed: PodcastFeed) -> [URLEntry] {
        var entries: [URLEntry] = []
        entries += extractArtworkURLs(from: feed)
        entries += extractEnclosureEntries(from: feed)

        guard let channel = feed.channel else { return entries }

        for atomLink in channel.atomLinks {
            entries.append(
                URLEntry(
                    url: atomLink.href,
                    field: "channel.atomLinks",
                    expectedType: atomLink.type
                ))
        }

        for funding in channel.funding {
            entries.append(
                URLEntry(
                    url: funding.url,
                    field: "channel.funding",
                    expectedType: nil
                ))
        }

        return entries
    }

    // MARK: - URL Checking

    private func checkURLs(_ entries: [URLEntry]) async -> [ValidationResult] {
        guard !entries.isEmpty else { return [] }

        return await withTaskGroup(
            of: [ValidationResult].self,
            returning: [ValidationResult].self
        ) { group in
            var results: [ValidationResult] = []
            var pending = 0

            for entry in entries {
                if pending >= maxConcurrency {
                    if let batch = await group.next() {
                        results += batch
                        pending -= 1
                    }
                }

                group.addTask {
                    await self.checkSingleURL(entry)
                }
                pending += 1
            }

            for await batch in group {
                results += batch
            }

            return results
        }
    }

    private func checkSingleURL(_ entry: URLEntry) async -> [ValidationResult] {
        var request = URLRequest(url: entry.url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = timeout

        do {
            let (_, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                return [
                    ValidationResult(
                        severity: .warning,
                        message: "Non-HTTP response for \(entry.url.absoluteString)",
                        field: entry.field
                    )
                ]
            }

            var results = validateStatusCode(httpResponse.statusCode, entry: entry)
            results += validateContentType(httpResponse, entry: entry)
            return results
        } catch {
            return [
                ValidationResult(
                    severity: .error,
                    message: "Network error for \(entry.url.absoluteString): "
                        + error.localizedDescription,
                    field: entry.field
                )
            ]
        }
    }

    private func validateStatusCode(
        _ statusCode: Int, entry: URLEntry
    ) -> [ValidationResult] {
        switch statusCode {
        case 200...299:
            return []
        case 300...399:
            return [
                ValidationResult(
                    severity: .info,
                    message: "URL redirects (HTTP \(statusCode)): "
                        + entry.url.absoluteString,
                    field: entry.field
                )
            ]
        case 400...599:
            return [
                ValidationResult(
                    severity: .error,
                    message: "URL unreachable (HTTP \(statusCode)): "
                        + entry.url.absoluteString,
                    field: entry.field
                )
            ]
        default:
            return [
                ValidationResult(
                    severity: .warning,
                    message: "Unexpected HTTP \(statusCode): "
                        + entry.url.absoluteString,
                    field: entry.field
                )
            ]
        }
    }

    private func validateContentType(
        _ response: HTTPURLResponse, entry: URLEntry
    ) -> [ValidationResult] {
        guard let expectedType = entry.expectedType,
            let contentType = response.value(forHTTPHeaderField: "Content-Type")
        else { return [] }

        let actualBase =
            contentType.components(separatedBy: ";").first?
            .trimmingCharacters(in: .whitespaces) ?? contentType

        if actualBase.lowercased() != expectedType.lowercased() {
            return [
                ValidationResult(
                    severity: .warning,
                    message: "Content-Type mismatch: expected '\(expectedType)' "
                        + "but got '\(actualBase)'",
                    field: entry.field
                )
            ]
        }
        return []
    }
}
