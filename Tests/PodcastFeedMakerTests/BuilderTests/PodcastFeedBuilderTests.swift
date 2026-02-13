import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - PodcastFeedBuilder — Channel

@Suite("PodcastFeedBuilder — Channel")
struct PodcastFeedBuilderChannelTests {

    // MARK: - Basic Construction

    @Test("Channel only produces feed with empty items")
    func channelOnly() {
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "My Podcast",
                link: url,
                description: "A great show"
            )
        }
        #expect(feed.channel?.title == "My Podcast")
        #expect(feed.channel?.items.isEmpty == true)
    }

    @Test("Channel with one item")
    func channelWithOneItem() {
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "My Podcast",
                link: url,
                description: "A great show"
            )
            Item(title: "Episode 1")
        }
        #expect(feed.channel?.items.count == 1)
        #expect(feed.channel?.items[0].title == "Episode 1")
    }

    @Test("Channel with multiple items")
    func channelWithMultipleItems() {
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Podcast",
                link: url,
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
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Show",
                link: url,
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
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Podcast",
                link: url,
                description: "Desc"
            )
        }
        #expect(feed.namespaces == PodcastNamespace.allStandard)
    }

    // MARK: - Fluent Modifiers Inside Builder

    @Test("Fluent modifiers work inside builder")
    func fluentModifiersInsideBuilder() {
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Podcast",
                link: url,
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
        let url = makeURL("https://techtalks.example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Tech Talks",
                link: url,
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
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Old School",
            link: url,
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
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Show",
                link: url,
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
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Item(title: "First")
            Channel(
                title: "Show",
                link: url,
                description: "Desc"
            )
            Item(title: "Second")
        }
        #expect(feed.channel?.items.count == 2)
    }

    // MARK: - Version

    @Test("Feed version defaults to 2.0")
    func versionDefaults() {
        let url = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Show",
                link: url,
                description: "Desc"
            )
        }
        #expect(feed.version == "2.0")
    }
}

// MARK: - PodcastFeedBuilder — Items & Static API

@Suite("PodcastFeedBuilder — Items & Static API")
struct PodcastFeedBuilderItemTests {

    // MARK: - buildBlock Array Variant

    @Test("buildBlock array variant assembles feed from array of components")
    func buildBlockArrayVariant() {
        let url = makeURL("https://example.com")
        let components: [FeedComponent] = [
            Channel(
                title: "Array Show",
                link: url,
                description: "Built from array"
            ),
            Item(title: "Array Episode 1"),
            Item(title: "Array Episode 2")
        ]
        let feed = PodcastFeedBuilder.buildBlock(components)
        #expect(feed.channel?.title == "Array Show")
        #expect(feed.channel?.items.count == 2)
        #expect(feed.channel?.items[0].title == "Array Episode 1")
        #expect(feed.channel?.items[1].title == "Array Episode 2")
    }

    @Test("buildBlock array variant with items only and no channel returns empty feed")
    func buildBlockArrayNoChannel() {
        let components: [FeedComponent] = [
            Item(title: "Orphan 1"),
            Item(title: "Orphan 2")
        ]
        let feed = PodcastFeedBuilder.buildBlock(components)
        #expect(feed.channel == nil)
    }

    // MARK: - buildOptional Nil Case

    @Test("buildOptional with nil returns empty array")
    func buildOptionalNil() {
        let result = PodcastFeedBuilder.buildOptional(nil)
        #expect(result.isEmpty)
    }

    @Test("buildOptional with value returns single-element array")
    func buildOptionalWithValue() {
        let item: FeedComponent = Item(title: "Optional Episode")
        let result = PodcastFeedBuilder.buildOptional(item)
        #expect(result.count == 1)
    }

    // MARK: - buildEither

    @Test("buildEither first returns the component unchanged")
    func buildEitherFirst() {
        let item = Item(title: "First Branch")
        let result = PodcastFeedBuilder.buildEither(first: item)
        #expect((result as? Item)?.title == "First Branch")
    }

    @Test("buildEither second returns the component unchanged")
    func buildEitherSecond() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Second Branch",
            link: url,
            description: "Else branch"
        )
        let result = PodcastFeedBuilder.buildEither(second: channel)
        #expect((result as? Channel)?.title == "Second Branch")
    }

    // MARK: - Assemble Zero Channels Fallback

    @Test("Assemble with zero channels returns empty PodcastFeed")
    func assembleZeroChannels() {
        let feed = PodcastFeedBuilder.buildBlock([])
        #expect(feed.channel == nil)
        #expect(feed.version == "2.0")
    }

    @Test("Assemble with only items and no channel returns empty feed")
    func assembleOnlyItems() {
        let components: [FeedComponent] = [
            Item(title: "Ep 1"),
            Item(title: "Ep 2")
        ]
        let feed = PodcastFeedBuilder.buildBlock(components)
        #expect(feed.channel == nil)
    }

    // MARK: - Assemble Multiple Channels Fallback

    @Test("Assemble with multiple channels uses first and assigns items")
    func assembleMultipleChannels() {
        let url1 = makeURL("https://example.com/1")
        let url2 = makeURL("https://example.com/2")
        let components: [FeedComponent] = [
            Channel(
                title: "First Channel",
                link: url1,
                description: "First"
            ),
            Channel(
                title: "Second Channel",
                link: url2,
                description: "Second"
            ),
            Item(title: "Episode A")
        ]
        let feed = PodcastFeedBuilder.buildBlock(components)
        #expect(feed.channel?.title == "First Channel")
        #expect(feed.channel?.items.count == 1)
        #expect(feed.channel?.items[0].title == "Episode A")
    }

    // MARK: - buildEither Direct Calls

    @Test("buildEither first with Item preserves identity")
    func buildEitherFirstItem() {
        let item = Item(title: "First Branch Item")
        let result = PodcastFeedBuilder.buildEither(first: item)
        let asItem = result as? Item
        #expect(asItem?.title == "First Branch Item")
    }

    @Test("buildEither second with Item preserves identity")
    func buildEitherSecondItem() {
        let item = Item(title: "Second Branch Item")
        let result = PodcastFeedBuilder.buildEither(second: item)
        let asItem = result as? Item
        #expect(asItem?.title == "Second Branch Item")
    }

    @Test("buildEither first with Channel preserves identity")
    func buildEitherFirstChannel() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Either First",
            link: url,
            description: "First branch channel"
        )
        let result = PodcastFeedBuilder.buildEither(first: channel)
        let asChannel = result as? Channel
        #expect(asChannel?.title == "Either First")
    }

    @Test("buildEither second with Channel preserves identity")
    func buildEitherSecondChannel() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Either Second",
            link: url,
            description: "Second branch channel"
        )
        let result = PodcastFeedBuilder.buildEither(second: channel)
        let asChannel = result as? Channel
        #expect(asChannel?.title == "Either Second")
    }

    // MARK: - buildExpression

    @Test("buildExpression wraps Item as FeedComponent")
    func buildExpressionItem() {
        let item = Item(title: "Wrapped")
        let result = PodcastFeedBuilder.buildExpression(item)
        #expect((result as? Item)?.title == "Wrapped")
    }

    @Test("buildExpression wraps Channel as FeedComponent")
    func buildExpressionChannel() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Wrapped Channel",
            link: url,
            description: "Desc"
        )
        let result = PodcastFeedBuilder.buildExpression(channel)
        #expect((result as? Channel)?.title == "Wrapped Channel")
    }
}
