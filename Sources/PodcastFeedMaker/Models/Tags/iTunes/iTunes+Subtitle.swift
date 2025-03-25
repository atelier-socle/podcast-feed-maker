public extension Namespace.iTunes {

    /// The `<itunes:subtitle>` tag from the Apple Podcasts namespace.
    ///
    /// This tag provides a short subtitle or summary for the podcast or episode.
    /// It is used by platforms like Apple Podcasts to provide additional context
    /// beneath the episode title or show name.
    ///
    /// - Important: Limited to **255 characters** as per Apple's recommendation.
    /// - SeeAlso: [Apple Podcasts – Subtitle Tag](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:subtitle>Weekly interviews with industry leaders</itunes:subtitle>
    /// ```
    struct Subtitle: Hashable, Equatable, Sendable {

        /// The subtitle text to display.
        public let text: String

        /// Initializes a new `<itunes:subtitle>` tag.
        ///
        /// - Parameter text: The subtitle string (max 255 characters).
        public init(text: String) {
            self.text = text
        }
    }
}

extension Namespace.iTunes.Subtitle: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:subtitle>` tag.
    ///
    /// - Returns: A properly escaped XML tag containing the subtitle.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:subtitle>\(text.cleanSpecialChars())</itunes:subtitle>
        """
    }
}
