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

// MARK: - XMLBuilder Showcase

@Suite("XMLBuilder Showcase")
struct XMLBuilderShowcase {

    // MARK: - Static Utility Methods

    @Test("XMLBuilder.escape — preserves valid XML entities")
    func escapePreservesEntities() {
        #expect(XMLBuilder.escape("&amp;") == "&amp;")
        #expect(XMLBuilder.escape("&lt;") == "&lt;")
        #expect(XMLBuilder.escape("&gt;") == "&gt;")
        #expect(XMLBuilder.escape("&quot;") == "&quot;")
        #expect(XMLBuilder.escape("&apos;") == "&apos;")
    }

    @Test("XMLBuilder.escape — escapes raw special characters")
    func escapeRawCharacters() {
        #expect(XMLBuilder.escape("A & B") == "A &amp; B")
        #expect(XMLBuilder.escape("1 < 2") == "1 &lt; 2")
        #expect(XMLBuilder.escape("2 > 1") == "2 &gt; 1")
        #expect(XMLBuilder.escape("say \"hi\"") == "say &quot;hi&quot;")
    }

    @Test("XMLBuilder.escape — handles copyright, trademark, and smart quotes")
    func escapeSpecialChars() {
        // Copyright symbol
        #expect(XMLBuilder.escape("\u{00A9}") == "&#xA9;")
        // Trademark
        #expect(XMLBuilder.escape("\u{2122}") == "&#x2122;")
        // Sound recording copyright
        #expect(XMLBuilder.escape("\u{2117}") == "&#x2117;")
        // Right single quote
        #expect(XMLBuilder.escape("\u{2019}") == "&apos;")
        // Smart double quotes
        #expect(XMLBuilder.escape("\u{201C}") == "&quot;")
        #expect(XMLBuilder.escape("\u{201D}") == "&quot;")
    }

    @Test("XMLBuilder.escape — does not double-escape numeric character references")
    func escapeNumericRefs() {
        #expect(XMLBuilder.escape("&#xA9;") == "&#xA9;")
        #expect(XMLBuilder.escape("&#x2122;") == "&#x2122;")
        #expect(XMLBuilder.escape("&#169;") == "&#169;")
    }

    @Test("XMLBuilder.escape — converts HTML named entities to numeric")
    func escapeHTMLEntities() {
        #expect(XMLBuilder.escape("&copy;") == "&#xA9;")
        #expect(XMLBuilder.escape("&trade;") == "&#x2122;")
        #expect(XMLBuilder.escape("&reg;") == "&#xAE;")
    }

    @Test("XMLBuilder.containsHTML — detects angle bracket tags")
    func containsHTMLDetection() {
        #expect(XMLBuilder.containsHTML("<p>Hello</p>") == true)
        #expect(XMLBuilder.containsHTML("Hello > World") == true)
        #expect(XMLBuilder.containsHTML("Plain text only") == false)
        #expect(XMLBuilder.containsHTML("") == false)
    }

    @Test("XMLBuilder.encodeURL — handles standard URLs")
    func encodeURL() {
        let url = makeURL("https://example.com/path?q=hello&lang=en")
        let result = XMLBuilder.encodeURL(url)
        #expect(result.contains("https://example.com/path"))
        #expect(result.contains("q=hello"))
    }

    @Test("XMLBuilder.validateURL — accepts valid HTTP/HTTPS URLs")
    func validateURLValid() throws {
        try XMLBuilder.validateURL(makeURL("https://example.com/feed.xml"), context: "test")
        try XMLBuilder.validateURL(makeURL("http://example.com/feed.xml"), context: "test")
    }

