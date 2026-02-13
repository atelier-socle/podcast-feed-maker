import Foundation
import Testing

@testable import PodcastFeedMaker

struct PodcastFeedMakerTests {

    @Test
    func test_xmlRepresentation_generatesValidFeed() throws {
        let channelLink = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/image.jpg")
        let channel = Channel(
            title: "My Podcast",
            link: channelLink,
            description: "Welcome to the show!",
            itunesAuthor: "Jane Doe",
            itunesCategories: [ITunesCategory(.technology)],
            itunesExplicit: false,
            itunesImage: imageURL
        )

        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)

        let xml = try maker.generate()

        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>My Podcast</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<description>Welcome to the show!</description>"))
        #expect(xml.contains("<itunes:author>Jane Doe</itunes:author>"))
    }

    @Test
    func test_xmlRepresentation_throwsIfChannelIsNil() {
        let feed = PodcastFeed(channel: nil)
        let maker = PodcastFeedMaker(feed)

        #expect(throws: GeneratorError.self) {
            _ = try maker.generate()
        }
    }

    @Test("generateStream yields chunks")
    func generateStreamYieldsChunks() async throws {
        let streamLink = makeURL("https://example.com")
        let channel = Channel(
            title: "Stream Test",
            link: streamLink,
            description: "Testing stream"
        )
        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)
        var chunks: [String] = []
        for try await chunk in maker.generateStream() {
            chunks.append(chunk)
        }
        #expect(chunks.count == 2)
        #expect(chunks.first?.contains("<channel>") == true)
    }

    @Test("generateStream with prettyPrint false")
    func generateStreamMinified() async throws {
        let minLink = makeURL("https://example.com")
        let channel = Channel(
            title: "Stream Test",
            link: minLink,
            description: "Testing stream"
        )
        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)
        var chunks: [String] = []
        for try await chunk in maker.generateStream(prettyPrint: false) {
            chunks.append(chunk)
        }
        #expect(chunks.count == 2)
    }
}
