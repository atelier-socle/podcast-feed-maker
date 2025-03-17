import Foundation

public extension RSSTag {
    struct LastBuildDate: Hashable, Equatable, Sendable {
        public let value: Date
        
        public init(value: Date) {
            self.value = value
        }
    }
}

extension RSSTag.LastBuildDate: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<lastBuildDate>\(value.rcfPubDate)</lastBuildDate>
        """
    }
}
