import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesVerifyTests {

    @Test
    func test_init_defaultIsFalse() {
        let verify = Namespace.iTunes.Verify()
        #expect(verify.value == false)
    }

    @Test
    func test_init_setsValue() {
        let verify = Namespace.iTunes.Verify(value: true)
        #expect(verify.value == true)
    }

    @Test
    func test_xmlRepresentation_true() throws {
        let tag = Namespace.iTunes.Verify(value: true)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:applepodcastsverify>true</itunes:applepodcastsverify>")
    }

    @Test
    func test_xmlRepresentation_false() throws {
        let tag = Namespace.iTunes.Verify(value: false)
        let xml = try tag.xmlRepresentation()
        #expect(xml == "\t<itunes:applepodcastsverify>false</itunes:applepodcastsverify>")
    }

    @Test
    func test_equatable_and_hashable() {
        let a = Namespace.iTunes.Verify(value: true)
        let b = Namespace.iTunes.Verify(value: true)
        let c = Namespace.iTunes.Verify(value: false)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
    }
}
