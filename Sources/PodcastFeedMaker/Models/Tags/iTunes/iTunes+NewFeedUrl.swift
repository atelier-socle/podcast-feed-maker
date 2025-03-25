import Foundation

public extension Namespace.iTunes {

    /// The `<itunes:new-feed-url>` tag from the Apple Podcasts namespace.
    ///
    /// This tag allows you to redirect subscribers to a new RSS feed URL.
    /// It is recognized by Apple Podcasts and other platforms that support iTunes extensions.
    ///
    /// - Important: The new feed URL must be a valid, fully-qualified HTTPS URL.
    /// - Note: This tag should remain in your feed **for at least two weeks** after migration.
    ///
    /// - SeeAlso: [Apple Podcasts – Moving Your Feed](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:new-feed-url>https://example.com/new-podcast-feed.xml</itunes:new-feed-url>
    /// ```
    struct NewFeedUrl: Hashable, Equatable, Sendable {

        /// The new RSS feed URL.
        public let url: URL

        /// Initializes a new `<itunes:new-feed-url>` tag.
        ///
        /// - Parameter url: The new RSS feed destination.
        public init(url: URL) {
            self.url = url
        }
    }
}

extension Namespace.iTunes.NewFeedUrl: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:new-feed-url>` tag.
    ///
    /// - Returns: A properly formatted `<itunes:new-feed-url>` tag with the escaped URL.
    /// - Throws: If the URL is invalid.
    public func xmlRepresentation() throws -> String {
        try url.isValid()
        return """
        \t<itunes:new-feed-url>\(url.encodeURLQueryAllowed)</itunes:new-feed-url>
        """
    }
}
