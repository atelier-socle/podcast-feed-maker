import Foundation

/// Represents the `<channel>` element in an RSS 2.0 podcast feed.
///
/// The channel contains all feed-level metadata from multiple namespaces:
/// RSS 2.0 core, iTunes, Podcast Namespace 2.0, Atom, and Dublin Core.
/// It also contains the list of ``Item`` entries (episodes).
///
/// This is a pure data model — XML generation and parsing are handled
/// by separate ``FeedGenerator`` and ``FeedParser`` types.
///
/// - SeeAlso: [RSS 2.0 — channel](https://www.rssboard.org/rss-specification#requiredChannelElements)
public struct Channel: Sendable, Hashable, Equatable, Codable {

    // MARK: - RSS 2.0 Core (Required)

    /// The name of the channel/podcast.
    public var title: String

    /// The URL to the HTML website corresponding to the channel.
    public var link: URL

    /// Phrase or sentence describing the channel.
    public var description: String

    // MARK: - RSS 2.0 Core (Optional)

    /// The language the channel is written in (RFC 5646 / BCP 47).
    public var language: String?

    /// Copyright notice for the channel content.
    public var copyright: String?

    /// Email address for the managing editor.
    public var managingEditor: String?

    /// Email address for the webmaster.
    public var webMaster: String?  // swiftlint:disable:this inclusive_language

    /// The publication date for the channel content.
    public var pubDate: Date?

    /// The last time the channel content changed.
    public var lastBuildDate: Date?

    /// RSS categories for this channel.
    public var categories: [RSSCategory]

    /// A string indicating the program used to generate the channel.
    public var generator: String?

    /// A URL that points to the documentation for the RSS format.
    public var docs: URL?

    /// Cloud update notification registration.
    public var cloud: RSSCloud?

    /// Time-to-live: number of minutes the channel can be cached.
    public var ttl: Int?

    /// The PICS rating for the channel.
    ///
    /// - SeeAlso: [RSS 2.0 — rating](https://www.rssboard.org/rss-specification#optionalChannelElements)
    public var rating: String?

    /// An image for the channel (RSS 2.0 spec).
    public var image: RSSImage?

    /// A text input box to display with the channel.
    public var textInput: RSSTextInput?

    /// Schedule hints for aggregators about when to skip polling.
    public var skipSchedule: SkipSchedule?

    // MARK: - Items

    /// The episodes in this channel.
    public var items: [Item]

    // MARK: - iTunes Namespace

    /// The podcast author (`<itunes:author>`).
    public var itunesAuthor: String?

    /// Whether the podcast is blocked from directories (`<itunes:block>`).
    ///
    /// - Note: This is the simple `<itunes:block>` (yes/no), distinct from
    ///   ``PodcastBlock`` which supports platform targeting.
    public var itunesBlock: Bool?

    /// iTunes categories for the podcast.
    public var itunesCategories: [ITunesCategory]

    /// Whether the podcast is complete (no more episodes) (`<itunes:complete>`).
    public var itunesComplete: Bool?

    /// Whether the podcast contains explicit content (`<itunes:explicit>`).
    public var itunesExplicit: Bool?

    /// The podcast artwork URL (`<itunes:image>`).
    public var itunesImage: URL?

    /// Deprecated keywords (`<itunes:keywords>`).
    public var itunesKeywords: [String]

    /// A new feed URL to redirect to (`<itunes:new-feed-url>`).
    public var itunesNewFeedUrl: URL?

    /// The podcast owner contact information.
    public var itunesOwner: ITunesOwner?

    /// A short subtitle (`<itunes:subtitle>`).
    public var itunesSubtitle: String?

    /// A longer summary (`<itunes:summary>`).
    public var itunesSummary: String?

    /// A show-level title override (`<itunes:title>`).
    public var itunesTitle: String?

    /// The show type: episodic or serial (`<itunes:type>`).
    public var itunesType: ITunesShowType?

    /// Whether Apple Podcasts should verify feed ownership (`<itunes:applepodcastsverify>`).
    ///
    /// - Note: Not in the official iTunes DTD, but used by Apple in special verification flows.
    public var itunesVerify: Bool?

    // MARK: - Atom Namespace

    /// Atom links (typically includes the self-referencing feed link).
    public var atomLinks: [AtomLink]

    // MARK: - Dublin Core Namespace

    /// Dublin Core metadata for the channel.
    public var dublinCore: DublinCore?

    // MARK: - Podcast Namespace 2.0

    /// A globally unique, permanent identifier for the podcast.
    public var podcastGuid: PodcastGuid?

    /// Whether the feed is locked to prevent platform imports.
    public var locked: Locked?

    /// Donation/support links.
    public var funding: [Funding]

    /// People associated with the podcast (hosts, producers, etc.).
    public var persons: [PodcastPerson]

    /// Geographic locations relevant to the podcast.
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

    /// License information for the podcast.
    public var license: PodcastLicense?

    /// Value-for-Value payment configuration.
    public var value: PodcastValue?

    /// The primary medium/content type of the feed.
    public var medium: PodcastMedium?

    /// Platform-specific block directives.
    public var podcastBlocks: [PodcastBlock]

    /// Free-form text records.
    public var txtRecords: [PodcastTxt]

    /// Recommended podcasts (podroll).
    public var podroll: Podroll?

    /// Hints about feed update schedule.
    public var updateFrequency: UpdateFrequency?

    /// Whether podping notifications are enabled for this feed.
    public var podpingEnabled: Bool?

    /// Show trailers or season previews.
    public var trailers: [Trailer]

    /// Live streaming episodes.
    public var liveItems: [PodcastLiveItem]

    /// The publisher or network.
    public var publisher: PodcastPublisher?

