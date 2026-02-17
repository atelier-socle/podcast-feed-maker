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

// MARK: - Parser

/// Tests for ``OPMLParser`` — SAX-style OPML parsing.
@Suite("OPML Parser Showcase")
struct OPMLParserShowcase {

    @Test("Parse OPML 2.0 — standard podcast subscription list")
    func parseStandard() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <head>
                    <title>My Podcasts</title>
                    <ownerName>Jane</ownerName>
                    <ownerEmail>jane@example.com</ownerEmail>
                </head>
                <body>
                    <outline text="ATP" type="rss" \
            xmlUrl="https://atp.fm/feed" htmlUrl="https://atp.fm"/>
                    <outline text="Relay FM" type="rss" \
            xmlUrl="https://relay.fm/feed"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)

        #expect(doc.version == "2.0")
        #expect(doc.head?.title == "My Podcasts")
        #expect(doc.head?.ownerName == "Jane")
        #expect(doc.head?.ownerEmail == "jane@example.com")
        #expect(doc.outlines.count == 2)
        #expect(doc.outlines[0].text == "ATP")
        #expect(doc.outlines[0].type == "rss")
    }

    @Test("Parse OPML 1.0 — legacy format still supported")
    func parseLegacy() throws {
        let xml = """
            <?xml version="1.0"?>
            <opml version="1.0">
                <head><title>Old Format</title></head>
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)
        #expect(doc.version == "1.0")
        #expect(doc.outlines.count == 1)
    }

    @Test("Parse nested categories — Technology > Software > Favorites")
    func parseNestedCategories() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <head><title>Organized</title></head>
                <body>
                    <outline text="Technology">
                        <outline text="Software">
                            <outline text="Deep Feed" type="rss" \
            xmlUrl="https://example.com/deep.xml"/>
                        </outline>
                        <outline text="Flat Feed" type="rss" \
            xmlUrl="https://example.com/flat.xml"/>
                    </outline>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)

        #expect(doc.outlines.count == 1)
        #expect(doc.outlines[0].text == "Technology")
        #expect(doc.outlines[0].children.count == 2)
        #expect(doc.outlines[0].children[0].text == "Software")
        #expect(doc.outlines[0].children[0].children[0].text == "Deep Feed")
        #expect(doc.podcastFeeds.count == 2)
    }

    @Test("Parse custom attributes — non-standard attrs preserved")
    func parseCustomAttributes() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Overcast" type="rss" \
            xmlUrl="https://example.com/feed.xml" \
            overcastId="12345" notify="1" sortOrder="newest"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)

        let outline = doc.outlines[0]
        #expect(outline.customAttributes["overcastId"] == "12345")
        #expect(outline.customAttributes["notify"] == "1")
        #expect(outline.customAttributes["sortOrder"] == "newest")
        #expect(outline.customAttributes["text"] == nil)
        #expect(outline.customAttributes["type"] == nil)
    }

    @Test("Parse head dates — dateCreated, dateModified RFC 822")
    func parseHeadDates() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <head>
                    <dateCreated>Sat, 18 Jun 2005 12:11:52 GMT</dateCreated>
                    <dateModified>Tue, 02 Aug 2005 21:42:48 GMT</dateModified>
                </head>
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)
        #expect(doc.head?.dateCreated != nil)
        #expect(doc.head?.dateModified != nil)
    }

    @Test("Parse from Data — binary input")
    func parseFromData() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let data = try #require(xml.data(using: .utf8))
        let doc = try OPMLParser().parse(data: data)
        #expect(doc.outlines.count == 1)
    }

    @Test("Parse error — invalid XML throws OPMLParserError")
    func parseInvalidXML() {
        let broken = "<<<not xml at all>>>"
        #expect(throws: OPMLParserError.self) {
            try OPMLParser().parse(broken)
        }
    }

    @Test("Parse error — missing opml element throws missingOPMLElement")
    func parseMissingOPMLElement() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel><title>Not OPML</title></channel>
            </rss>
            """
        #expect(throws: OPMLParserError.missingOPMLElement) {
            try OPMLParser().parse(xml)
        }
    }

    @Test("Parse with diagnostics — returns document and warnings")
    func parseWithDiagnostics() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let result = try OPMLParser().parseWithDiagnostics(xml)
        #expect(result.document.outlines.count == 1)
        #expect(result.warnings.isEmpty)
    }

    @Test("Parse with diagnostics from Data")
    func parseWithDiagnosticsData() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let data = try #require(xml.data(using: .utf8))
        let result = try OPMLParser().parseWithDiagnostics(data: data)
        #expect(result.document.outlines.count == 1)
    }

    @Test("Parse head — full metadata including window state")
    func parseHeadFull() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <head>
                    <title>Full Head</title>
                    <ownerName>Jane</ownerName>
                    <ownerEmail>jane@example.com</ownerEmail>
                    <ownerId>https://example.com/jane</ownerId>
                    <docs>http://dev.opml.org/spec2.html</docs>
                    <expansionState>1,3,5</expansionState>
                    <vertScrollState>42</vertScrollState>
                    <windowTop>100</windowTop>
                    <windowLeft>200</windowLeft>
                    <windowBottom>600</windowBottom>
                    <windowRight>800</windowRight>
                </head>
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)
        let head = try #require(doc.head)

        #expect(head.title == "Full Head")
        #expect(head.ownerId == makeURL("https://example.com/jane"))
        #expect(head.docs == makeURL("http://dev.opml.org/spec2.html"))
        #expect(head.expansionState == "1,3,5")
        #expect(head.vertScrollState == 42)
        #expect(head.windowTop == 100)
        #expect(head.windowLeft == 200)
        #expect(head.windowBottom == 600)
        #expect(head.windowRight == 800)
    }

    @Test("Parse outline — isComment and isBreakpoint attributes")
    func parseIsCommentIsBreakpoint() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Comment" isComment="true"/>
                    <outline text="Break" isBreakpoint="true"/>
                    <outline text="Normal"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)

        #expect(doc.outlines[0].isComment == true)
        #expect(doc.outlines[1].isBreakpoint == true)
        #expect(doc.outlines[2].isComment == nil)
    }

    @Test("Parse outline — created, category, url, version attributes")
    func parseOutlineMetadata() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Feed" type="rss" \
            xmlUrl="https://example.com/feed.xml" \
            created="Sat, 18 Jun 2005 12:11:52 GMT" \
            category="/Technology" version="RSS2" \
            url="https://example.com/include.opml"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)
        let outline = doc.outlines[0]

        #expect(outline.created != nil)
        #expect(outline.category == "/Technology")
        #expect(outline.version == "RSS2")
        #expect(outline.url == makeURL("https://example.com/include.opml"))
    }

    @Test("Parse real-world — Overcast-style export")
    func parseOvercastStyle() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="1.0">
                <head><title>Overcast Subscriptions</title></head>
                <body>
                    <outline text="feeds">
                        <outline text="ATP" type="rss" \
            xmlUrl="https://atp.fm/episodes?format=rss" \
            overcastId="1" overcastUrl="https://overcast.fm/+abc"/>
                        <outline text="Upgrade" type="rss" \
            xmlUrl="https://relay.fm/upgrade/feed" notify="1"/>
                    </outline>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)

        #expect(doc.outlines[0].children.count == 2)
        #expect(doc.outlines[0].children[0].customAttributes["overcastId"] == "1")
        #expect(doc.outlines[0].children[1].customAttributes["notify"] == "1")
    }

    @Test("Parse — OPML without head section")
    func parseWithoutHead() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
                <body>
                    <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml"/>
                </body>
            </opml>
            """
        let doc = try OPMLParser().parse(xml)
        #expect(doc.head == nil)
        #expect(doc.outlines.count == 1)
    }
}

// MARK: - OPMLParserError

/// Tests for ``OPMLParserError`` — error descriptions and equality.
@Suite("OPML Parser Error Showcase")
struct OPMLParserErrorShowcase {

    @Test("OPMLParserError — invalidXML error description")
    func invalidXMLDescription() {
        let error = OPMLParserError.invalidXML("bad element")
        #expect(error.errorDescription?.contains("Invalid OPML XML") == true)
        #expect(error.errorDescription?.contains("bad element") == true)
    }

    @Test("OPMLParserError — missingOPMLElement error description")
    func missingOPMLDescription() {
        let error = OPMLParserError.missingOPMLElement
        #expect(error.errorDescription?.contains("Missing <opml>") == true)
    }

    @Test("OPMLParserError — encodingError error description")
    func encodingErrorDescription() {
        let error = OPMLParserError.encodingError("UTF-8 failure")
        #expect(error.errorDescription?.contains("encoding error") == true)
    }

    @Test("OPMLParserError — Equatable conformance")
    func errorEquatable() {
        let err1 = OPMLParserError.invalidXML("test")
        let err2 = OPMLParserError.invalidXML("test")
        let err3 = OPMLParserError.missingOPMLElement

        #expect(err1 == err2)
        #expect(err1 != err3)
    }
}
