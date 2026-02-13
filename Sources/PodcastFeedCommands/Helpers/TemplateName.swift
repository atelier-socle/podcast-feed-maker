import ArgumentParser
import Foundation
import PodcastFeedMaker

/// ArgumentParser option type for template selection.
///
/// Maps CLI string values to built-in feed templates.
///
/// ```
/// podcastfeed lint feed.xml --template standard
/// ```
enum TemplateName: String, ExpressibleByArgument, CaseIterable, Sendable {
    case basic
    case standard
    case advanced
    case expert

    /// Resolves this template name to a concrete ``ComposedTemplate``.
    ///
    /// If platform names are provided, they override the template's
    /// default platform preset.
    ///
    /// - Parameter platforms: Optional platform name strings from `--platforms`.
    /// - Returns: A resolved ``ComposedTemplate``.
    func resolve(platforms: [String] = []) -> ComposedTemplate {
        let base: ComposedTemplate
        switch self {
        case .basic:
            base = BasicTemplate().named("Basic")
        case .standard:
            base = StandardTemplate().named("Standard")
        case .advanced:
            base = AdvancedTemplate().named("Advanced")
        case .expert:
            base = ExpertTemplate().named("Expert")
        }
        if !platforms.isEmpty {
            let resolved = Self.parsePlatformNames(platforms)
            return base.targeting(.custom(resolved))
        }
        return base
    }

    /// Parses platform name strings into a set of ``ValidationPlatform`` values.
    ///
    /// Accepts: `"apple"`, `"spotify"`, `"amazon"`, `"podcastIndex"`,
    /// `"podcast-index"`, `"podcastindex"`, `"psp1"`, `"all"`.
    ///
    /// - Parameter names: Platform name strings.
    /// - Returns: The resolved set of platforms.
    static func parsePlatformNames(_ names: [String]) -> Set<ValidationPlatform> {
        var platforms = Set<ValidationPlatform>()
        for name in names {
            switch name.lowercased() {
            case "apple":
                platforms.insert(.apple)
            case "spotify":
                platforms.insert(.spotify)
            case "amazon":
                platforms.insert(.amazon)
            case "podcastindex", "podcast-index":
                platforms.insert(.podcastIndex)
            case "psp1":
                platforms.insert(.psp1)
            case "all":
                return Set(ValidationPlatform.allCases)
            default:
                break
            }
        }
        return platforms
    }
}
