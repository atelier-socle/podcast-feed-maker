import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesKeywordsTests {

    @Test
    func test_keywordsXMLRepresentation_generatesCorrectXML() throws {
        let keywords = ["News", "Technology", "Innovation"]
        let tag = Namespace.iTunes.Keywords(keywords: keywords)
        let xml = try tag.xmlRepresentation()

        let expected = "\t<itunes:keywords>news, technology, innovation</itunes:keywords>"
        #expect(xml == expected)
    }

    @Test
    func test_keywords_areLowercasedAndCleaned() {
        let keywords = ["Music", "©Sound", "“Cool“"]
        let tag = Namespace.iTunes.Keywords(keywords: keywords)

        // We expect all keywords to be lowercased and XML-escaped.
        let expected = "music, &#xa9;sound, &quot;cool&quot;"
        #expect(tag.keywords.lowercased() == expected.lowercased())
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.iTunes.Keywords(keywords: ["a", "b", "c"])
        let b = Namespace.iTunes.Keywords(keywords: ["A", "B", "C"])
        let c = Namespace.iTunes.Keywords(keywords: ["x", "y", "z"])

        #expect(a == b)
        #expect(a != c)

        var set = Set<Namespace.iTunes.Keywords>()
        set.insert(a)
        set.insert(c)

        #expect(set.contains(b))  // a == b
        #expect(set.contains(c))
    }
}
