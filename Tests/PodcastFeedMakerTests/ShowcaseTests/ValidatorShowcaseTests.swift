import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Test Helpers

/// Builds a minimal Apple-valid feed for use as a starting point.
private func makeAppleValidFeed() throws -> PodcastFeed {
    let enclosure = Enclosure(
        url: try #require(URL(string: "https://cdn.example.com/ep1.mp3")),
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
        link: try #require(URL(string: "https://example.com")),
        description: "A podcast about showcasing validation.",
        language: "en-us",
        items: [item],
        itunesAuthor: "Jane Doe",
        itunesCategories: [.technology],
        itunesExplicit: false,
        itunesImage: URL(string: "https://cdn.example.com/artwork.jpg"),
        itunesOwner: ITunesOwner(name: "Jane Doe", email: "jane@example.com"),
        itunesType: .episodic,
        atomLinks: [.selfLink(href: try #require(URL(string: "https://example.com/feed.xml")))],
        podcastGuid: PodcastGuid(value: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"),
        locked: Locked(isLocked: true, owner: "jane@example.com"),
        funding: [Funding(url: try #require(URL(string: "https://example.com/donate")), message: "Support us")]
    )
    return PodcastFeed(channel: channel)
}

// MARK: - Apple Validation Showcase

@Suite("Apple Validation Showcase")
struct AppleValidationShowcase {

    let validator = FeedValidator()

    @Test("HTTPS required for artwork URL")
    func httpsRequiredForArtwork() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesImage = URL(string: "http://cdn.example.com/artwork.jpg")
        let report = validator.validate(feed, for: .apple)
        let artworkErrors = report.errors.filter { $0.field == "channel.itunesImage" }
        #expect(artworkErrors.contains { $0.message.contains("HTTPS") })
    }

    @Test("HTTPS required for enclosure URL")
    func httpsRequiredForEnclosure() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: try #require(URL(string: "http://cdn.example.com/ep1.mp3")),
            length: 12_345_678,
            type: "audio/mpeg"
        )
        let report = validator.validate(feed, for: .apple)
        let enclosureErrors = report.errors.filter {
            $0.field.contains("enclosure.url")
        }
        #expect(enclosureErrors.contains { $0.message.contains("HTTPS") })
    }

    @Test("itunes:image is required at channel level")
    func itunesImageRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.itunesImage" })
    }

    @Test("itunes:category is required")
    func itunesCategoryRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesCategories = []
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains {
            $0.field == "channel.itunesCategories"
        })
    }

    @Test("itunes:explicit is required")
    func itunesExplicitRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesExplicit = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains {
            $0.field == "channel.itunesExplicit"
        })
    }

    @Test("At least one item with an enclosure is required")
    func enclosureRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].enclosure = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains {
            $0.field == "channel.items" && $0.message.contains("enclosure")
        })
    }

    @Test("itunes:author is recommended (warning)")
    func itunesAuthorRecommended() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesAuthor = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.warnings.contains {
            $0.field == "channel.itunesAuthor"
        })
    }

    @Test("itunes:owner is recommended (warning)")
    func itunesOwnerRecommended() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesOwner = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.warnings.contains {
            $0.field == "channel.itunesOwner"
        })
    }

    @Test("Serial show without season/episode gets info")
    func serialShowCrossField() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesType = .serial
        feed.channel?.items[0].itunesSeason = nil
        feed.channel?.items[0].itunesEpisode = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.infos.contains {
            $0.field == "channel.itunesType" && $0.message.contains("Serial")
        })
    }

    @Test("Fully valid feed passes Apple validation with no errors")
    func validFeedPassesApple() throws {
        let feed = try makeAppleValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.isValid)
        #expect(report.errors.isEmpty)
        #expect(report.platform == .apple)
    }
}

// MARK: - Spotify Validation Showcase

@Suite("Spotify Validation Showcase")
struct SpotifyValidationShowcase {

    let validator = FeedValidator()

