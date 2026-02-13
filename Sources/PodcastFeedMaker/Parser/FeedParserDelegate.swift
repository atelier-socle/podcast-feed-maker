import Foundation

// MARK: - Parser Context

/// Tracks the current position in the XML element hierarchy.
enum ParserContext {
    case root
    case channel
    case item
    case image
    case textInput
    case skipHours
    case skipDays
    case itunesOwner
    case itunesCategory
    case podcastValue
    case valueTimeSplit
    case podroll
    case alternateEnclosure
    case liveItem
    case podloveChapters
    case podcastPublisher
}

// MARK: - FeedParserDelegate

/// SAX-style XML parser delegate that builds a ``PodcastFeed`` from XML events.
///
/// Handles all 7 namespaces: RSS 2.0, iTunes, Podcast NS 2.0, Atom,
/// Dublin Core, Content Module, and Podlove Simple Chapters.
final class FeedParserDelegate: NSObject, XMLParserDelegate {

    // MARK: - Public Results

    var feed = PodcastFeed(version: "2.0", namespaces: [])
    var parsingErrors: [ParserError] = []

    // MARK: - Context Stack

    var contextStack: [ParserContext] = [.root]

    var currentContext: ParserContext {
        contextStack.last ?? .root
    }

    // MARK: - Text Accumulation

    var currentText = ""
    var currentAttributes: [String: String] = [:]

    // MARK: - Channel Building

    var channelTitle: String?
    var channelLink: String?
    var channelDescription: String?
    var channelLanguage: String?
    var channelCopyright: String?
    var channelManagingEditor: String?
    var channelWebMaster: String?
    var channelPubDate: Date?
    var channelLastBuildDate: Date?
    var channelCategories: [RSSCategory] = []
    var channelGenerator: String?
    var channelDocs: URL?
    var channelCloud: RSSCloud?
    var channelTTL: Int?
    var channelRating: String?
    var channelImage: RSSImage?
    var channelTextInput: RSSTextInput?
    var channelSkipHours: Set<Int> = []
    var channelSkipDays: Set<SkipSchedule.Day> = []
    var items: [Item] = []

    // iTunes channel
    var chItunesAuthor: String?
    var chItunesBlock: Bool?
    var chItunesCategories: [ITunesCategory] = []
    var chItunesComplete: Bool?
    var chItunesExplicit: Bool?
    var chItunesImage: URL?
    var chItunesKeywords: [String] = []
    var chItunesNewFeedUrl: URL?
    var chItunesOwner: ITunesOwner?
    var chItunesSubtitle: String?
    var chItunesSummary: String?
    var chItunesTitle: String?
    var chItunesType: ITunesShowType?
    var chItunesVerify: Bool?

    // Atom channel
    var chAtomLinks: [AtomLink] = []

    // Dublin Core channel
    var chDublinCore: DublinCore?

    // Round-trip preservation
    var channelUnknownElements: [UnknownElement] = []
    var channelComments: [String] = []
    var channelCdataFields: Set<String> = []
    var currentElementUsedCDATA = false

    // Podcast NS channel
    var chPodcastGuid: PodcastGuid?
    var chLocked: Locked?
    var chFunding: [Funding] = []
    var chPersons: [PodcastPerson] = []
    var chLocations: [PodcastLocation] = []
    var chLicense: PodcastLicense?
    var chValue: PodcastValue?
    var chMedium: PodcastMedium?
    var chPodcastBlocks: [PodcastBlock] = []
    var chTxtRecords: [PodcastTxt] = []
    var chPodroll: Podroll?
    var chUpdateFrequency: UpdateFrequency?
    var chPodpingEnabled: Bool?
    var chTrailers: [Trailer] = []
    var chLiveItems: [PodcastLiveItem] = []
    var chPublisher: PodcastPublisher?
    var chPublisherRemoteItem: RemoteItem?
    var chPodcastImages: [PodcastImage] = []
    var chPodcastImagesSrcset: PodcastImages?
    var chChat: PodcastChat?

    // MARK: - Item Building

    var currentItem: Item?

    // MARK: - Nested Object Building

    var imageURL: String?
    var imageTitle: String?
    var imageLink: String?
    var imageWidth: Int?
    var imageHeight: Int?
    var imageDescription: String?

    var textInputTitle: String?
    var textInputDescription: String?
    var textInputName: String?
    var textInputLink: String?

    var ownerName: String?
    var ownerEmail: String?

    var categoryText: String?
    var subcategoryTexts: [String] = []
    var categoryNestLevel = 0

    var currentValue: PodcastValue?
    var currentTimeSplit: ValueTimeSplit?
    var timeSplitRecipients: [ValueRecipient] = []
    var timeSplitRemoteItem: RemoteItem?

    var podrollItems: [RemoteItem] = []

    var currentAltEnclosure: AlternateEnclosure?
    var altEnclosureSources: [PodcastSource] = []
    var altEnclosureIntegrity: PodcastIntegrity?

    var currentLiveItem: PodcastLiveItem?
    var liveItemAltEnclosure: AlternateEnclosure?
    var liveItemAltEncSources: [PodcastSource] = []
    var liveItemAltEncIntegrity: PodcastIntegrity?
    var liveItemValue: PodcastValue?

    var podloveVersion: String?
    var podloveChapterList: [PodloveChapter] = []

    // MARK: - Helpers

    func parseBool(_ string: String) -> Bool? {
        switch string.lowercased() {
        case "yes", "true", "1": return true
        case "no", "false", "0", "clean": return false
        default: return nil
        }
    }

    func parseDuration(_ string: String) -> Int? {
        if let seconds = Int(string) {
            return seconds
        }
        let parts = string.split(separator: ":").compactMap { Int($0) }
        if parts.count == 3 {
            return parts[0] * 3600 + parts[1] * 60 + parts[2]
        } else if parts.count == 2 {
            return parts[0] * 60 + parts[1]
        }
        return nil
    }

    func pushContext(_ context: ParserContext) {
        contextStack.append(context)
    }

    func popContext() {
        if contextStack.count > 1 {
            contextStack.removeLast()
        }
    }

    // MARK: - Attribute-Only Elements

    /// Element names handled entirely via start-element attributes.
    /// These must not be captured as unknown elements on end-element.
    static let attributeOnlyElements: Set<String> = [
        "atom:link", "cloud", "enclosure", "itunes:image",
        "podcast:transcript", "podcast:chapters", "podcast:source",
        "podcast:integrity", "podcast:remoteItem",
        "podcast:valueRecipient", "psc:chapter",
        "podcast:image", "podcast:images"
    ]

    // MARK: - XMLParserDelegate — Characters

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    // swiftlint:disable:next identifier_name
    func parser(_ parser: XMLParser, foundCDATA cdataBlock: Data) {
        if let string = String(data: cdataBlock, encoding: .utf8) {
            currentText += string
        }
        currentElementUsedCDATA = true
    }

    func parser(_ parser: XMLParser, foundComment comment: String) {
        let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        switch currentContext {
        case .channel:
            channelComments.append(trimmed)
        case .item:
            currentItem?.xmlComments.append(trimmed)
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        parseErrorOccurred parseError: Error
    ) {
        let nsError = parseError as NSError
        parsingErrors.append(.invalidXML(nsError.localizedDescription))
    }
}
