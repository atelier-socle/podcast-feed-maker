public extension Namespace.iTunes {
    struct Author: Hashable, Equatable, Sendable {
        public let author: String

        public init(author: String) {
            self.author = author
        }
    }
}

extension Namespace.iTunes.Author: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:author>\(author.cleanSpecialChars())</itunes:author>
        """
    }
}
