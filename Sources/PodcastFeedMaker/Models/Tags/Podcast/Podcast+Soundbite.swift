public extension Namespace.Podcast {

    /// The `<podcast:soundbite>` tag from the Podcast Namespace.
    ///
    /// This tag defines a short highlight or teaser segment from the episode.
    /// It is typically used to let listeners preview a moment without playing the full episode.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#soundbite).
    /// - Note: Multiple `<podcast:soundbite>` tags are allowed per episode.
    ///
    /// - Example:
    /// ```xml
    /// <podcast:soundbite startTime="30.5" duration="45.0">A funny intro moment</podcast:soundbite>
    /// ```
    struct Soundbite: Hashable, Equatable, Sendable {

        /// The start time of the soundbite (in seconds, as a float).
        public let startTime: Double

        /// The duration of the soundbite (in seconds).
        public let duration: Double

        /// Optional placeholder text (a caption or description).
        public let placeholder: String?

        /// Initializes a new `<podcast:soundbite>` tag.
        ///
        /// - Parameters:
        ///   - startTime: The start time (in seconds) where the snippet begins.
        ///   - duration: The duration of the snippet (in seconds).
        ///   - placeholder: An optional textual caption for the soundbite.
        public init(
            startTime: Double,
            duration: Double,
            placeholder: String?
        ) {
            self.startTime = startTime
            self.duration = duration
            self.placeholder = placeholder
        }
    }
}

extension Namespace.Podcast.Soundbite: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:soundbite>` tag.
    ///
    /// If a `placeholder` is provided, it will appear as inner content;
    /// otherwise the tag is self-closing.
    ///
    /// - Returns: A valid `<podcast:soundbite>` element.
    public func xmlRepresentation() throws -> String {
        if let placeholder {
            """
            \t<podcast:soundbite startTime="\(startTime)" duration="\(duration)">\(placeholder)</podcast:soundbite>
            """
        } else {
            """
            \t<podcast:soundbite startTime="\(startTime)" duration="\(duration)" />
            """
        }
    }
}
