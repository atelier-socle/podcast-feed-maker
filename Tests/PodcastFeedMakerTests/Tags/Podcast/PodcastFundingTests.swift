import Foundation
import Testing

@testable import PodcastFeedMaker

struct PodcastFundingTests {

    // MARK: - Initialization

    @Test
    func initSetsPropertiesCorrectly() {
        let url = makeURL("https://patreon.com/myshow")
        let funding = Funding(url: url, message: "Support us on Patreon")

        #expect(funding.url == url)
        #expect(funding.message == "Support us on Patreon")
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let urlA = makeURL("https://a.com")
        let urlB = makeURL("https://b.com")

        let a = Funding(url: urlA, message: "A")
        let b = Funding(url: urlA, message: "A")
        let c = Funding(url: urlB, message: "B")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let urlA = makeURL("https://a.com")
        let urlB = makeURL("https://b.com")

        let a = Funding(url: urlA, message: "A")
        let b = Funding(url: urlA, message: "A")
        let c = Funding(url: urlB, message: "B")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
        #expect(set.contains(a))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationContainsUrlAndMessage() {
        let fundingURL = makeURL("https://patreon.com/myshow")
        let funding = Funding(
            url: fundingURL,
            message: "Support us on Patreon"
        )

        let xml = XMLBuilder().element(
            "podcast:funding",
            content: funding.message,
            attributes: [("url", XMLBuilder.encodeURL(funding.url))]
        )

        #expect(xml.contains("podcast:funding"))
        #expect(xml.contains(#"url="https://patreon.com/myshow""#))
        #expect(xml.contains("Support us on Patreon"))
    }

    @Test
    func xmlRepresentationWrapsMessageAsElementContent() {
        let donateURL = makeURL("https://example.com/donate")
        let funding = Funding(
            url: donateURL,
            message: "Donate here"
        )

        let xml = XMLBuilder().element(
            "podcast:funding",
            content: funding.message,
            attributes: [("url", XMLBuilder.encodeURL(funding.url))]
        )

        #expect(xml.contains(">Donate here</podcast:funding>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Funding.self)
    }
}
