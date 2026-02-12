import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - LinkTests

/// Tests for the `link` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.link` is a required `URL` and
/// `Item.link` is an optional `URL?`.
@Suite("RSS Link Property Tests")
struct LinkTests {

    // MARK: - Channel Link

    @Test("Channel requires a link at initialization")
    func channelLinkIsRequired() {
        let url = URL(string: "https://podcast.example.com")!
        let channel = Channel(
            title: "My Podcast",
            link: url,
            description: "Description"
        )

        #expect(channel.link == url)
    }

    @Test("Channel link is mutable")
    func channelLinkIsMutable() {
        var channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://old.example.com")!,
            description: "Description"
        )

        let newURL = URL(string: "https://new.example.com")!
        channel.link = newURL
        #expect(channel.link == newURL)
    }

    @Test("Channel XML contains link tag")
    func channelXmlContainsLink() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://podcast.example.com")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<link>https://podcast.example.com</link>"))
    }

    @Test("Channel XML encodes link URL with query parameters")
    func channelXmlEncodesLinkUrl() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com/path?q=hello&lang=en")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
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
    func itemLinkCanBeSet() {
        let url = URL(string: "https://podcast.example.com/ep1")!
        let item = Item(link: url)
        #expect(item.link == url)
    }

    @Test("Item link is mutable")
    func itemLinkIsMutable() {
        var item = Item(link: URL(string: "https://example.com/old")!)
        let newURL = URL(string: "https://example.com/new")!
        item.link = newURL
        #expect(item.link == newURL)
    }

    @Test("Item XML contains link tag when set")
    func itemXmlContainsLinkWhenSet() throws {
        let item = Item(link: URL(string: "https://podcast.example.com/ep1")!)
        let xml = try item.xmlRepresentation()
        #expect(xml.contains("<link>https://podcast.example.com/ep1</link>"))
    }

    @Test("Item XML omits link tag when nil")
    func itemXmlOmitsLinkWhenNil() throws {
        let item = Item()
        let xml = try item.xmlRepresentation()
        #expect(!xml.contains("<link>"))
    }

    // MARK: - Equatable

    @Test("Channels with same link are equal")
    func channelsWithSameLinkAreEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D")
        let channel2 = Channel(title: "T", link: url, description: "D")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different links are not equal")
    func channelsWithDifferentLinksAreNotEqual() {
        let channel1 = Channel(
            title: "T",
            link: URL(string: "https://a.com")!,
            description: "D"
        )
        let channel2 = Channel(
            title: "T",
            link: URL(string: "https://b.com")!,
            description: "D"
        )
        #expect(channel1 != channel2)
    }
}
