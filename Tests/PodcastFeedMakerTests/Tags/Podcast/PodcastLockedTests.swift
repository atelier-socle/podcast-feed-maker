import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastLockedTests {

    @Test
    func test_xmlRepresentation_shouldReturnTrue() throws {
        let tag = Namespace.Podcast.Locked(value: true)
        let expected = "\t<podcast:locked>true</podcast:locked>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_shouldReturnFalse() throws {
        let tag = Namespace.Podcast.Locked(value: false)
        let expected = "\t<podcast:locked>false</podcast:locked>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_lockedEquatable() {
        let a = Namespace.Podcast.Locked(value: true)
        let b = Namespace.Podcast.Locked(value: true)
        let c = Namespace.Podcast.Locked(value: false)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func test_lockedHashable() {
        let lockedTrue = Namespace.Podcast.Locked(value: true)
        let lockedFalse = Namespace.Podcast.Locked(value: false)

        let set: Set = [lockedTrue, lockedFalse]
        #expect(set.contains(.init(value: true)))
        #expect(set.contains(.init(value: false)))
    }
}
