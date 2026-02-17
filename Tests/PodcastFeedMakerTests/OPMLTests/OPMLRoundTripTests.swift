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

@Suite("OPML Round-Trip Tests")
struct OPMLRoundTripTests {

    private let parser = OPMLParser()
    private let generator = OPMLGenerator()

    // MARK: - Parse → Generate → Parse → Equal

    @Test("Round-trip preserves minimal document")
    func roundTripMinimal() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" type="rss" xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        #expect(parsed1 == parsed2)
    }

    @Test("Round-trip preserves head metadata")
    func roundTripHead() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head>
                <title>My Podcasts</title>
                <ownerName>Jane Doe</ownerName>
                <ownerEmail>jane@example.com</ownerEmail>
                <expansionState>1,3,5</expansionState>
                <vertScrollState>7</vertScrollState>
                <windowTop>50</windowTop>
                <windowLeft>100</windowLeft>
                <windowBottom>500</windowBottom>
                <windowRight>700</windowRight>
              </head>
              <body>
                <outline text="Feed" />
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        #expect(parsed1.head?.title == parsed2.head?.title)
        #expect(parsed1.head?.ownerName == parsed2.head?.ownerName)
        #expect(parsed1.head?.ownerEmail == parsed2.head?.ownerEmail)
        #expect(parsed1.head?.expansionState == parsed2.head?.expansionState)
        #expect(parsed1.head?.vertScrollState == parsed2.head?.vertScrollState)
        #expect(parsed1.head?.windowTop == parsed2.head?.windowTop)
        #expect(parsed1.head?.windowLeft == parsed2.head?.windowLeft)
        #expect(parsed1.head?.windowBottom == parsed2.head?.windowBottom)
        #expect(parsed1.head?.windowRight == parsed2.head?.windowRight)
    }

    @Test("Round-trip preserves nested outlines")
    func roundTripNested() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Technology">
                  <outline text="ATP" type="rss" xmlUrl="https://atp.fm/rss" />
                  <outline text="Connected" type="rss" xmlUrl="https://relay.fm/connected/feed" />
                </outline>
                <outline text="Comedy">
                  <outline text="Show" type="rss" xmlUrl="https://example.com/show.xml" />
                </outline>
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        #expect(parsed1.outlines.count == parsed2.outlines.count)
        #expect(parsed1.outlines[0].children.count == parsed2.outlines[0].children.count)
        #expect(parsed1.outlines[1].children.count == parsed2.outlines[1].children.count)
        #expect(parsed1.podcastFeeds.count == parsed2.podcastFeeds.count)
    }

    @Test("Round-trip preserves all outline attributes")
    func roundTripOutlineAttributes() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Full Feed"
                  type="rss"
                  xmlUrl="https://example.com/feed.xml"
                  htmlUrl="https://example.com"
                  description="A podcast"
                  language="en-US"
                  title="Full Feed Title"
                  version="RSS2"
                  category="/Technology/Podcasts"
                  isComment="false"
                  isBreakpoint="false" />
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        let o1 = try #require(parsed1.outlines.first)
        let o2 = try #require(parsed2.outlines.first)

        #expect(o1.text == o2.text)
        #expect(o1.type == o2.type)
        #expect(o1.xmlUrl == o2.xmlUrl)
        #expect(o1.htmlUrl == o2.htmlUrl)
        #expect(o1.description == o2.description)
        #expect(o1.language == o2.language)
        #expect(o1.title == o2.title)
        #expect(o1.version == o2.version)
        #expect(o1.category == o2.category)
        #expect(o1.isComment == o2.isComment)
        #expect(o1.isBreakpoint == o2.isBreakpoint)
    }

    @Test("Round-trip preserves custom attributes")
    func roundTripCustomAttributes() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" overcastId="12345" myApp="custom" />
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        let o1 = try #require(parsed1.outlines.first)
        let o2 = try #require(parsed2.outlines.first)

        #expect(o1.customAttributes == o2.customAttributes)
    }

    @Test("Round-trip preserves OPML version")
    func roundTripVersion() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="1.1">
              <body>
                <outline text="Feed" />
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        #expect(parsed1.version == parsed2.version)
        #expect(parsed1.version == "1.1")
    }

    @Test("Round-trip preserves deeply nested structure")
    func roundTripDeepNesting() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="L1">
                  <outline text="L2">
                    <outline text="L3">
                      <outline text="L4" type="rss" xmlUrl="https://example.com/deep.xml" />
                    </outline>
                  </outline>
                </outline>
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        #expect(parsed1.totalOutlineCount == parsed2.totalOutlineCount)
        #expect(parsed1.totalOutlineCount == 4)
        #expect(parsed1.podcastFeeds.count == parsed2.podcastFeeds.count)
    }

    @Test("Round-trip preserves special characters in text")
    func roundTripSpecialChars() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed &amp; Friends" />
              </body>
            </opml>
            """
        let parsed1 = try parser.parse(xml)
        let generated = generator.generate(parsed1)
        let parsed2 = try parser.parse(generated)

        #expect(parsed1.outlines.first?.text == "Feed & Friends")
        #expect(parsed2.outlines.first?.text == "Feed & Friends")
    }
}
