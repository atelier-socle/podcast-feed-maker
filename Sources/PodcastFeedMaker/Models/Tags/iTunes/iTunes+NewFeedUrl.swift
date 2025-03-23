import Foundation

public extension Namespace.iTunes {
    struct NewFeedUrl: Hashable, Equatable, Sendable {
        public let url: URL

        public init(url: URL) {
            self.url = url
        }
    }
}

extension Namespace.iTunes.NewFeedUrl: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        try url.isValid()
        return """
        \t<itunes:new-feed-url>\(url.encodeURLQueryAllowed)</itunes:new-feed-url>
        """
    }
}
