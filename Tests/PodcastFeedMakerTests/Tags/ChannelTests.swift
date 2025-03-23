import Foundation
@testable import PodcastFeedMaker
import Testing

struct ChannelTests {
    @Test
    func testChannelXMLRepresentation() async throws {
        let channel = RSSTag.Channel(
            title: .init(value: "My Show"),
            description: .init(content: "This is my show"),
            itunesImage: .init(url: URL(string: "https://podcast.io/image.png")!),
            language: .init(value: "en-us"),
            categories: .init(categories: [.arts([])]),
            explicit: .init(value: false),
            author: .init(author: "John Doe"),
            link: .init(url: URL(string: "https://podcast.io")!),
            itunesTitle: .init(text: "My Show"),
            type: .init(type: .episodic),
            copyright: .init(value: "Copyright 2025 John Doe"),
            newFeedUrl: nil,
            block: .init(value: false),
            complete: .init(value: false),
            verify: nil,
            generator: .init(value: "Podcast Feed Maker by Atelier Socle"),
            items: [],
            summary: .init(content: "This is my show"),
            subtitle: nil,
            keywords: .init(keywords: ["key 9", "key 8"]),
            owner: .init(name: "John Doe", mail: "john@doe.com"),
            pubDate: .init(value: .now),
            lastBuildDate: .init(value: .now),
            ttl: .init(value: 60),
            locked: .init(value: false),
            guid: .init(value: UUID().uuidString),
            atomLink: .init(url: URL(string: "https://podcast.io")!),
            image: .init(url: URL(string: "https://example.com/image.png")!, title: "My Show", link: URL(string: "https://podcast.io")!),
            location: .init(place: "Paris, FR", latitude: 48.856614, longitude: 2.352222)
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<title>My Show</title>"))
        #expect(xml.contains("<link>https://podcast.io</link>"))
    }
}
