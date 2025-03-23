public extension Namespace.iTunes {
    struct Season: Hashable, Equatable, Sendable {
        public let value: Int

        public init(value: Int) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Season: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:season>\(value)</itunes:season>
        """
    }
}
