import Foundation
@testable import PodcastFeedMaker
import Testing

struct ImageTests {
    @Test
    func testImageXMLRepresentation() async throws {
        let image = RSSTag.Image(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Podcast Logo",
            link: URL(string: "https://example.com")!
        )
        let xml = try image.xmlRepresentation()

        #expect(xml.contains("<image>"))
        #expect(xml.contains("<url>https://example.com/logo.png</url>"))
        #expect(xml.contains("<title>Podcast Logo</title>"))
    }
}
