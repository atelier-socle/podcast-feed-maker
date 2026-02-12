import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFundingTests {

    // MARK: - Initialization

    @Test
    func initSetsPropertiesCorrectly() {
        let url = URL(string: "https://patreon.com/myshow")!
        let funding = Funding(url: url, message: "Support us on Patreon")

        #expect(funding.url == url)
        #expect(funding.message == "Support us on Patreon")
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = Funding(url: URL(string: "https://a.com")!, message: "A")
        let b = Funding(url: URL(string: "https://a.com")!, message: "A")
        let c = Funding(url: URL(string: "https://b.com")!, message: "B")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let a = Funding(url: URL(string: "https://a.com")!, message: "A")
        let b = Funding(url: URL(string: "https://a.com")!, message: "A")
        let c = Funding(url: URL(string: "https://b.com")!, message: "B")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
        #expect(set.contains(a))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationContainsUrlAndMessage() {
        let funding = Funding(
            url: URL(string: "https://patreon.com/myshow")!,
            message: "Support us on Patreon"
        )

        let xml = XMLBuilder().element("podcast:funding", content: funding.message, attributes: [("url", XMLBuilder.encodeURL(funding.url))])

        #expect(xml.contains("podcast:funding"))
        #expect(xml.contains(#"url="https://patreon.com/myshow""#))
        #expect(xml.contains("Support us on Patreon"))
    }

    @Test
    func xmlRepresentationWrapsMessageAsElementContent() {
        let funding = Funding(
            url: URL(string: "https://example.com/donate")!,
            message: "Donate here"
        )

        let xml = XMLBuilder().element("podcast:funding", content: funding.message, attributes: [("url", XMLBuilder.encodeURL(funding.url))])

        #expect(xml.contains(">Donate here</podcast:funding>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Funding.self)
    }
}
