import Foundation

/// Represents a single `<item>` in an RSS 2.0 podcast feed.
///
/// An item typically corresponds to a podcast episode. It contains metadata
/// from multiple namespaces: RSS 2.0 core, iTunes, Podcast Namespace 2.0,
/// Atom, Dublin Core, Content Module, and Podlove Simple Chapters.
///
/// This is a pure data model — XML generation and parsing are handled
/// by separate ``FeedGenerator`` and ``FeedParser`` types.
///
/// - SeeAlso: [RSS 2.0 — item](https://www.rssboard.org/rss-specification#hrelementsOfLtitemgt)
public struct Item: Sendable, Hashable, Equatable {

    // MARK: - RSS 2.0 Core

    /// The title of the item.
    public var title: String?

    /// The URL of the item's web page.
    public var link: URL?

    /// The item synopsis.
    public var description: String?

    /// The email address of the author.
    public var author: String?

    /// RSS categories for this item.
    public var categories: [RSSCategory]

    /// The URL of a page for comments relating to the item.
    public var comments: URL?

    /// The media enclosure (audio/video file) for the episode.
    public var enclosure: Enclosure?

    /// A unique identifier for the item.
    public var guid: GUID?

    /// The publication date of the item.
    public var pubDate: Date?

    /// The RSS channel the item came from (for aggregated feeds).
    public var source: RSSSource?

    // MARK: - iTunes Namespace

    /// The episode author (`<itunes:author>`).
    public var itunesAuthor: String?

    /// Whether the episode is blocked from appearing in directories (`<itunes:block>`).
    public var itunesBlock: Bool?

    /// The episode duration in seconds (`<itunes:duration>`).
    public var itunesDuration: Int?

    /// The episode number (`<itunes:episode>`).
    public var itunesEpisode: Int?

    /// The episode type (`<itunes:episodeType>`).
    public var itunesEpisodeType: ITunesEpisodeType?

    /// Whether the episode contains explicit content (`<itunes:explicit>`).
    public var itunesExplicit: Bool?

    /// Episode-level artwork URL (`<itunes:image>`).
    public var itunesImage: URL?

    /// Deprecated keywords for the episode (`<itunes:keywords>`).
    public var itunesKeywords: [String]

    /// The season number (`<itunes:season>`).
    public var itunesSeason: Int?

    /// A short subtitle (`<itunes:subtitle>`).
    public var itunesSubtitle: String?

    /// A longer summary (`<itunes:summary>`).
    public var itunesSummary: String?

    /// An episode-specific title override (`<itunes:title>`).
    public var itunesTitle: String?

    // MARK: - Atom Namespace

    /// Atom links associated with this item.
    public var atomLinks: [AtomLink]

    // MARK: - Dublin Core Namespace

    /// Dublin Core metadata for this item.
    public var dublinCore: DublinCore?

    // MARK: - Content Module

    /// Rich HTML content for the episode (`<content:encoded>`).
    public var contentEncoded: ContentEncoded?

    // MARK: - Podcast Namespace 2.0

    /// Transcript files for the episode.
    public var transcripts: [Transcript]

    /// Link to a JSON Chapters file.
    public var chaptersLink: ChaptersLink?

    /// Short audio clips (soundbites) from the episode.
    public var soundbites: [Soundbite]

    /// People associated with this episode (hosts, guests, etc.).
    public var persons: [PodcastPerson]

    /// Geographic locations relevant to this episode.
    ///
    /// Up to 2 allowed: one with `rel="creator"` and one with `rel="subject"`.
    public var locations: [PodcastLocation]

    /// Convenience accessor for the first location.
    ///
    /// Gets the first location in the array; setting replaces the entire array.
    public var location: PodcastLocation? {
        get { locations.first }
        set { locations = newValue.map { [$0] } ?? [] }
    }

    /// License information for this episode.
    public var license: PodcastLicense?

    /// Alternative media enclosures for the episode.
    public var alternateEnclosures: [AlternateEnclosure]

    /// Value-for-Value payment configuration for this episode.
    public var value: PodcastValue?

    /// Social interaction references for the episode.
    public var socialInteractions: [SocialInteract]

    /// Free-form text records for the episode.
    public var txtRecords: [PodcastTxt]

    /// Rich season metadata (`<podcast:season>` with `name` attribute).
    public var podcastSeason: PodcastSeason?

    /// Rich episode metadata (`<podcast:episode>` with `display` attribute).
    public var podcastEpisode: PodcastEpisode?

    /// Podcast Namespace 2.0 `podcast:image` tags.
    ///
    /// Multiple images allowed for different use cases (artwork, social, icon, canvas).
    public var podcastImages: [PodcastImage]

