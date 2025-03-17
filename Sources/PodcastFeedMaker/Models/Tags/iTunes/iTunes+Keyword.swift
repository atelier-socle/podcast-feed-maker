public extension Namespace.iTunes {
    struct Keywords: Hashable, Equatable, Sendable {
        public let keywords: String

        public init(keywords: [String]) {
            let cleanedValue = keywords.map {
                $0.cleanSpecialChars().lowercased()
            }.joined(separator: ", ")
            self.keywords = cleanedValue
        }
    }
}

extension Namespace.iTunes.Keywords: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:keywords>\(keywords)</itunes:keywords>
        """
    }
}
