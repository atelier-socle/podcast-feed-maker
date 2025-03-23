import Foundation

public extension RSSTag {
    struct Image: Hashable, Equatable, Sendable {
        public let url: URL
        public let title: String
        public let link: URL
        
        public init(
            url: URL,
            title: String,
            link: URL
        ) {
            self.url = url
            self.title = title
            self.link = link
        }
    }
}

extension RSSTag.Image: XmlRepresentable {
    private func formattedTags() throws -> String {
        let tags: [String] = [
            "\t<url>\(url.encodeURLQueryAllowed)</url>",
            "\t<title>\(title.cleanSpecialChars())</title>",
            "\t<link>\(link.encodeURLQueryAllowed)</link>"
        ].compactMap { $0 }

        return tags.doubleIndentedTagsRepresentation
    }

    public func xmlRepresentation() throws -> String {
        try url.isValid()
        try link.isValid()

        return try """
        \t<image>
        \(formattedTags())
        \t\t</image>
        """
    }
}
