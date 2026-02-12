import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastGuidTests {

    // MARK: - Initialization

    @Test
    func initSetsValueCorrectly() {
        let guid = PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")

        #expect(guid.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = PodcastGuid(value: "guid-001")
        let b = PodcastGuid(value: "guid-001")
        let c = PodcastGuid(value: "guid-002")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let guid1 = PodcastGuid(value: "guid-abc")
        let guid2 = PodcastGuid(value: "guid-def")

        let set: Set = [guid1, guid2]
        #expect(set.contains(PodcastGuid(value: "guid-abc")))
        #expect(!set.contains(PodcastGuid(value: "unknown")))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationContainsGuidValue() {
        let guid = PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")

        let xml = XMLBuilder().element("podcast:guid", content: guid.value)

        #expect(xml.contains("podcast:guid"))
        #expect(xml.contains("917393e3-1b1e-5cef-ace4-edaa54e1f3e1"))
    }

    @Test
    func xmlRepresentationWrapsValueAsElementContent() {
        let guid = PodcastGuid(value: "podcast.example.com/myshow")

        let xml = XMLBuilder().element("podcast:guid", content: guid.value)

        #expect(xml.contains(">podcast.example.com/myshow</podcast:guid>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(PodcastGuid.self)
    }
}
