import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesCompleteTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesComplete_true() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesComplete: true
        )
        #expect(channel.itunesComplete == true)
    }

    @Test
    func test_channel_itunesComplete_false() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesComplete: false
        )
        #expect(channel.itunesComplete == false)
    }

    @Test
    func test_channel_itunesComplete_defaultsToNil() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast"
        )
        #expect(channel.itunesComplete == nil)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameComplete() throws {
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesComplete: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesComplete: true
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentComplete() throws {
        let link = try #require(URL(string: "https://example.com"))
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesComplete: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesComplete: false
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
            itunesComplete: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesComplete: true
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesComplete: false
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
