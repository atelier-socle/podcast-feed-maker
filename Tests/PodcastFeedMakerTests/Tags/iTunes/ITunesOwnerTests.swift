import Foundation
@testable import PodcastFeedMaker
import Testing

struct ITunesOwnerTests {

    @Test
    func test_owner_initialization() {
        let tag = Namespace.iTunes.Owner(name: "Alice Smith", mail: "alice@example.com")
        #expect(tag.name == "Alice Smith")
        #expect(tag.mail == "alice@example.com")
    }

    @Test
    func test_owner_xmlRepresentation_escapesSpecialCharacters() throws {
        let tag = Namespace.iTunes.Owner(name: "John & Sons ©", mail: "john@example.com &copy;")

        let expectedLines = [
            "\t<itunes:owner>",
            "\t\t\t<itunes:name>John &amp; Sons &#xA9;</itunes:name>",
            "\t\t\t<itunes:email>john@example.com &#xA9;</itunes:email>",
            "\t\t</itunes:owner>"
        ]

        let result = try tag.xmlRepresentation()
        let resultLines = result.components(separatedBy: "\n")

        #expect(resultLines == expectedLines)
    }

    @Test
    func test_owner_xmlRepresentation_withoutSpecialCharacters() throws {
        let tag = Namespace.iTunes.Owner(name: "Jane Doe", mail: "jane@domain.com")

        let expectedLines = [
            "\t<itunes:owner>",
            "\t\t\t<itunes:name>Jane Doe</itunes:name>",
            "\t\t\t<itunes:email>jane@domain.com</itunes:email>",
            "\t\t</itunes:owner>"
        ]

        let result = try tag.xmlRepresentation()
        let resultLines = result.components(separatedBy: "\n")
        #expect(resultLines == expectedLines)
    }

    @Test
    func test_owner_equatable_and_hashable() {
        let a = Namespace.iTunes.Owner(name: "Alice", mail: "a@example.com")
        let b = Namespace.iTunes.Owner(name: "Alice", mail: "a@example.com")
        let c = Namespace.iTunes.Owner(name: "Bob", mail: "b@example.com")

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
    }
}
