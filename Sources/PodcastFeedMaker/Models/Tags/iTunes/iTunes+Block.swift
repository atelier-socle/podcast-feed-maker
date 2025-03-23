public extension Namespace.iTunes {
    struct Block: Hashable, Equatable, Sendable {
        public let value: Bool

        public init(value: Bool) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Block: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:block>\(value)</itunes:block>
        """
    }
}
