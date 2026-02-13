import Foundation

/// A template defining the expected tags and namespaces for a podcast feed.
///
/// Templates describe which ``FeedTag`` values are required or recommended
/// at both channel and item levels, which ``PodcastNamespace`` values must
/// be declared, and which ``ValidationPlatform`` platforms the feed targets.
///
/// Four built-in templates are available via static accessors:
/// ``basic``, ``standard``, ``advanced``, and ``expert``.
///
/// - SeeAlso: ``TemplateValidator``, ``ExpertiseLevel``
public protocol FeedTemplate: Sendable {

    /// The expertise level this template represents.
    var level: ExpertiseLevel { get }

    /// A short human-readable name for the template.
    var name: String { get }

    /// Tags that must be present at the channel level.
    var requiredChannelTags: Set<FeedTag> { get }

    /// Tags that should be present at the channel level for best results.
    var recommendedChannelTags: Set<FeedTag> { get }

    /// Tags that must be present at the item level.
    var requiredItemTags: Set<FeedTag> { get }

    /// Tags that should be present at the item level for best results.
    var recommendedItemTags: Set<FeedTag> { get }

    /// The XML namespaces this template uses.
    var namespaces: Set<PodcastNamespace> { get }

    /// The platform preset this template targets.
    var platformPreset: PlatformPreset { get }
}

// MARK: - Static Accessors

extension FeedTemplate where Self == BasicTemplate {

    /// A basic template for minimal iTunes feeds (Apple + Spotify).
    public static var basic: BasicTemplate { BasicTemplate() }
}

extension FeedTemplate where Self == StandardTemplate {

    /// A standard template for PSP-1 compliant feeds.
    public static var standard: StandardTemplate { StandardTemplate() }
}

extension FeedTemplate where Self == AdvancedTemplate {

    /// An advanced template with Podcast NS 2.0 phases 1-3.
    public static var advanced: AdvancedTemplate { AdvancedTemplate() }
}

extension FeedTemplate where Self == ExpertTemplate {

    /// An expert template with full 7-namespace coverage.
    public static var expert: ExpertTemplate { ExpertTemplate() }
}

// MARK: - Convenience

extension FeedTemplate {

    /// All tags (required + recommended) at both channel and item levels.
    public var allTags: Set<FeedTag> {
        requiredChannelTags
            .union(recommendedChannelTags)
            .union(requiredItemTags)
            .union(recommendedItemTags)
    }
}
