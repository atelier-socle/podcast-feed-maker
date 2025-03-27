import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesEpisodeTests {

    @Test
    func test_xmlRepresentation_withPositiveValue() throws {
        let tag = Namespace.iTunes.Episode(value: 3)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:episode>3</itunes:episode>")
    }

    @Test
    func test_xmlRepresentation_withZeroValue() throws {
        let tag = Namespace.iTunes.Episode(value: 0)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:episode>0</itunes:episode>")
    }

    @Test
    func test_xmlRepresentation_withLargeValue() throws {
        let tag = Namespace.iTunes.Episode(value: 999_999)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:episode>999999</itunes:episode>")
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.iTunes.Episode(value: 1)
        let b = Namespace.iTunes.Episode(value: 1)
        let c = Namespace.iTunes.Episode(value: 2)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Episode.self)
    }
}
