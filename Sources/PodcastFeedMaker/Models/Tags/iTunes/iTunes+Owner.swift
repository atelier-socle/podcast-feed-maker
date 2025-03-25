public extension Namespace.iTunes {

    /// The `<itunes:owner>` tag from the Apple Podcasts namespace.
    ///
    /// This tag defines the podcast owner contact information.
    /// It is used by platforms to identify the administrator or producer of the podcast.
    ///
    /// - Important: This tag is **required** in the `<channel>` element.
    /// - Note: Apple Podcasts uses this information to verify podcast ownership and send important communications.
    ///
    /// - SeeAlso: [Apple Podcasts – Podcast Owner Tag](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:owner>
    ///     <itunes:name>John Doe</itunes:name>
    ///     <itunes:email>john@example.com</itunes:email>
    /// </itunes:owner>
    /// ```
    struct Owner: Hashable, Equatable, Sendable {

        /// The full name of the podcast owner.
        public let name: String

        /// The contact email address of the owner.
        public let mail: String

        /// Initializes the `<itunes:owner>` tag.
        ///
        /// - Parameters:
        ///   - name: The full name of the podcast administrator.
        ///   - mail: A valid email address.
        public init(name: String, mail: String) {
            self.name = name
            self.mail = mail
        }
    }
}

extension Namespace.iTunes.Owner: XmlRepresentable {

    /// Returns the XML representation of `<itunes:name>`.
    private func nameRepresentation() throws -> String {
        """
        \t<itunes:name>\(name.cleanSpecialChars())</itunes:name>
        """
    }

    /// Returns the XML representation of `<itunes:email>`.
    private func mailRepresentation() throws -> String {
        """
        \t<itunes:email>\(mail.cleanSpecialChars())</itunes:email>
        """
    }

    /// Combines the inner tags for `<itunes:owner>`, indented twice.
    private func formattedTags() throws -> String {
        let tags: [String] = try [
            nameRepresentation(),
            mailRepresentation()
        ].compactMap { $0 }

        return tags.doubleIndentedTagsRepresentation
    }

    /// Generates the full XML representation of the `<itunes:owner>` tag.
    ///
    /// - Returns: A multi-line `<itunes:owner>` block with nested name and email.
    public func xmlRepresentation() throws -> String {
        try """
        \t<itunes:owner>
        \(formattedTags())
        \t\t</itunes:owner>
        """
    }
}
