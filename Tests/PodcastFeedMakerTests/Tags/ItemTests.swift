import Foundation
@testable import PodcastFeedMaker
import Testing

struct ItemTests {
    @Test
    func testItemXMLRepresentation() async throws {
        let guid = UUID().uuidString
        let item = RSSTag.Item(
            title: .init(value: "Episode 1"),
            enclosure: .init(url: URL(string: "https://podcast.io/ep1.m4a")!, length: 1243134, type: .m4a),
            guid: .init(id: guid),
            pubDate: .init(value: .now),
            description: .init(content: "This is the description of the episode"),
            duration: .init(duration: 60),
            link: .init(url: URL(string: "https://podcast.io/ep1")!),
            image: .init(url: URL(string: "https://podcast.io/image.png")!),
            explicit: .init(value: true),
            itunesTitle: .init(text: "Episode 1"),
            episode: .init(value: 1),
            season: .init(value: 2),
            episodeType: .init(type: .full),
            transcript: .init(url: URL(string: "https://podcast.io/transcript.txt")!, type: .vtt),
            block: .init(value: false),
            summary: .init(content: "This is the summary of the episode"),
            chapters: .init(url: URL(string: "https://podcast.io/chapters.json")!, type: .json)
        )

        let xml = try item.xmlRepresentation()

        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<enclosure url="))
        #expect(xml.contains("<guid isPermaLink=\"false\">\(guid)</guid>"))
    }
}
