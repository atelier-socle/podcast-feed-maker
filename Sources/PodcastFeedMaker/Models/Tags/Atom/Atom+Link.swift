import Foundation

extension Namespace.Atom {
    /// see example:
    /// `<atom:link href="https://www.podstandards.org/my-podcast.rss" rel="self" type="application/rss+xml" />`
    /// >important: href link must follow channel link.
    ///
    public struct Link: Hashable, Equatable, Sendable {
        public let url: URL
        
        public init(url: URL) {
            self.url = url
        }
    }
}

extension Namespace.Atom.Link: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        return """
        \t<atom:link href="\(url.encodeURLQueryAllowed)" rel="self" type="application/rss+xml" />
        """
    }
}
