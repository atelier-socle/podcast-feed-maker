import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - SpotifyValidationTests

@Suite("Spotify Validation Tests")
struct SpotifyValidationTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func spotifyFeed(items: [Item] = []) -> PodcastFeed {
        let url = makeURL("https://example.com")
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "A podcast",
                items: items
            ))
    }

    private func mp3Item(length: Int = 1024) -> Item {
        let url = makeURL("https://example.com/ep.mp3")
        return Item(
            title: "Episode",
            enclosure: Enclosure(
                url: url,
                length: length,
                type: "audio/mpeg"
            )
        )
    }

    // MARK: - Valid Feed

    @Test("Valid Spotify feed passes")
    func validFeedPasses() {
        let feed = spotifyFeed(items: [mp3Item()])
        let report = validator.validate(feed, for: .spotify)
        #expect(report.isValid)
    }

    // MARK: - Required Fields

    @Test("Missing title is error")
    func missingTitle() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "",
            link: url,
            description: "desc",
            items: [mp3Item()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "",
            items: [mp3Item()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("No items with enclosure is error")
    func noEnclosureItems() {
        let feed = spotifyFeed(items: [])
        let report = validator.validate(feed, for: .spotify)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    // MARK: - Audio Format

    @Test("MP3 enclosure has no format warning")
    func mp3Passes() {
        let feed = spotifyFeed(items: [mp3Item()])
        let report = validator.validate(feed, for: .spotify)
        let typeWarnings = report.warnings.filter {
            $0.field.contains("enclosure.type")
        }
        #expect(typeWarnings.isEmpty)
    }

    @Test("Non-MP3 enclosure generates warning")
    func nonMp3Warning() {
        let enclosureURL = makeURL("https://example.com/ep.m4a")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/x-m4a"
            )
        )
        let feed = spotifyFeed(items: [item])
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.type"
            })
    }

    // MARK: - Size Limits

    @Test("Enclosure under 200MB has no warning")
    func normalSizePasses() {
        let feed = spotifyFeed(items: [mp3Item(length: 50_000_000)])
        let report = validator.validate(feed, for: .spotify)
        let sizeWarnings = report.warnings.filter {
            $0.field.contains("enclosure.length")
        }
        #expect(sizeWarnings.isEmpty)
    }

    @Test("Enclosure over 200MB generates warning")
    func oversizedWarning() {
        let feed = spotifyFeed(items: [mp3Item(length: 250_000_000)])
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.length"
            })
    }

    // MARK: - Description Length

    @Test("Description over 4000 bytes generates warning")
    func longDescriptionWarning() {
        let longDesc = String(repeating: "a", count: 4500)
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: longDesc,
            items: [mp3Item()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description"
                    && $0.message.contains("4000")
            })
    }

    // MARK: - Missing Channel

    @Test("Missing channel is error")
    func missingChannel() {
        let feed = PodcastFeed(channel: nil)
        let report = validator.validate(feed, for: .spotify)
        #expect(!report.isValid)
        #expect(report.errors.contains { $0.field == "channel" })
    }

    // MARK: - Missing Enclosure Per Item

    @Test("Item without enclosure is error")
    func itemMissingEnclosure() {
        let item = Item(title: "Episode")
        let feed = spotifyFeed(items: [item])
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure"
            })
    }

    // MARK: - Cross-Field Validation

    @Test("Non-MP3 large enclosure generates cross-field warning")
    func nonMp3LargeEnclosure() {
        let enclosureURL = makeURL("https://example.com/ep.m4a")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 250_000_000,
                type: "audio/x-m4a"
            )
        )
        let feed = spotifyFeed(items: [item])
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.message.contains("Non-MP3") && $0.message.contains("200 MB")
            })
    }

    @Test("Item with Podlove chapters generates info")
    func podloveChaptersInfo() {
        let chapters = PodloveChapters(chapters: [
            PodloveChapter(start: "00:00:00", title: "Intro")
        ])
        var item = mp3Item()
        item.podloveChapters = chapters
        let feed = spotifyFeed(items: [item])
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.infos.contains {
                $0.message.contains("Podlove chapters")
            })
    }
}
