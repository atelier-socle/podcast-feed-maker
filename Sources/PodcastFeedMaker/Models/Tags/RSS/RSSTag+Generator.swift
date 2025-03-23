public extension RSSTag {
    struct Generator: Hashable, Equatable, Sendable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
}

extension RSSTag.Generator: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<generator>\(value.cleanSpecialChars())</generator>
        """
    }
}
