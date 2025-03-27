import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesChannelTypeTests {

    @Test
    func test_xmlRepresentation_withEpisodicType() throws {
        let tag = Namespace.iTunes.ChannelType(type: .episodic)
        let expected = "\t<itunes:type>episodic</itunes:type>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_withSerialType() throws {
        let tag = Namespace.iTunes.ChannelType(type: .serial)
        let expected = "\t<itunes:type>serial</itunes:type>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_equatable_and_hashable() {
        let a = Namespace.iTunes.ChannelType(type: .episodic)
        let b = Namespace.iTunes.ChannelType(type: .episodic)
        let c = Namespace.iTunes.ChannelType(type: .serial)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
        #expect(set.contains(c))
    }
}
