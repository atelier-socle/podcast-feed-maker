import Foundation

public extension Namespace.Podcast {

    /// The `<podcast:license>` tag from the Podcast Namespace.
    ///
    /// This tag indicates the license under which the podcast content is published (e.g. Creative Commons).
    /// It may contain a textual label and optionally a link to the full license text.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#license).
    /// - Tip: The form can be something like `"CC BY-NC-SA 4.0"` and the URL may point to `https://creativecommons.org/licenses/by-nc-sa/4.0/`.
    ///
    /// - Example:
    /// ```xml
    /// <podcast:license url="https://creativecommons.org/licenses/by-nc-sa/4.0/">CC BY-NC-SA 4.0</podcast:license>
    /// ```
    struct License: Hashable, Equatable, Sendable {

        /// An optional URL pointing to the full license description.
        public let url: URL?

        /// The human-readable label for the license.
        public let form: String

        /// Initializes a new `<podcast:license>` tag.
        ///
        /// - Parameters:
        ///   - url: Optional URL to the license document.
        ///   - form: A short textual representation of the license.
        public init(_ url: URL?, form: String) {
            self.url = url
            self.form = form
        }
    }
}

extension Namespace.Podcast.License: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:license>` tag.
    ///
    /// - Returns: A valid XML string with or without the `url` attribute.
    public func xmlRepresentation() throws -> String {
        if let url {
            """
            \t<podcast:license url="\(url.encodeURLQueryAllowed)">\(form)</podcast:license>
            """
        } else {
            "\t<podcast:license>\(form)</podcast:license>"
        }
    }
}
