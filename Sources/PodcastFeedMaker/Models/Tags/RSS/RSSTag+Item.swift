/*
public extension RSSTag {
    /// The episode (Item) tags informations.
    ///
    /// In the `Item` below, **Required tags** must be present in your RSS feed or it won’t pass validation to be listed in Apple Podcasts. **Recommended tags** aren’t required but are highly encouraged because they provide useful information to users. **Situational tags** are important in certain circumstances.
    struct Item: Hashable, Equatable, Sendable {
        
        // MARK: Required tags
        
        /// An episode title.
        ///
        /// title is a string containing a clear, concise name for your episode.
        ///
        /// Don’t specify the episode number or season number in this tag. Instead, specify those details in the appropriate tags (`<itunes:episode>`, `<itunes:season>`). Also, don’t repeat the title of your show within your episode title.
        ///
        /// Separating episode and season number from the title makes it possible for Apple to easily index and order content from all shows.
        public let title: RSSTag.Title
        
        /// The episode content, file size, and file type information.
        ///
        /// The `<enclosure>` tag has three attributes: URL, length, and type:
        ///
        /// - **URL**. The URL attribute points to your podcast media file. Specify the full file extension within the URL attribute. This determines whether or not content appears in the podcast directory. Supported file formats include M4A, MP3, MOV, MP4, M4V, and PDF.
        /// - **Length**. The length attribute is the file size in bytes. You can find this information in the properties of your podcast file (on a Mac, choose File > Get Info and refer to the size field).
        /// - **Type**. The type attribute provides the correct category for the type of file you are using. The type values for the supported file formats are: audio/x-m4a, audio/mpeg, video/quicktime, video/mp4, video/x-m4v, and application/pdf.
        /// For example:
        /// ```xml
        /// <enclosure
        /// url="http://mypodcast.com/episode001.mp3"
        /// length="5650889"
        /// type="audio/mpeg
        ////>
        ///```
        public let enclosure: RSSTag.Enclosure
        
        /// The episode’s globally unique identifier ([GUID](https://cyber.harvard.edu/rss/rss.html#ltguidgtSubelementOfLtitemgt)) If you uploaded subscriber audio in Apple Podcasts Connect and need to link it to an episode in your RSS feed, you can use the Apple Podcasts Episode ID in the GUID tag. Learn more about [how to set up your show for a subscription](https://podcasters.apple.com/support/set-up-your-show-for-a-subscription).
        ///
        /// It is very important that each episode have a unique GUID and that it never changes, even if an episode’s metadata, like title or enclosure URL, do change.
        ///
        /// [Globally unique identifiers (GUID)](https://help.apple.com/itc/podcasts_connect/#/itc5e66a7048) are case-sensitive strings. If a GUID is not provided, an episode’s enclosure URL will be used instead. If a GUID is not provided, make sure that an episode’s enclosure URL is unique and never changes.
        ///
        /// Failing to comply with these guidelines may result in duplicate episodes being shown to listeners, inaccurate data in [Analytics](https://help.apple.com/itc/podcastsanalytics/), and can cause issues with your podcasts’s listing and chart placement in Apple Podcasts.
        public let guid: RSSTag.Guid
        
        // MARK: Recommended tags
        
        /// The date and time when an episode was released.
        ///
        /// Format the date using the RFC 2822 specifications.
        /// For example:
        /// ```
        /// Sat, 01 Apr 2023 19:00:00 GMT.
        /// ```
        public let pubDate: RSSTag.PubDate?
        
        /// An episode description.
        ///
        /// description is text containing one or more sentences describing your episode to potential listeners. You can specify up to 10,000 characters. You can use rich text formatting and some HTML (`<p>`, `<ol>`, `<ul>`, `<li>`, `<a>`) if wrapped in the `<CDATA>` tag.
        ///
        /// To include links in your description or rich HTML, adhere to the following technical guidelines: enclose all portions of your XML that contain embedded HTML in a CDATA section to prevent formatting issues, and to ensure proper link functionality. For example:
        /// ```xml
        ///  <![CDATA[
        ///    <a href="https://www.domain.com">Website</a>
        ///  ]]>
        /// ```
        public let description: RSSTag.Description?
        
        /// The duration of an episode.
        ///
        /// Different duration formats are accepted however it is recommended to convert the length of the episode into seconds.
        public let duration: Namespace.iTunes.Duration?
        
        /// An episode link URL.
        ///
        /// This is used when an episode has a corresponding webpage. Use the full URL.
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
        
        /// The [episode artwork](https://podcasters.apple.com/support/896-artwork-requirements#episodes).
        ///
        ///You should use this tag when you have a high quality, episode-specific image you would like listeners to see.
        ///
        /// Specify your episode artwork using the href attribute in the `<itunes:image>` tag. [RSS Feed Sample](https://help.apple.com/itc/podcasts_connect/#/itcbaf351599).
        ///
        /// Depending on their device, listeners see your episode artwork in varying sizes. Therefore, make sure your design is effective at both its original size and at thumbnail size. You should include a title, brand, or source name as part of your episode artwork. To avoid technical issues when you update your episode artwork, be sure to:
        ///
        /// - Change the artwork file name and URL at the same time.
        /// - Confirm your art does not contain an Alpha Channel.
        /// - Verify the web server hosting your artwork allows HTTP head requests including Last Modified.
        /// Artwork must be a minimum size of 1400 x 1400 pixels and a maximum size of 3000 x 3000 pixels, in JPEG or PNG format, 72 dpi, with appropriate file extensions (.jpg, .png), and in the RGB colorspace.
        ///
        /// Make sure the file type in the URL matches the actual file type of the image file.
        public let image: Namespace.iTunes.Image?
        
        /// The episode parental advisory information.
        ///
        /// Where the explicit value can be one of the following:
        ///
        /// - **true**. If you specify _true_, indicating the presence of explicit content, Apple Podcasts displays an [Explicit](https://help.apple.com/itc/podcasts_connect/#/itcfafb6d665) parental advisory graphic for your episode.
        /// Episodes containing explicit material aren’t available in some Apple Podcasts territories.
        /// - **false**. If you specify _false_, indicating that the episode does not contain explicit language or adult content, Apple Podcasts displays a [Clean](https://help.apple.com/itc/podcasts_connect/#/itcb343e8058) parental advisory graphic for your episode.
        public let explicit: Namespace.iTunes.Explicit?
        
        // MARK: Situational tags
        
        /// An episode title specific for Apple Podcasts.
        ///
        /// `<itunes:title>` is a string containing a clear concise name of your episode on Apple Podcasts.
        ///
        /// Don’t specify the episode number or season number in this tag. Instead, specify those details in the appropriate tags (`<itunes:episode>`, `<itunes:season>`). Also, don’t repeat the title of your show within your episode title.
        ///
        /// Separating episode and season number from the title makes it possible for Apple to easily index and order content from all shows.
        public let itunesTitle: Namespace.iTunes.Title?
        
        /// An episode number.
        ///
        /// If all your episodes have numbers and you would like them to be ordered based on them, use this tag for each one.
        ///
        /// Episode numbers are optional for `<itunes:type>` _episodic_ shows, but are mandatory for serial shows.
        ///
        /// Where episode is a non-zero integer (1, 2, 3, etc.) representing your episode number.
        ///
        /// If you are using your RSS feed to distribute a free version of an episode that is already available to Apple Podcasts paid subscribers, make sure the episode numbers are the same so you don’t have duplicate episodes appear on your show page. Learn more about how to [set up your show for a subscription](https://podcasters.apple.com/support/set-up-your-show-for-a-subscription).
        public let episode: Namespace.iTunes.Episode?
        
        /// The episode season number.
        ///
        /// If an episode is within a season use this tag.
        ///
        /// Where season is a non-zero integer (1, 2, 3, etc.) representing your season number.
        ///
        /// To allow the season feature for shows containing a single season, if only one season exists in the RSS feed, Apple Podcasts doesn’t display a season number. When you add a second season to the RSS feed, Apple Podcasts displays the season numbers.
        public let season: Namespace.iTunes.Season?
        
        /// The episode type.
        ///
        /// If an episode is a trailer or bonus content, use this tag.
        ///
        /// Where the episodeType value can be one of the following:
        ///
        /// - **Full** (default). Specify _full_ when you are submitting the complete content of your [show](https://help.apple.com/itc/podcasts_connect/#/itca5dea085b).
        /// - **Trailer**. Specify _trailer_ when you are submitting a short, promotional piece of content that represents a preview of your current show.
        /// - **Bonus**. Specify _bonus_ when you are submitting extra content for your show (for example, behind the scenes information or interviews with the cast) or cross-promotional content for another show.
        /// The rules for using trailer and bonus tags depend on whether the `<itunes:season>` and `<itunes:episode>` tags have values:
        ///
        /// **Trailer:**
        ///
        /// - No season or episode number: a show trailer
        /// - A season number and no episode number: a season trailer. (Note: an episode trailer should have a different `<guid>` than the actual episode)
        /// - Episode number and optionally a season number: an episode trailer/teaser, later replaced with the actual episode
        ///
        /// **Bonus:**
        ///
        /// - No season or episode number: a show bonus
        /// - A season number: a season bonus
        /// - Episode number and optionally a season number: a bonus episode related to a specific episode
        public let episodeType: Namespace.iTunes.EpisodeType?
        
        /// A link to the episode transcript in the Closed Caption format. You should use this tag when you have a valid transcript file available for users to read.
        ///
        /// Specify the link to your transcript in the `url` attribute of the tag.
        ///
        /// Apple Podcasts will prefer VTT format over SRT format if multiple instances are included. A valid type attribute is required. Accepted types include `text/vtt`, `application/srt`, `application/x-subrip`.
        ///
        /// Learn more about `<podcast>` namespace RSS tags on the [Github repository](https://github.com/Podcastindex-org/podcast-namespace).
        ///
        /// Options for displaying transcripts are available in Apple Podcasts Connect for each show. [Learn more](https://podcasters.apple.com/support/5316-transcripts-on-apple-podcasts).
        public let transcript: Namespace.Podcast.Transcript?
        
        /// The episode show or hide status.
        ///
        /// If you want an episode removed from the Apple directory, use this tag.
        ///
        /// Specifying the `<itunes:block>` tag with a Yes value prevents that episode from appearing in Apple Podcasts.
        ///
        /// For example, you might want to block a specific episode if you know that its content would otherwise cause the entire podcast to be removed from Apple Podcasts.
        ///
        /// Specifying any value other than Yes has no effect.
        public let block: Namespace.iTunes.Block?
        
        public let summary: Namespace.iTunes.Summary?
        
        public let chapters: Namespace.Podcast.Chapters?

        // MARK: Initializer

        public init(
            title: RSSTag.Title,
            enclosure: RSSTag.Enclosure,
            guid: RSSTag.Guid,
            pubDate: RSSTag.PubDate?,
            description: RSSTag.Description?,
            duration: Namespace.iTunes.Duration?,
            link: RSSTag.Link?,
            image: Namespace.iTunes.Image?,
            explicit: Namespace.iTunes.Explicit?,
            itunesTitle: Namespace.iTunes.Title?,
            episode: Namespace.iTunes.Episode?,
            season: Namespace.iTunes.Season?,
            episodeType: Namespace.iTunes.EpisodeType?,
            transcript: Namespace.Podcast.Transcript?,
            block: Namespace.iTunes.Block?,
            summary: Namespace.iTunes.Summary?,
            chapters: Namespace.Podcast.Chapters?
        ) {
            self.title = title
            self.enclosure = enclosure
            self.guid = guid
            self.pubDate = pubDate
            self.description = description
            self.duration = duration
            self.link = link
            self.image = image
            self.explicit = explicit
            self.itunesTitle = itunesTitle
            self.episode = episode
            self.season = season
            self.episodeType = episodeType
            self.transcript = transcript
            self.block = block
            self.summary = summary
            self.chapters = chapters
        }
    }
}

extension RSSTag.Item: XmlRepresentable {
    private func formattedTags() throws -> String {
        let tags: [String] = try [
            title.xmlRepresentation(),
            itunesTitle?.xmlRepresentation(),
            enclosure.xmlRepresentation(),
            guid.xmlRepresentation(),
            pubDate?.xmlRepresentation(),
            description?.xmlRepresentation(),
            summary?.xmlRepresentation(),
            duration?.xmlRepresentation(),
            link?.xmlRepresentation(),
            image?.xmlRepresentation(),
            explicit?.xmlRepresentation(),
            episode?.xmlRepresentation(),
            season?.xmlRepresentation(),
            episodeType?.xmlRepresentation(),
            transcript?.xmlRepresentation(),
            block?.xmlRepresentation(),
            chapters?.xmlRepresentation()
        ].compactMap { $0 }

        return tags.doubleIndentedTagsRepresentation
    }

    public func xmlRepresentation() throws -> String {
        try """
        \t<item>
        \(formattedTags())
        \t\t</item>
        """
    }
}
*/

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
