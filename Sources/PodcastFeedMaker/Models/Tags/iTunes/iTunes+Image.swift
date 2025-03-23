import Foundation

public extension Namespace.iTunes {
    struct Image: Hashable, Equatable, Sendable {
        public let url: URL

        public init(url: URL) {
            self.url = url
        }
    }
}

extension Namespace.iTunes.Image: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        return """
        \t<itunes:image href="\(url.encodeURLQueryAllowed)" />
        """
    }
}
