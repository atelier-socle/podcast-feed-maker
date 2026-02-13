import Foundation
import Testing

@testable import PodcastFeedMaker

struct AtomLinkTests {

    // MARK: - Initialization

    @Test
    func initWithAllParameters() throws {
        let href = try #require(URL(string: "https://example.com/feed.xml"))
        let link = AtomLink(
            href: href,
            rel: "self",
            type: "application/rss+xml",
            hreflang: "en",
            title: "My Feed",
            length: 1024
        )

        #expect(link.href == href)
        #expect(link.rel == "self")
        #expect(link.type == "application/rss+xml")
        #expect(link.hreflang == "en")
        #expect(link.title == "My Feed")
        #expect(link.length == 1024)
    }

    @Test
    func initWithHrefOnly() throws {
        let href = try #require(URL(string: "https://example.com/feed.xml"))
        let link = AtomLink(href: href)

        #expect(link.href == href)
        #expect(link.rel == nil)
        #expect(link.type == nil)
        #expect(link.hreflang == nil)
        #expect(link.title == nil)
        #expect(link.length == nil)
    }

    // MARK: - Self Link Factory

    @Test
    func selfLinkFactorySetsSelfRelAndRssType() throws {
        let href = try #require(URL(string: "https://example.com/feed.xml"))
        let link = AtomLink.selfLink(href: href)

        #expect(link.href == href)
        #expect(link.rel == "self")
        #expect(link.type == "application/rss+xml")
        #expect(link.hreflang == nil)
        #expect(link.title == nil)
        #expect(link.length == nil)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() throws {
        let url1 = try #require(URL(string: "https://example.com/a.xml"))
        let url2 = try #require(URL(string: "https://example.com/b.xml"))

        let link1 = AtomLink(href: url1, rel: "self", type: "application/rss+xml")
        let link2 = AtomLink(href: url1, rel: "self", type: "application/rss+xml")
        let link3 = AtomLink(href: url2, rel: "alternate")

        #expect(link1 == link2)
        #expect(link1 != link3)
    }

    @Test
    func hashableConformance() throws {
        let url1 = try #require(URL(string: "https://example.com/a.xml"))
        let url2 = try #require(URL(string: "https://example.com/b.xml"))

        let link1 = AtomLink(href: url1, rel: "self")
        let link2 = AtomLink(href: url1, rel: "self")
        let link3 = AtomLink(href: url2, rel: "alternate")

        let set: Set = [link1, link2, link3]
        #expect(set.count == 2)
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithRelAndType() throws {
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        let link = AtomLink.selfLink(href: feedURL)
        let b = XMLBuilder()
        var attrs: [(String, String)] = [("href", XMLBuilder.encodeURL(link.href))]
        if let rel = link.rel { attrs.append(("rel", rel)) }
        if let type = link.type { attrs.append(("type", type)) }
        if let hreflang = link.hreflang { attrs.append(("hreflang", hreflang)) }
        if let title = link.title { attrs.append(("title", XMLBuilder.escape(title))) }
        if let length = link.length { attrs.append(("length", "\(length)")) }
        let xml = b.selfClosingElement("atom:link", attributes: attrs)

        #expect(xml.contains("atom:link"))
        #expect(xml.contains(#"href="https://example.com/feed.xml""#))
        #expect(xml.contains(#"rel="self""#))
        #expect(xml.contains(#"type="application/rss+xml""#))
    }

    @Test
    func xmlRepresentationWithHrefOnly() throws {
        let otherURL = try #require(URL(string: "https://example.com/other.xml"))
        let link = AtomLink(href: otherURL)
        let b = XMLBuilder()
        var attrs: [(String, String)] = [("href", XMLBuilder.encodeURL(link.href))]
        if let rel = link.rel { attrs.append(("rel", rel)) }
        if let type = link.type { attrs.append(("type", type)) }
        if let hreflang = link.hreflang { attrs.append(("hreflang", hreflang)) }
        if let title = link.title { attrs.append(("title", XMLBuilder.escape(title))) }
        if let length = link.length { attrs.append(("length", "\(length)")) }
        let xml = b.selfClosingElement("atom:link", attributes: attrs)

        #expect(xml.contains("atom:link"))
        #expect(xml.contains(#"href="https://example.com/other.xml""#))
        #expect(!xml.contains("rel="))
        #expect(!xml.contains("type="))
    }

    @Test
    func xmlRepresentationIsSelfClosingTag() throws {
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        let link = AtomLink.selfLink(href: feedURL)
        let b = XMLBuilder()
        var attrs: [(String, String)] = [("href", XMLBuilder.encodeURL(link.href))]
        if let rel = link.rel { attrs.append(("rel", rel)) }
        if let type = link.type { attrs.append(("type", type)) }
        if let hreflang = link.hreflang { attrs.append(("hreflang", hreflang)) }
        if let title = link.title { attrs.append(("title", XMLBuilder.escape(title))) }
        if let length = link.length { attrs.append(("length", "\(length)")) }
        let xml = b.selfClosingElement("atom:link", attributes: attrs)

        #expect(xml.contains("/>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(AtomLink.self)
    }
}
