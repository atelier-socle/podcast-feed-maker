import Foundation

public extension Namespace.iTunes {

    /// The `<itunes:summary>` tag from the Apple Podcasts namespace.
    ///
    /// This tag provides a long-form description of the podcast or episode.
    /// It supports either plain text or HTML wrapped in CDATA.
    ///
    /// - Important: This tag is often used by Apple Podcasts to display episode or show descriptions in the app.
    /// - Note: Plain text content must be XML-escaped.
    /// - SeeAlso: [Apple Podcasts – Summary Tag](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///
    /// - Example (plain text):
    /// ```xml
    /// <itunes:summary>A deep-dive into Swift Concurrency.</itunes:summary>
    /// ```
    ///
    /// - Example (HTML):
    /// ```xml
    /// <itunes:summary><![CDATA[<p><strong>Swift</strong> Concurrency explained.</p>]]></itunes:summary>
    /// ```
    struct Summary: Hashable, Equatable, Sendable {

        /// The content of the summary, as plain text or HTML.
        public let content: String

        /// The type of content: `.text` (escaped) or `.html` (wrapped in CDATA).
        private let type: DescriptionType

        /// Initializes the `<itunes:summary>` tag.
        ///
        /// - Parameters:
        ///   - content: The full description of the episode or show.
        ///   - type: The rendering type, defaults to `.text`.
        public init(content: String, type: DescriptionType = .text) {
            self.content = content
            self.type = type
        }

        /// The type of summary content to control XML rendering.
        ///
        /// - `text`: Plain text content that is XML-escaped.
        /// - `html`: Rich content wrapped in CDATA section.
        public enum DescriptionType: String, Hashable, Equatable, Sendable {
            case text
            case html

            /// Formats the content based on the chosen type.
            ///
            /// - Parameter content: The raw summary content.
            /// - Returns: A formatted `<itunes:summary>` XML tag.
            func representation(_ content: String) -> String {
                switch self {
                case .text:
                    return """
                    \t<itunes:summary>\(content.cleanSpecialChars())</itunes:summary>
                    """
                case .html:
                    return """
                    \t<itunes:summary><![CDATA[\(content)]]></itunes:summary>
                    """
                }
            }
        }
    }
}

extension Namespace.iTunes.Summary: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:summary>` tag.
    ///
    /// - Returns: A formatted `<itunes:summary>` tag using either escaped text or CDATA.
    public func xmlRepresentation() throws -> String {
        type.representation(content)
    }
}
