import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesNewFeedUrlTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesNewFeedUrl_shouldStoreURL() throws {
        let url = try #require(URL(string: "https://example.com/feed.xml"))
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesNewFeedUrl: url
        )
        #expect(channel.itunesNewFeedUrl == url)
    }

    @Test
    func test_channel_itunesNewFeedUrl_defaultsToNil() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast"
        )
        #expect(channel.itunesNewFeedUrl == nil)
    }

    @Test
    func test_channel_itunesNewFeedUrl_absoluteString() throws {
        let url = try #require(URL(string: "https://newhost.example.com/podcast/feed.xml"))
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesNewFeedUrl: url
        )
        #expect(channel.itunesNewFeedUrl?.absoluteString == "https://newhost.example.com/podcast/feed.xml")
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameNewFeedUrl() throws {
        let url = try #require(URL(string: "https://example.com/feed.xml"))
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: url
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: url
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentNewFeedUrl() throws {
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: try #require(URL(string: "https://a.com/feed.xml"))
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: try #require(URL(string: "https://b.com/feed.xml"))
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() throws {
        let urlA = try #require(URL(string: "https://a.com/feed.xml"))
        let urlB = try #require(URL(string: "https://b.com/feed.xml"))
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: urlA
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: urlA
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
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
