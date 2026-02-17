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

// MARK: - Core Parsing Tests

@Suite("FeedParser Core Tests")
struct FeedParserCoreTests {

    let parser = FeedParser()

    // MARK: - Basic Parsing

    @Test("Parses minimal feed")
    func minimalFeed() throws {
        let xml = minimalXML
        let feed = try parser.parse(xml)
        #expect(feed.version == "2.0")
        #expect(feed.channel != nil)
        #expect(feed.channel?.title == "Minimal Podcast")
        #expect(feed.channel?.link.absoluteString == "https://example.com")
        #expect(feed.channel?.description == "A minimal podcast feed")
    }

    @Test("Parses RSS version attribute")
    func rssVersion() throws {
        let feed = try parser.parse(minimalXML)
        #expect(feed.version == "2.0")
    }

    @Test("Throws for missing channel")
    func missingChannel() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        #expect(throws: ParserError.missingChannel) {
            try parser.parse(xml)
        }
    }

    @Test("Parse from Data works with valid UTF-8")
    func parseFromData() throws {
        let data = minimalXML.data(using: .utf8)
        let feed = try parser.parse(data: data ?? Data())
        #expect(feed.channel?.title == "Minimal Podcast")
    }

    // MARK: - Namespace Detection

    @Test("Detects namespaces from xmlns declarations")
    func detectsNamespaces() throws {
        let feed = try parser.parse(maximalFixture())
        let prefixes = Set(feed.namespaces.map(\.prefix))
        #expect(prefixes.contains("itunes"))
        #expect(prefixes.contains("podcast"))
        #expect(prefixes.contains("atom"))
        #expect(prefixes.contains("dc"))
        #expect(prefixes.contains("content"))
        #expect(prefixes.contains("psc"))
    }

    // MARK: - RSS 2.0 Channel Elements

    @Test("Parses channel required elements")
    func channelRequired() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.title == "Maximal Podcast")
        #expect(ch.link.absoluteString == "https://example.com")
        #expect(ch.description == "A feed exercising every single tag")
    }

    @Test("Parses channel optional string elements")
    func channelOptionalStrings() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.language == "en-us")
        #expect(ch.copyright == "Copyright 2025 Example Inc.")
        #expect(ch.managingEditor == "editor@example.com")
        #expect(ch.webMaster == "webmaster@example.com")
        #expect(ch.generator == "PodcastFeedMaker")
    }

    @Test("Parses channel dates")
    func channelDates() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.pubDate != nil)
        #expect(ch.lastBuildDate != nil)
    }

    @Test("Parses channel numeric elements")
    func channelNumeric() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.ttl == 60)
        #expect(ch.docs?.absoluteString == "https://www.rssboard.org/rss-specification")
    }

    @Test("Parses RSS categories")
    func channelCategories() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.categories.count == 2)
        #expect(ch.categories[0].value == "Technology")
        #expect(ch.categories[0].domain == "tech")
        #expect(ch.categories[1].value == "Education")
        #expect(ch.categories[1].domain == nil)
    }

    @Test("Parses RSS cloud element")
    func channelCloud() throws {
        let feed = try parser.parse(maximalFixture())
        let cloud = try #require(feed.channel?.cloud)
        #expect(cloud.domain == "rpc.example.com")
        #expect(cloud.port == 80)
        #expect(cloud.path == "/rpc")
        #expect(cloud.registerProcedure == "notify")
        #expect(cloud.protocolType == "xml-rpc")
    }

    @Test("Parses RSS image")
    func channelImage() throws {
        let feed = try parser.parse(maximalFixture())
        let image = try #require(feed.channel?.image)
        #expect(image.url.absoluteString == "https://example.com/logo.png")
        #expect(image.title == "Maximal Podcast")
        #expect(image.link.absoluteString == "https://example.com")
        #expect(image.width == 144)
        #expect(image.height == 400)
        #expect(image.imageDescription == "Show logo")
    }

    @Test("Parses RSS textInput")
    func channelTextInput() throws {
        let feed = try parser.parse(maximalFixture())
        let ti = try #require(feed.channel?.textInput)
        #expect(ti.title == "Search")
        #expect(ti.description == "Search episodes")
        #expect(ti.name == "q")
        #expect(ti.link.absoluteString == "https://example.com/search")
    }

    @Test("Parses skipHours and skipDays")
    func skipSchedule() throws {
        let feed = try parser.parse(maximalFixture())
        let skip = try #require(feed.channel?.skipSchedule)
        #expect(skip.hours == [0, 6, 12])
        #expect(skip.days == [.saturday, .sunday])
    }

    // MARK: - iTunes Namespace

    @Test("Parses iTunes channel elements")
    func itunesChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.itunesAuthor == "John Doe")
        #expect(ch.itunesBlock == true)
        #expect(ch.itunesComplete == true)
        #expect(ch.itunesExplicit == true)
        #expect(ch.itunesImage?.absoluteString == "https://example.com/itunes-art.jpg")
        #expect(ch.itunesKeywords == ["swift", "development", "podcast"])
        #expect(ch.itunesNewFeedUrl?.absoluteString == "https://example.com/new-feed.xml")
        #expect(ch.itunesSubtitle == "A short subtitle")
        #expect(ch.itunesSummary == "A longer summary of the show")
        #expect(ch.itunesTitle == "Title Override")
        #expect(ch.itunesType == .serial)
        #expect(ch.itunesVerify == true)
    }

    @Test("Parses iTunes owner")
    func itunesOwner() throws {
        let feed = try parser.parse(maximalFixture())
        let owner = try #require(feed.channel?.itunesOwner)
        #expect(owner.name == "Jane Doe")
        #expect(owner.email == "jane@example.com")
    }

    @Test("Parses iTunes categories with subcategories")
    func itunesCategories() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.itunesCategories.count == 2)
        #expect(ch.itunesCategories[0].text == "Technology")
        #expect(ch.itunesCategories[0].subcategories.count == 1)
        #expect(ch.itunesCategories[0].subcategories[0].text == "Tech News")
        #expect(ch.itunesCategories[1].text == "Education")
    }

    // MARK: - Atom Namespace

    @Test("Parses atom links")
    func atomLinks() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.atomLinks.count == 2)
        let selfLink = ch.atomLinks.first {
            $0.rel == "self"
        }
        #expect(selfLink != nil)
        #expect(selfLink?.href.absoluteString == "https://example.com/feed.xml")
        #expect(selfLink?.type == "application/rss+xml")
    }

    // MARK: - Dublin Core

    @Test("Parses Dublin Core channel elements")
    func dublinCoreChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let dc = try #require(feed.channel?.dublinCore)
        #expect(dc.creator == "John Doe")
        #expect(dc.contributor == "Jane Doe")
        #expect(dc.date == "2025-01-01")
        #expect(dc.description == "DC description")
        #expect(dc.format == "audio/mpeg")
        #expect(dc.identifier == "urn:uuid:12345")
        #expect(dc.language == "en")
        #expect(dc.publisher == "Example Publisher")
        #expect(dc.relation == "https://related.example.com")
        #expect(dc.rights == "All rights reserved")
        #expect(dc.source == "https://source.example.com")
        #expect(dc.subject == "Technology")
        #expect(dc.title == "DC Title")
        #expect(dc.type == "Sound")
        #expect(dc.coverage == "Worldwide")
    }

    // MARK: - Helpers

    private var minimalXML: String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Minimal Podcast</title>
            <link>https://example.com</link>
            <description>A minimal podcast feed</description>
          </channel>
        </rss>
        """
    }

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
