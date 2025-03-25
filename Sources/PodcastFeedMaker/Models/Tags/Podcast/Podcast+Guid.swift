public extension Namespace.Podcast {

    /// The `<podcast:guid>` tag from the Podcast Namespace.
    ///
    /// This tag defines a globally unique identifier for the podcast **show** (not episode).
    /// It is intended to remain consistent across platforms, hosting changes, and feed migrations.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#guid).
    /// - Note: The value should be a **persistent unique ID**, such as a UUID, URI, or domain-based string.
    ///
    /// - Example:
    /// ```xml
    /// <podcast:guid>podcast.example.com/myshow</podcast:guid>
    /// ```
    struct Guid: Hashable, Equatable, Sendable {

        /// The globally unique string identifier.
        public let value: String

        /// Initializes a new `<podcast:guid>` tag.
        ///
        /// - Parameter value: A globally unique ID for the podcast show.
        public init(value: String) {
            self.value = value
        }
    }
}

extension Namespace.Podcast.Guid: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:guid>` tag.
    ///
    /// - Returns: A formatted `<podcast:guid>` element containing the unique value.
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:guid>\(value)</podcast:guid>
        """
    }
}
