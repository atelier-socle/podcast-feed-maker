public extension Namespace.Podcast {

    /// The `<podcast:locked>` tag from the Podcast Namespace.
    ///
    /// This tag indicates whether the podcast feed is locked for import by other platforms or services.
    ///
    /// A value of `"true"` tells directories and aggregators **not** to allow import of the feed.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#locked).
    /// - Note: The value must be `"true"` or `"false"` (as a string in the XML).
    ///
    /// - Example:
    /// ```xml
    /// <podcast:locked>true</podcast:locked>
    /// ```
    struct Locked: Hashable, Equatable, Sendable {

        /// Whether the feed is locked (`true`) or not (`false`).
        public let value: Bool

        /// Initializes a new `<podcast:locked>` tag.
        ///
        /// - Parameter value: A boolean indicating whether the feed is locked.
        public init(value: Bool) {
            self.value = value
        }
    }
}

extension Namespace.Podcast.Locked: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:locked>` tag.
    ///
    /// - Returns: A valid `<podcast:locked>` element with a stringified boolean.
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:locked>\(value)</podcast:locked>
        """
    }
}