    @Test("Non-MP3 enclosure produces a warning")
    func nonMp3Warning() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: try #require(URL(string: "https://cdn.example.com/ep1.m4a")),
            length: 15_000_000,
            type: "audio/m4a"
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(report.warnings.contains {
            $0.field.contains("enclosure.type") && $0.message.contains("audio/mpeg")
        })
    }

    @Test("Enclosure exceeding 200 MB produces a warning")
    func fileSizeWarning() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: try #require(URL(string: "https://cdn.example.com/ep1.mp3")),
            length: 250_000_000,
            type: "audio/mpeg"
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(report.warnings.contains {
            $0.field.contains("enclosure.length") && $0.message.contains("200 MB")
        })
    }

    @Test("Non-MP3 enclosure over 200 MB produces combined warning")
    func nonMp3LargeFile() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: try #require(URL(string: "https://cdn.example.com/ep1.wav")),
            length: 250_000_000,
            type: "audio/wav"
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(report.warnings.contains {
            $0.field.contains("enclosure") && $0.message.contains("200 MB")
                && $0.message.contains("Spotify")
        })
    }

    @Test("Description exceeding 4000 bytes produces a warning")
    func descriptionLengthWarning() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.description = String(repeating: "A", count: 4500)
        let report = validator.validate(feed, for: .spotify)
        #expect(report.warnings.contains {
            $0.field == "channel.description" && $0.message.contains("4000")
        })
    }

    @Test("Artwork info when itunes:image is missing")
    func artworkInfo() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        let report = validator.validate(feed, for: .spotify)
        #expect(report.infos.contains {
            $0.field == "channel.itunesImage" && $0.message.contains("1400")
        })
    }

    @Test("Podlove chapters produce an info note")
    func podloveChaptersInfo() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].podloveChapters = PodloveChapters(
            version: "1.2",
            chapters: [PodloveChapter(start: "00:00:00.000", title: "Intro")]
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(report.infos.contains {
            $0.field.contains("podloveChapters") && $0.message.contains("chapters")
        })
    }

    @Test("Valid feed passes Spotify validation")
    func validFeedPassesSpotify() throws {
        let feed = try makeAppleValidFeed()
        let report = validator.validate(feed, for: .spotify)
        #expect(report.isValid)
        #expect(report.platform == .spotify)
    }
}

// MARK: - Amazon Validation Showcase

@Suite("Amazon Validation Showcase")
struct AmazonValidationShowcase {

    let validator = FeedValidator()

    @Test("Amazon requires title, description, and enclosure")
    func requiredFields() throws {
        let channel = Channel(
            title: "",
            link: try #require(URL(string: "https://example.com")),
            description: ""
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.title" })
        #expect(report.errors.contains { $0.field == "channel.description" })
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    @Test("Amazon recommends artwork, category, and explicit (warnings)")
    func recommendedFields() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        feed.channel?.itunesCategories = []
        feed.channel?.itunesExplicit = nil
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains { $0.field == "channel.itunesImage" })
        #expect(report.warnings.contains { $0.field == "channel.itunesCategories" })
        #expect(report.warnings.contains { $0.field == "channel.itunesExplicit" })
    }

    @Test("Amazon recommends GUID per item (warning)")
    func itemGuidRecommended() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].guid = nil
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains {
            $0.field.contains("guid") && $0.platform == .amazon
        })
    }

    @Test("Valid feed passes Amazon validation")
    func validFeedPassesAmazon() throws {
        let feed = try makeAppleValidFeed()
        let report = validator.validate(feed, for: .amazon)
        #expect(report.isValid)
        #expect(report.platform == .amazon)
    }
}

// MARK: - Podcast Index Validation Showcase

@Suite("Podcast Index Validation Showcase")
struct PodcastIndexValidationShowcase {

    let validator = FeedValidator()

