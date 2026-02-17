// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Testing

@testable import PodcastFeedMaker

struct AtomLinkTests {

    // MARK: - Initialization

    @Test
    func initWithAllParameters() {
        let href = makeURL("https://example.com/feed.xml")
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
    func initWithHrefOnly() {
        let href = makeURL("https://example.com/feed.xml")
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
    func selfLinkFactorySetsSelfRelAndRssType() {
        let href = makeURL("https://example.com/feed.xml")
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
    func equatableConformance() {
        let url1 = makeURL("https://example.com/a.xml")
        let url2 = makeURL("https://example.com/b.xml")

        let link1 = AtomLink(href: url1, rel: "self", type: "application/rss+xml")
        let link2 = AtomLink(href: url1, rel: "self", type: "application/rss+xml")
        let link3 = AtomLink(href: url2, rel: "alternate")

        #expect(link1 == link2)
        #expect(link1 != link3)
    }

    @Test
    func hashableConformance() {
        let url1 = makeURL("https://example.com/a.xml")
        let url2 = makeURL("https://example.com/b.xml")

        let link1 = AtomLink(href: url1, rel: "self")
        let link2 = AtomLink(href: url1, rel: "self")
        let link3 = AtomLink(href: url2, rel: "alternate")

        let set: Set = [link1, link2, link3]
        #expect(set.count == 2)
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithRelAndType() {
        let feedURL = makeURL("https://example.com/feed.xml")
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
    func xmlRepresentationWithHrefOnly() {
        let otherURL = makeURL("https://example.com/other.xml")
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
    func xmlRepresentationIsSelfClosingTag() {
        let feedURL = makeURL("https://example.com/feed.xml")
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
