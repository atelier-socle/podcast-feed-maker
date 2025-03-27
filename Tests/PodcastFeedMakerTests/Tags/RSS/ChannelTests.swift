import Foundation
@testable import PodcastFeedMaker
import Testing

struct ChannelTests {
    @Test
    func testChannelXMLRepresentation() async throws {
        let channel = RSSTag.Channel(
            title: .init("My Show"),
            link: .init(URL(string: "https://podcast.io")!),
            description: .init("This is my show"),
            atomSelfLink: .init(url: URL(string: "https://podcast.io")!),
            language: .init(value: "en-us"),
            explicit: .init(.clean),
            image: .init(url: URL(string: "https://example.com/image.png")!),
            categories: .init(categories: [.arts([])]),
            items: []
        )

        let xml = try channel.xmlRepresentation()

        #expect(xml.contains("<title>My Show</title>"))
        #expect(xml.contains("<link>https://podcast.io</link>"))
    }

    @Test
    func testChannelPodcastNamespaceXMLRepresentation() async throws {
        let channel = RSSTag.Channel(
            title: .init("My Show"),
            link: .init(URL(string: "https://podcast.io")!),
            description: .init("This is my show"),
            atomSelfLink: .init(url: URL(string: "https://podcast.io")!),
            language: .init(value: "en-us"),
            explicit: .init(.clean),
            image: .init(url: URL(string: "https://example.com/image.png")!),
            categories: .init(categories: [.arts([])]),
            items: [],
            guid: .init(value: "channel-guide-value"),
            locked: .init(value: false)
        )

        let xml = try channel.xmlRepresentation()

        #expect(xml.contains("<title>My Show</title>"))
        #expect(xml.contains("<link>https://podcast.io</link>"))
        #expect(xml.contains("<podcast:guid>channel-guide-value</podcast:guid>"))
        #expect(xml.contains("<podcast:locked>false</podcast:locked>"))
    }
}
