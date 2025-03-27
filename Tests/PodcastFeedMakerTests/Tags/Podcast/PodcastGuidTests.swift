import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastGuidTests {

    @Test
    func test_xmlRepresentation_shouldRenderCorrectly() throws {
        let tag = Namespace.Podcast.Guid(value: "podcast.example.com/myshow")
        let expected = "\t<podcast:guid>podcast.example.com/myshow</podcast:guid>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_guidEquatable() {
        let a = Namespace.Podcast.Guid(value: "guid-001")
        let b = Namespace.Podcast.Guid(value: "guid-001")
        let c = Namespace.Podcast.Guid(value: "guid-002")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func test_guidHashable() {
        let guid1 = Namespace.Podcast.Guid(value: "guid-abc")
        let guid2 = Namespace.Podcast.Guid(value: "guid-def")

        let set: Set = [guid1, guid2]
        #expect(set.contains(.init(value: "guid-abc")))
        #expect(!set.contains(.init(value: "unknown")))
    }
}
