import Foundation

public extension RSSTag {

    /// The `<description>` tag in an RSS feed.
    ///
    /// This tag provides a textual description of the podcast or episode.
    /// It may include plain text or HTML depending on the `type`.
    ///
    /// - Important: This tag is required in the `<channel>` element according to the RSS 2.0 specification.
    struct Description: Hashable, Equatable, Sendable {

        /// The actual content of the description.
        public let value: String

        /// The content type of the description.
        ///
        /// This is used to control whether the text is rendered as plain text or HTML.
        public let type: DescriptionType

        /// Initializes a new RSS `<description>` tag.
        ///
        /// - Parameters:
        ///   - value: The description content.
        ///   - type: The content type (e.g. `.text` or `.html`).
        public init(_ value: String, type: DescriptionType = .text) {
            self.value = value
            self.type = type
        }
    }

    /// Supported types for the RSS `<description>` tag content.
    ///
    /// - Note: While RSS 2.0 does not require a `type` attribute, this enum can help you
    /// decide whether to escape HTML or not.
    enum DescriptionType: String, Hashable, Equatable, Sendable {
        /// Plain text (default).
        case text

        /// HTML content.
        case html
    }
}

extension RSSTag.Description: XmlRepresentable {

    /// Generates the XML representation of the `<description>` tag.
    ///
    /// - Returns: An indented `<description>` XML tag.
    public func xmlRepresentation() throws -> String {
        let content = switch type {
        case .text: value.cleanSpecialChars()
        case .html: "<![CDATA[\(value)]]>"
        }

        return "\t<description>\(content)</description>"
    }
}
