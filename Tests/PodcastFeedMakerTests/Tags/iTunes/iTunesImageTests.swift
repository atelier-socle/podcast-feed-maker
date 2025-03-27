import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesImageTests {

    @Test
    func test_xmlRepresentation_shouldGenerateCorrectImageTag() throws {
        let url = URL(string: "https://example.com/podcast.jpg")!
        let tag = Namespace.iTunes.Image(url: url)

        let result = try tag.xmlRepresentation()
        let expected = "\t<itunes:image href=\"https://example.com/podcast.jpg\" />"
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_shouldThrowForInvalidScheme() {
        let invalidURL = URL(string: "ftp://example.com/image.jpg")!
        let tag = Namespace.iTunes.Image(url: invalidURL)

        #expect(throws: URL.URLValidatorError.invalidScheme) {
            try tag.xmlRepresentation()
        }
    }

    @Test
    func test_equatableAndHashable() {
        let url1 = URL(string: "https://example.com/1.jpg")!
        let url2 = URL(string: "https://example.com/2.jpg")!

        let a = Namespace.iTunes.Image(url: url1)
        let b = Namespace.iTunes.Image(url: url1)
        let c = Namespace.iTunes.Image(url: url2)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Image.self)
    }
}
