import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastChaptersTests {

    // MARK: - Initialization

    @Test
    func initWithDefaultType() {
        let url = URL(string: "https://example.com/chapters.json")!
        let chapters = ChaptersLink(url: url)

        #expect(chapters.url == url)
        #expect(chapters.type == "application/json+chapters")
    }

    @Test
    func initWithCustomType() {
        let url = URL(string: "https://example.com/chapters.json")!
        let chapters = ChaptersLink(url: url, type: "application/json")

        #expect(chapters.url == url)
        #expect(chapters.type == "application/json")
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let url1 = URL(string: "https://example.com/chapters1.json")!
        let url2 = URL(string: "https://example.com/chapters2.json")!

        let a = ChaptersLink(url: url1)
        let b = ChaptersLink(url: url1)
        let c = ChaptersLink(url: url2)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let url1 = URL(string: "https://example.com/chapters1.json")!
        let url2 = URL(string: "https://example.com/chapters2.json")!

        let a = ChaptersLink(url: url1)
        let b = ChaptersLink(url: url1)
        let c = ChaptersLink(url: url2)

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationContainsUrlAndType() {
        let url = URL(string: "https://example.com/ep1/chapters.json")!
        let chapters = ChaptersLink(url: url)

        let xml = XMLBuilder().selfClosingElement("podcast:chapters", attributes: [("url", XMLBuilder.encodeURL(chapters.url)), ("type", chapters.type)])

        #expect(xml.contains("podcast:chapters"))
        #expect(xml.contains(#"url="https://example.com/ep1/chapters.json""#))
        #expect(xml.contains(#"type="application/json+chapters""#))
    }

    @Test
    func xmlRepresentationWithCustomType() {
        let url = URL(string: "https://example.com/ep1/chapters.json")!
        let chapters = ChaptersLink(url: url, type: "application/json")

        let xml = XMLBuilder().selfClosingElement("podcast:chapters", attributes: [("url", XMLBuilder.encodeURL(chapters.url)), ("type", chapters.type)])

        #expect(xml.contains(#"type="application/json""#))
    }

    @Test
    func xmlRepresentationIsSelfClosingTag() {
        let url = URL(string: "https://example.com/chapters.json")!
        let chapters = ChaptersLink(url: url)

        let xml = XMLBuilder().selfClosingElement("podcast:chapters", attributes: [("url", XMLBuilder.encodeURL(chapters.url)), ("type", chapters.type)])

        #expect(xml.contains("/>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(ChaptersLink.self)
    }
}
