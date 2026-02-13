import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Test Helpers

/// Builds a minimal Apple-valid feed for use as a starting point.
private func makeAppleValidFeed() -> PodcastFeed {
    let enclosure = Enclosure(
        url: makeURL("https://cdn.example.com/ep1.mp3"),
        length: 12_345_678,
        type: "audio/mpeg"
    )
    let item = Item(
        title: "Pilot Episode",
        description: "The very first episode.",
        enclosure: enclosure,
        guid: GUID(value: "ep-001", isPermaLink: false),
        pubDate: Date(timeIntervalSince1970: 1_700_000_000),
        itunesDuration: 1800,
        itunesEpisodeType: .full,
        itunesExplicit: false,
        itunesImage: URL(string: "https://cdn.example.com/ep1.jpg")
    )
    let channel = Channel(
        title: "Showcase Podcast",
        link: makeURL("https://example.com"),
        description: "A podcast about showcasing validation.",
        language: "en-us",
        items: [item],
        itunesAuthor: "Jane Doe",
        itunesCategories: [.technology],
        itunesExplicit: false,
        itunesImage: URL(string: "https://cdn.example.com/artwork.jpg"),
        itunesOwner: ITunesOwner(name: "Jane Doe", email: "jane@example.com"),
        itunesType: .episodic,
        atomLinks: [.selfLink(href: makeURL("https://example.com/feed.xml"))],
        podcastGuid: PodcastGuid(value: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"),
        locked: Locked(isLocked: true, owner: "jane@example.com"),
        funding: [Funding(url: makeURL("https://example.com/donate"), message: "Support us")]
    )
    return PodcastFeed(channel: channel)
}

// MARK: - Podcast Index Validation Showcase

@Suite("Podcast Index Validation Showcase")
struct PodcastIndexValidationShowcase {

    let validator = FeedValidator()

    @Test("podcast:locked is recommended (warning)")
    func lockedRecommended() {
        var feed = makeAppleValidFeed()
        feed.channel?.locked = nil
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.locked" && $0.platform == .podcastIndex
            })
    }

    @Test("podcast:guid is recommended (warning)")
    func guidRecommended() {
        var feed = makeAppleValidFeed()
        feed.channel?.podcastGuid = nil
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.podcastGuid" && $0.platform == .podcastIndex
            })
    }

    @Test("podcast:funding is encouraged (warning)")
    func fundingEncouraged() {
        var feed = makeAppleValidFeed()
        feed.channel?.funding = []
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.funding" && $0.platform == .podcastIndex
            })
    }

    @Test("podcast:value encourages V4V (info when absent)")
    func valueEncouraged() {
        var feed = makeAppleValidFeed()
        feed.channel?.value = nil
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.infos.contains {
                $0.field == "channel.value" && $0.message.contains("V4V")
            })
    }

    @Test("Valid fully-tagged feed passes Podcast Index")
    func validFeedPasses() {
        let feed = makeAppleValidFeed()
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.isValid)
        #expect(report.platform == .podcastIndex)
    }
}

// MARK: - PSP-1 Validation Showcase

@Suite("PSP-1 Validation Showcase")
struct PSP1ValidationShowcase {

    let validator = FeedValidator()

    @Test("Language is required (error when missing)")
    func languageRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.language = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.language" && $0.platform == .psp1
            })
    }

    @Test("atom:link with rel=self is required (error when missing)")
    func atomLinkSelfRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.atomLinks = []
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.atomLinks" && $0.platform == .psp1
            })
    }

    @Test("podcast:locked is required (error when missing)")
    func lockedRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.locked = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.locked" && $0.platform == .psp1
            })
    }

    @Test("podcast:guid is required (error when missing)")
    func podcastGuidRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.podcastGuid = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.podcastGuid" && $0.platform == .psp1
            })
    }

    @Test("Item GUID is required (error when missing)")
    func itemGuidRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].guid = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field.contains("guid") && $0.platform == .psp1
            })
    }

    @Test("Leading or trailing whitespace produces warning")
    func whitespaceWarning() {
        var feed = makeAppleValidFeed()
        feed.channel?.title = "  Showcase Podcast  "
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("whitespace")
            })
    }

    @Test("Title exceeding 255 characters produces warning")
    func titleLengthWarning() {
        var feed = makeAppleValidFeed()
        feed.channel?.title = String(repeating: "X", count: 300)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("255")
            })
    }

    @Test("Valid PSP-1 feed passes with no errors")
    func validPSP1Feed() {
        let feed = makeAppleValidFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(report.isValid)
        #expect(report.errors.isEmpty)
        #expect(report.platform == .psp1)
    }
}

