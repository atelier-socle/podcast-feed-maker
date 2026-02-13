import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesTitleTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesTitle_shouldStoreValue() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesTitle: "This is my show title"
        )
        #expect(channel.itunesTitle == "This is my show title")
    }

    @Test
    func test_channel_itunesTitle_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesTitle == nil)
    }

    @Test
    func test_channel_itunesTitle_withEmptyString() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesTitle: ""
        )
        #expect(channel.itunesTitle == "")
    }

    @Test
    func test_channel_itunesTitle_withSpecialCharacters() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesTitle: #"Swift & Friends "Live""#
        )
        #expect(channel.itunesTitle == #"Swift & Friends "Live""#)
    }

    // MARK: - Item

    @Test
    func test_item_itunesTitle_shouldStoreValue() {
        let item = Item(itunesTitle: "This is my episode title")
        #expect(item.itunesTitle == "This is my episode title")
    }

    @Test
    func test_item_itunesTitle_defaultsToNil() {
        let item = Item()
        #expect(item.itunesTitle == nil)
    }

    @Test
    func test_item_itunesTitle_withEmptyString() {
        let item = Item(itunesTitle: "")
        #expect(item.itunesTitle == "")
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameTitle() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Title"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Title"
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentTitle() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Title"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Another"
        )
        #expect(channelA != channelB)
    }

    @Test
    func test_item_equatable_sameTitle() {
        let itemA = Item(itunesTitle: "Title")
        let itemB = Item(itunesTitle: "Title")
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentTitle() {
        let itemA = Item(itunesTitle: "Title")
        let itemB = Item(itunesTitle: "Another")
        #expect(itemA != itemB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Title"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Title"
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesTitle: "Another"
        )
        let set: Set = [channelA, channelB, channelC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable

    @Test
    func test_channelSendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Channel.self)
    }

    @Test
    func test_itemSendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Item.self)
    }
}
