public extension Namespace.iTunes {
    struct Complete: Hashable, Equatable, Sendable {
        public let value: Bool

        public init(value: Bool = false) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Complete: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:complete>\(value)</itunes:complete>
        """
    }
}
