public extension RSSTag {
    struct Copyright: Hashable, Equatable, Sendable {
        public let value: String
        
        public init(value: String) {
            self.value = value
        }
    }
}

extension RSSTag.Copyright: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<copyright>\(value.cleanSpecialChars())</copyright>
        """
    }
}
