public extension RSSTag {

    /// The `<generator>` tag in an RSS feed.
    ///
    /// This tag identifies the software that generated the RSS feed.
    ///
    /// - Note: This tag is **optional** according to the [RSS 2.0 specification](https://cyber.harvard.edu/rss/rss.html#ltgeneratorgtSubelementOfLtchannelgt),
    /// but can be useful for diagnostics or analytics.
    ///
    /// It typically includes the name and version of the tool or library used.
    ///
    /// Example:
    /// ```xml
    /// <generator>PodcastFeedMaker 1.0</generator>
    /// ```
    struct Generator: Hashable, Equatable, Sendable {

        /// The content of the generator tag (e.g. "PodcastFeedMaker 1.0").
        public let value: String

        /// Initializes a `<generator>` tag.
        ///
        /// - Parameter value: The name and version of the feed generator.
        public init(_ value: String) {
            self.value = value
        }
    }
}

extension RSSTag.Generator: XmlRepresentable {

    /// Generates the XML representation of the `<generator>` tag.
    ///
    /// - Returns: A properly indented `<generator>` tag with escaped content.
    public func xmlRepresentation() throws -> String {
        "\t<generator>\(value.cleanSpecialChars())</generator>"
    }
}
