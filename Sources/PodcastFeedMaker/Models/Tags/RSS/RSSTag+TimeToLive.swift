public extension RSSTag {

    /// The `<ttl>` (Time To Live) tag in an RSS feed.
    ///
    /// This tag specifies the number of minutes a podcast client should cache the feed before checking for updates.
    ///
    /// - Note: While this tag is **optional** per [RSS 2.0](https://cyber.harvard.edu/rss/rss.html#ltttlgtSubelementOfLtchannelgt),
    /// it can help reduce server load and bandwidth usage.
    ///
    /// - Tip: A common value is `60` (check once per hour).
    struct TimeToLive: Hashable, Equatable, Sendable {

        /// The TTL value in minutes.
        public let value: Int

        /// Initializes a `<ttl>` tag.
        ///
        /// - Parameter value: The number of minutes to cache the feed.
        public init(_ value: Int) {
            self.value = value
        }
    }
}

extension RSSTag.TimeToLive: XmlRepresentable {

    /// Generates the XML representation of the `<ttl>` tag.
    ///
    /// Example:
    /// ```xml
    /// <ttl>60</ttl>
    /// ```
    ///
    /// - Returns: A valid `<ttl>` XML element.
    public func xmlRepresentation() throws -> String {
        "\t<ttl>\(value)</ttl>"
    }
}
