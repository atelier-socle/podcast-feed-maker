import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

#if canImport(FoundationXML)
    import FoundationXML
#endif

/// Parses podcast RSS feeds from XML into ``PodcastFeed`` models.
///
/// `FeedParser` is the primary public API for feed parsing. It supports
/// parsing from `String`, `Data`, or `URL` sources.
///
/// All 7 namespaces are handled: RSS 2.0, iTunes, Podcast NS 2.0,
/// Atom, Dublin Core, Content Module, and Podlove Simple Chapters.
///
/// ## Usage
///
/// ```swift
/// let parser = FeedParser()
/// let feed = try parser.parse(xmlString)
/// ```
///
/// ## Best-Effort Parsing
///
/// The parser collects non-fatal errors (e.g., malformed dates, missing
/// optional attributes) and continues parsing. Use ``parseWithDiagnostics(_:)``
/// to access both the feed and any warnings.
public struct FeedParser: Sendable {

    /// Creates a new feed parser.
    public init() {}

    // MARK: - Parse from String

    /// Parses an XML string into a ``PodcastFeed``.
    ///
    /// - Parameter string: The RSS XML string.
    /// - Returns: The parsed feed.
    /// - Throws: ``ParserError`` if the XML is invalid or required
    ///   elements are missing.
    public func parse(_ string: String) throws -> PodcastFeed {
        guard let data = string.data(using: .utf8) else {
            throw ParserError.encodingError(
                "Failed to encode string as UTF-8"
            )
        }
        return try parse(data: data)
    }

    /// Parses XML data into a ``PodcastFeed``.
    ///
    /// - Parameter data: The raw XML data.
    /// - Returns: The parsed feed.
    /// - Throws: ``ParserError`` if the XML is invalid or required
    ///   elements are missing.
    public func parse(data: Data) throws -> PodcastFeed {
        let result = try parseInternal(data: data)
        return result.feed
    }

    /// Parses a feed from a URL (remote or local file).
    ///
    /// - Parameter url: The feed URL.
    /// - Returns: The parsed feed.
    /// - Throws: ``ParserError`` if the network request fails,
    ///   the XML is invalid, or required elements are missing.
    public func parse(url: URL) async throws -> PodcastFeed {
        let data: Data
        if url.isFileURL {
            do {
                data = try Data(contentsOf: url)
            } catch {
                throw ParserError.networkError(error.localizedDescription)
            }
        } else {
            do {
                let (fetchedData, _) = try await URLSession.shared.data(
                    from: url
                )
                data = fetchedData
            } catch {
                throw ParserError.networkError(error.localizedDescription)
            }
        }
        return try parse(data: data)
    }

    // MARK: - Parse with Diagnostics

    /// The result of parsing with diagnostic information.
    public struct ParseResult: Sendable {
        /// The parsed feed.
        public let feed: PodcastFeed
        /// Non-fatal warnings encountered during parsing.
        public let warnings: [ParserError]
    }

    /// Parses an XML string and returns both the feed and any warnings.
    ///
    /// - Parameter string: The RSS XML string.
    /// - Returns: A ``ParseResult`` with the feed and warnings.
    /// - Throws: ``ParserError`` for fatal parsing errors.
    public func parseWithDiagnostics(
        _ string: String
    ) throws -> ParseResult {
        guard let data = string.data(using: .utf8) else {
            throw ParserError.encodingError(
                "Failed to encode string as UTF-8"
            )
        }
        return try parseWithDiagnostics(data: data)
    }

    /// Parses XML data and returns both the feed and any warnings.
    ///
    /// - Parameter data: The raw XML data.
    /// - Returns: A ``ParseResult`` with the feed and warnings.
    /// - Throws: ``ParserError`` for fatal parsing errors.
    public func parseWithDiagnostics(
        data: Data
    ) throws -> ParseResult {
        let result = try parseInternal(data: data)
        return ParseResult(
            feed: result.feed, warnings: result.warnings
        )
    }

    // MARK: - Internal

    private func parseInternal(
        data: Data
    ) throws -> (feed: PodcastFeed, warnings: [ParserError]) {
        let xmlParser = XMLParser(data: data)
        xmlParser.shouldProcessNamespaces = false
        xmlParser.shouldReportNamespacePrefixes = false

        let delegate = FeedParserDelegate()
        xmlParser.delegate = delegate

        guard xmlParser.parse() || delegate.feed.channel != nil else {
            if let error = xmlParser.parserError {
                throw ParserError.invalidXML(
                    error.localizedDescription
                )
            }
            throw ParserError.invalidXML("Unknown parsing error")
        }

        let feed = delegate.feed

        if feed.channel == nil && delegate.parsingErrors.isEmpty {
            throw ParserError.missingChannel
        }

        return (feed: feed, warnings: delegate.parsingErrors)
    }
}
