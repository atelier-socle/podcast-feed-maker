public extension Namespace.iTunes {

    /// The `<itunes:keywords>` tag from the Apple Podcasts namespace.
    ///
    /// This tag specifies a comma-separated list of keywords to help users discover your podcast or episode via search.
    ///
    /// - Important: This tag is defined in the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12).
    /// - Note: Apple recommends using a maximum of 12 keywords separated by commas.
    /// - Tip: Keywords should be lowercase and free of special characters.
    ///
    /// - Example:
    /// ```xml
    /// <itunes:keywords>news, technology, innovation</itunes:keywords>
    /// ```
    struct Keywords: Hashable, Equatable, Sendable {

        /// The final keyword string to inject into the XML (comma-separated).
        public let keywords: String

        /// Initializes the `<itunes:keywords>` tag using a list of raw keywords.
        ///
        /// Each keyword will be:
        /// - Lowercased
        /// - Escaped for XML safety
        /// - Joined with `, ` as separator
        ///
        /// - Parameter keywords: An array of strings representing keywords.
        public init(keywords: [String]) {
            let cleanedValue = keywords.map {
                $0.cleanSpecialChars().lowercased()
            }.joined(separator: ", ")
            self.keywords = cleanedValue
        }
    }
}

extension Namespace.iTunes.Keywords: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:keywords>` tag.
    ///
    /// - Returns: A valid `<itunes:keywords>` element with the cleaned list.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:keywords>\(keywords)</itunes:keywords>
        """
    }
}
