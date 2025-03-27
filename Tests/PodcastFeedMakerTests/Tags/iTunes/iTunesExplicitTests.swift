import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesExplicitTests {

    @Test
    func test_xmlRepresentation_withYes() throws {
        let tag = Namespace.iTunes.Explicit(.yes)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:explicit>yes</itunes:explicit>")
    }

    @Test
    func test_xmlRepresentation_withNo() throws {
        let tag = Namespace.iTunes.Explicit(.no)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:explicit>no</itunes:explicit>")
    }

    @Test
    func test_xmlRepresentation_withClean() throws {
        let tag = Namespace.iTunes.Explicit(.clean)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:explicit>no</itunes:explicit>")
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.iTunes.Explicit(.clean)
        let b = Namespace.iTunes.Explicit(.no)
        let c = Namespace.iTunes.Explicit(.yes)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test
    func test_explicitType_formattedValue() {
        #expect(Namespace.iTunes.Explicit.ExplicitType.yes.formattedValue == "yes")
        #expect(Namespace.iTunes.Explicit.ExplicitType.no.formattedValue == "no")
        #expect(Namespace.iTunes.Explicit.ExplicitType.clean.formattedValue == "no")
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Explicit.self)
        assertSendable(Namespace.iTunes.Explicit.ExplicitType.self)
    }
}
