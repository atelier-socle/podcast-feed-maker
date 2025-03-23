public extension RSSTag {
    struct Title: Hashable, Equatable, Sendable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
}

extension RSSTag.Title: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<title>\(value.cleanSpecialChars())</title>
        """
    }
}
