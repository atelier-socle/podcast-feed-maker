import Foundation

public extension RSSTag {
    struct Link: Hashable, Equatable, Sendable {
        public let url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
}

extension RSSTag.Link: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        return """
        \t<link>\(url.encodeURLQueryAllowed)</link>
        """
    }
}
