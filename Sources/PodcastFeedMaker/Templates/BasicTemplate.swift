import Foundation

/// A minimal feed template targeting Apple Podcasts and Spotify.
///
/// Requires only RSS 2.0 core fields and essential iTunes tags.
/// This is the minimum viable podcast feed for major platforms.
///
/// **Namespaces**: itunes, atom
///
/// - SeeAlso: ``FeedTemplate``, ``ExpertiseLevel/basic``
public struct BasicTemplate: FeedTemplate, Sendable, Hashable {

    public init() {}

    public let level: ExpertiseLevel = .basic
    public let name: String = "Basic"

    public let requiredChannelTags: Set<FeedTag> = [
        .title, .link, .description,
        .itunesCategory, .itunesExplicit, .itunesImage
    ]

    public let recommendedChannelTags: Set<FeedTag> = [
        .language, .itunesAuthor, .itunesType
    ]

    public let requiredItemTags: Set<FeedTag> = [
        .itemTitle, .itemEnclosure
    ]

    public let recommendedItemTags: Set<FeedTag> = [
        .itemDescription, .itemGuid, .itemPubDate,
        .itunesDuration, .itunesExplicit
    ]

    public let namespaces: Set<PodcastNamespace> = [.itunes, .atom]

    public let platformPreset: PlatformPreset = .majorPlatforms

    /// All tags used by this template (required + recommended, both scopes).
    public static let allTags: Set<FeedTag> = {
        let template = BasicTemplate()
        return template.allTags
    }()
}
