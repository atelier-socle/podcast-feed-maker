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

@Suite("OPMLGenerator Tests")
struct OPMLGeneratorTests {

    private let generator = OPMLGenerator()

    // MARK: - Basic Generation

    @Test("Generates minimal OPML document")
    func generateMinimal() {
        let doc = OPMLDocument(
            outlines: [
                OPMLOutline(
                    text: "My Podcast", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml"))
            ]
        )
        let xml = generator.generate(doc)

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<opml version=\"2.0\">"))
        #expect(xml.contains("</opml>"))
        #expect(xml.contains("<body>"))
        #expect(xml.contains("</body>"))
        #expect(xml.contains("text=\"My Podcast\""))
        #expect(xml.contains("type=\"rss\""))
        #expect(xml.contains("xmlUrl=\"https://example.com/feed.xml\""))
    }

    @Test("Generates with head section")
    func generateWithHead() {
        let doc = OPMLDocument(
            head: OPMLHead(
                title: "Subscriptions",
                ownerName: "John Doe",
                ownerEmail: "john@example.com"
            ),
            outlines: []
        )
        let xml = generator.generate(doc)

        #expect(xml.contains("<head>"))
        #expect(xml.contains("<title>Subscriptions</title>"))
        #expect(xml.contains("<ownerName>John Doe</ownerName>"))
        #expect(xml.contains("<ownerEmail>john@example.com</ownerEmail>"))
        #expect(xml.contains("</head>"))
    }

    @Test("Generates head with dates in RFC 2822 format")
    func generateHeadDates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        let components = DateComponents(year: 2025, month: 3, day: 18, hour: 12, minute: 0, second: 0)
        let date = calendar.date(from: components)

        let doc = OPMLDocument(
            head: OPMLHead(dateCreated: date, dateModified: date),
            outlines: []
        )
        let xml = generator.generate(doc)

        #expect(xml.contains("<dateCreated>"))
        #expect(xml.contains("18 Mar 2025"))
        #expect(xml.contains("<dateModified>"))
    }

    @Test("Generates head with all window state fields")
    func generateWindowState() {
        let doc = OPMLDocument(
            head: OPMLHead(
                expansionState: "1,2,5",
                vertScrollState: 3,
                windowTop: 100,
                windowLeft: 200,
                windowBottom: 600,
                windowRight: 800
            ),
            outlines: []
        )
        let xml = generator.generate(doc)

        #expect(xml.contains("<expansionState>1,2,5</expansionState>"))
        #expect(xml.contains("<vertScrollState>3</vertScrollState>"))
        #expect(xml.contains("<windowTop>100</windowTop>"))
        #expect(xml.contains("<windowLeft>200</windowLeft>"))
        #expect(xml.contains("<windowBottom>600</windowBottom>"))
        #expect(xml.contains("<windowRight>800</windowRight>"))
    }

    // MARK: - Outline Generation

    @Test("Generates nested outlines")
    func generateNested() {
        let feed = OPMLOutline(
            text: "ATP", type: "rss",
            xmlUrl: makeURL("https://atp.fm/rss"))
        let category = OPMLOutline(text: "Technology", children: [feed])
        let doc = OPMLDocument(outlines: [category])
        let xml = generator.generate(doc)

        #expect(xml.contains("<outline text=\"Technology\">"))
        #expect(xml.contains("text=\"ATP\""))
        #expect(xml.contains("</outline>"))
    }

    @Test("Generates self-closing leaf outlines")
    func generateSelfClosingLeaf() {
        let doc = OPMLDocument(
            outlines: [OPMLOutline(text: "Leaf")]
        )
        let xml = generator.generate(doc)

        #expect(xml.contains("<outline text=\"Leaf\" />"))
    }

    @Test("Generates all outline attributes")
    func generateAllOutlineAttributes() {
        let outline = OPMLOutline(
            text: "Feed",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            htmlUrl: makeURL("https://example.com"),
            description: "A feed",
            language: "en",
            title: "Feed Title",
            version: "RSS2",
            category: "/Tech",
            isComment: true,
            isBreakpoint: false,
            url: makeURL("https://example.com/include.opml")
        )
        let doc = OPMLDocument(outlines: [outline])
        let xml = generator.generate(doc)

        #expect(xml.contains("text=\"Feed\""))
        #expect(xml.contains("type=\"rss\""))
        #expect(xml.contains("xmlUrl=\"https://example.com/feed.xml\""))
        #expect(xml.contains("htmlUrl=\"https://example.com\""))
        #expect(xml.contains("description=\"A feed\""))
        #expect(xml.contains("language=\"en\""))
        #expect(xml.contains("title=\"Feed Title\""))
        #expect(xml.contains("version=\"RSS2\""))
        #expect(xml.contains("category=\"/Tech\""))
        #expect(xml.contains("isComment=\"true\""))
        #expect(xml.contains("isBreakpoint=\"false\""))
        #expect(xml.contains("url=\"https://example.com/include.opml\""))
    }

    @Test("Generates custom attributes sorted alphabetically")
    func generateCustomAttributes() {
        let outline = OPMLOutline(
            text: "Feed",
            customAttributes: ["zebra": "1", "alpha": "2"]
        )
        let doc = OPMLDocument(outlines: [outline])
        let xml = generator.generate(doc)

        // alpha should come before zebra
        let alphaRange = xml.range(of: "alpha=\"2\"")
        let zebraRange = xml.range(of: "zebra=\"1\"")
        #expect(alphaRange != nil)
        #expect(zebraRange != nil)
        if let a = alphaRange, let z = zebraRange {
            #expect(a.lowerBound < z.lowerBound)
        }
    }

    // MARK: - Options

    @Test("Generates without XML declaration")
    func generateWithoutDeclaration() {
        let gen = OPMLGenerator(includeXMLDeclaration: false)
        let doc = OPMLDocument(outlines: [])
        let xml = gen.generate(doc)

        #expect(!xml.contains("<?xml"))
        #expect(xml.hasPrefix("<opml"))
    }

    @Test("Generates compact output without pretty printing")
    func generateCompact() {
        let gen = OPMLGenerator(prettyPrint: false)
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [OPMLOutline(text: "Feed")]
        )
        let xml = gen.generate(doc)

        // Should not contain tab or newline-based indentation
        #expect(!xml.contains("\t"))
    }

    // MARK: - Escaping

    @Test("Escapes special characters in attributes")
    func escapesSpecialChars() {
        let outline = OPMLOutline(text: "Feed & \"Friends\" <Show>")
        let doc = OPMLDocument(outlines: [outline])
        let xml = generator.generate(doc)

        #expect(xml.contains("Feed &amp; &quot;Friends&quot; &lt;Show&gt;"))
    }

    @Test("Escapes special characters in head elements")
    func escapesHeadContent() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Feeds & More"),
            outlines: []
        )
        let xml = generator.generate(doc)

        #expect(xml.contains("Feeds &amp; More"))
    }
}
