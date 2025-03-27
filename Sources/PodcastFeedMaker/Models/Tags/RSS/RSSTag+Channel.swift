public extension RSSTag {

    /// A flexible `<channel>` container designed to support major podcast specifications,
    /// including [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itcb54353390),
    /// [PSP-1](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification),
    /// and the [Podcast Namespace](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md).
    ///
    /// The channel is composed of:
    /// - Standard feed-level tags
    /// - An iTunes category structure
    /// - A list of episode items
    ///
    /// All elements are based on types conforming to `XmlRepresentable`.
    struct Channel: Sendable {

        /// Header-level tags (e.g. `<title>`, `<description>`, `<itunes:image>`, etc.)
        public let tags: [any XmlRepresentable]

        /// iTunes categories describing the podcast topic and subtopics.
        public let categories: Namespace.iTunes.Category

        /// All `<item>` tags representing podcast episodes.
        public let items: [RSSTag.Item]

        /// Initializes a `<channel>` block compliant with [Apple Podcasts RSS Specification](https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
        ///
        /// This initializer includes all Apple-required tags:
        /// - `<title>`
        /// - `<link>`
        /// - `<description>`
        /// - `<itunes:author>`
        /// - `<itunes:explicit>`
        /// - `<itunes:image>`
        /// - `<itunes:category>`
        ///
        /// It also supports Apple-recommended tags:
        /// - `<language>`
        /// - `<itunes:summary>`
        /// - `<itunes:owner>`
        /// - `<itunes:type>`
        /// - `<atom:link rel="self">`
        ///
        /// Use `additionalTags` to append any custom or namespaced metadata.
        ///
        /// - Parameters:
        ///   - title: The `<title>` of the feed.
        ///   - link: The canonical webpage link for the podcast.
        ///   - description: The main `<description>` of the podcast.
        ///   - author: `<itunes:author>` tag representing the creator.
        ///   - explicit: `<itunes:explicit>` flag (`yes`, `no`, `clean`).
        ///   - image: `<itunes:image>` pointing to podcast artwork.
        ///   - categories: Apple-compatible category tree.
        ///   - items: The podcast episodes.
        ///   - language: Optional `<language>` tag (RFC 5646 format).
        ///   - summary: Optional `<itunes:summary>`.
        ///   - owner: Optional `<itunes:owner>` with name and email.
        ///   - type: Optional `<itunes:type>` (`episodic` or `serial`).
        ///   - atomSelfLink: Optional `<atom:link rel="self">`.
        ///   - additionalTags: Any other custom XML tags.
        public init(
            title: RSSTag.Title,
            link: RSSTag.Link,
            description: RSSTag.Description,
            author: Namespace.iTunes.Author,
            explicit: Namespace.iTunes.Explicit,
            image: Namespace.iTunes.Image,
            categories: Namespace.iTunes.Category,
            items: [RSSTag.Item],
            language: RSSTag.Language? = nil,
            summary: Namespace.iTunes.Summary? = nil,
            owner: Namespace.iTunes.Owner? = nil,
            type: Namespace.iTunes.ChannelType? = nil,
            atomSelfLink: Namespace.Atom.Link? = nil,
            additionalTags: [any XmlRepresentable] = []
        ) {
            let required: [any XmlRepresentable] = [
                title,
                link,
                description,
                author,
                explicit,
                image
            ]

            let recommended: [(any XmlRepresentable)?] = [
                language,
                summary,
                owner,
                type,
                atomSelfLink
            ]

            self.tags = required + recommended.compactMap { $0 } + additionalTags
            self.categories = categories
            self.items = items
        }

        /// Initializes a `<channel>` block fully compliant with the [PSP-1 Podcast RSS Specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification).
        ///
        /// Includes all required tags:
        /// - `<title>`
        /// - `<link>`
        /// - `<description>`
        /// - `<atom:link rel="self">`
        /// - `<language>`
        /// - `<itunes:explicit>`
        /// - `<itunes:image>`
        /// - `<itunes:category>`
        /// - `<item>` (via `items`)
        ///
        /// - Parameters:
        ///   - title: Feed `<title>`
        ///   - link: Feed `<link>`
        ///   - description: Feed `<description>`
        ///   - atomSelfLink: `<atom:link>` with `rel="self"`
        ///   - language: Feed language (RFC 5646)
        ///   - explicit: Explicit content indicator
        ///   - image: Podcast artwork image
        ///   - categories: iTunes categories
        ///   - items: List of episodes
        ///   - additionalTags: Optional extra tags
        public init(
            title: RSSTag.Title,
            link: RSSTag.Link,
            description: RSSTag.Description,
            atomSelfLink: Namespace.Atom.Link,
            language: RSSTag.Language,
            explicit: Namespace.iTunes.Explicit,
            image: Namespace.iTunes.Image,
            categories: Namespace.iTunes.Category,
            items: [RSSTag.Item],
            additionalTags: [any XmlRepresentable] = []
        ) {
            self.tags = [
                title,
                link,
                description,
                atomSelfLink,
                language,
                explicit,
                image
            ] + additionalTags

            self.categories = categories
            self.items = items
        }

        /// Initializes a `<channel>` block including [Podcast Namespace 1.0](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md) elements.
        ///
        /// Includes recommended Podcast Namespace tags such as:
        /// - `<podcast:guid>`
        /// - `<podcast:locked>`
        /// - `<podcast:funding>`
        /// - `<podcast:location>`
        /// - `<podcast:license>`
        ///
        /// - Parameters:
        ///   - title: Feed `<title>`
        ///   - link: Feed `<link>`
        ///   - description: Feed `<description>`
        ///   - atomSelfLink: `<atom:link rel="self">`
        ///   - language: Feed language
        ///   - explicit: iTunes explicit content flag
        ///   - image: Podcast artwork
        ///   - categories: iTunes categories
        ///   - items: Episodes
        ///   - guid: Persistent podcast GUID (Podcast Namespace)
        ///   - locked: Feed ownership lock
        ///   - funding: Donation or support URL
        ///   - location: Geolocation info
        ///   - license: Licensing information
        ///   - additionalTags: Optional custom elements
        public init(
            title: RSSTag.Title,
            link: RSSTag.Link,
            description: RSSTag.Description,
            atomSelfLink: Namespace.Atom.Link,
            language: RSSTag.Language,
            explicit: Namespace.iTunes.Explicit,
            image: Namespace.iTunes.Image,
            categories: Namespace.iTunes.Category,
            items: [RSSTag.Item],
            guid: Namespace.Podcast.Guid,
            locked: Namespace.Podcast.Locked,
            funding: Namespace.Podcast.Funding? = nil,
            location: Namespace.Podcast.Location? = nil,
            license: Namespace.Podcast.License? = nil,
            additionalTags: [any XmlRepresentable] = []
        ) {
            let required: [any XmlRepresentable] = [
                title,
                link,
                description,
                atomSelfLink,
                language,
                explicit,
                image,
                guid,
                locked
            ]

            let recommended: [(any XmlRepresentable)?] = [
                funding,
                location,
                license
            ]

            self.tags = required + recommended.compactMap { $0 } + additionalTags
            self.categories = categories
            self.items = items
        }

        /// Initializes a new `Channel` with fully customized tags, items, and iTunes categories.
        ///
        /// Use this initializer when you want full control over the tags injected into the `<channel>`
        /// node, including experimental or future extensions, while keeping the feed compliant with major
        /// podcast platforms like Apple Podcasts, PodcastIndex, Spotify, etc.
        ///
        /// This is especially useful when you are generating feeds dynamically or working with
        /// advanced namespaces like `podcast:`, `itunes:`, `psc:`, or custom modules.
        ///
        /// - Parameters:
        ///   - tags: An array of `XmlRepresentable` values representing all non-item, non-category channel-level tags.
        ///           This allows you to inject any tag conforming to the `XmlRepresentable` protocol, such as `RSSTag.Title`, `RSSTag.Link`, `Namespace.Podcast.Guid`, etc.
        ///   - items: The list of podcast episodes as `[RSSTag.Item]`, each describing a show episode.
        ///   - categories: One or more iTunes categories used to classify the podcast in podcast directories.
        ///
        /// - Important: You are responsible for ensuring all required tags (as per the [PSP-1](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification),
        ///   [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itcb54353390), and [Podcast Namespace](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md))
        ///   are present and valid, including `title`, `link`, `description`, `itunes:author`, `itunes:image`, `language`, and `atom:link`.
        ///
        /// - SeeAlso: `RSSTag.Title`, `RSSTag.Link`, `Namespace.iTunes.Author`, `Namespace.Podcast.Guid`, etc.
        public init(
            tags: [any XmlRepresentable],
            items: [RSSTag.Item],
            categories: Namespace.iTunes.Category
        ) {
            self.tags = tags
            self.items = items
            self.categories = categories
        }
    }
}

extension RSSTag.Channel: XmlRepresentable {

    /// Generates the full XML representation of the `<channel>` element.
    ///
    /// Includes header tags, category tags, and item entries with proper indentation.
    ///
    /// - Returns: A fully indented channel block.
    /// - Throws: If any tag or item fails to render.
    public func xmlRepresentation() throws -> String {
        try """
        \t<channel>
        \(formattedTags())
        \(formattedCategoriesTags())
        \(formattedItemTags())
        \t</channel>
        """
    }

    /// Formats all header tags (`title`, `link`, etc.) into an indented block.
    private func formattedTags() throws -> String {
        let tagXml = try tags.map { try $0.xmlRepresentation() }
        return tagXml.indentedTagsRepresentation
    }

    /// Renders the iTunes category hierarchy.
    private func formattedCategoriesTags() throws -> String {
        try categories.xmlRepresentation()
    }

    /// Renders all `<item>` entries.
    private func formattedItemTags() throws -> String {
        let itemXml = try items.map { try $0.xmlRepresentation() }
        return itemXml.indentedTagsRepresentation
    }
}
