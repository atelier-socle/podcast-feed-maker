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

@Suite("OPML Edge Case Tests")
struct OPMLEdgeCaseTests {

    private let parser = OPMLParser()
    private let generator = OPMLGenerator()

    // MARK: - App-Specific OPML Formats

    @Test("Parses Overcast-style OPML with custom attributes")
    func overcastStyle() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="1.0">
              <head><title>Overcast Podcast Subscriptions</title></head>
              <body>
                <outline text="feeds">
                  <outline text="ATP" type="rss"
                    xmlUrl="https://atp.fm/rss"
                    htmlUrl="https://atp.fm"
                    overcastId="123456"
                    overcastAddedDate="2023-01-15" />
                  <outline text="The Talk Show" type="rss"
                    xmlUrl="https://daringfireball.net/thetalkshow/rss"
                    overcastId="789012" />
                </outline>
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)

        #expect(doc.version == "1.0")
        #expect(doc.outlines.count == 1)
        #expect(doc.outlines.first?.text == "feeds")
        #expect(doc.podcastFeeds.count == 2)

        let atp = doc.podcastFeeds.first
        #expect(atp?.customAttributes["overcastId"] == "123456")
        #expect(atp?.customAttributes["overcastAddedDate"] == "2023-01-15")
    }

    @Test("Parses Pocket Casts-style OPML with folder categories")
    func pocketCastsStyle() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="1.0">
              <head>
                <title>Pocket Casts Feeds</title>
              </head>
              <body>
                <outline text="Tech" category="Technology">
                  <outline type="rss" text="ATP"
                    xmlUrl="https://atp.fm/rss"
                    htmlUrl="https://atp.fm" />
                </outline>
                <outline text="Comedy" category="Entertainment">
                  <outline type="rss" text="Comedy Show"
                    xmlUrl="https://example.com/comedy.xml" />
                </outline>
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)

        #expect(doc.outlines.count == 2)
        #expect(doc.outlines[0].category == "Technology")
        #expect(doc.outlines[1].category == "Entertainment")
        #expect(doc.podcastFeeds.count == 2)
    }

    @Test("Parses Apple Podcasts-style OPML")
    func applePodcastsStyle() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="1.0">
              <head>
                <title>My Apple Podcasts Subscriptions</title>
              </head>
              <body>
                <outline text="podcasts">
                  <outline type="rss" text="The Daily"
                    title="The Daily"
                    xmlUrl="https://feeds.simplecast.com/54nAGcIl"
                    htmlUrl="https://www.nytimes.com/the-daily" />
                  <outline type="rss" text="Serial"
                    title="Serial"
                    xmlUrl="https://feeds.serialpodcast.org/serialpodcast"
                    htmlUrl="https://serialpodcast.org" />
                </outline>
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.podcastFeeds.count == 2)
        #expect(doc.podcastFeeds[0].title == "The Daily")
    }

    // MARK: - Scale

    @Test("Handles document with 100+ feeds")
    func largeFeedList() throws {
        var outlines = ""
        for i in 1...150 {
            outlines += """
                <outline text="Podcast \(i)" type="rss"
                  xmlUrl="https://example.com/feed\(i).xml" />\n
                """
        }

        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                \(outlines)
              </body>
            </opml>
            """

        let doc = try parser.parse(xml)
        #expect(doc.outlines.count == 150)
        #expect(doc.podcastFeeds.count == 150)

        // Round-trip
        let generated = generator.generate(doc)
        let reparsed = try parser.parse(generated)
        #expect(reparsed.outlines.count == 150)
    }

    // MARK: - Deep Nesting

    @Test("Handles 10-level deep nesting")
    func deepNesting() throws {
        var xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0"><body>
            """
        for i in 1...10 {
            xml += "<outline text=\"Level \(i)\">"
        }
        xml += "<outline text=\"Deep Leaf\" type=\"rss\" xmlUrl=\"https://example.com/deep.xml\" />"
        for _ in 1...10 {
            xml += "</outline>"
        }
        xml += "</body></opml>"

        let doc = try parser.parse(xml)
        #expect(doc.totalOutlineCount == 11)
        #expect(doc.podcastFeeds.count == 1)
        #expect(doc.podcastFeeds.first?.text == "Deep Leaf")
    }

    // MARK: - HTML Entities

    @Test("Handles XML entities in text attributes")
    func xmlEntitiesInText() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Tom &amp; Jerry&#39;s Show" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.outlines.first?.text == "Tom & Jerry's Show")
    }

    @Test("Handles Unicode in text attributes")
    func unicodeInText() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="日本語ポッドキャスト" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.outlines.first?.text == "日本語ポッドキャスト")
    }

    // MARK: - Empty / Minimal Documents

    @Test("Handles empty body")
    func emptyBody() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head><title>Empty</title></head>
              <body></body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.outlines.isEmpty)
        #expect(doc.head?.title == "Empty")
    }

    @Test("Handles document with only empty head")
    func onlyEmptyHead() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head></head>
              <body><outline text="Test" /></body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.head == nil)
        #expect(doc.outlines.count == 1)
    }

    // MARK: - Mixed Content

    @Test("Handles mix of flat and categorized feeds")
    func mixedFlatAndCategorized() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Standalone" type="rss"
                  xmlUrl="https://example.com/standalone.xml" />
                <outline text="Category">
                  <outline text="Grouped" type="rss"
                    xmlUrl="https://example.com/grouped.xml" />
                </outline>
              </body>
            </opml>
            """
        let doc = try parser.parse(xml)
        #expect(doc.outlines.count == 2)
        #expect(doc.podcastFeeds.count == 2)
    }

    // MARK: - Outline Computed Properties

    @Test("OPMLOutline.isLeaf returns true for leaf nodes")
    func outlineIsLeaf() {
        let leaf = OPMLOutline(text: "Leaf")
        let parent = OPMLOutline(text: "Parent", children: [leaf])

        #expect(leaf.isLeaf)
        #expect(!parent.isLeaf)
    }

    @Test("OPMLOutline.isPodcastFeed checks type and xmlUrl")
    func outlineIsPodcastFeed() {
        let feed = OPMLOutline(
            text: "Feed", type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"))
        let rssNoUrl = OPMLOutline(text: "No URL", type: "rss")
        let urlNoType = OPMLOutline(
            text: "No Type",
            xmlUrl: makeURL("https://example.com/feed.xml"))
        let category = OPMLOutline(text: "Category")

        #expect(feed.isPodcastFeed)
        #expect(!rssNoUrl.isPodcastFeed)
        #expect(!urlNoType.isPodcastFeed)
        #expect(!category.isPodcastFeed)
    }

    @Test("OPMLOutline.allLeaves traverses tree")
    func allLeaves() {
        let leaf1 = OPMLOutline(text: "L1")
        let leaf2 = OPMLOutline(text: "L2")
        let parent = OPMLOutline(text: "P", children: [leaf1, leaf2])
        let root = OPMLOutline(text: "R", children: [parent])

        #expect(root.allLeaves.count == 2)
        #expect(root.allLeaves.map(\.text) == ["L1", "L2"])
    }

    @Test("OPMLOutline.allOutlines includes self")
    func allOutlinesIncludesSelf() {
        let child = OPMLOutline(text: "Child")
        let parent = OPMLOutline(text: "Parent", children: [child])

        let all = parent.allOutlines
        #expect(all.count == 2)
        #expect(all.first?.text == "Parent")
        #expect(all.last?.text == "Child")
    }
}
