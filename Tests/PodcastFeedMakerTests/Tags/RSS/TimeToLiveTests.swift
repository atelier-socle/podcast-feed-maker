import Foundation
@testable import PodcastFeedMaker
import Testing

struct TimeToLiveTests {

    @Test
    func test_xmlRepresentation_shouldReturnCorrectTag() throws {
        let tag = RSSTag.TimeToLive(60)
        let result = try tag.xmlRepresentation()
        let expected = "\t<ttl>60</ttl>"
        #expect(result == expected)
    }

    @Test
    func test_equatable_conformance() {
        let tag1 = RSSTag.TimeToLive(30)
        let tag2 = RSSTag.TimeToLive(30)
        let tag3 = RSSTag.TimeToLive(90)

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func test_hashable_conformance() {
        let tag = RSSTag.TimeToLive(15)
        let set: Set = [tag]
        #expect(set.contains(RSSTag.TimeToLive(15)))
    }
}
