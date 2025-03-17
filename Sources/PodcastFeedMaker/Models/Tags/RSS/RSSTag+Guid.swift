import Foundation

public extension RSSTag {
    struct Guid: Hashable, Equatable, Identifiable, Sendable {
        public let id: String
        public let isPermalink: Bool
        
        public init(id: String, isPermalink: Bool = false) {
            self.id = id
            self.isPermalink = isPermalink
        }
    }
}

extension RSSTag.Guid: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<guid isPermaLink="\(isPermalink)">\(id)</guid>
        """
    }
}
