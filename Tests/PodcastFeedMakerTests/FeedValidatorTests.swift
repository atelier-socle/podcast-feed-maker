import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - FeedValidatorTests

@Suite("FeedValidator Tests")
struct FeedValidatorTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func minimalValidFeed() -> PodcastFeed {
        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep1.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 300,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/ep1.jpg")!
        )
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            language: "en",
            items: [item],
            itunesAuthor: "Host Name",
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!,
            itunesOwner: ITunesOwner(name: "Host", email: "host@example.com"),
            itunesType: .episodic,
            atomLinks: [.selfLink(href: URL(string: "https://example.com/feed.xml")!)],
            podcastGuid: PodcastGuid(value: "abc-123"),
            locked: Locked(isLocked: false)
        )
        return PodcastFeed(channel: channel)
    }

    private func emptyFeed() -> PodcastFeed {
        PodcastFeed(channel: nil)
    }

    private func minimalChannelFeed() -> PodcastFeed {
        PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc"
        ))
    }

    // MARK: - Fully Compliant Feed

    @Test("Fully compliant feed passes all platforms")
    func fullyCompliantFeedPassesAll() {
        let feed = minimalValidFeed()
        let reports = validator.validateAll(feed)
        for report in reports {
            #expect(
                report.isValid,
                "Feed should be valid for \(report.platform)"
            )
        }
    }

    // MARK: - Empty Feed (No Channel)

    @Test("Empty feed generates errors for all platforms")
    func emptyFeedErrors() {
        let feed = emptyFeed()
        let reports = validator.validateAll(feed)
        for report in reports {
            #expect(!report.isValid)
            #expect(report.errors.contains { $0.field == "channel" })
        }
    }

    // MARK: - Single Platform

    @Test("Validate against single platform returns one report")
    func singlePlatformReport() {
        let feed = minimalValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.platform == .apple)
    }

    // MARK: - Multiple Platforms

    @Test("Validate against multiple platforms returns correct count")
    func multiplePlatformReports() {
        let feed = minimalValidFeed()
        let reports = validator.validate(
            feed, for: [.apple, .spotify, .psp1]
        )
        #expect(reports.count == 3)
        #expect(reports[0].platform == .apple)
        #expect(reports[1].platform == .spotify)
        #expect(reports[2].platform == .psp1)
    }

    // MARK: - ValidateAll

    @Test("validateAll returns reports for all 5 platforms")
    func validateAllReturns5Reports() {
        let feed = minimalValidFeed()
        let reports = validator.validateAll(feed)
        #expect(reports.count == 5)
        let platforms = Set(reports.map(\.platform))
        #expect(platforms.count == 5)
    }

    // MARK: - Apple Specific

    @Test("Missing itunes:image is error for Apple")
    func missingItunesImageApple() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.itunesImage" })
    }

    @Test("Missing itunes:category is error for Apple")
    func missingItunesCategoryApple() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains {
            $0.field == "channel.itunesCategories"
        })
    }

    @Test("Missing itunes:explicit is error for Apple")
    func missingItunesExplicitApple() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains {
            $0.field == "channel.itunesExplicit"
        })
    }

    @Test("Feed with no items is error for Apple")
    func noItemsApple() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    @Test("HTTP enclosure URL is error for Apple")
    func httpEnclosureApple() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "http://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [item],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains {
            $0.field == "channel.items[0].enclosure.url"
        })
    }

    // MARK: - PSP-1 Specific

    @Test("Missing atom:link rel=self is error for PSP-1")
    func missingAtomLinkSelfPSP1() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field == "channel.atomLinks"
        })
    }

    @Test("Missing podcast:locked is error for PSP-1")
    func missingLockedPSP1() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.locked" })
    }

    @Test("Missing podcast:guid is error for PSP-1")
    func missingGuidPSP1() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains {
            $0.field == "channel.podcastGuid"
        })
    }

    // MARK: - Spotify Specific

    @Test("MP3 enclosure has no format warning for Spotify")
    func mp3NoWarningSpotify() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        let typeWarnings = report.warnings.filter {
            $0.field.contains("enclosure.type")
        }
        #expect(typeWarnings.isEmpty)
    }

    @Test("M4A enclosure generates warning for Spotify")
    func m4aWarningSpotify() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.m4a")!,
                length: 1024,
                type: "audio/x-m4a"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(report.warnings.contains {
            $0.field == "channel.items[0].enclosure.type"
        })
    }

    @Test("Oversized enclosure generates warning for Spotify")
    func oversizedEnclosureSpotify() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 250_000_000,
                type: "audio/mpeg"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(report.warnings.contains {
            $0.field == "channel.items[0].enclosure.length"
        })
    }

    // MARK: - Podcast Index Specific

    @Test("podcast:value without recipients is warning for Podcast Index")
    func valueWithoutRecipients() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            value: PodcastValue(type: "lightning", method: "keysend")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.warnings.contains {
            $0.field == "channel.value.recipients"
        })
    }

    // MARK: - Cross-Cutting

    @Test("Duplicate GUIDs generate warning")
    func duplicateGuids() {
        let items = [
            Item(
                title: "Ep 1",
                guid: GUID(value: "same-guid", isPermaLink: false)
            ),
            Item(
                title: "Ep 2",
                guid: GUID(value: "same-guid", isPermaLink: false)
            ),
        ]
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: items
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.warnings.contains {
            $0.field == "channel.items[1].guid"
                && $0.message.contains("Duplicate")
        })
    }

    // MARK: - Report Structure

    @Test("Results are sorted by severity (errors first)")
    func resultsSortedBySeverity() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .apple)
        guard report.results.count >= 2 else { return }
        for i in 0..<(report.results.count - 1) {
            #expect(
                report.results[i].severity >= report.results[i + 1].severity
            )
        }
    }

    @Test("isValid is true when no errors")
    func isValidNoErrors() {
        let feed = minimalValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.isValid)
    }

    @Test("isValid is false when errors present")
    func isValidFalseWithErrors() {
        let feed = emptyFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(!report.isValid)
    }
}
