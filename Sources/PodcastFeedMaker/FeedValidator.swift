import Foundation

/// A flexible feed validator that supports strict and lenient validation modes.
public struct FeedValidator: Sendable {
    
    /// Validates the structure of a podcast feed and returns issues.
    /// - Parameters:
    ///   - feed: The `Feed` instance to validate.
    ///   - platforms: List of platforms to validate against.
    /// - Returns: An array of `ValidationIssue` describing any problems.
    public static func validate(
        _ feed: Feed,
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
            case .google:
                issues += validateGoogle(feed)
            }
        }
        return issues
    }
    
    /// Validates and throws an error if any issue is found.
    @discardableResult
    public static func strictValidate(
        _ feed: Feed,
        for platforms: [PodcastPlatform] = PodcastPlatform.allCases
    ) throws -> Bool {
        let issues = validate(feed, for: platforms)
        if let _ = issues.first {
            throw ValidationError.issuesFound(issues)
        }
        return true
    }
    
    private static func validateApple(_ feed: Feed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .apple)]
        }

        let required: [(String, Bool)] = [
            ("title", channel.hasValidTag("title")),
            ("link", channel.hasValidTag("link")),
            ("description", channel.hasValidTag("description")),
            ("itunes:author", channel.hasValidTag("itunes:author")),
            ("itunes:owner", channel.hasValidTag("itunes:owner")),
            ("itunes:image", channel.hasValidTag("itunes:image")),
            ("itunes:explicit", channel.hasValidTag("itunes:explicit")),
            ("item", channel.hasValidTag("item"))
        ]

        var issues: [ValidationIssue] = []
        for (tag, isValid) in required where !isValid {
            issues.append(.init(tag: tag, message: "Required by Apple Podcasts", platform: .apple))
        }

        for (idx, item) in channel.items.enumerated() {
            if !item.hasValidTag("title") {
                issues.append(.init(tag: "item[\(idx)]/title", message: "Each <item> must contain an <title> (Apple)", platform: .apple))
            }
            if !item.hasValidTag("enclosure") {
                issues.append(.init(tag: "item[\(idx)]/enclosure", message: "Each <item> must contain an <enclosure> (Apple)", platform: .apple))
            }
            if !item.hasValidTag("guid") {
                issues.append(.init(tag: "item[\(idx)]/guid", message: "Each <item> must contain an <guid> (Apple)", platform: .apple))
            }
            if !item.hasValidTag("pubDate") {
                issues.append(.init(tag: "item[\(idx)]/pubDate", message: "Each <item> must contain an <pubDate> (Apple)", platform: .apple))
            }            
        }

        return issues
    }

    private static func validatePodcastIndex(_ feed: Feed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .podcastIndex)]
        }

        return ["podcast:guid", "atom:link"].compactMap {
            channel.hasValidTag($0) ? nil : ValidationIssue(tag: $0, message: "Required by PodcastIndex", platform: .podcastIndex)
        }
    }

    private static func validateSpotify(_ feed: Feed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .spotify)]
        }

        return ["title", "link", "description", "language", "itunes:image", "itunes:explicit"].compactMap {
            channel.hasValidTag($0) ? nil : ValidationIssue(tag: $0, message: "Required by Spotify", platform: .spotify)
        }
    }

    private static func validateAmazon(_ feed: Feed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .amazon)]
        }

        return ["title", "link", "description", "language", "itunes:owner"].compactMap {
            channel.hasValidTag($0) ? nil : ValidationIssue(tag: $0, message: "Required by Amazon", platform: .amazon)
        }
    }

    private static func validateGoogle(_ feed: Feed) -> [ValidationIssue] {
        guard let channel = feed.channel else {
            return [.init(tag: "channel", message: "Missing <channel> element", platform: .google)]
        }

        return ["title", "link", "description"].compactMap {
            channel.hasValidTag($0) ? nil : ValidationIssue(tag: $0, message: "Required by Google Podcasts", platform: .google)
        }
    }

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
        case apple, podcastIndex, spotify, amazon, google
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

private extension RSSTag.Channel {
    func hasValidTag(_ name: String) -> Bool {
        (try? self.xmlRepresentation().contains("<\(name)")) == true
    }
}

private extension RSSTag.Item {
    func hasValidTag(_ name: String) -> Bool {
        (try? self.xmlRepresentation().contains("<\(name)")) == true
    }
}
