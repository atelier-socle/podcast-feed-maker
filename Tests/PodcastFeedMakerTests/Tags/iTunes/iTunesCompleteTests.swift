import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesCompleteTests {

    @Test
    func test_xmlRepresentation_true() throws {
        let complete = Namespace.iTunes.Complete(value: true)
        let xml = try complete.xmlRepresentation()
        #expect(xml == "\t<itunes:complete>true</itunes:complete>")
    }

    @Test
    func test_xmlRepresentation_false() throws {
        let complete = Namespace.iTunes.Complete(value: false)
        let xml = try complete.xmlRepresentation()
        #expect(xml == "\t<itunes:complete>false</itunes:complete>")
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.iTunes.Complete(value: true)
        let b = Namespace.iTunes.Complete(value: true)
        let c = Namespace.iTunes.Complete(value: false)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Complete.self)
    }
}
