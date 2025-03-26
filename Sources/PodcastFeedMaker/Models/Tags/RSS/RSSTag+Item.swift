import Foundation

public extension RSSTag {

    /// Represents a single `<item>` block in an RSS feed, typically corresponding to a podcast episode.
    ///
    /// This structure supports specifications such as:
    /// - [PSP-1 Podcast RSS Specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification)
    /// - [Apple Podcasts RSS Guidelines](https://help.apple.com/itc/podcasts_connect/#/itc2b3780e76)
    /// - [Podcast Namespace 1.0](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md)
    ///
    /// You may use a manual initializer to inject custom tags or opt for spec-driven initializers to ensure compliance.
    struct Item: Sendable {

        // MARK: - Properties

        /// All XML-conformant tags that make up this `<item>`.
        public let tags: [any XmlRepresentable]

        // MARK: - Initializers

        /// Creates a fully custom `<item>` using the provided tags.
        ///
        /// This initializer gives you full flexibility but does not enforce compliance with any specification.
        ///
        /// - Parameter tags: The XML tags to include inside the `<item>` block.
        public init(tags: [any XmlRepresentable]) {
            self.tags = tags
        }

        /// Creates an `<item>` that complies with PSP-1 and Apple Podcasts specifications.
        ///
        /// Includes all PSP-1 required tags:
        /// - `<title>`
        /// - `<enclosure>`
        /// - `<guid>`
        /// - `<pubDate>`
        ///
        /// And optional Apple extensions:
        /// - `<itunes:duration>`
        /// - `<itunes:episode>`
        /// - `<itunes:episodeType>`
        /// - `<itunes:summary>`
        /// - `<itunes:explicit>`
        /// - `<itunes:image>`
        ///
        /// - Parameters:
        ///   - title: The title of the episode.
        ///   - enclosure: The media file associated with the episode.
        ///   - guid: A unique identifier for this episode.
        ///   - pubDate: The publication date.
        ///   - duration: Optional episode duration.
        ///   - episode: Optional episode number.
        ///   - episodeType: Optional episode type (full, trailer, bonus).
        ///   - summary: Optional episode summary.
        ///   - explicit: Optional explicit content indicator.
        ///   - image: Optional episode-level artwork.
        ///   - additionalTags: Optional custom tags or namespaced extensions.
        public init(
            title: Title,
            enclosure: Enclosure,
            guid: Guid,
            pubDate: PubDate,
            duration: Namespace.iTunes.Duration? = nil,
            episode: Namespace.iTunes.Episode? = nil,
            episodeType: Namespace.iTunes.EpisodeType? = nil,
            summary: Namespace.iTunes.Summary? = nil,
            explicit: Namespace.iTunes.Explicit? = nil,
            image: Namespace.iTunes.Image? = nil,
            additionalTags: [any XmlRepresentable] = []
        ) {
            let required: [any XmlRepresentable] = [
                title,
                enclosure,
                guid,
                pubDate
            ]

            let recommended: [(any XmlRepresentable)?] = [
                duration,
                episode,
                episodeType,
                summary,
                explicit,
                image
            ]

            self.tags = required + recommended.compactMap { $0 } + additionalTags
        }

        /// Creates an `<item>` enriched with tags from the [Podcast Namespace 1.0](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md).
        ///
        /// Includes:
        /// - Required PSP-1 fields
        /// - Podcast Namespace fields like `<podcast:chapters>`, `<podcast:transcript>`, `<podcast:soundbite>`, etc.
        ///
        /// - Parameters:
        ///   - title: Episode title.
        ///   - enclosure: Media reference (audio or video).
        ///   - guid: Unique episode identifier.
        ///   - pubDate: Date of publication.
        ///   - chapters: Optional chapters JSON or VTT.
        ///   - transcript: Optional transcript file.
        ///   - soundbite: Optional teaser clip.
        ///   - location: Optional geolocation.
        ///   - license: Optional license for this episode.
        ///   - additionalTags: Optional custom tags.
        public init(
            title: Title,
            enclosure: Enclosure,
            guid: Guid,
            pubDate: PubDate,
            chapters: Namespace.Podcast.Chapters? = nil,
            transcript: Namespace.Podcast.Transcript? = nil,
            soundbite: Namespace.Podcast.Soundbite? = nil,
            location: Namespace.Podcast.Location? = nil,
            license: Namespace.Podcast.License? = nil,
            additionalTags: [any XmlRepresentable] = []
        ) {
            let required: [any XmlRepresentable] = [
                title,
                enclosure,
                guid,
                pubDate
            ]

            let podcastNamespaceTags: [(any XmlRepresentable)?] = [
                chapters,
                transcript,
                soundbite,
                location,
                license
            ]

            self.tags = required + podcastNamespaceTags.compactMap { $0 } + additionalTags
        }
    }
}

extension RSSTag.Item: XmlRepresentable {

    /// Generates the XML `<item>` block by rendering each child tag's XML representation.
    ///
    /// All tags stored in the `tags` property are rendered in order and indented using `doubleIndentedTagsRepresentation`.
    ///
    /// Example output:
    /// ```xml
    /// <item>
    ///     <title>Episode 1</title>
    ///     <enclosure url="..." length="..." type="..." />
    ///     ...
    /// </item>
    /// ```
    ///
    /// - Returns: A fully-formed XML `<item>` string.
    /// - Throws: Rethrows any error thrown by the individual `xmlRepresentation()` of each tag.
    public func xmlRepresentation() throws -> String {
        let xmlTags = try tags.map { try $0.xmlRepresentation() }.doubleIndentedTagsRepresentation
        return """
        \t<item>
        \(xmlTags)
        \t\t</item>
        """
    }
}
