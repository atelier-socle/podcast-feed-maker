import Foundation

/// Named combinations of ``ValidationPlatform`` for common validation scenarios.
///
/// Use presets to validate a feed against typical platform combinations
/// without manually assembling sets of ``ValidationPlatform`` values.
///
/// - SeeAlso: ``FeedTemplate/platformPreset``
public enum PlatformPreset: Sendable, Hashable {

    /// Apple Podcasts only.
    case apple

    /// Spotify only.
    case spotify

    /// Amazon Music only.
    case amazon

    /// Podcast Index only.
    case podcastIndex

    /// PSP-1 compliance only.
    case psp1

    /// All major commercial platforms: Apple + Spotify + Amazon.
    case majorPlatforms

    /// Open ecosystem: Podcast Index + PSP-1.
    case openEcosystem

    /// All major platforms + open ecosystem (Apple + Spotify + Amazon + Podcast Index).
    case universal

    /// All 5 platforms.
    case all

    /// A custom set of validation platforms.
    case custom(Set<ValidationPlatform>)

    /// The set of ``ValidationPlatform`` values this preset represents.
    public var platforms: Set<ValidationPlatform> {
        switch self {
        case .apple:
            [.apple]
        case .spotify:
            [.spotify]
        case .amazon:
            [.amazon]
        case .podcastIndex:
            [.podcastIndex]
        case .psp1:
            [.psp1]
        case .majorPlatforms:
            [.apple, .spotify, .amazon]
        case .openEcosystem:
            [.podcastIndex, .psp1]
        case .universal:
            [.apple, .spotify, .amazon, .podcastIndex]
        case .all:
            Set(ValidationPlatform.allCases)
        case .custom(let platforms):
            platforms
        }
    }
}
