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

@Suite("OPMLParser Tests")
struct OPMLParserTests {

    private let parser = OPMLParser()

    // MARK: - Basic Parsing

    @Test("Parses minimal OPML document")
    func parseMinimal() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head><title>Subscriptions</title></head>
              <body>
                <outline text="My Podcast" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)

        #expect(doc.version == "2.0")
        #expect(doc.head?.title == "Subscriptions")
        #expect(doc.outlines.count == 1)
        #expect(doc.outlines.first?.text == "My Podcast")
        #expect(doc.outlines.first?.type == "rss")
        #expect(doc.outlines.first?.xmlUrl?.absoluteString == "https://example.com/feed.xml")
    }

    @Test("Parses OPML 1.0 version")
    func parseVersion10() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="1.0">
              <body>
                <outline text="Feed" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.version == "1.0")
    }

    @Test("Parses all head elements")
    func parseAllHeadElements() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head>
                <title>My Subscriptions</title>
                <dateCreated>Sat, 18 Jun 2005 12:11:52 GMT</dateCreated>
                <dateModified>Thu, 14 Jul 2005 23:41:05 GMT</dateModified>
                <ownerName>John Doe</ownerName>
                <ownerEmail>john@example.com</ownerEmail>
                <ownerId>https://example.com/john</ownerId>
                <docs>https://opml.org/spec2.opml</docs>
                <expansionState>1,2,5</expansionState>
                <vertScrollState>3</vertScrollState>
                <windowTop>100</windowTop>
                <windowLeft>200</windowLeft>
                <windowBottom>600</windowBottom>
                <windowRight>800</windowRight>
              </head>
              <body><outline text="Test" /></body>
            </opml>
            """
        let doc = try parser.parse(xml)
        let head = try #require(doc.head)

        #expect(head.title == "My Subscriptions")
        #expect(head.dateCreated != nil)
        #expect(head.dateModified != nil)
        #expect(head.ownerName == "John Doe")
        #expect(head.ownerEmail == "john@example.com")
        #expect(head.ownerId?.absoluteString == "https://example.com/john")
        #expect(head.docs?.absoluteString == "https://opml.org/spec2.opml")
        #expect(head.expansionState == "1,2,5")
        #expect(head.vertScrollState == 3)
        #expect(head.windowTop == 100)
        #expect(head.windowLeft == 200)
        #expect(head.windowBottom == 600)
        #expect(head.windowRight == 800)
    }

    // MARK: - Outline Attributes

    @Test("Parses all standard outline attributes")
    func parseAllOutlineAttributes() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Tech Podcast"
                  type="rss"
                  xmlUrl="https://example.com/feed.xml"
                  htmlUrl="https://example.com"
                  description="A tech podcast"
                  language="en"
                  title="Tech Podcast Title"
                  version="RSS2"
                  created="Sat, 18 Jun 2005 12:11:52 GMT"
                  category="/Technology"
                  isComment="true"
                  isBreakpoint="false"
                  url="https://example.com/include.opml" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        let outline = try #require(doc.outlines.first)

        #expect(outline.text == "Tech Podcast")
        #expect(outline.type == "rss")
        #expect(outline.xmlUrl?.absoluteString == "https://example.com/feed.xml")
        #expect(outline.htmlUrl?.absoluteString == "https://example.com")
        #expect(outline.description == "A tech podcast")
        #expect(outline.language == "en")
        #expect(outline.title == "Tech Podcast Title")
        #expect(outline.version == "RSS2")
        #expect(outline.created != nil)
        #expect(outline.category == "/Technology")
        #expect(outline.isComment == true)
        #expect(outline.isBreakpoint == false)
        #expect(outline.url?.absoluteString == "https://example.com/include.opml")
    }

    @Test("Parses custom attributes")
    func parseCustomAttributes() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" overcastId="12345" pocketCastsFolderUuid="abc" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        let outline = try #require(doc.outlines.first)

        #expect(outline.customAttributes["overcastId"] == "12345")
        #expect(outline.customAttributes["pocketCastsFolderUuid"] == "abc")
    }

    // MARK: - Nested Outlines

    @Test("Parses nested outlines (categories with feeds)")
    func parseNestedOutlines() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head><title>Podcasts</title></head>
              <body>
                <outline text="Technology">
                  <outline text="ATP" type="rss"
                    xmlUrl="https://atp.fm/rss" />
                  <outline text="Connected" type="rss"
                    xmlUrl="https://relay.fm/connected/feed" />
                </outline>
                <outline text="Comedy">
                  <outline text="Show" type="rss"
                    xmlUrl="https://example.com/show.xml" />
                </outline>
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)

        #expect(doc.outlines.count == 2)
        #expect(doc.outlines[0].text == "Technology")
        #expect(doc.outlines[0].children.count == 2)
        #expect(doc.outlines[0].children[0].text == "ATP")
        #expect(doc.outlines[1].text == "Comedy")
        #expect(doc.outlines[1].children.count == 1)
    }

    @Test("Parses deeply nested outlines (3 levels)")
    func parseDeeplyNested() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Level 1">
                  <outline text="Level 2">
                    <outline text="Level 3" type="rss"
                      xmlUrl="https://example.com/feed.xml" />
                  </outline>
                </outline>
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)

        let level1 = try #require(doc.outlines.first)
        let level2 = try #require(level1.children.first)
        let level3 = try #require(level2.children.first)

        #expect(level1.text == "Level 1")
        #expect(level2.text == "Level 2")
        #expect(level3.text == "Level 3")
        #expect(level3.xmlUrl != nil)
    }

    // MARK: - Multiple Feeds (Flat)

    @Test("Parses flat list of feeds")
    func parseFlatList() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed 1" type="rss" xmlUrl="https://example.com/1.xml" />
                <outline text="Feed 2" type="rss" xmlUrl="https://example.com/2.xml" />
                <outline text="Feed 3" type="rss" xmlUrl="https://example.com/3.xml" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.outlines.count == 3)
        #expect(doc.podcastFeeds.count == 3)
    }

    // MARK: - Error Handling

    @Test("Throws for invalid XML")
    func throwsForInvalidXML() {
        let xml = "<not valid xml><<<<>>>"
        #expect(throws: OPMLParserError.self) {
            try parser.parse(xml)
        }
    }

    @Test("Throws for missing opml element")
    func throwsForMissingOPML() {
        let xml = """
            <?xml version="1.0"?>
            <rss version="2.0"><channel><title>Not OPML</title></channel></rss>
            """
        #expect(throws: OPMLParserError.self) {
            try parser.parse(xml)
        }
    }

    @Test("Throws for encoding error")
    func throwsEncodingError() {
        // Invalid UTF-8 data
        let data = Data([0xFF, 0xFE, 0x80])
        #expect(throws: OPMLParserError.self) {
            try parser.parse(data: data)
        }
    }

    // MARK: - Parse with Diagnostics

    @Test("parseWithDiagnostics returns document and warnings")
    func parseWithDiagnostics() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        let result = try parser.parseWithDiagnostics(xml)
        #expect(result.document.outlines.count == 1)
        #expect(result.warnings.isEmpty)
    }

    // MARK: - Edge Cases

    @Test("Parses OPML without head section")
    func parseWithoutHead() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.head == nil)
        #expect(doc.outlines.count == 1)
    }

    @Test("Parses OPML without version attribute defaults to 2.0")
    func parseWithoutVersion() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml>
              <body><outline text="Feed" /></body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.version == "2.0")
    }

    @Test("Handles empty text attribute")
    func emptyTextAttribute() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="" type="rss" xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.outlines.first?.text == "")
    }
}
