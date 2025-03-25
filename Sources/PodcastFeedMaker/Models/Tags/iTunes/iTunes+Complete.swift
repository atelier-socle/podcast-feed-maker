public extension Namespace.iTunes {

    /// The `<itunes:complete>` tag from the Apple Podcasts namespace.
    ///
    /// This tag indicates whether a podcast is complete, meaning no more episodes will be added.
    /// Setting this tag to `true` notifies platforms that the podcast is finished and will no longer update.
    ///
    /// - Important: This tag is defined in the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
    /// - Tip: This tag should only be used at the `<channel>` level.
    ///
    /// - Example:
    /// ```xml
    /// <itunes:complete>true</itunes:complete>
    /// ```
    struct Complete: Hashable, Equatable, Sendable {

        /// Indicates whether the podcast is complete (`true`) or ongoing (`false`).
        public let value: Bool

        /// Initializes a new `<itunes:complete>` tag.
        ///
        /// - Parameter value: A boolean indicating podcast completion. Defaults to `false`.
        public init(value: Bool = false) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Complete: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:complete>` tag.
    ///
    /// - Returns: A `<itunes:complete>` element with the boolean value as string.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:complete>\(value)</itunes:complete>
        """
    }
}
