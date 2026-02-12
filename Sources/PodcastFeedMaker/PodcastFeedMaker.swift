/// A utility for creating podcast feeds in XML format.
///
/// `PodcastFeedMaker` is a lightweight wrapper around a ``PodcastFeed``
/// that conforms to the ``XmlRepresentable`` protocol. It generates a complete
/// RSS feed suitable for Apple Podcasts, Spotify, and platforms that follow
/// [RSS 2.0](https://validator.w3.org/feed/docs/rss2.html), [PSP-1](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification),
/// and the [Podcast Namespace](https://github.com/Podcastindex-org/podcast-namespace).
///
/// - Important: The ``PodcastFeed`` instance passed must be properly configured with required tags.
/// - SeeAlso: ``PodcastFeed``, ``Channel``, ``XmlRepresentable``
public struct PodcastFeedMaker: Sendable {

    /// The underlying ``PodcastFeed`` instance used to generate XML.
    private let feed: PodcastFeed

    /// Initializes a new podcast feed maker.
    ///
    /// - Parameter feed: A ``PodcastFeed`` instance representing the complete podcast structure.
    ///
    /// ### Example:
    /// ```swift
    /// let feed = PodcastFeed(channel: myChannel)
    /// let maker = PodcastFeedMaker(feed)
    /// do {
    ///     let xml = try maker.xmlRepresentation()
    ///     print(xml)
    /// } catch {
    ///     print("Failed to generate XML: \(error)")
    /// }
    /// ```
    public init(_ feed: PodcastFeed) {
        self.feed = feed
    }
}

extension PodcastFeedMaker: XmlRepresentable {

    /// Generates the complete XML string for the podcast RSS feed.
    ///
    /// - Returns: A fully-formed RSS 2.0 feed including all configured namespaces and metadata.
    /// - Throws: If any of the underlying tags fail to generate XML (e.g., missing required fields).
    public func xmlRepresentation() throws -> String {
        try feed.xmlRepresentation()
    }
}
