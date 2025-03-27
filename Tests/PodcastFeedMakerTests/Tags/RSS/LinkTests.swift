import Foundation
@testable import PodcastFeedMaker
import Testing

struct LinkTests {

    @Test
    func test_xmlRepresentation_shouldReturnValidXmlTag() throws {
        let url = URL(string: "https://example.com")!
        let tag = RSSTag.Link(url)

        let expected = "\t<link>https://example.com</link>"
        let result = try tag.xmlRepresentation()

        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_shouldEscapeURLWithQuery() throws {
        let url = URL(string: "https://example.com/page?param=val ue&ok=true")!
        let tag = RSSTag.Link(url)

        let result = try tag.xmlRepresentation()
        #expect(result.contains("param=val%20ue"))
        #expect(result.contains("ok=true"))
    }

    @Test
    func test_xmlRepresentation_shouldThrowOnInvalidURL() {
        let invalidURL = URL(string: "https://")!
        let tag = RSSTag.Link(invalidURL)

        #expect(throws: URL.URLValidatorError.self) {
            _ = try tag.xmlRepresentation()
        }
        
        #expect(performing: {
            try tag.xmlRepresentation()
        }, throws: { error in
            error as? URL.URLValidatorError == .invalidHost && error.localizedDescription == URL.URLValidatorError.invalidHost.localizedDescription
        })
    }
}
