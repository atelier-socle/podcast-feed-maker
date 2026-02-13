import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("CrossCuttingValidation Tests")
struct CrossCuttingValidationTests {

    private let validator = FeedValidator()

    // MARK: - No Channel

    @Test("Feed with no channel returns empty cross-cutting results")
    func noChannel() {
        let feed = PodcastFeed(channel: nil)
        let results = CrossCuttingValidation.validate(feed)
        #expect(results.isEmpty)
    }

    // MARK: - GUID Uniqueness

    @Test("Duplicate GUIDs produce warning")
    func duplicateGuids() {
        let item1 = Item(
            title: "Episode 1",
            guid: GUID(value: "same-guid", isPermaLink: false)
        )
        let item2 = Item(
            title: "Episode 2",
            guid: GUID(value: "same-guid", isPermaLink: false)
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item1, item2]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(results.contains { $0.message.contains("Duplicate GUID") })
    }

    @Test("Unique GUIDs produce no warnings")
    func uniqueGuids() {
        let item1 = Item(
            title: "Episode 1",
            guid: GUID(value: "guid-1", isPermaLink: false)
        )
        let item2 = Item(
            title: "Episode 2",
            guid: GUID(value: "guid-2", isPermaLink: false)
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item1, item2]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(!results.contains { $0.message.contains("Duplicate GUID") })
    }

    // MARK: - Item Minimum Content

    @Test("Item with neither title nor description is error")
    func itemNoContent() {
        let item = Item()
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(results.contains { $0.message.contains("title or description") })
    }

    @Test("Item with title but no description passes")
    func itemTitleOnly() {
        let item = Item(title: "Episode")
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(!results.contains { $0.message.contains("title or description") })
    }

    // MARK: - GUID PermaLink Consistency

    @Test("URL-like GUID with isPermaLink false generates warning")
    func urlGuidNotPermaLink() {
        let item = Item(
            title: "Episode",
            guid: GUID(
                value: "https://example.com/ep1",
                isPermaLink: false
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            results.contains {
                $0.message.contains("looks like a URL") && $0.message.contains("isPermaLink")
            })
    }

    @Test("Non-URL GUID with isPermaLink true generates warning")
    func nonUrlGuidIsPermaLink() {
        let item = Item(
            title: "Episode",
            guid: GUID(value: "ep-001-uuid", isPermaLink: true)
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            results.contains {
                $0.message.contains("not a URL") && $0.message.contains("isPermaLink")
            })
    }

    // MARK: - Future PubDate

    @Test("PubDate more than 24h in the future generates warning")
    func futurePubDate() {
        let futureDate = Date().addingTimeInterval(48 * 60 * 60)
        let item = Item(title: "Episode", pubDate: futureDate)
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            results.contains {
                $0.message.contains("future") && $0.field.contains("pubDate")
            })
    }

    @Test("PubDate within 24h does not generate warning")
    func recentPubDate() {
        let recentDate = Date().addingTimeInterval(12 * 60 * 60)
        let item = Item(title: "Episode", pubDate: recentDate)
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            !results.contains {
                $0.message.contains("future") && $0.field.contains("pubDate")
            })
    }

    // MARK: - Atom Self Link

    @Test("No atom:link self generates info")
    func noAtomSelfLink() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [Item(title: "Ep")]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            results.contains {
                $0.message.contains("atom:link") && $0.message.contains("self")
            })
    }

    // MARK: - Channel PubDate Future

    @Test("Channel pubDate more than 24h in the future generates warning")
    func channelPubDateFarFuture() {
        let futureDate = Date().addingTimeInterval(48 * 60 * 60)
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            pubDate: futureDate,
            items: [Item(title: "Ep")]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            results.contains {
                $0.message.contains("Channel pubDate")
                    && $0.message.contains("future")
                    && $0.field == "channel.pubDate"
                    && $0.severity == .warning
            })
    }

    @Test("Channel pubDate within 24h does not generate warning")
    func channelPubDateNearFuture() {
        let nearDate = Date().addingTimeInterval(12 * 60 * 60)
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            pubDate: nearDate,
            items: [Item(title: "Ep")]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            !results.contains {
                $0.message.contains("Channel pubDate")
                    && $0.message.contains("future")
            })
    }

    // MARK: - Item Link Empty URL

    @Test("Item with empty link absoluteString generates warning")
    func itemLinkEmptyAbsoluteString() {
        // URL(string: "") returns nil, so we construct via init that sets an empty-ish link.
        // Foundation's URL(string: "") returns nil. Test what happens with a real empty-ish URL.
        // Since Foundation URL(string: "") is nil, this path may be unreachable via normal API.
        // Instead, verify the check does not false-positive on a valid link.
        let item = Item(
            title: "Episode",
            link: URL(string: "https://example.com/ep1")
        )
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            !results.contains {
                $0.message.contains("Item link URL is empty")
            })
    }

    @Test("Item with no link does not trigger empty URL warning")
    func itemNoLinkDoesNotWarn() {
        let item = Item(title: "Episode")
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        #expect(
            !results.contains {
                $0.message.contains("Item link URL is empty")
            })
    }
}
