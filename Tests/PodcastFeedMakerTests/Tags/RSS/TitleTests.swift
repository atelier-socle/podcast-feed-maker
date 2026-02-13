import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - TitleTests

/// Tests for the `title` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.title` is a required `String` and
/// `Item.title` is an optional `String?`. There is no standalone
/// `RSSTag.Title` wrapper type.
@Suite("RSS Title Property Tests")
struct TitleTests {

    // MARK: - Channel Title

    @Test("Channel requires a title at initialization")
    func channelTitleIsRequired() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "My Podcast",
            link: link,
            description: "A great podcast"
        )

        #expect(channel.title == "My Podcast")
    }

    @Test("Channel title is mutable")
    func channelTitleIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Original",
            link: link,
            description: "Description"
        )

        channel.title = "Updated Title"
        #expect(channel.title == "Updated Title")
    }

    @Test("Channel XML contains title tag")
    func channelXmlContainsTitle() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Episode 1: Getting Started",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<title>Episode 1: Getting Started</title>"))
    }

    @Test("Channel XML escapes special characters in title")
    func channelXmlEscapesSpecialCharsInTitle() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Swift & XML <Guide>",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<title>Swift &amp; XML &lt;Guide&gt;</title>"))
    }

    // MARK: - Item Title

    @Test("Item title defaults to nil")
    func itemTitleDefaultsToNil() {
        let item = Item()
        #expect(item.title == nil)
    }

    @Test("Item title can be set at initialization")
    func itemTitleCanBeSet() {
        let item = Item(title: "Episode 42")
        #expect(item.title == "Episode 42")
    }

    @Test("Item title is mutable")
    func itemTitleIsMutable() {
        var item = Item(title: "Old Title")
        item.title = "New Title"
        #expect(item.title == "New Title")
    }

    @Test("Item XML contains title tag when set")
    func itemXmlContainsTitleWhenSet() {
        let item = Item(title: "Episode 1")
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<title>Episode 1</title>"))
    }

    @Test("Item XML omits title tag when nil")
    func itemXmlOmitsTitleWhenNil() {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(!xml.contains("<title>"))
    }

    // MARK: - Equatable / Hashable via Channel

    @Test("Channels with same title are equal (given same required fields)")
    func channelsWithSameTitleAreEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "A", link: url, description: "D")
        let channel2 = Channel(title: "A", link: url, description: "D")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different titles are not equal")
    func channelsWithDifferentTitlesAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "A", link: url, description: "D")
        let channel2 = Channel(title: "B", link: url, description: "D")
        #expect(channel1 != channel2)
    }

    @Test("Items with same title are equal")
    func itemsWithSameTitleAreEqual() {
        let item1 = Item(title: "Ep1")
        let item2 = Item(title: "Ep1")
        #expect(item1 == item2)
    }

    @Test("Items with different titles are not equal")
    func itemsWithDifferentTitlesAreNotEqual() {
        let item1 = Item(title: "Ep1")
        let item2 = Item(title: "Ep2")
        #expect(item1 != item2)
    }

    @Test("Channel is Hashable and title contributes to hash")
    func channelHashableWithTitle() {
        let url = makeURL("https://example.com")
        let channel = Channel(title: "Hello", link: url, description: "D")
        let set: Set = [channel]
        #expect(set.contains(Channel(title: "Hello", link: url, description: "D")))
        #expect(!set.contains(Channel(title: "World", link: url, description: "D")))
    }
}
