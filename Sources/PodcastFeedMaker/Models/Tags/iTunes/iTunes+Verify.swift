public extension Namespace.iTunes {
    struct Verify: Hashable, Equatable, Sendable {
        public let value: Bool

        public init(
            value: Bool = false
        ) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Verify: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:applepodcastsverify>\(value)</itunes:applepodcastsverify>
        """
    }
}
