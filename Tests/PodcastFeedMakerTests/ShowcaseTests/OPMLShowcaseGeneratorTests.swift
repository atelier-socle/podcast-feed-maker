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

// MARK: - Generator

/// Tests for ``OPMLGenerator`` — XML generation from ``OPMLDocument``.
@Suite("OPML Generator Showcase")
struct OPMLGeneratorShowcase {

    @Test("Generate OPML 2.0 — complete document with head and body")
    func generateComplete() throws {
        let head = OPMLHead(
            title: "My Podcasts",
            dateCreated: Date(timeIntervalSince1970: 1_700_000_000),
            ownerName: "Jane",
            ownerEmail: "jane@example.com"
        )
        let doc = OPMLDocument(
            head: head,
            outlines: [
                OPMLOutline(
                    text: "Feed",
                    type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml")
                )
            ]
        )

        let xml = OPMLGenerator().generate(doc)

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<opml version=\"2.0\">"))
        #expect(xml.contains("<title>My Podcasts</title>"))
        #expect(xml.contains("<ownerName>Jane</ownerName>"))
        #expect(xml.contains("<ownerEmail>jane@example.com</ownerEmail>"))
        #expect(xml.contains("text=\"Feed\""))
        #expect(xml.contains("type=\"rss\""))
        #expect(xml.contains("</opml>"))
    }

    @Test("Generate compact — no pretty-print")
    func generateCompact() {
        let doc = OPMLDocument(
            outlines: [OPMLOutline(text: "Feed")]
        )
        let xml = OPMLGenerator(prettyPrint: false).generate(doc)
        #expect(!xml.contains("\n"))
    }

    @Test("Generate without XML declaration")
    func generateNoDeclaration() {
        let doc = OPMLDocument(outlines: [OPMLOutline(text: "Feed")])
        let xml = OPMLGenerator(includeXMLDeclaration: false).generate(doc)
        #expect(!xml.contains("<?xml"))
        #expect(xml.hasPrefix("<opml"))
    }

    @Test("Generate XML escaping — ampersand, quotes in attributes")
    func generateEscaping() {
        let doc = OPMLDocument(
            outlines: [
                OPMLOutline(
                    text: "Tom & Jerry's \"Podcast\"",
                    description: "A <great> show"
                )
            ]
        )
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("Tom &amp; Jerry's &quot;Podcast&quot;"))
        #expect(xml.contains("A &lt;great&gt; show"))
    }

    @Test("Generate recursive outlines — nested categories")
    func generateNested() {
        let feed = OPMLOutline(
            text: "Feed",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml")
        )
        let category = OPMLOutline(text: "Tech", children: [feed])
        let doc = OPMLDocument(outlines: [category])

        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("<outline text=\"Tech\">"))
        #expect(xml.contains("</outline>"))
        #expect(xml.contains("text=\"Feed\""))
    }

    @Test("Generate self-closing tags — leaf outlines")
    func generateSelfClosing() {
        let doc = OPMLDocument(
            outlines: [OPMLOutline(text: "Leaf")]
        )
        let xml = OPMLGenerator().generate(doc)
        let lines = xml.components(separatedBy: "\n")
        let outlineLines = lines.filter { $0.contains("text=\"Leaf\"") }
        #expect(outlineLines.count == 1)
        #expect(outlineLines[0].contains("/>"))
    }

    @Test("Generate custom attributes — sorted for deterministic output")
    func generateCustomAttributes() {
        let doc = OPMLDocument(
            outlines: [
                OPMLOutline(
                    text: "Feed",
                    customAttributes: ["zebra": "z", "alpha": "a", "middle": "m"]
                )
            ]
        )
        let xml = OPMLGenerator().generate(doc)
        let outlineLine =
            xml.components(separatedBy: "\n")
            .first { $0.contains("text=\"Feed\"") } ?? ""
        let alphaPos = outlineLine.range(of: "alpha=")?.lowerBound
        let middlePos = outlineLine.range(of: "middle=")?.lowerBound
        let zebraPos = outlineLine.range(of: "zebra=")?.lowerBound
        if let a = alphaPos, let m = middlePos, let z = zebraPos {
            #expect(a < m)
            #expect(m < z)
        }
    }

    @Test("Generate empty document — minimal valid OPML")
    func generateEmpty() {
        let doc = OPMLDocument()
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("<opml version=\"2.0\">"))
        #expect(xml.contains("<body>"))
        #expect(xml.contains("</body>"))
        #expect(xml.contains("</opml>"))
    }

    @Test("Generate head — dates formatted as RFC 2822")
    func generateHeadDates() {
        let doc = OPMLDocument(
            head: OPMLHead(
                title: "Test",
                dateCreated: Date(timeIntervalSince1970: 1_700_000_000),
                dateModified: Date(timeIntervalSince1970: 1_700_100_000)
            )
        )
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("<dateCreated>"))
        #expect(xml.contains("<dateModified>"))
    }

    @Test("Generate head — ownerId and docs URL elements")
    func generateHeadURLs() {
        let doc = OPMLDocument(
            head: OPMLHead(
                ownerId: makeURL("https://example.com/owner"),
                docs: makeURL("http://dev.opml.org/spec2.html")
            )
        )
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("<ownerId>https://example.com/owner</ownerId>"))
        #expect(xml.contains("<docs>http://dev.opml.org/spec2.html</docs>"))
    }

    @Test("Generate head — window state elements")
    func generateHeadWindowState() {
        let doc = OPMLDocument(
            head: OPMLHead(
                expansionState: "1,3,5",
                vertScrollState: 42,
                windowTop: 100,
                windowLeft: 200,
                windowBottom: 600,
                windowRight: 800
            )
        )
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("<expansionState>1,3,5</expansionState>"))
        #expect(xml.contains("<vertScrollState>42</vertScrollState>"))
        #expect(xml.contains("<windowTop>100</windowTop>"))
        #expect(xml.contains("<windowLeft>200</windowLeft>"))
        #expect(xml.contains("<windowBottom>600</windowBottom>"))
        #expect(xml.contains("<windowRight>800</windowRight>"))
    }

    @Test("Generate outline — metadata attributes")
    func generateOutlineMetadata() {
        let doc = OPMLDocument(
            outlines: [
                OPMLOutline(
                    text: "Annotated",
                    created: Date(timeIntervalSince1970: 1_700_000_000),
                    category: "/Tech",
                    isComment: true,
                    isBreakpoint: false,
                    url: makeURL("https://example.com/include.opml")
                )
            ]
        )
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("created=\""))
        #expect(xml.contains("category=\"/Tech\""))
        #expect(xml.contains("isComment=\"true\""))
        #expect(xml.contains("isBreakpoint=\"false\""))
        #expect(xml.contains("url=\"https://example.com/include.opml\""))
    }

    @Test("Generate outline — all feed attributes")
    func generateOutlineFeedAttributes() {
        let doc = OPMLDocument(
            outlines: [
                OPMLOutline(
                    text: "Full Feed",
                    type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml"),
                    htmlUrl: makeURL("https://example.com"),
                    description: "A podcast",
                    language: "en-US",
                    title: "Full Feed Title",
                    version: "RSS2"
                )
            ]
        )
        let xml = OPMLGenerator().generate(doc)
        #expect(xml.contains("type=\"rss\""))
        #expect(xml.contains("xmlUrl=\"https://example.com/feed.xml\""))
        #expect(xml.contains("htmlUrl=\"https://example.com\""))
        #expect(xml.contains("description=\"A podcast\""))
        #expect(xml.contains("language=\"en-US\""))
        #expect(xml.contains("title=\"Full Feed Title\""))
        #expect(xml.contains("version=\"RSS2\""))
    }
}
