import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - PodcastFeedBuilder Tests

@Suite("PodcastFeedBuilder Tests")
struct PodcastFeedBuilderTests {

    // MARK: - Basic Construction

    @Test("Channel only produces feed with empty items")
    func channelOnly() {
        let feed = PodcastFeed {
            Channel(
                title: "My Podcast",
                link: URL(string: "https://example.com")!,
                description: "A great show"
            )
        }
        #expect(feed.channel?.title == "My Podcast")
        #expect(feed.channel?.items.isEmpty == true)
    }

    @Test("Channel with one item")
    func channelWithOneItem() {
        let feed = PodcastFeed {
            Channel(
                title: "My Podcast",
                link: URL(string: "https://example.com")!,
                description: "A great show"
            )
            Item(title: "Episode 1")
        }
        #expect(feed.channel?.items.count == 1)
        #expect(feed.channel?.items[0].title == "Episode 1")
    }

    @Test("Channel with multiple items")
    func channelWithMultipleItems() {
        let feed = PodcastFeed {
            Channel(
                title: "Podcast",
                link: URL(string: "https://example.com")!,
                description: "Desc"
            )
            Item(title: "Episode 1")
            Item(title: "Episode 2")
            Item(title: "Episode 3")
        }
        #expect(feed.channel?.items.count == 3)
        #expect(feed.channel?.items[2].title == "Episode 3")
    }

    // MARK: - Items Auto-Assigned

    @Test("Items declared after channel are auto-assigned to channel.items")
    func itemsAutoAssigned() {
        let feed = PodcastFeed {
            Channel(
                title: "Show",
                link: URL(string: "https://example.com")!,
                description: "Desc"
            )
            Item(title: "A")
            Item(title: "B")
        }
        #expect(feed.channel?.items.count == 2)
        #expect(feed.channel?.items[0].title == "A")
        #expect(feed.channel?.items[1].title == "B")
    }

    // MARK: - Namespaces

    @Test("Feed has allStandard namespaces")
    func feedHasAllStandardNamespaces() {
        let feed = PodcastFeed {
            Channel(
                title: "Podcast",
                link: URL(string: "https://example.com")!,
                description: "Desc"
            )
        }
        #expect(feed.namespaces == PodcastNamespace.allStandard)
    }

    // MARK: - Fluent Modifiers Inside Builder

    @Test("Fluent modifiers work inside builder")
    func fluentModifiersInsideBuilder() {
        let feed = PodcastFeed {
            Channel(
                title: "Podcast",
                link: URL(string: "https://example.com")!,
                description: "Desc"
            )
            .author("Jane Doe")
            .explicit(false)
            .language("en-us")

            Item(title: "Ep 1")
                .duration(1800)
        }
        #expect(feed.channel?.itunesAuthor == "Jane Doe")
        #expect(feed.channel?.itunesExplicit == false)
        #expect(feed.channel?.language == "en-us")
        #expect(feed.channel?.items[0].itunesDuration == 1800)
    }

    // MARK: - Full Spec Example

    @Test("Full spec example compiles and generates valid XML")
    func fullSpecExample() throws {
        let feed = PodcastFeed {
            Channel(
                title: "Tech Talks",
                link: URL(string: "https://techtalks.example.com")!,
                description: "Weekly technology discussions"
            )
            .author("Tech Team")
            .explicit(false)
            .image("https://techtalks.example.com/art.jpg")
            .category(.technology)
            .owner(name: "Tech Team", email: "team@techtalks.example.com")
            .locked(owner: "team@techtalks.example.com")
            .guid("aaaabbbb-cccc-dddd-eeee-ffffgggghhhh")

            Item(title: "Episode 1: Swift 6")
                .description("All about Swift 6 concurrency")
                .duration(3600)
                .guid("ep-001", isPermaLink: false)

            Item(title: "Episode 2: SwiftUI")
                .description("Building modern UIs")
                .duration(2700)
                .guid("ep-002", isPermaLink: false)
        }

        #expect(feed.channel?.title == "Tech Talks")
        #expect(feed.channel?.items.count == 2)
        #expect(feed.channel?.locked?.isLocked == true)
        #expect(feed.channel?.podcastGuid?.value == "aaaabbbb-cccc-dddd-eeee-ffffgggghhhh")

        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("<title>Tech Talks</title>"))
        #expect(xml.contains("Episode 1: Swift 6"))
        #expect(xml.contains("Episode 2: SwiftUI"))
    }

    // MARK: - Existing Init Still Works

    @Test("Existing init(channel:) still works")
    func existingInitStillWorks() {
        let channel = Channel(
            title: "Old School",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [Item(title: "Ep")]
        )
        let feed = PodcastFeed(channel: channel)
        #expect(feed.channel?.title == "Old School")
        #expect(feed.channel?.items.count == 1)
    }

    // MARK: - Channel With Pre-Existing Items

    @Test("Builder appends items to channel's existing items")
    func builderAppendsToExistingItems() {
        let feed = PodcastFeed {
            Channel(
                title: "Show",
                link: URL(string: "https://example.com")!,
                description: "Desc",
                items: [Item(title: "Pre-existing")]
            )
            Item(title: "New")
        }
        #expect(feed.channel?.items.count == 2)
        #expect(feed.channel?.items[0].title == "Pre-existing")
        #expect(feed.channel?.items[1].title == "New")
    }

    // MARK: - Items Before Channel

    @Test("Items before channel are still collected")
    func itemsBeforeChannel() {
        let feed = PodcastFeed {
            Item(title: "First")
            Channel(
                title: "Show",
                link: URL(string: "https://example.com")!,
                description: "Desc"
            )
            Item(title: "Second")
        }
        #expect(feed.channel?.items.count == 2)
    }

    // MARK: - Version

    @Test("Feed version defaults to 2.0")
    func versionDefaults() {
        let feed = PodcastFeed {
            Channel(
                title: "Show",
                link: URL(string: "https://example.com")!,
                description: "Desc"
            )
        }
        #expect(feed.version == "2.0")
    }
}
