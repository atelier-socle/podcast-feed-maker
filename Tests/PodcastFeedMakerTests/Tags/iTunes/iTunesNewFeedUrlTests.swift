import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesNewFeedUrlTests {

    @Test
    func test_init_setsURLCorrectly() {
        let url = URL(string: "https://example.com/feed.xml")!
        let tag = Namespace.iTunes.NewFeedUrl(url: url)

        #expect(tag.url == url)
    }

    @Test
    func test_xmlRepresentation_generatesExpectedXML() throws {
        let url = URL(string: "https://example.com/feed.xml")!
        let tag = Namespace.iTunes.NewFeedUrl(url: url)

        let expected = """
        \t<itunes:new-feed-url>\(url.absoluteString)</itunes:new-feed-url>
        """

        #expect(try tag.xmlRepresentation() == expected)
    }

    @Test
    func test_xmlRepresentation_throwsIfURLIsInvalid() {
        let url = URL(string: "file:///Users/desktop/feed.xml")!
        let tag = Namespace.iTunes.NewFeedUrl(url: url)

        #expect(throws: URL.URLValidatorError.self) {
            try tag.xmlRepresentation()
        }
    }

    @Test
    func test_equatableAndHashable() {
        let urlA = URL(string: "https://a.com")!
        let urlB = URL(string: "https://b.com")!

        let a1 = Namespace.iTunes.NewFeedUrl(url: urlA)
        let a2 = Namespace.iTunes.NewFeedUrl(url: urlA)
        let b = Namespace.iTunes.NewFeedUrl(url: urlB)

        #expect(a1 == a2)
        #expect(a1 != b)

        let set: Set = [a1, b]
        #expect(set.contains(a2))
        #expect(!set.contains(Namespace.iTunes.NewFeedUrl(url: URL(string: "https://c.com")!)))
    }
}
