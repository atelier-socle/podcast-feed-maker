import Foundation
@testable import PodcastFeedMaker
import Testing

struct SubtitleTests {

    @Test
    func test_xmlRepresentation_shouldGenerateCorrectTag() throws {
        let tag = Namespace.iTunes.Subtitle(text: "Welcome to the show")
        let expected = "\t<itunes:subtitle>Welcome to the show</itunes:subtitle>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_shouldEscapeSpecialCharacters() throws {
        let tag = Namespace.iTunes.Subtitle(text: #"Latest updates & highlights © 2025"#)
        let expected = "\t<itunes:subtitle>Latest updates &amp; highlights &#xA9; 2025</itunes:subtitle>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_subtitle_acceptsEmptyString() throws {
        let tag = Namespace.iTunes.Subtitle(text: "")
        let expected = "\t<itunes:subtitle></itunes:subtitle>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_subtitle_acceptsExactly255Characters() throws {
        let text = String(repeating: "a", count: 255)
        let tag = Namespace.iTunes.Subtitle(text: text)
        let expected = "\t<itunes:subtitle>\(text)</itunes:subtitle>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_subtitle_conformsToProtocols() throws {
        let tag1 = Namespace.iTunes.Subtitle(text: "A")
        let tag2 = Namespace.iTunes.Subtitle(text: "A")
        let tag3 = Namespace.iTunes.Subtitle(text: "B")

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)

        let set: Set = [tag1, tag3]
        #expect(set.contains(tag2))
    }
}
