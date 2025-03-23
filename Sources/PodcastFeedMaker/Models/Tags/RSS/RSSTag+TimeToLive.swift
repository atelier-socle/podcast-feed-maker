public extension RSSTag {
    struct TimeToLive: Hashable, Equatable, Sendable {
        public let value: Int
        
        public init(value: Int) {
            self.value = value
        }
    }
}

extension RSSTag.TimeToLive: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<ttl>\(value)</ttl>
        """
    }
}
