import Foundation
@testable import PodcastFeedMaker
import Testing

struct FeedTests {
    @Test
    func testFeedXMLRepresentation() async throws {
        let channel = MockFeed.applePodcasts.channel
        let feed = Feed(version: "2.0", namespaces: Namespace.allCases, channel: channel)
        let xml = try feed.xmlRepresentation()

        #expect(xml.contains("<rss"))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>CHANNEL TITLE</title>"))
        #expect(xml.contains("</channel>"))
        #expect(xml.contains("</rss>"))
    }

    @Test
    func testFeedXMLRepresentationError() async throws {
        let feed = Feed(version: "2.0", namespaces: Namespace.allCases, channel: nil)

        #expect(performing: {
            let _ = try feed.xmlRepresentation()
        }, throws: { error in
            error as? Feed.FeedError == .missingChannelTag
            && error.localizedDescription.contains("Missing channel tag")
        })
    }
}
