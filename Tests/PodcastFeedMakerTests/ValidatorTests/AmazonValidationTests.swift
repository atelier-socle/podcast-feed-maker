import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - AmazonValidationTests

@Suite("Amazon Validation Tests")
struct AmazonValidationTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func amazonFeed(items: [Item] = []) -> PodcastFeed {
        PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "A podcast",
            items: items,
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        ))
    }

    private func validItem() -> Item {
        Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
    }

    // MARK: - Valid Feed

    @Test("Valid Amazon feed passes")
    func validFeedPasses() {
        let feed = amazonFeed(items: [validItem()])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.isValid)
    }

    // MARK: - Required Fields

    @Test("Missing title is error")
    func missingTitle() {
        let channel = Channel(
            title: "",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "",
            items: [validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("No items is error")
    func noItems() {
        let feed = amazonFeed(items: [])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    // MARK: - Format Flexibility

    @Test("M4A enclosure has no error for Amazon")
    func m4aAccepted() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.m4a")!,
                length: 1024,
                type: "audio/x-m4a"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        let typeErrors = report.errors.filter {
            $0.field.contains("enclosure.type")
        }
        #expect(typeErrors.isEmpty)
    }

    // MARK: - Recommended Fields

    @Test("Missing itunes:image is warning")
    func missingImageWarning() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains {
            $0.field == "channel.itunesImage"
        })
    }

    @Test("Missing GUID on item is warning")
    func missingGuidWarning() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains {
            $0.field == "channel.items[0].guid"
        })
    }

    // MARK: - Missing Channel

    @Test("Missing channel is error")
    func missingChannel() {
        let feed = PodcastFeed(channel: nil)
        let report = validator.validate(feed, for: .amazon)
        #expect(!report.isValid)
    }

    // MARK: - Missing Recommended

    @Test("Missing itunes:category is warning")
    func missingCategoryWarning() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [validItem()],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains {
            $0.field == "channel.itunesCategories"
        })
    }

    @Test("Missing itunes:explicit is warning")
    func missingExplicitWarning() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.warnings.contains {
            $0.field == "channel.itunesExplicit"
        })
    }

    @Test("Item without enclosure is error")
    func itemNoEnclosure() {
        let item = Item(title: "Episode")
        let feed = amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains {
            $0.field == "channel.items[0].enclosure"
        })
    }
}
