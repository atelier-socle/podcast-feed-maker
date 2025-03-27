import Foundation
@testable import PodcastFeedMaker
import Testing

struct IndentedTagsRepresentationTests {

    @Test
    func test_indentedTagsRepresentation_shouldAddSingleTabPrefix() {
        let tags = ["<title>Podcast</title>", "<link>https://example.com</link>"]
        let expected = """
        \t<title>Podcast</title>
        \t<link>https://example.com</link>
        """
        #expect(tags.indentedTagsRepresentation == expected)
    }

    @Test
    func test_doubleIndentedTagsRepresentation_shouldAddDoubleTabPrefix() {
        let tags = ["<itunes:name>John Doe</itunes:name>", "<itunes:email>john@example.com</itunes:email>"]
        let expected = """
        \t\t<itunes:name>John Doe</itunes:name>
        \t\t<itunes:email>john@example.com</itunes:email>
        """
        #expect(tags.doubleIndentedTagsRepresentation == expected)
    }

    @Test
    func test_emptyArray_shouldReturnEmptyString() {
        let tags: [String] = []
        #expect(tags.indentedTagsRepresentation.isEmpty)
        #expect(tags.doubleIndentedTagsRepresentation.isEmpty)
    }
}
