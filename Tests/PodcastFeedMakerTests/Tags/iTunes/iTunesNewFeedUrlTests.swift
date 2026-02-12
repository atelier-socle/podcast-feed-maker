import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesNewFeedUrlTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesNewFeedUrl_shouldStoreURL() {
        let url = URL(string: "https://example.com/feed.xml")!
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesNewFeedUrl: url
        )
        #expect(channel.itunesNewFeedUrl == url)
    }

    @Test
    func test_channel_itunesNewFeedUrl_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast"
        )
        #expect(channel.itunesNewFeedUrl == nil)
    }

    @Test
    func test_channel_itunesNewFeedUrl_absoluteString() {
        let url = URL(string: "https://newhost.example.com/podcast/feed.xml")!
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesNewFeedUrl: url
        )
        #expect(channel.itunesNewFeedUrl?.absoluteString == "https://newhost.example.com/podcast/feed.xml")
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameNewFeedUrl() {
        let url = URL(string: "https://example.com/feed.xml")!
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: url
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: url
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentNewFeedUrl() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: URL(string: "https://a.com/feed.xml")!
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: URL(string: "https://b.com/feed.xml")!
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() {
        let urlA = URL(string: "https://a.com/feed.xml")!
        let urlB = URL(string: "https://b.com/feed.xml")!
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: urlA
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: urlA
        )
        let channelC = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesNewFeedUrl: urlB
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
