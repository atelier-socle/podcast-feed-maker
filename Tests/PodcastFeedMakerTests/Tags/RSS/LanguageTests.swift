import Foundation
@testable import PodcastFeedMaker
import Testing

struct LanguageTests {
    @Test
    func testLanguageXMLRepresentation() async throws {
        let language = RSSTag.Language(value: "en_US")
        let xml = try language.xmlRepresentation()

        #expect(xml.contains("<language>en-us</language>"))
        #expect(language.formattedLanguageCode == "English (United States)")
    }

    @Test
    func testLanguageCodeXMLRepresentation() async throws {
        let language = RSSTag.Language(value: .french)
        let xml = try language.xmlRepresentation()

        #expect(xml.contains("<language>fr</language>"))
        #expect(language.formattedLanguageCode == "français")
    }
}
