public extension Namespace.iTunes {
    struct Duration: Hashable, Equatable, Sendable {
        public let duration: Int

        public init(duration: Int) {
            self.duration = duration
        }
    }
}

extension Namespace.iTunes.Duration: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:duration>\(duration)</itunes:duration>
        """
    }
}
