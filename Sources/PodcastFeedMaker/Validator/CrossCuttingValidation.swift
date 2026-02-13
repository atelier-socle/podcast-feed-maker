import Foundation

// MARK: - Cross-Cutting Validation

/// Universal validation rules applied regardless of platform.
enum CrossCuttingValidation {

    /// Runs all cross-cutting checks on the feed.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Universal validation results.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else { return [] }

        var results: [ValidationResult] = []
        results += checkGuidUniqueness(channel)
        results += checkGuidPermaLinkConsistency(channel)
        results += checkURLFormats(channel)
        results += checkItemMinimumContent(channel)
        results += checkFuturePubDate(channel)
        results += checkAtomSelfLink(channel)
        results += checkNewFeedUrlScheme(channel)
        results += checkItunesComplete(channel)
        return results
    }

    // MARK: - GUID Uniqueness

    private static func checkGuidUniqueness(
        _ channel: Channel
    ) -> [ValidationResult] {
        var seen: [String: Int] = [:]
        var results: [ValidationResult] = []
        for (idx, item) in channel.items.enumerated() {
            guard let guid = item.guid else { continue }
            if let firstIdx = seen[guid.value] {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Duplicate GUID '\(guid.value)' "
                            + "(also at items[\(firstIdx)])",
                        field: "channel.items[\(idx)].guid"
                    ))
            } else {
                seen[guid.value] = idx
            }
        }
        return results
    }

    // MARK: - GUID PermaLink Consistency

    private static func checkGuidPermaLinkConsistency(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []
        for (idx, item) in channel.items.enumerated() {
            guard let guid = item.guid else { continue }
            let looksLikeURL =
                guid.value.hasPrefix("http://")
                || guid.value.hasPrefix("https://")

            if looksLikeURL && !guid.isPermaLink {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "GUID looks like a URL but isPermaLink is false",
                        field: "channel.items[\(idx)].guid"
                    ))
            }
            if !looksLikeURL && guid.isPermaLink {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "GUID is not a URL but isPermaLink is true",
                        field: "channel.items[\(idx)].guid"
                    ))
            }
        }
        return results
    }

    // MARK: - Future PubDate

    private static func checkFuturePubDate(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []
        let futureThreshold = Date().addingTimeInterval(24 * 60 * 60)

        if let pubDate = channel.pubDate, pubDate > futureThreshold {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Channel pubDate is more than 24 hours in the future",
                    field: "channel.pubDate"
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let pubDate = item.pubDate, pubDate > futureThreshold {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Item pubDate is more than 24 hours in the future",
                        field: "channel.items[\(idx)].pubDate"
                    ))
            }
        }

        return results
    }

    // MARK: - Atom Self Link

    private static func checkAtomSelfLink(
        _ channel: Channel
    ) -> [ValidationResult] {
        let hasSelfLink = channel.atomLinks.contains { $0.rel == "self" }
        if !hasSelfLink {
            return [
                ValidationResult(
                    severity: .info,
                    message: "No atom:link with rel=\"self\" found",
                    field: "channel.atomLinks"
                )
            ]
        }
        return []
    }

    // MARK: - URL Format

    private static func checkURLFormats(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.link.absoluteString.isEmpty {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Channel link URL is empty",
                    field: "channel.link"
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let link = item.link,
                link.absoluteString.isEmpty
            {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Item link URL is empty",
                        field: "channel.items[\(idx)].link"
                    ))
            }
        }

        return results
    }

    // MARK: - New Feed URL Scheme

    private static func checkNewFeedUrlScheme(
        _ channel: Channel
    ) -> [ValidationResult] {
        guard let url = channel.itunesNewFeedUrl else { return [] }
        if url.scheme?.lowercased() != "https" {
            return [
                ValidationResult(
                    severity: .warning,
                    message: "itunes:new-feed-url should use HTTPS",
                    field: "channel.itunesNewFeedUrl"
                )
            ]
        }
        return []
    }

    // MARK: - iTunes Complete

    private static func checkItunesComplete(
        _ channel: Channel
    ) -> [ValidationResult] {
        if channel.itunesComplete == true {
            return [
                ValidationResult(
                    severity: .info,
                    message: "Podcast is marked as complete. "
                        + "No new episodes expected.",
                    field: "channel.itunesComplete"
                )
            ]
        }
        return []
    }

    // MARK: - Item Minimum Content

    private static func checkItemMinimumContent(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []
        for (idx, item) in channel.items.enumerated() {
            let hasTitle = item.title.map { !$0.isEmpty } ?? false
            let hasDescription = item.description.map { !$0.isEmpty } ?? false
            if !hasTitle && !hasDescription {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Item must have at least a title or description",
                        field: "channel.items[\(idx)]"
                    ))
            }
        }
        return results
    }
}
