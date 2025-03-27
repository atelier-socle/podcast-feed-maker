import Foundation
@testable import PodcastFeedMaker
import Testing

struct CopyrightTests {

    @Test
    func test_xmlRepresentation_generatesCorrectXml() throws {
        let tag = RSSTag.Copyright("© 2025 Atelier Socle")
        let expected = "\t<copyright>&#xA9; 2025 Atelier Socle</copyright>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_escapesSpecialCharacters() throws {
        let tag = RSSTag.Copyright("My & Co <2025> \"Great\"")
        let expected = "\t<copyright>My &amp; Co &lt;2025&gt; &quot;Great&quot;</copyright>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_equatableAndHashable() {
        let tag1 = RSSTag.Copyright("© 2025 Atelier Socle")
        let tag2 = RSSTag.Copyright("© 2025 Atelier Socle")
        let tag3 = RSSTag.Copyright("© 2024 Another Studio")

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)

        let set: Set = [tag1, tag2, tag3]
        #expect(set.count == 2)
    }
}
