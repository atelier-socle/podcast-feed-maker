import Foundation
@testable import PodcastFeedMaker
import Testing

struct EnclosureTests {
    @Test
    func testEnclosureXMLRepresentation() async throws {
        let enclosure = RSSTag.Enclosure(
            url:  URL(string: "https://example.com/audio.mp3")!,
            length: 123456,
            type: "audio/mpeg"
        )
        let xml = try enclosure.xmlRepresentation()

        #expect(xml.contains("<enclosure"))
        #expect(xml.contains("url=\"https://example.com/audio.mp3\""))
    }
}
