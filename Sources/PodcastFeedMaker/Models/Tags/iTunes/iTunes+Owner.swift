public extension Namespace.iTunes {
    struct Owner: Hashable, Equatable, Sendable {
        public let name: String
        public let mail: String

        public init (name: String, mail: String) {
            self.name = name
            self.mail = mail
        }
    }
}

extension Namespace.iTunes.Owner: XmlRepresentable {
    private func nameRepresentation() throws -> String {
        """
        \t<itunes:name>\(name.cleanSpecialChars())</itunes:name>
        """
    }

    private func mailRepresentation() throws -> String {
        """
        \t<itunes:email>\(mail.cleanSpecialChars())</itunes:email>
        """
    }

    private func formattedTags() throws -> String {
        let tags: [String] = try [
            nameRepresentation(),
            mailRepresentation()
        ].compactMap { $0 }

        return tags.doubleIndentedTagsRepresentation
    }

    public func xmlRepresentation() throws -> String {
        try """
        \t<itunes:owner>
        \(formattedTags())
        \t\t</itunes:owner>
        """
    }
}
