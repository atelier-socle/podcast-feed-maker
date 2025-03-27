import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesTitleTests {

    @Test
    func test_xmlRepresentation_shouldEscapeSpecialCharacters() throws {
        let tag = Namespace.iTunes.Title(text: #"Swift & Friends “Live” ©"#)
        let expected = "\t<itunes:title>Swift &amp; Friends &quot;Live&quot; &#xA9;</itunes:title>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_withPlainText() throws {
        let tag = Namespace.iTunes.Title(text: "This is my episode title")
        let expected = "\t<itunes:title>This is my episode title</itunes:title>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_withEmptyText() throws {
        let tag = Namespace.iTunes.Title(text: "")
        let expected = "\t<itunes:title></itunes:title>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_equatable_and_hashable() {
        let a = Namespace.iTunes.Title(text: "Title")
        let b = Namespace.iTunes.Title(text: "Title")
        let c = Namespace.iTunes.Title(text: "Another")

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
        #expect(set.contains(c))
    }
}
