import Foundation

public extension Namespace.Podcast {

    /// The `<podcast:funding>` tag from the Podcast Namespace.
    ///
    /// This tag provides a link to a support or donation page, along with a short label for the funding option.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#funding).
    /// Multiple `<podcast:funding>` tags may be included.
    ///
    /// - Example:
    /// ```xml
    /// <podcast:funding url="https://patreon.com/myshow">Support us on Patreon</podcast:funding>
    /// ```
    struct Funding: Hashable, Equatable, Sendable {

        /// The URL pointing to a donation or support page.
        public let url: URL

        /// A short human-readable label or description of the funding method.
        public let form: String

        /// Initializes a new `<podcast:funding>` tag.
        ///
        /// - Parameters:
        ///   - url: The URL to the donation or support platform.
        ///   - form: The label shown to users (e.g. "Support us on Patreon").
        public init(_ url: URL, form: String) {
            self.url = url
            self.form = form
        }
    }
}

extension Namespace.Podcast.Funding: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:funding>` tag.
    ///
    /// - Returns: A fully formed `<podcast:funding>` element.
    /// - Throws: If the URL is invalid.
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:funding url="\(url.encodeURLQueryAllowed)">\(form)</podcast:funding>
        """
    }
}
