import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesSubtitleTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesSubtitle_shouldStoreValue() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSubtitle: "Welcome to the show"
        )
        #expect(channel.itunesSubtitle == "Welcome to the show")
    }

    @Test
    func test_channel_itunesSubtitle_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast"
        )
        #expect(channel.itunesSubtitle == nil)
    }

    @Test
    func test_channel_itunesSubtitle_withEmptyString() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSubtitle: ""
        )
        #expect(channel.itunesSubtitle == "")
    }

    @Test
    func test_channel_itunesSubtitle_withSpecialCharacters() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSubtitle: "Latest updates & highlights"
        )
        #expect(channel.itunesSubtitle == "Latest updates & highlights")
    }

    @Test
    func test_channel_itunesSubtitle_with255Characters() {
        let text = String(repeating: "a", count: 255)
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSubtitle: text
        )
        #expect(channel.itunesSubtitle?.count == 255)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameSubtitle() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSubtitle: "A"
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentSubtitle() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSubtitle: "B"
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSubtitle: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSubtitle: "B"
        )
        let channelC = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
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