    /// Podcast Namespace 2.0 `podcast:image` tags.
    ///
    /// Multiple images allowed for different use cases (artwork, social, icon, canvas).
    public var podcastImages: [PodcastImage]

    /// Deprecated `podcast:images` tag with `srcset` attribute.
    ///
    /// Parsed for round-trip fidelity. Superseded by ``podcastImages``.
    public var podcastImagesSrcset: PodcastImages?

    /// Chat/discussion room information.
    public var chat: PodcastChat?

    // MARK: - Round-Trip Preservation

    /// Unknown XML elements captured during parsing for round-trip fidelity.
    public var unknownElements: [UnknownElement]

    /// XML comments captured during parsing for round-trip fidelity.
    public var xmlComments: [String]

    /// Element names whose content was originally wrapped in CDATA sections.
    public var cdataFields: Set<String>

    // MARK: - Initializer

    /// Creates a new channel with all properties.
    ///
    /// Only `title`, `link`, and `description` are required per RSS 2.0.
    /// All other parameters default to `nil` or empty arrays.
    public init(
        title: String,
        link: URL,
        description: String,
        language: String? = nil,
        copyright: String? = nil,
        managingEditor: String? = nil,
        // swiftlint:disable:next inclusive_language
        webMaster: String? = nil,
        pubDate: Date? = nil,
        lastBuildDate: Date? = nil,
        categories: [RSSCategory] = [],
        generator: String? = nil,
        docs: URL? = nil,
        cloud: RSSCloud? = nil,
        ttl: Int? = nil,
        rating: String? = nil,
        image: RSSImage? = nil,
        textInput: RSSTextInput? = nil,
        skipSchedule: SkipSchedule? = nil,
        items: [Item] = [],
        itunesAuthor: String? = nil,
        itunesBlock: Bool? = nil,
        itunesCategories: [ITunesCategory] = [],
        itunesComplete: Bool? = nil,
        itunesExplicit: Bool? = nil,
        itunesImage: URL? = nil,
        itunesKeywords: [String] = [],
        itunesNewFeedUrl: URL? = nil,
        itunesOwner: ITunesOwner? = nil,
        itunesSubtitle: String? = nil,
        itunesSummary: String? = nil,
        itunesTitle: String? = nil,
        itunesType: ITunesShowType? = nil,
        itunesVerify: Bool? = nil,
        atomLinks: [AtomLink] = [],
        dublinCore: DublinCore? = nil,
        podcastGuid: PodcastGuid? = nil,
        locked: Locked? = nil,
        funding: [Funding] = [],
        persons: [PodcastPerson] = [],
        locations: [PodcastLocation] = [],
        license: PodcastLicense? = nil,
        value: PodcastValue? = nil,
        medium: PodcastMedium? = nil,
        podcastBlocks: [PodcastBlock] = [],
        txtRecords: [PodcastTxt] = [],
        podroll: Podroll? = nil,
        updateFrequency: UpdateFrequency? = nil,
        podpingEnabled: Bool? = nil,
        trailers: [Trailer] = [],
        liveItems: [PodcastLiveItem] = [],
        publisher: PodcastPublisher? = nil,
        podcastImages: [PodcastImage] = [],
        podcastImagesSrcset: PodcastImages? = nil,
        chat: PodcastChat? = nil,
        unknownElements: [UnknownElement] = [],
        xmlComments: [String] = [],
        cdataFields: Set<String> = []
    ) {
        self.title = title
        self.link = link
        self.description = description
        self.language = language
        self.copyright = copyright
        self.managingEditor = managingEditor
        self.webMaster = webMaster
        self.pubDate = pubDate
        self.lastBuildDate = lastBuildDate
        self.categories = categories
        self.generator = generator
        self.docs = docs
        self.cloud = cloud
        self.ttl = ttl
        self.rating = rating
        self.image = image
        self.textInput = textInput
        self.skipSchedule = skipSchedule
        self.items = items
        self.itunesAuthor = itunesAuthor
        self.itunesBlock = itunesBlock
        self.itunesCategories = itunesCategories
        self.itunesComplete = itunesComplete
        self.itunesExplicit = itunesExplicit
        self.itunesImage = itunesImage
        self.itunesKeywords = itunesKeywords
        self.itunesNewFeedUrl = itunesNewFeedUrl
        self.itunesOwner = itunesOwner
        self.itunesSubtitle = itunesSubtitle
        self.itunesSummary = itunesSummary
        self.itunesTitle = itunesTitle
        self.itunesType = itunesType
        self.itunesVerify = itunesVerify
        self.atomLinks = atomLinks
        self.dublinCore = dublinCore
        self.podcastGuid = podcastGuid
        self.locked = locked
        self.funding = funding
        self.persons = persons
        self.locations = locations
        self.license = license
        self.value = value
        self.medium = medium
        self.podcastBlocks = podcastBlocks
        self.txtRecords = txtRecords
        self.podroll = podroll
        self.updateFrequency = updateFrequency
        self.podpingEnabled = podpingEnabled
        self.trailers = trailers
        self.liveItems = liveItems
        self.publisher = publisher
        self.podcastImages = podcastImages
        self.podcastImagesSrcset = podcastImagesSrcset
        self.chat = chat
        self.unknownElements = unknownElements
        self.xmlComments = xmlComments
        self.cdataFields = cdataFields
    }
}

// MARK: - iTunes Show Type

/// The show type for `<itunes:type>`.
public enum ITunesShowType: String, CaseIterable, Hashable, Equatable, Sendable, Codable {

    /// Episodes are standalone and can be listened to in any order.
    case episodic

    /// Episodes should be consumed in order.
    case serial
}
