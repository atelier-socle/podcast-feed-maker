public extension Namespace.iTunes {

    /// The `<itunes:applepodcastsverify>` tag from the Apple Podcasts namespace.
    ///
    /// This tag indicates whether Apple Podcasts should attempt to verify ownership of a podcast RSS feed.
    /// It's typically used in conjunction with automated podcast claiming workflows.
    ///
    /// - Important: This tag is **rarely needed** and only used in special verification flows.
    /// - Default value is `false`.
    ///
    /// - Example:
    /// ```xml
    /// <itunes:applepodcastsverify>true</itunes:applepodcastsverify>
    /// ```
    struct Verify: Hashable, Equatable, Sendable {

        /// Whether Apple Podcasts should verify the feed.
        public let value: Bool

        /// Creates a new `<itunes:applepodcastsverify>` tag.
        ///
        /// - Parameter value: A boolean indicating whether to enable verification.
        public init(value: Bool = false) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Verify: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:applepodcastsverify>` tag.
    ///
    /// - Returns: The `<itunes:applepodcastsverify>` tag with a boolean value (`true` or `false`).
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:applepodcastsverify>\(value)</itunes:applepodcastsverify>
        """
    }
}
