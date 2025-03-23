public extension Namespace.Podcast {
    struct Guid: Hashable, Equatable, Sendable {
        public let value: String

        public init(value: String) {
            self.value = value
        }
    }
}

extension Namespace.Podcast.Guid: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:guid>\(value)</podcast:guid>
        """
    }
}
