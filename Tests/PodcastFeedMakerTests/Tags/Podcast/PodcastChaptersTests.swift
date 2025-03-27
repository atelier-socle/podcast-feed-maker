import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastChaptersTests {

    @Test
    func test_init_withChaptersType_setsCorrectType() {
        let url = URL(string: "https://example.com/chapters.json")!
        let chapters = Namespace.Podcast.Chapters(url: url, type: .json)

        #expect(chapters.url == url)
        #expect(chapters.type == "application/json")
    }

    @Test
    func test_xmlRepresentation_generatesExpectedXML() throws {
        let url = URL(string: "https://example.com/chapters.json")!
        let chapters = Namespace.Podcast.Chapters(url: url, type: .json)

        let xml = try chapters.xmlRepresentation()
        #expect(xml.contains(#"<podcast:chapters url="https://example.com/chapters.json" type="application/json">"#))
    }

    @Test
    func test_xmlRepresentation_throwsIfURLInvalid() {
        let url = URL(string: "file:///Users/local.json")!
        let chapters = Namespace.Podcast.Chapters(url: url, type: .json)

        #expect(throws: URL.URLValidatorError.self) {
            try chapters.xmlRepresentation()
        }
    }

    @Test
    func test_xmlRepresentation_throwsIfTypeInvalid() {
        let url = URL(string: "https://example.com/chapters.json")!
        let chapters = Namespace.Podcast.Chapters(url: url, type: "application/unknown")

        #expect(throws: Namespace.Podcast.Chapters.ChaptersTypeError.self) {
            try chapters.xmlRepresentation()
        }
    }

    @Test
    func test_chaptersTypeRawValue_isCorrect() {
        #expect(Namespace.Podcast.Chapters.ChaptersType.json.rawValue == "application/json")
    }

    @Test
    func test_chaptersTypeErrorDescription() {
        let error = Namespace.Podcast.Chapters.ChaptersTypeError.invalidType
        #expect(error.localizedDescription == "Invalid chapters type")
    }
}
