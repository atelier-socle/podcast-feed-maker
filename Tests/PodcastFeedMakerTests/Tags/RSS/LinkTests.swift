import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - LinkTests

/// Tests for the `link` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.link` is a required `URL` and
/// `Item.link` is an optional `URL?`.
@Suite("RSS Link Property Tests")
struct LinkTests {

    // MARK: - Channel Link

    @Test("Channel requires a link at initialization")
    func channelLinkIsRequired() throws {
        let url = try #require(URL(string: "https://podcast.example.com"))
        let channel = Channel(
            title: "My Podcast",
            link: url,
            description: "Description"
        )

        #expect(channel.link == url)
    }

    @Test("Channel link is mutable")
    func channelLinkIsMutable() throws {
        let oldURL = try #require(URL(string: "https://old.example.com"))
        var channel = Channel(
            title: "My Podcast",
            link: oldURL,
            description: "Description"
        )

        let newURL = try #require(URL(string: "https://new.example.com"))
        channel.link = newURL
        #expect(channel.link == newURL)
    }

    @Test("Channel XML contains link tag")
    func channelXmlContainsLink() throws {
        let link = try #require(URL(string: "https://podcast.example.com"))
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<link>https://podcast.example.com</link>"))
    }

    @Test("Channel XML encodes link URL with query parameters")
    func channelXmlEncodesLinkUrl() throws {
        let link = try #require(URL(string: "https://example.com/path?q=hello&lang=en"))
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<link>"))
        #expect(xml.contains("https://example.com/path"))
    }

    // MARK: - Item Link

    @Test("Item link defaults to nil")
    func itemLinkDefaultsToNil() {
        let item = Item()
        #expect(item.link == nil)
    }

    @Test("Item link can be set at initialization")
    func itemLinkCanBeSet() throws {
        let url = try #require(URL(string: "https://podcast.example.com/ep1"))
        let item = Item(link: url)
        #expect(item.link == url)
    }

    @Test("Item link is mutable")
    func itemLinkIsMutable() throws {
        let oldURL = try #require(URL(string: "https://example.com/old"))
        var item = Item(link: oldURL)
        let newURL = try #require(URL(string: "https://example.com/new"))
        item.link = newURL
        #expect(item.link == newURL)
    }

    @Test("Item XML contains link tag when set")
    func itemXmlContainsLinkWhenSet() throws {
        let link = try #require(URL(string: "https://podcast.example.com/ep1"))
        let item = Item(link: link)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<link>https://podcast.example.com/ep1</link>"))
    }

    @Test("Item XML omits link tag when nil")
    func itemXmlOmitsLinkWhenNil() throws {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(!xml.contains("<link>"))
    }

    // MARK: - Equatable

    @Test("Channels with same link are equal")
    func channelsWithSameLinkAreEqual() throws {
        let url = try #require(URL(string: "https://example.com"))
        let channel1 = Channel(title: "T", link: url, description: "D")
        let channel2 = Channel(title: "T", link: url, description: "D")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different links are not equal")
    func channelsWithDifferentLinksAreNotEqual() throws {
        let linkA = try #require(URL(string: "https://a.com"))
        let linkB = try #require(URL(string: "https://b.com"))
        let channel1 = Channel(
            title: "T",
            link: linkA,
            description: "D"
        )
        let channel2 = Channel(
            title: "T",
            link: linkB,
            description: "D"
        )
        #expect(channel1 != channel2)
    }
}
