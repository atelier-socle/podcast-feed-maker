import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// High-level facade combining generation, parsing, and validation.
///
/// `PodcastFeedEngine` provides a single entry point for the most common
/// podcast feed workflows. It delegates to ``FeedGenerator``,
/// ``FeedParser``, and ``FeedValidator`` internally.
///
/// ## Usage
///
/// ```swift
/// let engine = PodcastFeedEngine()
///
/// // Generate
/// let xml = try engine.generate(feed)
///
/// // Parse
/// let parsed = try engine.parse(xmlString)
///
/// // Validate
/// let report = engine.validate(feed, for: .apple)
///
/// // Combined: parse + validate
/// let (feed, report) = try engine.parseAndValidate(xmlString, for: .apple)
///
/// // Normalize (round-trip)
/// let normalized = try engine.normalize(xmlString)
///
/// // Equivalence check
/// let equal = try engine.isEquivalent(xml1, xml2)
/// ```
///
/// - SeeAlso: ``FeedGenerator``, ``FeedParser``, ``FeedValidator``
public struct PodcastFeedEngine: Sendable {

    /// Creates a new podcast feed engine.
    public init() {}

    // MARK: - Generation

    /// Generates an RSS XML string from a feed model.
    ///
    /// - Parameters:
    ///   - feed: The feed to generate XML for.
    ///   - prettyPrint: Whether to indent the output. Defaults to `true`.
    /// - Returns: A complete RSS 2.0 XML string.
    /// - Throws: ``GeneratorError`` if the feed is invalid.
    public func generate(
        _ feed: PodcastFeed, prettyPrint: Bool = true
    ) throws -> String {
        try FeedGenerator(prettyPrint: prettyPrint).generate(feed)
    }

    /// Generates an RSS feed as an async stream of XML chunks.
    ///
    /// Yields N+2 chunks for a feed with N items: header, each item,
    /// and footer. Suitable for large catalogs (10,000+ episodes).
    ///
    /// - Parameters:
    ///   - feed: The feed to generate XML for.
    ///   - prettyPrint: Whether to indent the output. Defaults to `true`.
    /// - Returns: An `AsyncThrowingStream` yielding XML string chunks.
    public func generateStream(
        _ feed: PodcastFeed, prettyPrint: Bool = true
    ) -> AsyncThrowingStream<String, Error> {
        StreamingFeedGenerator(prettyPrint: prettyPrint).generate(feed)
    }

    // MARK: - Parsing

    /// Parses an XML string into a ``PodcastFeed``.
    ///
    /// - Parameter xml: The RSS XML string.
    /// - Returns: The parsed feed model.
    /// - Throws: ``ParserError`` if the XML is invalid.
    public func parse(_ xml: String) throws -> PodcastFeed {
        try FeedParser().parse(xml)
    }

    /// Parses XML data into a ``PodcastFeed``.
    ///
    /// - Parameter data: The raw XML data.
    /// - Returns: The parsed feed model.
    /// - Throws: ``ParserError`` if the XML is invalid.
    public func parse(data: Data) throws -> PodcastFeed {
        try FeedParser().parse(data: data)
    }

    /// Parses a remote feed from a URL.
    ///
    /// - Parameter url: The feed URL.
    /// - Returns: The parsed feed model.
    /// - Throws: ``ParserError`` if the network request or parsing fails.
    public func parse(url: URL) async throws -> PodcastFeed {
        try await FeedParser().parse(url: url)
    }

    // MARK: - Validation

    /// Validates a feed against a single platform.
    ///
    /// - Parameters:
    ///   - feed: The feed to validate.
    ///   - platform: The target platform.
    /// - Returns: A ``ValidationReport`` with the findings.
    public func validate(
        _ feed: PodcastFeed, for platform: ValidationPlatform
    ) -> ValidationReport {
        FeedValidator().validate(feed, for: platform)
    }

    /// Validates a feed against all supported platforms.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: An array of ``ValidationReport``, one per platform.
    public func validateAll(_ feed: PodcastFeed) -> [ValidationReport] {
        FeedValidator().validateAll(feed)
    }

    // MARK: - Network Validation

    /// Validates feed URLs by performing HTTP HEAD requests.
    ///
    /// Checks artwork, enclosures, Atom links, and funding URLs for
    /// reachability and correct content types. Uses HEAD requests only
    /// (no downloads).
    ///
    /// - Parameters:
    ///   - feed: The feed to validate.
    ///   - session: The URL session to use. Defaults to `.shared`.
    /// - Returns: Validation results for all checked URLs.
    public func validateNetwork(
        _ feed: PodcastFeed,
        session: URLSession = .shared
    ) async throws -> [ValidationResult] {
        try await NetworkValidator(session: session).checkAllURLs(feed)
    }

