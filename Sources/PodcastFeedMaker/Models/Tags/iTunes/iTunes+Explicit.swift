public extension Namespace.iTunes {
    struct Explicit: Hashable, Equatable, Sendable {
        public let value: Bool

        public init(value: Bool = false) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Explicit: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:explicit>\(value)</itunes:explicit>
        """
    }
}