    /// Deprecated `podcast:images` tag with `srcset` attribute.
    ///
    /// Parsed for round-trip fidelity. Superseded by ``podcastImages``.
    public var podcastImagesSrcset: PodcastImages?

    // MARK: - Podlove Simple Chapters

    /// Podlove chapter markers embedded in the feed.
    public var podloveChapters: PodloveChapters?

    // MARK: - Round-Trip Preservation

    /// Unknown XML elements captured during parsing for round-trip fidelity.
    public var unknownElements: [UnknownElement]

    /// XML comments captured during parsing for round-trip fidelity.
    public var xmlComments: [String]

    /// Element names whose content was originally wrapped in CDATA sections.
    public var cdataFields: Set<String>

    // MARK: - Initializer

    /// Creates a new feed item (episode).
    ///
    /// All parameters are optional except arrays which default to empty.
    /// Use the properties that match the namespaces your feed supports.
    public init(
        title: String? = nil,
        link: URL? = nil,
        description: String? = nil,
        author: String? = nil,
        categories: [RSSCategory] = [],
        comments: URL? = nil,
        enclosure: Enclosure? = nil,
        guid: GUID? = nil,
        pubDate: Date? = nil,
        source: RSSSource? = nil,
        itunesAuthor: String? = nil,
        itunesBlock: Bool? = nil,
        itunesDuration: Int? = nil,
        itunesEpisode: Int? = nil,
        itunesEpisodeType: ITunesEpisodeType? = nil,
        itunesExplicit: Bool? = nil,
        itunesImage: URL? = nil,
        itunesKeywords: [String] = [],
        itunesSeason: Int? = nil,
        itunesSubtitle: String? = nil,
        itunesSummary: String? = nil,
        itunesTitle: String? = nil,
        atomLinks: [AtomLink] = [],
        dublinCore: DublinCore? = nil,
        contentEncoded: ContentEncoded? = nil,
        transcripts: [Transcript] = [],
        chaptersLink: ChaptersLink? = nil,
        soundbites: [Soundbite] = [],
        persons: [PodcastPerson] = [],
        locations: [PodcastLocation] = [],
        license: PodcastLicense? = nil,
        alternateEnclosures: [AlternateEnclosure] = [],
        value: PodcastValue? = nil,
        socialInteractions: [SocialInteract] = [],
        txtRecords: [PodcastTxt] = [],
        podcastSeason: PodcastSeason? = nil,
        podcastEpisode: PodcastEpisode? = nil,
        podcastImages: [PodcastImage] = [],
        podcastImagesSrcset: PodcastImages? = nil,
        podloveChapters: PodloveChapters? = nil,
        unknownElements: [UnknownElement] = [],
        xmlComments: [String] = [],
        cdataFields: Set<String> = []
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.author = author
        self.categories = categories
        self.comments = comments
        self.enclosure = enclosure
        self.guid = guid
        self.pubDate = pubDate
        self.source = source
        self.itunesAuthor = itunesAuthor
        self.itunesBlock = itunesBlock
        self.itunesDuration = itunesDuration
        self.itunesEpisode = itunesEpisode
        self.itunesEpisodeType = itunesEpisodeType
        self.itunesExplicit = itunesExplicit
        self.itunesImage = itunesImage
        self.itunesKeywords = itunesKeywords
        self.itunesSeason = itunesSeason
        self.itunesSubtitle = itunesSubtitle
        self.itunesSummary = itunesSummary
        self.itunesTitle = itunesTitle
        self.atomLinks = atomLinks
        self.dublinCore = dublinCore
        self.contentEncoded = contentEncoded
        self.transcripts = transcripts
        self.chaptersLink = chaptersLink
        self.soundbites = soundbites
        self.persons = persons
        self.locations = locations
        self.license = license
        self.alternateEnclosures = alternateEnclosures
        self.value = value
        self.socialInteractions = socialInteractions
        self.txtRecords = txtRecords
        self.podcastSeason = podcastSeason
        self.podcastEpisode = podcastEpisode
        self.podcastImages = podcastImages
        self.podcastImagesSrcset = podcastImagesSrcset
        self.podloveChapters = podloveChapters
        self.unknownElements = unknownElements
        self.xmlComments = xmlComments
        self.cdataFields = cdataFields
    }
}

// MARK: - iTunes Episode Type

/// The episode type for `<itunes:episodeType>`.
public enum ITunesEpisodeType: String, CaseIterable, Hashable, Equatable, Sendable, Codable {

    /// A standard full episode.
    case full

    /// A preview or promotional trailer.
    case trailer

    /// Bonus or supplemental content.
    case bonus
}