    @Test("podcast:locked is recommended (warning)")
    func lockedRecommended() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.locked = nil
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.warnings.contains {
            $0.field == "channel.locked" && $0.platform == .podcastIndex
        })
    }

    @Test("podcast:guid is recommended (warning)")
    func guidRecommended() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.podcastGuid = nil
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.warnings.contains {
            $0.field == "channel.podcastGuid" && $0.platform == .podcastIndex
        })
    }

    @Test("podcast:funding is encouraged (warning)")
    func fundingEncouraged() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.funding = []
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.warnings.contains {
            $0.field == "channel.funding" && $0.platform == .podcastIndex
        })
    }

    @Test("podcast:value encourages V4V (info when absent)")
    func valueEncouraged() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.value = nil
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.infos.contains {
            $0.field == "channel.value" && $0.message.contains("V4V")
        })
    }

    @Test("Valid fully-tagged feed passes Podcast Index")
    func validFeedPasses() throws {
        let feed = try makeAppleValidFeed()
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
    func languageRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.language = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field == "channel.language" && $0.platform == .psp1
        })
    }

    @Test("atom:link with rel=self is required (error when missing)")
    func atomLinkSelfRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.atomLinks = []
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field == "channel.atomLinks" && $0.platform == .psp1
        })
    }

    @Test("podcast:locked is required (error when missing)")
    func lockedRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.locked = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field == "channel.locked" && $0.platform == .psp1
        })
    }

    @Test("podcast:guid is required (error when missing)")
    func podcastGuidRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.podcastGuid = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field == "channel.podcastGuid" && $0.platform == .psp1
        })
    }

    @Test("Item GUID is required (error when missing)")
    func itemGuidRequired() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].guid = nil
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field.contains("guid") && $0.platform == .psp1
        })
    }

    @Test("Leading or trailing whitespace produces warning")
    func whitespaceWarning() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.title = "  Showcase Podcast  "
        let report = validator.validate(feed, for: .psp1)
        #expect(report.warnings.contains {
            $0.field == "channel.title" && $0.message.contains("whitespace")
        })
    }

    @Test("Title exceeding 255 characters produces warning")
    func titleLengthWarning() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.title = String(repeating: "X", count: 300)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.warnings.contains {
            $0.field == "channel.title" && $0.message.contains("255")
        })
    }

    @Test("Valid PSP-1 feed passes with no errors")
    func validPSP1Feed() throws {
        let feed = try makeAppleValidFeed()
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
    func singlePlatform() throws {
        let feed = try makeAppleValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.platform == .apple)
    }

    @Test("Multi-platform validation returns one report per platform")
    func multiPlatform() throws {
        let feed = try makeAppleValidFeed()
        let reports = validator.validate(feed, for: [.apple, .spotify, .amazon])
        #expect(reports.count == 3)
        let platforms = Set(reports.map(\.platform))
        #expect(platforms == [.apple, .spotify, .amazon])
    }

    @Test("validateAll returns reports for all 5 platforms")
    func allPlatforms() throws {
        let feed = try makeAppleValidFeed()
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
    func duplicateGuidDetection() throws {
        var feed = try makeAppleValidFeed()
        let duplicate = Item(
            title: "Episode 2",
            enclosure: Enclosure(
                url: try #require(URL(string: "https://cdn.example.com/ep2.mp3")),
                length: 10_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-001", isPermaLink: false)
        )
        feed.channel?.items.append(duplicate)
        let report = validator.validate(feed, for: .apple)
        #expect(report.warnings.contains {
            $0.message.contains("Duplicate GUID") && $0.platform == nil
        })
    }

    @Test("Cross-cutting checks detect GUID/isPermaLink inconsistency")
    func guidPermaLinkInconsistency() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.items[0].guid = GUID(
            value: "not-a-url-just-an-id",
            isPermaLink: true
        )
        let report = validator.validate(feed, for: .apple)
        #expect(report.warnings.contains {
            $0.message.contains("isPermaLink") && $0.platform == nil
        })
    }

    @Test("Cross-cutting checks note missing atom:link self")
    func atomSelfLinkInfo() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.atomLinks = []
        let report = validator.validate(feed, for: .amazon)
        #expect(report.infos.contains {
            $0.field == "channel.atomLinks" && $0.message.contains("atom:link")
        })
    }

    @Test("Cross-cutting checks note itunes:complete true")
    func itunesCompleteInfo() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesComplete = true
        let report = validator.validate(feed, for: .apple)
        #expect(report.infos.contains {
            $0.field == "channel.itunesComplete" && $0.message.contains("complete")
        })
    }

    @Test("Cross-cutting checks warn on new-feed-url without HTTPS")
    func newFeedUrlSchemeWarning() throws {
        var feed = try makeAppleValidFeed()
        feed.channel?.itunesNewFeedUrl = URL(string: "http://example.com/new-feed.xml")
        let report = validator.validate(feed, for: .apple)
        #expect(report.warnings.contains {
            $0.field == "channel.itunesNewFeedUrl" && $0.message.contains("HTTPS")
        })
    }

    @Test("ValidationReport convenience properties filter correctly")
    func reportConvenienceProperties() throws {
        var feed = try makeAppleValidFeed()
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
