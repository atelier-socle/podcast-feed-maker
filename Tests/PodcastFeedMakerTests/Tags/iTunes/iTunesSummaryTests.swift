import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesSummaryTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesSummary_shouldStoreValue() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSummary: "Swift & SwiftUI explained in detail"
        )
        #expect(channel.itunesSummary == "Swift & SwiftUI explained in detail")
    }

    @Test
    func test_channel_itunesSummary_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast"
        )
        #expect(channel.itunesSummary == nil)
    }

    @Test
    func test_channel_itunesSummary_withEmptyString() {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSummary: ""
        )
        #expect(channel.itunesSummary == "")
    }

    @Test
    func test_channel_itunesSummary_withHTMLContent() {
        let htmlContent = "<p><strong>SwiftUI</strong> explained</p>"
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSummary: htmlContent
        )
        #expect(channel.itunesSummary == htmlContent)
    }

    @Test
    func test_channel_itunesSummary_withLongText() {
        let longText = String(repeating: "A long summary. ", count: 100)
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast",
            itunesSummary: longText
        )
        #expect(channel.itunesSummary == longText)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameSummary() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSummary: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSummary: "A"
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentSummary() {
        let channelA = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSummary: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSummary: "B"
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
            itunesSummary: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSummary: "A"
        )
        let channelC = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesSummary: "B"
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
