import Foundation
@testable import PodcastFeedMaker
import Testing

struct GuidTests {
    @Test
    func testGuidXMLRepresentation() async throws {
        let guid = RSSTag.Guid(id: "ep001", isPermalink: false)
        let xml = try guid.xmlRepresentation()

        #expect(xml.contains("<guid isPermaLink=\"false\">ep001</guid>"))
    }
}