    // MARK: - Media Verification

    /// Verifies actual media file types by checking magic bytes.
    ///
    /// Downloads the first 12 bytes of each enclosure URL and compares
    /// the detected file signature against the declared MIME type.
    ///
    /// - Parameters:
    ///   - feed: The feed whose media URLs to verify.
    ///   - session: The URL session to use. Defaults to `.shared`.
    /// - Returns: Validation results for mismatches and errors.
    public func verifyMediaTypes(
        _ feed: PodcastFeed,
        session: URLSession = .shared
    ) async throws -> [ValidationResult] {
        try await NetworkValidator(session: session).verifyMediaTypes(feed)
    }

    /// Checks artwork dimensions and aspect ratio against platform requirements.
    ///
    /// Downloads the first 1024 bytes of each artwork URL, parses the
    /// image dimensions, and validates against the specified platform's
    /// size and aspect ratio rules.
    ///
    /// - Parameters:
    ///   - feed: The feed whose artwork URLs to check.
    ///   - platform: The target platform for dimension requirements.
    ///   - session: The URL session to use. Defaults to `.shared`.
    /// - Returns: Validation results for dimension issues and errors.
    public func checkArtworkDimensions(
        _ feed: PodcastFeed,
        for platform: ValidationPlatform,
        session: URLSession = .shared
    ) async throws -> [ValidationResult] {
        try await NetworkValidator(session: session)
            .checkArtworkDimensions(feed, for: platform)
    }


    // MARK: - Combined Workflows

    /// Parses an XML string and validates the result against a platform.
    ///
    /// Combines ``parse(_:)`` and ``validate(_:for:)`` in a single call.
    ///
    /// - Parameters:
    ///   - xml: The RSS XML string.
    ///   - platform: The target platform.
    /// - Returns: A tuple of the parsed feed and its validation report.
    /// - Throws: ``ParserError`` if the XML is invalid.
    public func parseAndValidate(
        _ xml: String, for platform: ValidationPlatform
    ) throws -> (feed: PodcastFeed, report: ValidationReport) {
        let feed = try parse(xml)
        let report = validate(feed, for: platform)
        return (feed: feed, report: report)
    }

    /// Normalizes an XML feed by parsing and re-generating it.
    ///
    /// This round-trip ensures consistent formatting, tag ordering,
    /// and namespace declarations.
    ///
    /// - Parameters:
    ///   - xml: The RSS XML string to normalize.
    ///   - prettyPrint: Whether to indent the output. Defaults to `true`.
    /// - Returns: The normalized XML string.
    /// - Throws: ``ParserError`` or ``GeneratorError`` if the feed
    ///   cannot be round-tripped.
    public func normalize(
        _ xml: String, prettyPrint: Bool = true
    ) throws -> String {
        let feed = try parse(xml)
        return try FeedGenerator(
            prettyPrint: prettyPrint,
            namespaceMode: .auto
        ).generate(feed)
    }

    // MARK: - Diff

    /// Compares two feed models and returns detailed differences.
    ///
    /// - Parameters:
    ///   - lhs: The original feed.
    ///   - rhs: The updated feed.
    /// - Returns: An array of ``FeedDifference`` values.
    public func diff(
        _ lhs: PodcastFeed, _ rhs: PodcastFeed
    ) -> [FeedDifference] {
        FeedDiff().diff(lhs, rhs)
    }

    /// Compares two XML feed strings and returns detailed differences.
    ///
    /// Parses both strings, then diffs the resulting models.
    ///
    /// - Parameters:
    ///   - lhs: The original XML string.
    ///   - rhs: The updated XML string.
    /// - Returns: An array of ``FeedDifference`` values.
    /// - Throws: ``ParserError`` if either string cannot be parsed.
    public func diff(
        xml lhs: String, xml rhs: String
    ) throws -> [FeedDifference] {
        try FeedDiff().diff(xml: lhs, xml: rhs)
    }

    /// Checks whether two XML feeds produce equivalent models.
    ///
    /// Parses both strings and compares the resulting ``PodcastFeed``
    /// instances for equality. Differences in formatting, whitespace,
    /// or tag ordering do not affect the result.
    ///
    /// - Parameters:
    ///   - xml1: The first RSS XML string.
    ///   - xml2: The second RSS XML string.
    /// - Returns: `true` if both feeds parse to equal models.
    /// - Throws: ``ParserError`` if either string is invalid XML.
    public func isEquivalent(
        _ xml1: String, _ xml2: String
    ) throws -> Bool {
        let feed1 = try parse(xml1)
        let feed2 = try parse(xml2)
        return feed1 == feed2
    }
}
