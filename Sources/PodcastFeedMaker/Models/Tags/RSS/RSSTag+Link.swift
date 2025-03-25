import Foundation

public extension RSSTag {

    /// The `<link>` tag in an RSS feed.
    ///
    /// This tag defines the URL for the homepage or website associated with the podcast feed or item.
    ///
    /// - Important: The `<link>` tag is **required** in the `<channel>` element by the [PSP-1 specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification#rss-feed-elements)
    ///   and also by [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itc2b3780e76).
    ///
    /// Example:
    /// ```xml
    /// <link>https://example.com</link>
    /// ```
    struct Link: Hashable, Equatable, Sendable {

        /// The website or homepage URL.
        public let value: URL

        /// Initializes a `<link>` tag.
        ///
        /// - Parameter value: The website or homepage URL.
        public init(_ value: URL) {
            self.value = value
        }
    }
}

extension RSSTag.Link: XmlRepresentable {

    /// Generates the XML representation of the `<link>` tag.
    ///
    /// - Returns: A valid `<link>` element with escaped URL.
    /// - Throws: If the URL is invalid.
    public func xmlRepresentation() throws -> String {
        try value.isValid()
        return "\t<link>\(value.encodeURLQueryAllowed)</link>"
    }
}
