import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesVerifyTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesVerify_true() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesVerify: true
        )
        #expect(channel.itunesVerify == true)
    }

    @Test
    func test_channel_itunesVerify_false() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesVerify: false
        )
        #expect(channel.itunesVerify == false)
    }

    @Test
    func test_channel_itunesVerify_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesVerify == nil)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameVerify() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentVerify() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: false
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: false
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
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
