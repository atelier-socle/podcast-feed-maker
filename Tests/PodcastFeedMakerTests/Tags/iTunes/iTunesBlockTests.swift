import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesBlockTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesBlock_true() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesBlock: true
        )
        #expect(channel.itunesBlock == true)
    }

    @Test
    func test_channel_itunesBlock_false() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesBlock: false
        )
        #expect(channel.itunesBlock == false)
    }

    @Test
    func test_channel_itunesBlock_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesBlock == nil)
    }

    // MARK: - Item

    @Test
    func test_item_itunesBlock_true() {
        let item = Item(itunesBlock: true)
        #expect(item.itunesBlock == true)
    }

    @Test
    func test_item_itunesBlock_false() {
        let item = Item(itunesBlock: false)
        #expect(item.itunesBlock == false)
    }

    @Test
    func test_item_itunesBlock_defaultsToNil() {
        let item = Item()
        #expect(item.itunesBlock == nil)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameBlock() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesBlock: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesBlock: true
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentBlock() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesBlock: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesBlock: false
        )
        #expect(channelA != channelB)
    }

    @Test
    func test_item_equatable_sameBlock() {
        let itemA = Item(itunesBlock: true)
        let itemB = Item(itunesBlock: true)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentBlock() {
        let itemA = Item(itunesBlock: true)
        let itemB = Item(itunesBlock: false)
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
            itunesBlock: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesBlock: false
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesBlock: true
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
