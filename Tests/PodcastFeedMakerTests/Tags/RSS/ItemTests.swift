import Foundation
@testable import PodcastFeedMaker
import Testing

struct ItemTests {
    @Test
    func testItemXMLRepresentation() async throws {
        let guid = UUID().uuidString

        let item = RSSTag.Item(
            title: RSSTag.Title("Episode 1"),
            enclosure: RSSTag.Enclosure(
                url: URL(string: "https://podcast.io/ep1.m4a")!,
                length: 1243134,
                type: .m4a
            ),
            guid: RSSTag.Guid(guid),
            pubDate: RSSTag.PubDate(.now),
            duration: Namespace.iTunes.Duration(duration: 60),
            episode: Namespace.iTunes.Episode(value: 1),
            episodeType: Namespace.iTunes.EpisodeType(type: .full),
            summary: Namespace.iTunes.Summary(content: "This is the summary of the episode"),
            explicit: Namespace.iTunes.Explicit(.clean),
            image: Namespace.iTunes.Image(url: URL(string: "https://podcast.io/image.png")!),
            additionalTags: [
                RSSTag.Link(URL(string: "https://podcast.io/ep1")!),
                try Namespace.iTunes.Season(value: 2),
                Namespace.iTunes.Title(text: "Episode 1"),
                Namespace.iTunes.Block(value: false),
                RSSTag.Description("This is the summary of the episode"),
                Namespace.Podcast.Chapters(url: URL(string: "https://podcast.io/chapters.json")!, type: .json),
                Namespace.Podcast.Transcript(url: URL(string: "https://podcast.io/transcript.txt")!, type: .vtt)
            ]
        )

        let xml = try item.xmlRepresentation()

        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<enclosure url="))
        #expect(xml.contains("<guid isPermaLink=\"false\">\(guid)</guid>"))
    }

    @Test
    func testItemPodcastNamespaceXMLRepresentation() async throws {
        let guid = UUID().uuidString

        let item = RSSTag.Item(
            title: RSSTag.Title("Episode 1"),
            enclosure: RSSTag.Enclosure(
                url: URL(string: "https://podcast.io/ep1.m4a")!,
                length: 1243134,
                type: .m4a
            ),
            guid: RSSTag.Guid(guid),
            pubDate: RSSTag.PubDate(.now),
            soundbite: Namespace.Podcast.Soundbite(
                startTime: 0.0,
                duration: 10.0,
                placeholder: "placeholder"
            )
        )

        let xml = try item.xmlRepresentation()

        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<enclosure url="))
        #expect(xml.contains("<guid isPermaLink=\"false\">\(guid)</guid>"))
        #expect(
            xml.contains(
                #"<podcast:soundbite startTime="0.0" duration="10.0">placeholder</podcast:soundbite>"#
            )
        )
    }

    @Test
    func testItemTagsXMLRepresentation() async throws {
        let guid = UUID().uuidString

        let item = RSSTag.Item(
            tags: [
                RSSTag.Title("Episode 1"),
                RSSTag.Enclosure(
                    url: URL(string: "https://podcast.io/ep1.m4a")!,
                    length: 1243134,
                    type: .m4a
                ),
                RSSTag.Guid(guid),
                RSSTag.PubDate(.now),
                Namespace.Podcast.Soundbite(
                    startTime: 0.0,
                    duration: 10.0,
                    placeholder: nil
                )
            ]
        )

        let xml = try item.xmlRepresentation()

        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<enclosure url="))
        #expect(xml.contains("<guid isPermaLink=\"false\">\(guid)</guid>"))
        #expect(
            xml.contains(
                #"<podcast:soundbite startTime="0.0" duration="10.0" />"#
            )
        )
    }
}
