import Foundation

/// A flexible feed validator that supports strict and lenient validation modes.
///
/// Validates a ``PodcastFeed`` against the requirements of multiple podcast platforms.
///
/// - SeeAlso: ``ValidationPlatform``, ``PodcastFeed``
public struct FeedValidator: Sendable {

    /// Validates the structure of a podcast feed and returns issues.
    ///
    /// - Parameters:
    ///   - feed: The ``PodcastFeed`` instance to validate.
    ///   - platforms: List of platforms to validate against.
    /// - Returns: An array of ``ValidationIssue`` describing any problems.
    public static func validate(
        _ feed: PodcastFeed,
        for platforms: [PodcastPlatform] = PodcastPlatform.allCases
    ) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        for platform in platforms {
            switch platform {
            case .apple:
                issues += validateApple(feed)
            case .podcastIndex:
                issues += validatePodcastIndex(feed)
            case .spotify:
                issues += validateSpotify(feed)
            case .amazon:
                issues += validateAmazon(feed)
            case .psp1:
                issues += validatePSP1(feed)
            }
        }
        return issues
    }

    /// Validates and throws an error if any issue is found.
    ///
    /// - Parameters:
    ///   - feed: The ``PodcastFeed`` instance to validate.
    ///   - platforms: List of platforms to validate against.
    /// - Returns: `true` if no issues found.
    /// - Throws: ``ValidationError/issuesFound(_:)`` if validation fails.
    @discardableResult
    public static func strictValidate(
        _ feed: PodcastFeed,
        for platforms: [PodcastPlatform] = PodcastPlatform.allCases
    ) throws -> Bool {
        let issues = validate(feed, for: platforms)
        if !issues.isEmpty {
            throw ValidationError.issuesFound(issues)
        }
        return true
    }

    // MARK: - Apple Podcasts

    private static func validateApple(_ feed: PodcastFeed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .apple)]
        }

        var issues: [ValidationIssue] = []

        let requiredChecks: [(String, Bool)] = [
            ("title", !channel.title.isEmpty),
            ("description", !channel.description.isEmpty),
            ("itunes:author", channel.itunesAuthor != nil),
            ("itunes:owner", channel.itunesOwner != nil),
            ("itunes:image", channel.itunesImage != nil),
            ("itunes:explicit", channel.itunesExplicit != nil),
            ("item", !channel.items.isEmpty)
        ]

        for (tag, isValid) in requiredChecks where !isValid {
            issues.append(.init(tag: tag, message: "Required by Apple Podcasts", platform: .apple))
        }

        for (idx, item) in channel.items.enumerated() {
            if item.title == nil {
                issues.append(.init(
                    tag: "item[\(idx)]/title",
                    message: "Each <item> must contain a <title> (Apple)",
                    platform: .apple
                ))
            }
            if item.enclosure == nil {
                issues.append(.init(
                    tag: "item[\(idx)]/enclosure",
                    message: "Each <item> must contain an <enclosure> (Apple)",
                    platform: .apple
                ))
            }
            if item.guid == nil {
                issues.append(.init(
                    tag: "item[\(idx)]/guid",
                    message: "Each <item> must contain a <guid> (Apple)",
                    platform: .apple
                ))
            }
            if item.pubDate == nil {
                issues.append(.init(
                    tag: "item[\(idx)]/pubDate",
                    message: "Each <item> must contain a <pubDate> (Apple)",
                    platform: .apple
                ))
            }
        }

        return issues
    }

    // MARK: - Podcast Index

    private static func validatePodcastIndex(_ feed: PodcastFeed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .podcastIndex)]
        }

        var issues: [ValidationIssue] = []
        if channel.podcastGuid == nil {
            issues.append(.init(tag: "podcast:guid", message: "Required by PodcastIndex", platform: .podcastIndex))
        }
        if channel.atomLinks.isEmpty {
            issues.append(.init(tag: "atom:link", message: "Required by PodcastIndex", platform: .podcastIndex))
        }
        return issues
    }

    // MARK: - Spotify

    private static func validateSpotify(_ feed: PodcastFeed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .spotify)]
        }

        let requiredChecks: [(String, Bool)] = [
            ("title", !channel.title.isEmpty),
            ("description", !channel.description.isEmpty),
            ("language", channel.language != nil),
            ("itunes:image", channel.itunesImage != nil),
            ("itunes:explicit", channel.itunesExplicit != nil)
        ]

        return requiredChecks.compactMap { tag, isValid in
            isValid ? nil : ValidationIssue(tag: tag, message: "Required by Spotify", platform: .spotify)
        }
    }

    // MARK: - Amazon Music

    private static func validateAmazon(_ feed: PodcastFeed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .amazon)]
        }

        let requiredChecks: [(String, Bool)] = [
            ("title", !channel.title.isEmpty),
            ("description", !channel.description.isEmpty),
            ("language", channel.language != nil),
            ("itunes:owner", channel.itunesOwner != nil)
        ]

        return requiredChecks.compactMap { tag, isValid in
            isValid ? nil : ValidationIssue(tag: tag, message: "Required by Amazon", platform: .amazon)
        }
    }

    // MARK: - PSP-1

    private static func validatePSP1(_ feed: PodcastFeed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .psp1)]
        }

        var issues: [ValidationIssue] = []
        if channel.podcastGuid == nil {
            issues.append(.init(tag: "podcast:guid", message: "Required by PSP-1", platform: .psp1))
        }
        if channel.locked == nil {
            issues.append(.init(tag: "podcast:locked", message: "Required by PSP-1", platform: .psp1))
        }
        if channel.atomLinks.isEmpty || !channel.atomLinks.contains(where: { $0.rel == "self" }) {
            issues.append(.init(tag: "atom:link[rel=self]", message: "Required by PSP-1", platform: .psp1))
        }
        return issues
    }

    // MARK: - Error Types

    /// Errors thrown by strict validation.
    public enum ValidationError: Swift.Error, LocalizedError, Equatable, Sendable {
        case issuesFound([ValidationIssue])

        public var errorDescription: String? {
            switch self {
            case let .issuesFound(issues):
                issues.map { "- [\($0.platform.rawValue)] \($0.tag): \($0.message)" }.joined(separator: "\n")
            }
        }
    }

    /// Supported podcast validation platforms.
    public enum PodcastPlatform: String, CaseIterable, Sendable {
        case apple
        case podcastIndex
        case spotify
        case amazon
        case psp1
    }

    /// Describes a validation issue found in a feed.
    public struct ValidationIssue: Hashable, Equatable, Sendable {
        public let tag: String
        public let message: String
        public let platform: PodcastPlatform

        public init(tag: String, message: String, platform: PodcastPlatform) {
            self.tag = tag
            self.message = message
            self.platform = platform
        }
    }
}
