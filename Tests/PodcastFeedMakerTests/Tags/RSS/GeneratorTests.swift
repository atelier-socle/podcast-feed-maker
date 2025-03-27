import Foundation
@testable import PodcastFeedMaker
import Testing

struct GeneratorTests {

    @Test
    func test_xmlRepresentation_withNormalText() throws {
        let tag = RSSTag.Generator("PodcastFeedMaker 1.0")
        let expected = "\t<generator>PodcastFeedMaker 1.0</generator>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_escapesSpecialCharacters() throws {
        let tag = RSSTag.Generator("My & Co <2025> \"Stable\"")
        let expected = "\t<generator>My &amp; Co &lt;2025&gt; &quot;Stable&quot;</generator>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }
}
