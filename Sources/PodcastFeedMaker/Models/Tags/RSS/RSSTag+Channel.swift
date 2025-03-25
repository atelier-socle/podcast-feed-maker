/*
public extension RSSTag {
    /// The show informations.
    ///
    /// In the `Channel` below, **Required tags** must be present in your RSS feed
    /// or it won’t pass validation to be listed in Apple Podcasts.
    /// **Recommended tags** aren’t required but are highly encouraged because they provide
    /// useful information to users. **Situational tags** are important in certain circumstances.
    struct Channel: Hashable, Equatable, Sendable {
        
        // MARK: Required tags
        
        /// The show title.
        ///
        /// It’s important to have a clear, concise name for your podcast. Make your title specific. A show titled _Our Community Bulletin_ is too vague to attract many subscribers, no matter how compelling the content.
        ///
        /// Pay close attention to the title as Apple Podcasts uses this field for search.
        ///
        /// >important: If you include a long list of keywords in an attempt to game podcast search, your show may be removed from the Apple directory.
        public let title: RSSTag.Title
        
        /// The show description.
        ///
        /// Where description is text containing one or more sentences describing your podcast to potential listeners. The maximum amount of text allowed for this tag is 4000 bytes.
        ///
        /// To include links in your description or rich HTML, adhere to the following technical guidelines: enclose all portions of your XML that contain embedded HTML in a CDATA section to prevent formatting issues, and to ensure proper link functionality. For example:
        /// ```xml
        /// <![CDATA[
        ///   <a href="https://www.domain.com">My Website</a>
        /// ]]>
        /// ```
        public let description: RSSTag.Description
        
        /// The artwork for the show.
        ///
        /// Specify your show artwork by providing a URL linking to it.
        ///
        /// Depending on their device, subscribers see your podcast artwork in varying sizes. Therefore, make sure your design is effective at both its original size and at thumbnail size. You should include a show title, brand, or source name as part of your podcast artwork. Here are additional [marketing best practices](https://podcasters.apple.com/). For examples of podcast artwork, see the Top Podcasts chart. To avoid technical issues when you update your podcast artwork, be sure to:
        ///
        /// - Change the artwork file name and URL at the same time
        /// - Make sure the file type in the URL matches the actual file type of the image file.
        /// - Verify the web server hosting your artwork allows HTTP head requests including Last Modified.
        /// Artwork must be a minimum size of 1400 x 1400 pixels and a maximum size of 3000 x 3000 pixels, in JPEG or PNG format, 72 dpi, with appropriate file extensions (.jpg, .png), and in the RGB colorspace. Confirm your art does not contain an Alpha Channel. These requirements are different from the standard RSS image tag specifications.
        public let itunesImage: Namespace.iTunes.Image
        
        /// The language spoken on the show.
        ///
        /// Because Apple Podcasts is available in territories around the world, it is critical to specify the language
        /// of a podcast. Apple Podcasts only supports values from the [ISO 639](http://www.loc.gov/standards/iso639-2/php/code_list.php) list
        /// (two-letter language codes, with some possible modifiers, such as "fr-ca").
        ///
        /// >important: Invalid language codes will cause your feed to fail Apple validation.
        public let language: RSSTag.Language
        
        /// The show category information. For a complete list of categories and subcategories, see Apple Podcast categories.
        ///
        /// Select the category that best reflects the content of your show. If available, you can also define a subcategory.
        ///
        /// Although you can specify more than one category and subcategory in your RSS feed, Apple Podcasts only recognizes the first category and subcategory.
        ///
        /// When specifying categories and subcategories, be sure to properly escape ampersands. For example:
        ///
        /// Single category:
        /// ```xml
        /// <itunes:category text="History" />
        /// ```
        ///
        /// Category with ampersand:
        /// ```xml
        /// <itunes:category text="Kids &amp; Family" />
        /// ```
        ///
        /// Category with subcategory:
        /// ```xml
        /// <itunes:category text="Society &amp; Culture">
        ///    <itunes:category text="Documentary" />
        /// </itunes:category>
        /// ```
        ///
        /// Multiple categories:
        /// ```xml
        /// <itunes:category text="Society &amp; Culture">
        ///     <itunes:category text="Documentary" />
        ///   </itunes:category>
        ///   <itunes:category text="Health">
        ///     <itunes:category text="Mental Health" />
        ///   </itunes:category>
        /// ```
        public let categories: Namespace.iTunes.Category
        
        /// The podcast parental advisory information.
        ///
        /// The explicit value can be one of the following:
        ///
        /// - **True**. If you specify true, indicating the presence of explicit content, Apple Podcasts displays an [Explicit](https://help.apple.com/itc/podcasts_connect/#/itcfafb6d665) parental advisory graphic for your podcast.
        /// Podcasts containing explicit material aren’t available in some Apple Podcasts territories.
        ///
        /// - **False**. If you specify false, indicating that your podcast doesn’t contain explicit language or adult content, Apple Podcasts displays a [Clean](https://help.apple.com/itc/podcasts_connect/#/itcb343e8058) parental advisory graphic for your podcast.
        public let explicit: Namespace.iTunes.Explicit
        
        // MARK: Recommended tags
        
        /// The group responsible for creating the show.
        ///
        /// Show author most often refers to the parent company or network of a podcast,
        /// but it can also be used to identify the host(s) if none exists.
        ///
        ///Author information is especially useful if a company or organization publishes multiple podcasts.
        public let author: Namespace.iTunes.Author?
        
        /// The website associated with a podcast. Use the full URL.
        ///
        /// Typically a home page for a podcast or a dedicated portion of a larger website.
        /// For example:
        /// ```xml
        /// <link>
        ///     https://www.example.com
        /// </link>
        /// ```
        /// or
        /// ```xml
        /// <link>
        ///     https://www.example.com/podcast
        /// </link>
        /// ```
        public let link: RSSTag.Link?
        
        // MARK: Situational tags
        
        /// The show title specific for Apple Podcasts.
        ///
        /// `<itunes:title>` is a string containing a clear concise name of your show on
        /// Apple Podcasts. Do not include episode or season number in the title.
        /// There are dedicated tags for that information. See `<itunes:episode>`
        /// and `<itunes:season>`.
        public let itunesTitle: Namespace.iTunes.Title?
        
        /// The type of show.
        ///
        /// If your show is Serial you must use this tag.
        ///
        /// Its values can be one of the following:
        ///
        /// - **Episodic** (default). Specify _episodic_ when episodes are intended to be consumed without any specific order. Apple Podcasts will present newest episodes first and display the publish date (required) of each episode. If organized into [seasons](https://help.apple.com/itc/podcasts_connect/#/itc77382b700), the newest season will be presented first - otherwise, episodes will be grouped by year published, newest first.
        /// For new subscribers, Apple Podcasts adds the newest, most recent episode in their Library.
        /// - **Serial**. Specify _serial_ when episodes are intended to be consumed in sequential order. Apple Podcasts will present the oldest episodes first and display the episode numbers (required) of each episode. If organized into seasons, the newest season will be presented first and `<itunes:episode>` numbers must be given for each episode.
        /// Each show type has different behavior for automatic downloads. [Learn more](https://podcasters.apple.com/support/1662-automatic-downloads-on-apple-podcasts).
        public let type: Namespace.iTunes.ChannelType?
        
        /// The show copyright details.
        ///
        /// If your show is copyrighted you should use this tag.
        /// For example:
        /// ```xml
        /// <copyright>Copyright 1995-2025 John Appleseed</copyright>
        /// ```
        /// or by using `©` symbol
        /// ```xml
        /// <copyright>&#169; 2025 John Appleseed</copyright>
        /// ```
        public let copyright: RSSTag.Copyright?
        
        /// The new podcast RSS Feed URL.
        ///
        /// If you change the URL of your podcast feed, you should use this tag in your new feed.
        ///
        /// Use the `<itunes:new-feed-url>` tag to manually change the URL where your podcast is located.
        ///
        /// ```xml
        /// <itunes:new-feed-url>
        ///   https://newlocation.com/example.rss
        /// </itunes:new-feed-url>
        /// ```
        ///
        /// You should maintain your old feed until you have migrated your existing followers. Learn how to [update your podcast RSS feed URL](https://podcasters.apple.com/support/change-the-rss-feed-url).
        ///
        /// >Note: The `<itunes:new-feed-url>` tag reports new feed URLs to Apple Podcasts and isn’t displayed in Apple Podcasts.
        public let newFeedUrl: Namespace.iTunes.NewFeedUrl?
        
        /// The podcast show or hide status.
        ///
        /// If you want your show removed from the Apple directory, use this tag.
        ///
        /// Specifying the `<itunes:block>` tag with a **Yes** value, prevents the entire podcast from appearing in Apple Podcasts.
        ///
        /// Specifying any value other than Yes has no effect.
        public let block: Namespace.iTunes.Block?
        
        /// The podcast update status.
        ///
        /// If you will never publish another episode to your show, use this tag.
        ///
        /// Specifying the `<itunes:complete>` tag with a **Yes** value indicates that a podcast is complete and you will not post any more episodes in the future.
        ///
        /// Specifying any value other than Yes has no effect.
        public let complete: Namespace.iTunes.Complete?
        
        /// This tag is used to verify ownership of a show when a podcast creator chooses
        /// to move it from one Apple Podcasts Connect account to another.
        /// [Learn more about how to claim your show](https://podcasters.apple.com/support/5497-claim-your-show).
        public let verify: Namespace.iTunes.Verify?
        
        /// Specifies the program or hosting provider used to create the RSS feed.
        ///
        /// Hosting providers use this tag to identify themselves as the creator of an RSS feed.
        public let generator: RSSTag.Generator?
        
        /// The episodes (Items) tags informations.
        public let items: [RSSTag.Item]
        
        // MARK: Deprecated iTunes tags
        
        /// The itunes summary content (like description).
        public let summary: Namespace.iTunes.Summary?
        
        /// The itunes channel subtitle.
        public let subtitle: Namespace.iTunes.Subtitle?
        
        /// The itunes channel keywords.
        public let keywords: Namespace.iTunes.Keywords?
        
        /// The itunes channel owner.
        public let owner: Namespace.iTunes.Owner?
        
        // MARK: Common recommanded tags
        
        /// The channel first publication date.
        public let pubDate: RSSTag.PubDate?
        
        /// The channel last build publication date.
        public let lastBuildDate: RSSTag.LastBuildDate?
        
        /// The `<ttl>` (ttl=time to live) element specifies the **number of minutes**
        /// the feed can stay cached before refreshing it from the source.
        public let ttl: RSSTag.TimeToLive?
        
        public let locked: Namespace.Podcast.Locked?
        
        public let guid: Namespace.Podcast.Guid?
        
        public let atomLink: Namespace.Atom.Link?
        
        public let image: RSSTag.Image?
        
        public let location: Namespace.Podcast.Location?

        // MARK: Initializer

        public init(
            title: RSSTag.Title,
            description: RSSTag.Description,
            itunesImage: Namespace.iTunes.Image,
            language: RSSTag.Language,
            categories: Namespace.iTunes.Category,
            explicit: Namespace.iTunes.Explicit,
            author: Namespace.iTunes.Author?,
            link: RSSTag.Link?,
            itunesTitle: Namespace.iTunes.Title?,
            type: Namespace.iTunes.ChannelType?,
            copyright: RSSTag.Copyright?,
            newFeedUrl: Namespace.iTunes.NewFeedUrl?,
            block: Namespace.iTunes.Block?,
            complete: Namespace.iTunes.Complete?,
            verify: Namespace.iTunes.Verify?,
            generator: RSSTag.Generator?,
            items: [RSSTag.Item],
            summary: Namespace.iTunes.Summary?,
            subtitle: Namespace.iTunes.Subtitle?,
            keywords: Namespace.iTunes.Keywords?,
            owner: Namespace.iTunes.Owner?,
            pubDate: RSSTag.PubDate?,
            lastBuildDate: RSSTag.LastBuildDate?,
            ttl: RSSTag.TimeToLive?,
            locked: Namespace.Podcast.Locked?,
            guid: Namespace.Podcast.Guid?,
            atomLink: Namespace.Atom.Link?,
            image: RSSTag.Image?,
            location: Namespace.Podcast.Location?
        ) {
            self.title = title
            self.description = description
            self.itunesImage = itunesImage
            self.language = language
            self.categories = categories
            self.explicit = explicit
            self.author = author
            self.link = link
            self.itunesTitle = itunesTitle
            self.type = type
            self.copyright = copyright
            self.newFeedUrl = newFeedUrl
            self.block = block
            self.complete = complete
            self.verify = verify
            self.generator = generator
            self.items = items
            self.summary = summary
            self.subtitle = subtitle
            self.keywords = keywords
            self.owner = owner
            self.pubDate = pubDate
            self.lastBuildDate = lastBuildDate
            self.ttl = ttl
            self.locked = locked
            self.guid = guid
            self.atomLink = atomLink
            self.image = image
            self.location = location
        }
    }
}

extension RSSTag.Channel: XmlRepresentable {
    private func formattedTags() throws -> String {
        let tags: [String] = try [
            ttl?.xmlRepresentation(),
            atomLink?.xmlRepresentation(),
            title.xmlRepresentation(),
            description.xmlRepresentation(),
            itunesImage.xmlRepresentation(),
            image?.xmlRepresentation(),
            language.xmlRepresentation(),
            explicit.xmlRepresentation(),
            author?.xmlRepresentation(),
            link?.xmlRepresentation(),
            itunesTitle?.xmlRepresentation(),
            type?.xmlRepresentation(),
            copyright?.xmlRepresentation(),
            newFeedUrl?.xmlRepresentation(),
            block?.xmlRepresentation(),
            complete?.xmlRepresentation(),
            verify?.xmlRepresentation(),
            generator?.xmlRepresentation(),
            pubDate?.xmlRepresentation(),
            lastBuildDate?.xmlRepresentation(),
            locked?.xmlRepresentation(),
            summary?.xmlRepresentation(),
            subtitle?.xmlRepresentation(),
            keywords?.xmlRepresentation(),
            owner?.xmlRepresentation(),
            guid?.xmlRepresentation(),
            location?.xmlRepresentation()
        ].compactMap { $0 }

        return tags.indentedTagsRepresentation
    }

    private func formattedItemTags() throws -> String {
        let representation = try items.map { try $0.xmlRepresentation() }
        return representation.indentedTagsRepresentation
    }

    private func formattedCategoriesTags() throws -> String {
        let representation = try categories.xmlRepresentation()
        return representation
    }

    public func xmlRepresentation() throws -> String {
        try """
        \t<channel>
        \(formattedTags())
        \(formattedCategoriesTags())
        \(formattedItemTags())
        \t</channel>
        """
    }
}
*/

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
