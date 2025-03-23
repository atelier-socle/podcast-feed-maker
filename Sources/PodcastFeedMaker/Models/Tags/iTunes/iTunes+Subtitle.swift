public extension Namespace.iTunes {
    struct Subtitle: Hashable, Equatable, Sendable {
        public let text: String

        public init(text: String) {
            self.text = text
        }
    }
}

extension Namespace.iTunes.Subtitle: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:subtitle>\(text.cleanSpecialChars())</itunes:subtitle>
        """
    }
}
