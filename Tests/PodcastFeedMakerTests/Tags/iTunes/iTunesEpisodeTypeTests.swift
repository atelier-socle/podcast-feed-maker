import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesEpisodeTypeTests {

    @Test
    func test_xmlRepresentation_withFull() throws {
        let tag = Namespace.iTunes.EpisodeType(type: .full)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:episodeType>full</itunes:episodeType>")
    }

    @Test
    func test_xmlRepresentation_withTrailer() throws {
        let tag = Namespace.iTunes.EpisodeType(type: .trailer)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:episodeType>trailer</itunes:episodeType>")
    }

    @Test
    func test_xmlRepresentation_withBonus() throws {
        let tag = Namespace.iTunes.EpisodeType(type: .bonus)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:episodeType>bonus</itunes:episodeType>")
    }

    @Test
    func test_init_withRawString_shouldMatchKnownValue() {
        let rawValue = Namespace.iTunes.EpisodeTypeValue.full.rawValue
        let tag = Namespace.iTunes.EpisodeType(value: rawValue)
        #expect(tag.value == "full")
    }

    @Test
    func test_equatableAndHashable() {
        let a = Namespace.iTunes.EpisodeType(type: .bonus)
        let b = Namespace.iTunes.EpisodeType(type: .bonus)
        let c = Namespace.iTunes.EpisodeType(type: .trailer)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.EpisodeType.self)
        assertSendable(Namespace.iTunes.EpisodeTypeValue.self)
    }
}
