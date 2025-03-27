import Foundation
@testable import PodcastFeedMaker
import Testing

struct AtomLinkTests {

    @Test
    func test_init_setsURLCorrectly() {
        let url = URL(string: "https://example.com/feed.rss")!
        let link = Namespace.Atom.Link(url: url)

        #expect(link.url == url)
    }

    @Test
    func test_xmlRepresentation_success() throws {
        let url = URL(string: "https://example.com/feed.rss")!
        let link = Namespace.Atom.Link(url: url)

        let xml = try link.xmlRepresentation()

        #expect(xml == "\t<atom:link href=\"https://example.com/feed.rss\" rel=\"self\" type=\"application/rss+xml\" />")
    }

    @Test
    func test_xmlRepresentation_throwsOnInvalidURL() {
        // Simulate a file:// URL (which is invalid per the internal URL validator)
        let url = URL(fileURLWithPath: "/invalid/path")

        let link = Namespace.Atom.Link(url: url)

        #expect(throws: URL.URLValidatorError.isFileURL) {
            try link.xmlRepresentation()
        }
    }

    @Test
    func test_EquatableAndHashableConformance() {
        let url1 = URL(string: "https://example.com/a.xml")!
        let url2 = URL(string: "https://example.com/b.xml")!

        let link1 = Namespace.Atom.Link(url: url1)
        let link2 = Namespace.Atom.Link(url: url1)
        let link3 = Namespace.Atom.Link(url: url2)

        #expect(link1 == link2)
        #expect(link1 != link3)

        let set: Set = [link1, link2, link3]
        #expect(set.count == 2)
    }

    @Test
    func test_SendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Namespace.Atom.Link.self)
    }
}
