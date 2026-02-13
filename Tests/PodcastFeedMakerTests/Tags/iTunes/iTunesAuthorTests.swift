import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesAuthorTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesAuthor_shouldStoreValue() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesAuthor: "John Doe"
        )
        #expect(channel.itunesAuthor == "John Doe")
    }

    @Test
    func test_channel_itunesAuthor_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesAuthor == nil)
    }

    @Test
    func test_channel_itunesAuthor_withSpecialCharacters() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesAuthor: "John & Sons <Media>"
        )
        #expect(channel.itunesAuthor == "John & Sons <Media>")
    }

    @Test
    func test_channel_itunesAuthor_withEmptyString() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesAuthor: ""
        )
        #expect(channel.itunesAuthor == "")
    }

    // MARK: - Item

    @Test
    func test_item_itunesAuthor_shouldStoreValue() {
        let item = Item(itunesAuthor: "Jane Smith")
        #expect(item.itunesAuthor == "Jane Smith")
    }

    @Test
    func test_item_itunesAuthor_defaultsToNil() {
        let item = Item()
        #expect(item.itunesAuthor == nil)
    }

    @Test
    func test_item_itunesAuthor_withSpecialCharacters() {
        let item = Item(itunesAuthor: "Bob & Alice <Podcast>")
        #expect(item.itunesAuthor == "Bob & Alice <Podcast>")
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameAuthor() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesAuthor: "Same Author"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesAuthor: "Same Author"
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentAuthor() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesAuthor: "Author A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesAuthor: "Author B"
        )
        #expect(channelA != channelB)
    }

    @Test
    func test_item_equatable_sameAuthor() {
        let itemA = Item(itunesAuthor: "Same")
        let itemB = Item(itunesAuthor: "Same")
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentAuthor() {
        let itemA = Item(itunesAuthor: "A")
        let itemB = Item(itunesAuthor: "B")
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
