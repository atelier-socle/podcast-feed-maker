public extension Namespace.Podcast {
    struct Locked: Hashable, Equatable, Sendable {
        public let value: Bool

        public init(value: Bool) {
            self.value = value
        }
    }
}

extension Namespace.Podcast.Locked: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:locked>\(value.stringValue)</podcast:locked>
        """
    }
}
