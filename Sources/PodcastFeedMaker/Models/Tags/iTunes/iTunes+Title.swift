public extension Namespace.iTunes {
    struct Title: Hashable, Equatable, Sendable {
        public let text: String

        public init(text: String) {
            self.text = text
        }
    }
}

extension Namespace.iTunes.Title: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:title>\(text.cleanSpecialChars())</itunes:title>
        """
    }
}
