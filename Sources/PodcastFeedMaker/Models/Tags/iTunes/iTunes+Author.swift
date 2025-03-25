public extension Namespace.iTunes {

    /// The `<itunes:author>` tag from the Apple Podcasts namespace.
    ///
    /// This tag defines the author or creator of the podcast or episode.
    /// It is displayed in podcast directories like Apple Podcasts and reflects the content owner or organization.
    ///
    /// - Important: The `<itunes:author>` tag can appear at both the `<channel>` (show) and `<item>` (episode) level.
    /// - SeeAlso: [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:author>John Doe Productions</itunes:author>
    /// ```
    struct Author: Hashable, Equatable, Sendable {

        /// The author's name or organization.
        public let name: String

        /// Creates a new iTunes `<author>` tag.
        ///
        /// - Parameter name: The name of the podcast creator.
        public init(name: String) {
            self.name = name
        }
    }
}

extension Namespace.iTunes.Author: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:author>` tag.
    ///
    /// Escapes special characters when necessary.
    ///
    /// - Returns: A properly formatted `<itunes:author>` tag.
    public func xmlRepresentation() throws -> String {
        "\t<itunes:author>\(name.cleanSpecialChars())</itunes:author>"
    }
}
