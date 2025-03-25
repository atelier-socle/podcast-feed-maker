public extension Namespace.iTunes {

    /// The `<itunes:title>` tag from the Apple Podcasts namespace.
    ///
    /// This tag defines a title for the episode or podcast that differs from the standard RSS `<title>`.
    /// It is displayed by Apple Podcasts instead of the RSS `<title>` if both are present.
    ///
    /// - Important: This tag is optional but recommended when the episode title
    ///   requires formatting or differs from the canonical feed title.
    ///
    /// - SeeAlso: [Apple Podcasts – Title Tag](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:title>Swift 6 is here: What's new?</itunes:title>
    /// ```
    struct Title: Hashable, Equatable, Sendable {

        /// The title text specific to the iTunes feed.
        public let text: String

        /// Initializes a new `<itunes:title>` tag.
        ///
        /// - Parameter text: The custom title for the episode or show.
        public init(text: String) {
            self.text = text
        }
    }
}

extension Namespace.iTunes.Title: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:title>` tag.
    ///
    /// - Returns: An escaped XML tag for the iTunes-specific title.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:title>\(text.cleanSpecialChars())</itunes:title>
        """
    }
}
