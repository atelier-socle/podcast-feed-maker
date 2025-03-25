public extension RSSTag {

    /// The `<title>` tag in an RSS feed.
    ///
    /// This tag represents the name of the podcast or the title of an episode.
    /// It must be present in both `<channel>` and `<item>` elements.
    ///
    /// - Important: This tag is **required** by [RSS 2.0](https://cyber.harvard.edu/rss/rss.html#ltitemgt) and the [PSP-1 specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification),
    /// and **mandatory** for podcast platforms such as [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itc2b3780e76).
    ///
    /// Example:
    /// ```xml
    /// <title>Episode 1: Getting Started</title>
    /// ```
    struct Title: Hashable, Equatable, Sendable {

        /// The title content (e.g. podcast name or episode title).
        public let value: String

        /// Initializes a new `<title>` tag with a given string value.
        ///
        /// - Parameter value: The title text to display.
        public init(_ value: String) {
            self.value = value
        }
    }
}

extension RSSTag.Title: XmlRepresentable {

    /// Generates the XML representation of the `<title>` tag.
    ///
    /// The value is escaped to ensure it is XML-safe.
    ///
    /// Example:
    /// ```xml
    /// <title>My Podcast Title</title>
    /// ```
    ///
    /// - Returns: An escaped and indented XML `<title>` element.
    public func xmlRepresentation() throws -> String {
        "\t<title>\(value.cleanSpecialChars())</title>"
    }
}