// MARK: - Cross-Platform Validation Showcase

@Suite("Cross-Platform Validation Showcase")
struct CrossPlatformValidationShowcase {

    let validator = FeedValidator()

    @Test("Single platform validation returns one report")
    func singlePlatform() {
        let feed = makeAppleValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.platform == .apple)
    }

    @Test("Multi-platform validation returns one report per platform")
    func multiPlatform() {
        let feed = makeAppleValidFeed()
        let reports = validator.validate(feed, for: [.apple, .spotify, .amazon])
        #expect(reports.count == 3)
        let platforms = Set(reports.map(\.platform))
        #expect(platforms == [.apple, .spotify, .amazon])
    }

    @Test("validateAll returns reports for all 5 platforms")
    func allPlatforms() {
        let feed = makeAppleValidFeed()
        let reports = validator.validateAll(feed)
        #expect(reports.count == ValidationPlatform.allCases.count)
        let platforms = Set(reports.map(\.platform))
        #expect(platforms == Set(ValidationPlatform.allCases))
    }

    @Test("Severity levels are ordered: error > warning > info")
    func severityOrdering() {
        #expect(ValidationSeverity.error > .warning)
        #expect(ValidationSeverity.warning > .info)
        #expect(ValidationSeverity.error > .info)
        #expect(ValidationSeverity.info < .warning)
    }

    @Test("ValidationResult contains severity, message, field, and platform")
    func resultFields() {
        let result = ValidationResult(
            severity: .error,
            message: "Channel title is required",
            field: "channel.title",
            platform: .apple
        )
        #expect(result.severity == .error)
        #expect(result.message == "Channel title is required")
        #expect(result.field == "channel.title")
        #expect(result.platform == .apple)
    }

    @Test("Cross-cutting checks detect duplicate GUIDs")
    func duplicateGuidDetection() {
        var feed = makeAppleValidFeed()
        let duplicate = Item(
            title: "Episode 2",
            enclosure: Enclosure(
                url: makeURL("https://cdn.example.com/ep2.mp3"),
                length: 10_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-001", isPermaLink: false)
        )
        feed.channel?.items.append(duplicate)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.message.contains("Duplicate GUID") && $0.platform == nil
            })
    }

    @Test("Cross-cutting checks detect GUID/isPermaLink inconsistency")
    func guidPermaLinkInconsistency() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].guid = GUID(
            value: "not-a-url-just-an-id",
            isPermaLink: true
        )
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.message.contains("isPermaLink") && $0.platform == nil
            })
    }

    @Test("Cross-cutting checks note missing atom:link self")
    func atomSelfLinkInfo() {
        var feed = makeAppleValidFeed()
        feed.channel?.atomLinks = []
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.infos.contains {
                $0.field == "channel.atomLinks" && $0.message.contains("atom:link")
            })
    }

    @Test("Cross-cutting checks note itunes:complete true")
    func itunesCompleteInfo() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesComplete = true
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.infos.contains {
                $0.field == "channel.itunesComplete" && $0.message.contains("complete")
            })
    }

    @Test("Cross-cutting checks warn on new-feed-url without HTTPS")
    func newFeedUrlSchemeWarning() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesNewFeedUrl = URL(string: "http://example.com/new-feed.xml")
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesNewFeedUrl" && $0.message.contains("HTTPS")
            })
    }

    @Test("ValidationReport convenience properties filter correctly")
    func reportConvenienceProperties() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        feed.channel?.itunesAuthor = nil
        let report = validator.validate(feed, for: .apple)
        #expect(!report.errors.isEmpty)
        #expect(!report.warnings.isEmpty)
        #expect(!report.isValid)
        let allSeverities = Set(report.results.map(\.severity))
        #expect(allSeverities.isSubset(of: [.error, .warning, .info]))
    }
}
