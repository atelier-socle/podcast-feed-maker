public extension Namespace.iTunes {

    /// The `<itunes:episodeType>` tag from the Apple Podcasts namespace.
    ///
    /// This tag defines the type of the episode: full content, a trailer, or bonus material.
    /// It helps platforms organize content and distinguish between regular episodes and extras.
    ///
    /// - Important: This tag is defined in the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12).
    ///
    /// - Example:
    /// ```xml
    /// <itunes:episodeType>trailer</itunes:episodeType>
    /// ```
    struct EpisodeType: Hashable, Equatable, Sendable {

        /// The raw value of the episode type (`"full"`, `"trailer"`, or `"bonus"`).
        public let value: String

        /// Internal initializer using raw string values.
        ///
        /// - Parameter value: A raw string value representing the episode type.
        package init(value: String) {
            self.value = value
        }

        /// Public initializer using the strongly typed enum `EpisodeTypeValue`.
        ///
        /// - Parameter type: The enum case representing the episode type.
        public init(type: EpisodeTypeValue) {
            self.init(value: type.rawValue)
        }
    }

    /// The set of valid values for `<itunes:episodeType>`.
    ///
    /// - `full`: A standard full-length episode.
    /// - `trailer`: A short preview promoting the show or an upcoming episode.
    /// - `bonus`: Bonus content not part of the regular episode sequence.
    enum EpisodeTypeValue: String, Hashable, Equatable, Sendable {
        /// A standard full episode.
        case full
        /// A promotional trailer.
        case trailer
        /// Extra or bonus content.
        case bonus
    }
}

extension Namespace.iTunes.EpisodeType: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:episodeType>` tag.
    ///
    /// - Returns: A properly formatted `<itunes:episodeType>` tag.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:episodeType>\(value)</itunes:episodeType>
        """
    }
}
