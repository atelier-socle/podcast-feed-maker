public extension Namespace.iTunes {

    /// The `<itunes:season>` tag from the Apple Podcasts namespace.
    ///
    /// This tag specifies the season number that the episode belongs to.
    /// It helps platforms organize episodes within seasonal groupings, especially for serialized podcasts.
    ///
    /// - Important: Must be a **positive integer**. Season numbers should start at 1.
    /// - SeeAlso: [Apple Podcasts – Seasons & Episodes](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:season>2</itunes:season>
    /// ```
    struct Season: Hashable, Equatable, Sendable {

        /// The season number (must be ≥ 1).
        public let value: Int

        /// Initializes a new `<itunes:season>` tag.
        ///
        /// - Parameter value: The number of the season.
        public init(value: Int) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Season: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:season>` tag.
    ///
    /// - Returns: A formatted XML tag with the season number.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:season>\(value)</itunes:season>
        """
    }
}
