import Foundation

public extension Namespace.Podcast {

    /// The `<podcast:txt>` tag from the Podcast Namespace.
    ///
    /// This tag is a generic field used to include arbitrary, machine- or human-readable text.
    /// It can also be used for feed ownership verification when the `purpose="verify"` attribute is set.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#txt).
    ///
    /// - Tip: When `verify` is `true`, the content is used for verification by external directories or services.
    ///
    /// - Example (verification):
    /// ```xml
    /// <podcast:txt purpose="verify">1234567890</podcast:txt>
    /// ```
    ///
    /// - Example (generic text):
    /// ```xml
    /// <podcast:txt>This is an experimental tag</podcast:txt>
    /// ```
    struct TextField: Hashable, Equatable, Sendable {

        /// The content of the text field.
        public let text: String

        /// Whether this field is intended for verification (`purpose="verify"`).
        public let verify: Bool

        /// Initializes a `<podcast:txt>` tag.
        ///
        /// - Parameters:
        ///   - text: The raw text content to include.
        ///   - verify: Whether to add `purpose="verify"` to the XML output.
        public init(_ text: String, verify: Bool) {
            self.text = text
            self.verify = verify
        }
    }
}

extension Namespace.Podcast.TextField: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:txt>` tag.
    ///
    /// - Returns: A properly formatted `<podcast:txt>` element.
    /// - Note: If `verify == true`, the `purpose="verify"` attribute is added.
    public func xmlRepresentation() throws -> String {
        if verify {
            """
            \t<podcast:txt purpose="verify">\(text)</podcast:txt>
            """
        } else {
            "\t<podcast:txt>\(text)</podcast:txt>"
        }
    }
}
