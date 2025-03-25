import Foundation

public extension RSSTag {

    /// The `<pubDate>` tag in an RSS feed.
    ///
    /// This tag defines the publication date and time of a podcast episode or feed.
    ///
    /// - Important: This tag is **required** for each `<item>` in the [PSP-1 specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification#item-elements),
    /// and **strongly recommended** by [RSS 2.0](https://cyber.harvard.edu/rss/rss.html#ltpubdategtSubelementOfLtitemgt)
    /// and [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itc2b3780e76).
    ///
    /// - Note: The date must be formatted using the [RFC 822](https://www.rfc-editor.org/rfc/rfc822.txt) date-time format.
    struct PubDate: Hashable, Equatable, Sendable {

        /// The publication date to display in the RSS feed.
        public let date: Date

        /// Initializes a new `<pubDate>` tag.
        ///
        /// - Parameter date: The publication date (will be formatted as RFC 822).
        public init(_ date: Date) {
            self.date = date
        }
    }
}

extension RSSTag.PubDate: XmlRepresentable {

    /// Generates the XML representation of the `<pubDate>` tag.
    ///
    /// Uses `Date.rcfPubDate` to output a string formatted according to RFC 822.
    ///
    /// Example:
    /// ```xml
    /// <pubDate>Mon, 24 Mar 2025 18:30:00 +0000</pubDate>
    /// ```
    ///
    /// - Returns: A valid `<pubDate>` XML element.
    public func xmlRepresentation() throws -> String {
        "\t<pubDate>\(date.rcfPubDate)</pubDate>"
    }
}
