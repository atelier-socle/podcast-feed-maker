import Foundation

extension Namespace.Atom {

    /// A tag representing an Atom `<link>` element in a podcast RSS feed.
    ///
    /// This tag is part of the [Atom Syndication Format](https://tools.ietf.org/html/rfc4287)
    /// and is used in RSS feeds to explicitly declare the URL of the feed itself.
    ///
    /// Apple Podcasts, Spotify, and the [Podcast Standards Project (PSP-1)](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification)
    /// require or recommend this tag for proper feed discovery.
    ///
    /// ### Example:
    /// ```xml
    /// <atom:link href="https://example.com/feed.rss" rel="self" type="application/rss+xml" />
    /// ```
    ///
    /// - Important: The `href` attribute (represented by `url`) **must exactly match**
    ///   the value declared in the `<channel><link>` tag to ensure proper validation.
    public struct Link: Hashable, Equatable, Sendable {

        /// The absolute URL to the RSS feed itself.
        ///
        /// This will be used as the `href` attribute in the generated `<atom:link>` tag.
        public let url: URL

        /// Creates a new Atom `<link>` tag for feed discovery.
        ///
        /// - Parameter url: The canonical public URL of the RSS feed.
        public init(url: URL) {
            self.url = url
        }
    }
}

extension Namespace.Atom.Link: XmlRepresentable {

    /// Converts the tag into its XML string representation.
    ///
    /// This renders a valid `<atom:link>` element with attributes `href`, `rel`, and `type`.
    ///
    /// - Returns: A single-line XML tag.
    /// - Throws: An error if the provided URL is not valid.
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        return """
        \t<atom:link href="\(url.encodeURLQueryAllowed)" rel="self" type="application/rss+xml" />
        """
    }
}
