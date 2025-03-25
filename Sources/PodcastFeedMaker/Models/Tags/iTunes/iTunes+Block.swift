public extension Namespace.iTunes {

    /// The `<itunes:block>` tag from the Apple Podcasts namespace.
    ///
    /// This tag allows podcast creators to block their show or episodes from appearing in the Apple Podcasts directory.
    ///
    /// - Important: This tag is defined in the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
    /// - Note: When the value is `"yes"`, the content will not appear in Apple Podcasts search or listings.
    /// - Values must be `"true"` or `"false"` (converted as string from `Bool`).
    ///
    /// - Example:
    /// ```xml
    /// <itunes:block>true</itunes:block>
    /// ```
    struct Block: Hashable, Equatable, Sendable {

        /// Whether the show or episode should be blocked from Apple Podcasts directory.
        public let value: Bool

        /// Initializes a new `<itunes:block>` tag.
        ///
        /// - Parameter value: A boolean indicating whether to block the content.
        public init(value: Bool) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Block: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:block>` tag.
    ///
    /// - Returns: A valid `<itunes:block>` tag with a stringified boolean.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:block>\(value)</itunes:block>
        """
    }
}
