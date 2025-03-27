import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesDurationTests {

    @Test
    func test_xmlRepresentation_withTypicalDuration() throws {
        let duration = Namespace.iTunes.Duration(duration: 3681)
        let xml = try duration.xmlRepresentation()
        #expect(xml == "\t<itunes:duration>3681</itunes:duration>")
    }

    @Test
    func test_xmlRepresentation_withZeroDuration() throws {
        let duration = Namespace.iTunes.Duration(duration: 0)
        let xml = try duration.xmlRepresentation()
        #expect(xml == "\t<itunes:duration>0</itunes:duration>")
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.iTunes.Duration(duration: 42)
        let b = Namespace.iTunes.Duration(duration: 42)
        let c = Namespace.iTunes.Duration(duration: 99)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Duration.self)
    }
}
