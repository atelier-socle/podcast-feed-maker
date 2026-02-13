import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesSubtitleTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesSubtitle_shouldStoreValue() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesSubtitle: "Welcome to the show"
        )
        #expect(channel.itunesSubtitle == "Welcome to the show")
    }

    @Test
    func test_channel_itunesSubtitle_defaultsToNil() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast"
        )
        #expect(channel.itunesSubtitle == nil)
    }

    @Test
    func test_channel_itunesSubtitle_withEmptyString() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesSubtitle: ""
        )
        #expect(channel.itunesSubtitle == "")
    }

    @Test
    func test_channel_itunesSubtitle_withSpecialCharacters() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesSubtitle: "Latest updates & highlights"
        )
        #expect(channel.itunesSubtitle == "Latest updates & highlights")
    }

    @Test
    func test_channel_itunesSubtitle_with255Characters() throws {
        let text = String(repeating: "a", count: 255)
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesSubtitle: text
        )
        #expect(channel.itunesSubtitle?.count == 255)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameSubtitle() throws {
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "A"
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentSubtitle() throws {
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "B"
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() throws {
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "B"
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let set: Set = [channelA, channelB, channelC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Channel.self)
    }
}
