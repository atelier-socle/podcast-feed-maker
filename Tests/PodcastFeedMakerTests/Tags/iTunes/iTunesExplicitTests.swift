import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesExplicitTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesExplicit_true() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesExplicit: true
        )
        #expect(channel.itunesExplicit == true)
    }

    @Test
    func test_channel_itunesExplicit_false() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesExplicit: false
        )
        #expect(channel.itunesExplicit == false)
    }

    @Test
    func test_channel_itunesExplicit_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast"
        )
        #expect(channel.itunesExplicit == nil)
    }

    // MARK: - Item

    @Test
    func test_item_itunesExplicit_true() {
        let item = Item(itunesExplicit: true)
        #expect(item.itunesExplicit == true)
    }

    @Test
    func test_item_itunesExplicit_false() {
        let item = Item(itunesExplicit: false)
        #expect(item.itunesExplicit == false)
    }

    @Test
    func test_item_itunesExplicit_defaultsToNil() {
        let item = Item()
        #expect(item.itunesExplicit == nil)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameExplicit() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesExplicit: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesExplicit: true
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentExplicit() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesExplicit: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesExplicit: false
        )
        #expect(channelA != channelB)
    }

    @Test
    func test_item_equatable_sameExplicit() {
        let itemA = Item(itunesExplicit: false)
        let itemB = Item(itunesExplicit: false)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentExplicit() {
        let itemA = Item(itunesExplicit: true)
        let itemB = Item(itunesExplicit: false)
        #expect(itemA != itemB)
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
