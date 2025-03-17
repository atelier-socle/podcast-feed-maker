public extension Namespace.iTunes {
    struct Episode: Hashable, Equatable, Sendable {
        public let value: Int

        public init(value: Int) {
            self.value = value
        }
    }
}

extension Namespace.iTunes.Episode: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:episode>\(value)</itunes:episode>
        """
    }
}
