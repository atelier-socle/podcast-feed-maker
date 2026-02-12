import Foundation
@testable import PodcastFeedMaker
import Testing

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
}
