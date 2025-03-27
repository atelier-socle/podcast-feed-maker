import Foundation
@testable import PodcastFeedMaker
import Testing

struct TitleTagTests {

    @Test
    func test_xmlRepresentation_shouldReturnCorrectTag() throws {
        let tag = RSSTag.Title("Episode 1: Getting Started")
        let expected = "\t<title>Episode 1: Getting Started</title>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_shouldEscapeSpecialCharacters() throws {
        let tag = RSSTag.Title("Swift & XML <Guide> \"Podcast\"")
        let expected = "\t<title>Swift &amp; XML &lt;Guide&gt; &quot;Podcast&quot;</title>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_equatable_conformance() {
        let tag1 = RSSTag.Title("A")
        let tag2 = RSSTag.Title("A")
        let tag3 = RSSTag.Title("B")

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func test_hashable_conformance() {
        let tag = RSSTag.Title("Hello")
        let set: Set = [tag]
        #expect(set.contains(RSSTag.Title("Hello")))
        #expect(!set.contains(RSSTag.Title("World")))
    }
}
