import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFeedMakerTests {

    @Test
    func test_xmlRepresentation_generatesValidFeed() throws {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "Welcome to the show!",
            itunesAuthor: "Jane Doe",
            itunesCategories: [ITunesCategory(.technology)],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/image.jpg")!
        )

        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)

        let xml = try maker.xmlRepresentation()

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

        #expect(throws: PodcastFeed.FeedError.self) {
            _ = try maker.xmlRepresentation()
        }
    }
}
