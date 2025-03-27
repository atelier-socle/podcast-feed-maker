import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesAuthorTests {

    @Test
    func test_init_shouldStoreAuthorName() {
        let author = Namespace.iTunes.Author(name: "John Doe")
        #expect(author.name == "John Doe")
    }

    @Test
    func test_xmlRepresentation_shouldEscapeSpecialCharacters() throws {
        let author = Namespace.iTunes.Author(name: "John & Sons <Media>")
        let xml = try author.xmlRepresentation()
        #expect(xml == "\t<itunes:author>John &amp; Sons &lt;Media&gt;</itunes:author>")
    }

    @Test
    func test_authorEquatable() {
        let a1 = Namespace.iTunes.Author(name: "Same")
        let a2 = Namespace.iTunes.Author(name: "Same")
        let a3 = Namespace.iTunes.Author(name: "Different")

        #expect(a1 == a2)
        #expect(a1 != a3)
    }

    @Test
    func test_authorHashable() {
        let set: Set = [
            Namespace.iTunes.Author(name: "A"),
            Namespace.iTunes.Author(name: "B"),
            Namespace.iTunes.Author(name: "A")
        ]
        #expect(set.count == 2)
    }

    @Test
    func test_authorSendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Author.self)
    }
}
