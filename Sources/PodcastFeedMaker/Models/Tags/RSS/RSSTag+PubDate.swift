import Foundation

public extension RSSTag {
    struct PubDate: Hashable, Equatable, Sendable {
        public let value: Date
        
        public init(value: Date) {
            self.value = value
        }
    }
}

extension RSSTag.PubDate: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<pubDate>\(value.rcfPubDate)</pubDate>
        """
    }
}
