public extension Namespace.iTunes {

    /// The `<itunes:duration>` tag from the Apple Podcasts namespace.
    ///
    /// This tag specifies the duration of a podcast episode in seconds.
    /// Platforms use it to display how long an episode runs.
    ///
    /// - Important: This tag is defined in the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
    /// - Note: While the spec allows both time strings (`HH:MM:SS`) and integers (in seconds),
    /// providing a value in seconds ensures compatibility and simplifies generation.
    ///
    /// - Example:
    /// ```xml
    /// <itunes:duration>3681</itunes:duration>
    /// ```
    struct Duration: Hashable, Equatable, Sendable {

        /// The total duration of the episode in seconds.
        public let duration: Int

        /// Initializes a new `<itunes:duration>` tag.
        ///
        /// - Parameter duration: The duration of the episode in seconds.
        public init(duration: Int) {
            self.duration = duration
        }
    }
}

extension Namespace.iTunes.Duration: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:duration>` tag.
    ///
    /// - Returns: A valid `<itunes:duration>` element with the duration in seconds.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:duration>\(duration)</itunes:duration>
        """
    }
}
