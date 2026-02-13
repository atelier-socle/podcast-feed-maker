import Foundation

/// A template composed from other templates or modified via fluent methods.
///
/// `ComposedTemplate` is a concrete value type that conforms to ``FeedTemplate``.
/// It is created by the `+` operator or fluent builder methods like
/// ``FeedTemplate/requiring(_:)``, ``FeedTemplate/recommending(_:)``,
/// and ``FeedTemplate/targeting(_:)-(PlatformPreset)``.
///
/// ```swift
/// let networkTemplate = StandardTemplate()
///     .requiring(.podcastTranscript, .podcastPerson)
///     .targeting(.universal)
///     .named("Network Standard")
/// ```
///
/// - SeeAlso: ``FeedTemplate``
public struct ComposedTemplate: FeedTemplate, Sendable, Hashable {

    public let name: String
    public let level: ExpertiseLevel
    public let platformPreset: PlatformPreset
    public let requiredChannelTags: Set<FeedTag>
    public let recommendedChannelTags: Set<FeedTag>
    public let requiredItemTags: Set<FeedTag>
    public let recommendedItemTags: Set<FeedTag>
    public let namespaces: Set<PodcastNamespace>

    /// Creates a new composed template with explicit values.
    ///
    /// - Parameters:
    ///   - name: A short human-readable name.
    ///   - level: The expertise level.
    ///   - platformPreset: The target platforms.
    ///   - requiredChannelTags: Tags that must be present at channel level.
    ///   - recommendedChannelTags: Tags that should be present at channel level.
    ///   - requiredItemTags: Tags that must be present at item level.
    ///   - recommendedItemTags: Tags that should be present at item level.
    ///   - namespaces: The XML namespaces this template uses.
    public init(
        name: String,
        level: ExpertiseLevel,
        platformPreset: PlatformPreset,
        requiredChannelTags: Set<FeedTag>,
        recommendedChannelTags: Set<FeedTag>,
        requiredItemTags: Set<FeedTag>,
        recommendedItemTags: Set<FeedTag>,
        namespaces: Set<PodcastNamespace>
    ) {
        self.name = name
        self.level = level
        self.platformPreset = platformPreset
        self.requiredChannelTags = requiredChannelTags
        self.recommendedChannelTags = recommendedChannelTags
        self.requiredItemTags = requiredItemTags
        self.recommendedItemTags = recommendedItemTags
        self.namespaces = namespaces
    }
}

// MARK: - Merge Operator

/// Merges two templates by taking the union of all tag sets.
///
/// The resulting level is the maximum of both templates. Namespaces and
/// platforms are unioned. The name becomes "LHS + RHS".
///
/// ```swift
/// let combined = BasicTemplate() + AdvancedTemplate()
/// // combined.requiredChannelTags is the union of both
/// ```
///
/// - Parameters:
///   - lhs: The left-hand template.
///   - rhs: The right-hand template.
/// - Returns: A composed template with merged requirements.
public func + <L: FeedTemplate, R: FeedTemplate>(lhs: L, rhs: R) -> ComposedTemplate {
    let mergedPlatforms = lhs.platformPreset.platforms.union(rhs.platformPreset.platforms)
    return ComposedTemplate(
        name: "\(lhs.name) + \(rhs.name)",
        level: max(lhs.level, rhs.level),
        platformPreset: PlatformPreset.resolveNamed(mergedPlatforms),
        requiredChannelTags: lhs.requiredChannelTags.union(rhs.requiredChannelTags),
        recommendedChannelTags: lhs.recommendedChannelTags.union(rhs.recommendedChannelTags),
        requiredItemTags: lhs.requiredItemTags.union(rhs.requiredItemTags),
        recommendedItemTags: lhs.recommendedItemTags.union(rhs.recommendedItemTags),
        namespaces: lhs.namespaces.union(rhs.namespaces)
    )
}

// MARK: - PlatformPreset Reverse Resolution

extension PlatformPreset {

    /// Resolves a set of platforms to the best-matching named preset.
    ///
    /// If the set matches a known named preset, that preset is returned.
    /// Otherwise, returns `.custom(platforms)`.
    ///
    /// - Parameter platforms: The set of platforms to resolve.
    /// - Returns: The matching named preset or `.custom`.
    static func resolveNamed(_ platforms: Set<ValidationPlatform>) -> PlatformPreset {
        if platforms == Set(ValidationPlatform.allCases) { return .all }
        let universal: Set<ValidationPlatform> = [.apple, .spotify, .amazon, .podcastIndex]
        if platforms == universal { return .universal }
        let major: Set<ValidationPlatform> = [.apple, .spotify, .amazon]
        if platforms == major { return .majorPlatforms }
        let open: Set<ValidationPlatform> = [.podcastIndex, .psp1]
        if platforms == open { return .openEcosystem }
        if platforms.count == 1, let single = platforms.first {
            switch single {
            case .apple: return .apple
            case .spotify: return .spotify
            case .amazon: return .amazon
            case .podcastIndex: return .podcastIndex
            case .psp1: return .psp1
            }
        }
        return .custom(platforms)
    }
}
