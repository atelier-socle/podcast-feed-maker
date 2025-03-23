/// A protocol defining the ability to convert an object to an XML representation.
///
/// Types conforming to `XmlRepresentable` must implement the `xmlRepresentation()` method,
/// which returns the XML content as a `String`.
///
/// This protocol is useful for generating XML feeds, such as podcast feeds.
public protocol XmlRepresentable: Sendable {
    /// Returns the XML representation of the conforming object.
    ///
    /// - Throws: An error if the XML generation fails.
    /// - Returns: A `String` containing the XML representation.
    func xmlRepresentation() throws -> String
}

/// A utility for creating podcast feeds in XML format.
///
/// `PodcastFeedMaker` wraps a `Feed` object and provides a way to generate
/// an XML feed compliant with podcast standards.
public struct PodcastFeedMaker: Hashable, Equatable, Sendable {
    private let feed: Feed

    /// Initializes a new podcast feed maker with the given feed.
    ///
    /// - Parameter feed: A `Feed` object representing the podcast feed.
    ///
    /// Example usage:
    /// ```swift
    /// let feed = Feed(channel: ...)
    /// let podcastMaker = PodcastFeedMaker(feed)
    /// do {
    ///     let xml = try podcastMaker.xmlRepresentation()
    ///     print(xml)
    /// } catch {
    ///     print("Failed to generate XML: \(error)")
    /// }
    /// ```
    public init(_ feed: Feed) {
        self.feed = feed
    }
}

extension PodcastFeedMaker: XmlRepresentable {
    /// Generates the XML representation of the podcast feed.
    ///
    /// - Throws: Propagates any errors from the underlying `Feed` object.
    /// - Returns: A `String` containing the podcast feed in XML format.
    public func xmlRepresentation() throws -> String {
        try feed.xmlRepresentation()
    }
}
