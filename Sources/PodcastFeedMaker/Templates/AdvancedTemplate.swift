import Foundation

/// An advanced feed template with Podcast Namespace 2.0 phases 1-3.
///
/// Builds on ``StandardTemplate`` by adding rich metadata: transcripts,
/// chapters, soundbites, persons, locations, licenses, alternate enclosures,
/// and `content:encoded`.
///
/// **Namespaces**: itunes, atom, podcast, content
///
/// - SeeAlso: ``FeedTemplate``, ``ExpertiseLevel/advanced``
public struct AdvancedTemplate: FeedTemplate, Sendable, Hashable {

    public init() {}

    public let level: ExpertiseLevel = .advanced
    public let name: String = "Advanced"

    public let requiredChannelTags: Set<FeedTag> = [
        // RSS 2.0 core
        .title, .link, .description,
        // iTunes
        .itunesCategory, .itunesExplicit, .itunesImage,
        .itunesAuthor, .itunesOwner,
        // Atom
        .atomLink,
        // Podcast NS 2.0 (Standard required + medium)
        .podcastLocked, .podcastGuid, .podcastMedium,
        // RSS optional
        .language
    ]

    public let recommendedChannelTags: Set<FeedTag> = [
        .copyright, .pubDate, .itunesType,
        .podcastFunding, .podcastPerson, .podcastLocation,
        .podcastLicense, .podcastPublisher, .podcastTrailer
    ]

    public let requiredItemTags: Set<FeedTag> = [
        .itemTitle, .itemEnclosure, .itemGuid,
        .itemPubDate, .itunesDuration, .itunesExplicit
    ]

    public let recommendedItemTags: Set<FeedTag> = [
        .itemDescription,
        .itunesEpisode, .itunesSeason, .itunesEpisodeType,
        .podcastTranscript, .podcastChapters, .podcastSoundbite,
        .podcastPerson, .contentEncoded, .podcastAlternateEnclosure
    ]

    public let namespaces: Set<PodcastNamespace> = [.itunes, .atom, .podcast, .content]

    public let platformPreset: PlatformPreset = .all

    /// All tags used by this template (required + recommended, both scopes).
    public static let allTags: Set<FeedTag> = {
        let template = AdvancedTemplate()
        return template.allTags
    }()
}
