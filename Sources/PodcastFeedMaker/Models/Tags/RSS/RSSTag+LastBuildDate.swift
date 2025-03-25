import Foundation

public extension RSSTag {

    /// The `<lastBuildDate>` tag in an RSS feed.
    ///
    /// This tag indicates the last time the content of the feed was modified.
    /// It is used by aggregators and podcast clients to determine if the feed has changed.
    ///
    /// - Note: The date must be formatted using the [RFC 822](https://www.rfc-editor.org/rfc/rfc822.txt) format.
    ///
    /// - Important: This tag is **optional** per the [RSS 2.0 specification](https://cyber.harvard.edu/rss/rss.html#ltttlgtSubelementOfLtchannelgt),
    /// but its presence improves update detection.
    struct LastBuildDate: Hashable, Equatable, Sendable {

        /// The date to use in the tag.
        public let value: Date

        /// Initializes the `<lastBuildDate>` tag.
        ///
        /// - Parameter value: The date representing the last update to the feed.
        public init(_ value: Date) {
            self.value = value
        }
    }
}

extension RSSTag.LastBuildDate: XmlRepresentable {

    /// Generates the XML representation of the `<lastBuildDate>` tag.
    ///
    /// Example:
    /// ```xml
    /// <lastBuildDate>Mon, 25 Mar 2024 20:00:00 +0000</lastBuildDate>
    /// ```
    ///
    /// - Returns: A valid RFC 822–formatted date string inside `<lastBuildDate>`.
    public func xmlRepresentation() throws -> String {
        "\t<lastBuildDate>\(value.rcfPubDate)</lastBuildDate>"
    }
}
