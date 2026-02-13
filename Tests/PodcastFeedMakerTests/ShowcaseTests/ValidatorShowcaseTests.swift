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

// MARK: - Apple Validation Showcase

@Suite("Apple Validation Showcase")
struct AppleValidationShowcase {

    let validator = FeedValidator()

    @Test("HTTPS required for artwork URL")
    func httpsRequiredForArtwork() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesImage = URL(string: "http://cdn.example.com/artwork.jpg")
        let report = validator.validate(feed, for: .apple)
        let artworkErrors = report.errors.filter { $0.field == "channel.itunesImage" }
        #expect(artworkErrors.contains { $0.message.contains("HTTPS") })
    }

    @Test("HTTPS required for enclosure URL")
    func httpsRequiredForEnclosure() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: makeURL("http://cdn.example.com/ep1.mp3"),
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
    func itunesImageRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.itunesImage" })
    }

    @Test("itunes:category is required")
    func itunesCategoryRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesCategories = []
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("itunes:explicit is required")
    func itunesExplicitRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesExplicit = nil
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    @Test("At least one item with an enclosure is required")
    func enclosureRequired() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].enclosure = nil
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items" && $0.message.contains("enclosure")
            })
    }

    @Test("itunes:author is recommended (warning)")
    func itunesAuthorRecommended() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesAuthor = nil
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor"
            })
    }

    @Test("itunes:owner is recommended (warning)")
    func itunesOwnerRecommended() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesOwner = nil
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesOwner"
            })
    }

    @Test("Serial show without season/episode gets info")
    func serialShowCrossField() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesType = .serial
        feed.channel?.items[0].itunesSeason = nil
        feed.channel?.items[0].itunesEpisode = nil
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.infos.contains {
                $0.field == "channel.itunesType" && $0.message.contains("Serial")
            })
    }

    @Test("Fully valid feed passes Apple validation with no errors")
    func validFeedPassesApple() {
        let feed = makeAppleValidFeed()
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
    func nonMp3Warning() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: makeURL("https://cdn.example.com/ep1.m4a"),
            length: 15_000_000,
            type: "audio/m4a"
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field.contains("enclosure.type") && $0.message.contains("audio/mpeg")
            })
    }

    @Test("Enclosure exceeding 200 MB produces a warning")
    func fileSizeWarning() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: makeURL("https://cdn.example.com/ep1.mp3"),
            length: 250_000_000,
            type: "audio/mpeg"
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field.contains("enclosure.length") && $0.message.contains("200 MB")
            })
    }

    @Test("Non-MP3 enclosure over 200 MB produces combined warning")
    func nonMp3LargeFile() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].enclosure = Enclosure(
            url: makeURL("https://cdn.example.com/ep1.wav"),
            length: 250_000_000,
            type: "audio/wav"
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field.contains("enclosure") && $0.message.contains("200 MB")
                    && $0.message.contains("Spotify")
            })
    }

    @Test("Description exceeding 4000 bytes produces a warning")
    func descriptionLengthWarning() {
        var feed = makeAppleValidFeed()
        feed.channel?.description = String(repeating: "A", count: 4500)
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description" && $0.message.contains("4000")
            })
    }

    @Test("Artwork info when itunes:image is missing")
    func artworkInfo() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.infos.contains {
                $0.field == "channel.itunesImage" && $0.message.contains("1400")
            })
    }

    @Test("Podlove chapters produce an info note")
    func podloveChaptersInfo() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].podloveChapters = PodloveChapters(
            version: "1.2",
            chapters: [PodloveChapter(start: "00:00:00.000", title: "Intro")]
        )
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.infos.contains {
                $0.field.contains("podloveChapters") && $0.message.contains("chapters")
            })
    }

    @Test("Valid feed passes Spotify validation")
    func validFeedPassesSpotify() {
        let feed = makeAppleValidFeed()
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
    func requiredFields() {
        let channel = Channel(
            title: "",
            link: makeURL("https://example.com"),
            description: ""
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.title" })
        #expect(report.errors.contains { $0.field == "channel.description" })
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    @Test("Amazon recommends artwork, category, and explicit (warnings)")
    func recommendedFields() {
        var feed = makeAppleValidFeed()
        feed.channel?.itunesImage = nil
        feed.channel?.itunesCategories = []
        feed.channel?.itunesExplicit = nil
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains { $0.field == "channel.itunesImage" })
        #expect(report.warnings.contains { $0.field == "channel.itunesCategories" })
        #expect(report.warnings.contains { $0.field == "channel.itunesExplicit" })
    }

    @Test("Amazon recommends GUID per item (warning)")
    func itemGuidRecommended() {
        var feed = makeAppleValidFeed()
        feed.channel?.items[0].guid = nil
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field.contains("guid") && $0.platform == .amazon
            })
    }

    @Test("Valid feed passes Amazon validation")
    func validFeedPassesAmazon() {
        let feed = makeAppleValidFeed()
        let report = validator.validate(feed, for: .amazon)
        #expect(report.isValid)
        #expect(report.platform == .amazon)
    }
}