    @Test("XMLBuilder.validateURL — rejects file URLs")
    func validateURLFile() throws {
        let fileURL = makeURL("file:///etc/passwd")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(fileURL, context: "link")
        }
    }

    @Test("XMLBuilder.validateURL — rejects non-HTTP schemes")
    func validateURLScheme() throws {
        let ftpURL = makeURL("ftp://example.com/file")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(ftpURL, context: "enclosure")
        }
    }

    @Test("XMLBuilder.formatAttributes — produces well-formed XML attribute strings")
    func formatAttributes() {
        let result = XMLBuilder.formatAttributes([
            ("href", "https://example.com"),
            ("rel", "self"),
            ("type", "application/rss+xml")
        ])
        #expect(result == " href=\"https://example.com\" rel=\"self\" type=\"application/rss+xml\"")
    }

    @Test("XMLBuilder.formatAttributes — returns empty string for empty array")
    func formatAttributesEmpty() {
        #expect(XMLBuilder.formatAttributes([]) == "")
    }

    @Test("XMLBuilder.boolYesNo — converts booleans to yes/no")
    func boolYesNo() {
        #expect(XMLBuilder.boolYesNo(true) == "yes")
        #expect(XMLBuilder.boolYesNo(false) == "no")
    }

    @Test("XMLBuilder.boolTrueFalse — converts booleans to true/false")
    func boolTrueFalse() {
        #expect(XMLBuilder.boolTrueFalse(true) == "true")
        #expect(XMLBuilder.boolTrueFalse(false) == "false")
    }

    @Test("XMLBuilder.rfc2822Date — formats date in RFC 2822 with UTC offset")
    func rfc2822Date() {
        // 2025-02-13 00:00:00 UTC
        let date = Date(timeIntervalSince1970: 1_739_404_800)
        let result = XMLBuilder.rfc2822Date(date)

        #expect(result.contains("+0000"))
        #expect(result.contains("Feb"))
        #expect(result.contains("2025"))
        #expect(result.contains("13"))
    }

    @Test("XMLBuilder.iso8601Date — formats date in ISO 8601 with Z suffix")
    func iso8601Date() {
        let date = Date(timeIntervalSince1970: 1_739_404_800)
        let result = XMLBuilder.iso8601Date(date)

        #expect(result.hasSuffix("Z"))
        #expect(result.contains("2025"))
        #expect(result.contains("-02-"))
        #expect(result.contains("T"))
    }

    // MARK: - Instance Methods

    @Test("XMLBuilder — element building with content")
    func elementBuilding() {
        let builder = XMLBuilder()
        let result = builder.element("title", content: "My Podcast")
        #expect(result == "<title>My Podcast</title>")
    }

    @Test("XMLBuilder — element building with attributes")
    func elementWithAttributes() {
        let builder = XMLBuilder()
        let result = builder.element(
            "guid",
            content: "123",
            attributes: [("isPermaLink", "false")]
        )
        #expect(result == "<guid isPermaLink=\"false\">123</guid>")
    }

    @Test("XMLBuilder — self-closing element")
    func selfClosingElement() {
        let builder = XMLBuilder()
        let result = builder.selfClosingElement(
            "enclosure",
            attributes: [
                ("url", "https://example.com/ep.mp3"),
                ("type", "audio/mpeg")
            ]
        )
        #expect(result == "<enclosure url=\"https://example.com/ep.mp3\" type=\"audio/mpeg\" />")
    }

    @Test("XMLBuilder — open and close tags")
    func openCloseTag() {
        let builder = XMLBuilder()
        #expect(builder.openTag("channel") == "<channel>")
        #expect(builder.closeTag("channel") == "</channel>")
    }

    @Test("XMLBuilder — CDATA element")
    func cdataElement() {
        let builder = XMLBuilder()
        let result = builder.cdataElement("content:encoded", content: "<p>HTML</p>")
        #expect(result == "<content:encoded><![CDATA[<p>HTML</p>]]></content:encoded>")
    }

    @Test("XMLBuilder — smart element auto-detects HTML for CDATA")
    func smartElement() {
        let builder = XMLBuilder()

        // Plain text: no CDATA
        let plain = builder.smartElement("description", content: "Plain text")
        #expect(!plain.contains("CDATA"))
        #expect(plain == "<description>Plain text</description>")

        // HTML content: CDATA wrapping
        let html = builder.smartElement("description", content: "<b>Bold</b>")
        #expect(html.contains("<![CDATA[<b>Bold</b>]]>"))
    }

    @Test("XMLBuilder — indentation with depth")
    func indentation() {
        let builder = XMLBuilder(indentString: "\t", depth: 0)
        #expect(builder.indent == "")

        let nested1 = builder.indented()
        #expect(nested1.indent == "\t")
        #expect(nested1.depth == 1)

        let nested2 = nested1.indented()
        #expect(nested2.indent == "\t\t")
        #expect(nested2.depth == 2)
    }

    @Test("XMLBuilder — custom indent string")
    func customIndent() {
        let builder = XMLBuilder(indentString: "  ", depth: 2)
        #expect(builder.indent == "    ")

        let result = builder.element("title", content: "Test")
        #expect(result == "    <title>Test</title>")
    }
}

// MARK: - Namespace Resolver Showcase

@Suite("Namespace Resolver Showcase")
struct NamespaceResolverShowcase {

    @Test("NamespaceResolver — detects iTunes namespace from channel properties")
    func resolveITunes() {
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            itunesAuthor: "Host"
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.itunes))
    }

    @Test("NamespaceResolver — detects iTunes namespace from item properties")
    func resolveITunesFromItem() {
        let item = Item(title: "Ep", itunesDuration: 600)
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            items: [item]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.itunes))
    }

    @Test("NamespaceResolver — detects Atom namespace from atomLinks")
    func resolveAtom() {
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            atomLinks: [AtomLink.selfLink(href: makeURL("https://example.com/feed"))]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.atom))
    }

    @Test("NamespaceResolver — detects Podcast NS 2.0 from channel fields")
    func resolvePodcast() {
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            podcastGuid: PodcastGuid(value: "some-guid")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.podcast))
    }

    @Test("NamespaceResolver — detects Dublin Core namespace")
    func resolveDublinCore() {
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            dublinCore: DublinCore(creator: "Author")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.dublinCore))
    }

    @Test("NamespaceResolver — detects Content namespace from item contentEncoded")
    func resolveContent() {
        let item = Item(title: "Ep", contentEncoded: ContentEncoded(value: "<p>Notes</p>"))
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            items: [item]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.content))
    }

    @Test("NamespaceResolver — detects Podlove namespace from item chapters")
    func resolvePodlove() {
        let item = Item(
            title: "Ep",
            podloveChapters: PodloveChapters(chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Start")
            ])
        )
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test.",
            items: [item]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.podloveSimpleChapters))
    }

    @Test("NamespaceResolver — empty channel produces no namespaces")
    func resolveEmpty() {
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Plain RSS only."
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.isEmpty)
    }

    @Test("NamespaceResolver — nil channel produces no namespaces")
    func resolveNilChannel() {
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.isEmpty)
    }

    @Test("NamespaceResolver — preserves custom namespaces from feed")
    func resolveCustom() {
        let channel = Channel(
            title: "Show",
            link: makeURL("https://example.com"),
            description: "Test."
        )
        let customNS = PodcastNamespace.custom("xmlns:custom=\"https://custom.example.com\"")
        let feed = PodcastFeed(
            version: "2.0",
            namespaces: [customNS],
            channel: channel
        )
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(customNS))
    }
}
