import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - AmazonValidationTests

@Suite("Amazon Validation Tests")
struct AmazonValidationTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func amazonFeed(items: [Item] = []) throws -> PodcastFeed {
        let linkURL = try #require(URL(string: "https://example.com"))
        let imageURL = try #require(URL(string: "https://example.com/art.jpg"))
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: linkURL,
                description: "A podcast",
                items: items,
                itunesCategories: [ITunesCategory(text: "Tech")],
                itunesExplicit: false,
                itunesImage: imageURL
            ))
    }

    private func validItem() throws -> Item {
        let enclosureURL = try #require(URL(string: "https://example.com/ep.mp3"))
        return Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
    }

    // MARK: - Valid Feed

    @Test("Valid Amazon feed passes")
    func validFeedPasses() throws {
        let feed = try amazonFeed(items: [validItem()])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.isValid)
    }

    // MARK: - Required Fields

    @Test("Missing title is error")
    func missingTitle() throws {
        let url = try #require(URL(string: "https://example.com"))
        let channel = Channel(
            title: "",
            link: url,
            description: "desc",
            items: [try validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() throws {
        let url = try #require(URL(string: "https://example.com"))
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "",
            items: [try validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("No items is error")
    func noItems() throws {
        let feed = try amazonFeed(items: [])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    // MARK: - Format Flexibility

    @Test("M4A enclosure has no error for Amazon")
    func m4aAccepted() throws {
        let enclosureURL = try #require(URL(string: "https://example.com/ep.m4a"))
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/x-m4a"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = try amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        let typeErrors = report.errors.filter {
            $0.field.contains("enclosure.type")
        }
        #expect(typeErrors.isEmpty)
    }

    // MARK: - Recommended Fields

    @Test("Missing itunes:image is warning")
    func missingImageWarning() throws {
        let url = try #require(URL(string: "https://example.com"))
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [try validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesImage"
            })
    }

    @Test("Missing GUID on item is warning")
    func missingGuidWarning() throws {
        let enclosureURL = try #require(URL(string: "https://example.com/ep.mp3"))
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = try amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
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
    func missingCategoryWarning() throws {
        let url = try #require(URL(string: "https://example.com"))
        let imageURL = try #require(URL(string: "https://example.com/art.jpg"))
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [try validItem()],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is warning")
    func missingExplicitWarning() throws {
        let url = try #require(URL(string: "https://example.com"))
        let imageURL = try #require(URL(string: "https://example.com/art.jpg"))
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [try validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    @Test("Item without enclosure is error")
    func itemNoEnclosure() throws {
        let item = Item(title: "Episode")
        let feed = try amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure"
            })
    }
}
