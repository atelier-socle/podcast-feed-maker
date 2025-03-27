import Foundation
@testable import PodcastFeedMaker
import Testing

struct EnclosureTests {

    @Test
    func test_init_withEnclosureType_setsPropertiesCorrectly() {
        let url = URL(string: "https://example.com/audio.mp3")!
        let enclosure = RSSTag.Enclosure(url: url, length: 12345, type: .mpeg)

        #expect(enclosure.url == url)
        #expect(enclosure.length == 12345)
        #expect(enclosure.type == "audio/mpeg")
    }

    @Test
    func test_xmlRepresentation_returnsExpectedXML() throws {
        let url = URL(string: "https://example.com/audio.m4a")!
        let enclosure = RSSTag.Enclosure(url: url, length: 9999, type: .m4a)
        let xml = try enclosure.xmlRepresentation()

        #expect(xml.contains(#"<enclosure url="https://example.com/audio.m4a" length="9999" type="audio/m4a""#))
    }

    @Test
    func test_xmlRepresentation_throwsIfURLIsInvalid() {
        let invalidURL = URL(string: "file:///tmp/audio.mp3")!
        let enclosure = RSSTag.Enclosure(url: invalidURL, length: 1000, type: .mpeg)

        #expect(throws: URL.URLValidatorError.self) {
            try enclosure.xmlRepresentation()
        }
    }

    @Test
    func test_xmlRepresentation_throwsIfTypeIsInvalid() {
        let url = URL(string: "https://example.com/audio.mp3")!
        let enclosure = RSSTag.Enclosure(url: url, length: 1234, type: "invalid/type")

        #expect(throws: RSSTag.Enclosure.EnclosureError.self) {
            try enclosure.xmlRepresentation()
        }
    }

    @Test
    func test_enclosureTypeRawValues_areCorrect() {
        #expect(RSSTag.Enclosure.EnclosureType.m4a.rawValue == "audio/m4a")
        #expect(RSSTag.Enclosure.EnclosureType.mpeg.rawValue == "audio/mpeg")
        #expect(RSSTag.Enclosure.EnclosureType.quicktime.rawValue == "video/quicktime")
        #expect(RSSTag.Enclosure.EnclosureType.mp4.rawValue == "video/mp4")
        #expect(RSSTag.Enclosure.EnclosureType.m4v.rawValue == "video/m4v")
        #expect(RSSTag.Enclosure.EnclosureType.pdf.rawValue == "application/pdf")
    }

    @Test
    func test_enclosureErrorDescription_isCorrect() {
        let error = RSSTag.Enclosure.EnclosureError.invalidType
        #expect(error.localizedDescription == "Invalid enclosure type")
    }
}
