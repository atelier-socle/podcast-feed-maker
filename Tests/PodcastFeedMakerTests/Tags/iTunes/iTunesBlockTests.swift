import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesBlockTests {

    @Test
    func test_init_shouldStoreBooleanValue() {
        let block = Namespace.iTunes.Block(value: true)
        #expect(block.value == true)
    }

    @Test
    func test_xmlRepresentation_shouldReturnTrueWhenBlocked() throws {
        let block = Namespace.iTunes.Block(value: true)
        let xml = try block.xmlRepresentation()
        #expect(xml == "\t<itunes:block>true</itunes:block>")
    }

    @Test
    func test_xmlRepresentation_shouldReturnFalseWhenNotBlocked() throws {
        let block = Namespace.iTunes.Block(value: false)
        let xml = try block.xmlRepresentation()
        #expect(xml == "\t<itunes:block>false</itunes:block>")
    }

    @Test
    func test_blockEquatable() {
        let b1 = Namespace.iTunes.Block(value: true)
        let b2 = Namespace.iTunes.Block(value: true)
        let b3 = Namespace.iTunes.Block(value: false)

        #expect(b1 == b2)
        #expect(b1 != b3)
    }

    @Test
    func test_blockHashable() {
        let set: Set = [
            Namespace.iTunes.Block(value: true),
            Namespace.iTunes.Block(value: false),
            Namespace.iTunes.Block(value: true)
        ]
        #expect(set.count == 2)
    }

    @Test
    func test_blockSendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Namespace.iTunes.Block.self)
    }
}
