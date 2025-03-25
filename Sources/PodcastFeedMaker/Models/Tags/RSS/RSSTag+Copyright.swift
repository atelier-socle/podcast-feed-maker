import Foundation

public extension RSSTag {

    /// The `<copyright>` tag in an RSS feed.
    ///
    /// This tag is used to convey the legal copyright information of the podcast content.
    /// It can appear inside the `<channel>` or `<item>` element.
    ///
    /// - Important: Recommended by both the [RSS 2.0 specification](https://cyber.harvard.edu/rss/rss.html#ltcopyrightgtSubelementOfLtchannelgt)
    ///   and [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itcb54353390) guidelines.
    struct Copyright: Hashable, Equatable, Sendable {

        /// The copyright string, usually including the copyright owner and year.
        ///
        /// Example: `"© 2025 Atelier Socle"`
        public let value: String

        /// Initializes a `<copyright>` tag.
        ///
        /// - Parameter value: The copyright statement.
        public init(_ value: String) {
            self.value = value
        }
    }
}

extension RSSTag.Copyright: XmlRepresentable {

    /// Generates the XML representation of the `<copyright>` tag.
    ///
    /// The content is escaped for special XML characters.
    ///
    /// Example:
    /// ```xml
    /// <copyright>© 2025 Atelier Socle</copyright>
    /// ```
    ///
    /// - Returns: A valid `<copyright>` XML tag string.
    public func xmlRepresentation() throws -> String {
        "\t<copyright>\(value.cleanSpecialChars())</copyright>"
    }
}
