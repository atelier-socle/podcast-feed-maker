import Foundation

public extension RSSTag {

    /// The `<guid>` tag in an RSS feed.
    ///
    /// This tag provides a globally unique identifier for an `<item>`, such as a podcast episode.
    /// It helps podcast clients distinguish episodes and avoid duplicates.
    ///
    /// - Important: This tag is **required** by the [PSP-1 specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification#item-elements)
    ///   and **recommended** by [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itc2b3780e76).
    ///
    /// - Note: The `isPermaLink` attribute is optional and indicates whether the value is a URL.
    struct Guid: Hashable, Equatable, Sendable {

        /// The unique identifier value (e.g. a UUID or a permalink).
        public let value: String

        /// Indicates whether the value is a permalink.
        ///
        /// If `true`, the value is expected to be a valid URL.
        public let isPermaLink: Bool

        /// Initializes a new `<guid>` tag.
        ///
        /// - Parameters:
        ///   - value: A string that uniquely identifies the episode.
        ///   - isPermaLink: Whether the value is a permanent URL.
        public init(_ value: String, isPermaLink: Bool = false) {
            self.value = value
            self.isPermaLink = isPermaLink
        }
    }
}

extension RSSTag.Guid: XmlRepresentable {

    /// Generates the XML representation of the `<guid>` tag.
    ///
    /// Example:
    /// ```xml
    /// <guid isPermaLink="false">episode-001</guid>
    /// ```
    ///
    /// - Returns: A formatted and escaped `<guid>` tag.
    public func xmlRepresentation() throws -> String {
        let escaped = value.cleanSpecialChars()
        return """
        \t<guid isPermaLink="\(isPermaLink)">\(escaped)</guid>
        """
    }
}
