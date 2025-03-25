public extension Namespace.iTunes {

    /// The `<itunes:episode>` tag from the Apple Podcasts namespace.
    ///
    /// This tag specifies the episode number within a podcast season or series.
    /// It helps Apple Podcasts and other apps display episodes in the correct order,
    /// especially when using a serial presentation style.
    ///
    /// - Important: The value must be a positive integer.
    /// - Tip: If used alongside `<itunes:season>`, the episode is grouped within that season.
    /// - SeeAlso: [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:episode>3</itunes:episode>
    /// ```
    struct Episode: Hashable, Equatable, Sendable {

        /// The episode number (must be a positive integer).
        public let value: Int

        /// Initializes a new `<itunes:episode>` tag.
        ///
        /// - Parameter value: The episode number to assign.
        public init(value: Int) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Episode: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:episode>` tag.
    ///
    /// - Returns: A `<itunes:episode>` tag with the given episode number.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:episode>\(value)</itunes:episode>
        """
    }
}
