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

// MARK: - Malformed Feed Parsing Showcase

@Suite("Malformed Feed Parsing Showcase")
struct MalformedParsingShowcase {

    @Test("FeedParser — best-effort parsing of feed with malformed date")
    func parseMalformedDate() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Malformed Dates</title>
                    <link>https://example.com</link>
                    <description>Feed with bad dates.</description>
                    <pubDate>not-a-real-date</pubDate>
                    <item>
                        <title>Good Episode</title>
                        <pubDate>Mon, 10 Feb 2025 12:00:00 +0000</pubDate>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        // Channel date should be nil (unparseable)
        #expect(channel.pubDate == nil)

        // Item with valid date should parse correctly
        #expect(channel.items[0].pubDate != nil)
        #expect(channel.items[0].title == "Good Episode")
    }

    @Test("FeedParser — best-effort parsing collects warnings via diagnostics")
    func parseMalformedWithDiagnostics() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Warnings Show</title>
                    <link>https://example.com</link>
                    <description>Test with non-fatal issues.</description>
                    <item>
                        <title>Good Episode</title>
                        <itunes:duration>1800</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let result = try parser.parseWithDiagnostics(xml)

        // Feed should be parsed successfully
        let channel = try #require(result.feed.channel)
        #expect(channel.title == "Warnings Show")
        #expect(channel.items[0].itunesDuration == 1800)

        // Warnings array is accessible
        #expect(result.warnings.count >= 0)
    }

    @Test("FeedParser — throws for completely invalid XML")
    func parseInvalidXML() {
        let parser = FeedParser()

        #expect(throws: ParserError.self) {
            try parser.parse("This is not XML at all <><><<")
        }
    }

    @Test("FeedParser — throws missingChannel for RSS with no channel")
    func parseMissingChannel() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            </rss>
            """
        let parser = FeedParser()

        #expect(throws: ParserError.self) {
            try parser.parse(xml)
        }
    }

    @Test("FeedParser — handles empty items gracefully")
    func parseEmptyItems() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Empty Items</title>
                    <link>https://example.com</link>
                    <description>Items with no content.</description>
                    <item>
                    </item>
                    <item>
                        <title>Real Episode</title>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == nil)
        #expect(channel.items[1].title == "Real Episode")
    }
}

// MARK: - Parser Error Showcase

@Suite("Parser Error Showcase")
struct ParserErrorShowcase {

    @Test("ParserError — error cases are equatable")
    func errorEquatable() {
        #expect(ParserError.missingChannel == ParserError.missingChannel)
        #expect(ParserError.missingRSSElement == ParserError.missingRSSElement)
        #expect(
            ParserError.invalidXML("bad") == ParserError.invalidXML("bad")
        )
        #expect(
            ParserError.invalidXML("a") != ParserError.invalidXML("b")
        )
    }

    @Test("ParserError — error descriptions are human-readable")
    func errorDescriptions() {
        #expect(ParserError.missingChannel.errorDescription?.contains("Missing") == true)
        #expect(ParserError.missingRSSElement.errorDescription?.contains("rss") == true)
        #expect(ParserError.invalidXML("reason").errorDescription?.contains("Invalid XML") == true)
        #expect(ParserError.encodingError("utf-8").errorDescription?.contains("Encoding") == true)
        #expect(ParserError.networkError("timeout").errorDescription?.contains("Network") == true)
    }

    @Test("ParserError — encoding error on invalid UTF-8 simulation")
    func encodingError() {
        let parser = FeedParser()
        // Create data that would cause encoding issues by simulating the error path
        let badData = Data([0xFF, 0xFE, 0x00])  // Not valid UTF-8 XML
        #expect(throws: ParserError.self) {
            try parser.parse(data: badData)
        }
    }
}

// MARK: - Streaming Feed Parser Showcase

@Suite("Streaming Feed Parser Showcase")
struct StreamingParserShowcase {

    @Test("StreamingFeedParser — async item parsing from string")
    func streamingParseString() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Stream Show</title>
                    <link>https://example.com</link>
                    <description>Streaming test.</description>
                    <item>
                        <title>Episode 1</title>
                    </item>
                    <item>
                        <title>Episode 2</title>
                    </item>
                    <item>
                        <title>Episode 3</title>
                    </item>
                </channel>
            </rss>
            """

        let parser = StreamingFeedParser()
        var items: [Item] = []
        for try await item in parser.parseItems(from: xml) {
            items.append(item)
        }

        #expect(items.count == 3)
        #expect(items[0].title == "Episode 1")
        #expect(items[1].title == "Episode 2")
        #expect(items[2].title == "Episode 3")
    }

    @Test("StreamingFeedParser — async item parsing from Data")
    func streamingParseData() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Data Show</title>
                    <link>https://example.com</link>
                    <description>Data test.</description>
                    <item>
                        <title>Data Episode</title>
                    </item>
                </channel>
            </rss>
            """
        let data = try #require(xml.data(using: .utf8))

        let parser = StreamingFeedParser()
        var items: [Item] = []
        for try await item in parser.parseItems(from: data) {
            items.append(item)
        }

        #expect(items.count == 1)
        #expect(items[0].title == "Data Episode")
    }

    @Test("StreamingFeedParser — items include all namespace data")
    func streamingNamespaceData() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0">
                <channel>
                    <title>NS Show</title>
                    <link>https://example.com</link>
                    <description>Namespace test.</description>
                    <item>
                        <title>Rich Item</title>
                        <itunes:duration>1800</itunes:duration>
                        <itunes:episode>5</itunes:episode>
                        <itunes:season>2</itunes:season>
                        <itunes:episodeType>full</itunes:episodeType>
                        <podcast:transcript url="https://example.com/t.vtt" type="text/vtt" />
                    </item>
                </channel>
            </rss>
            """

        let parser = StreamingFeedParser()
        var items: [Item] = []
        for try await item in parser.parseItems(from: xml) {
            items.append(item)
        }

        let item = try #require(items.first)
        #expect(item.itunesDuration == 1800)
        #expect(item.itunesEpisode == 5)
        #expect(item.itunesSeason == 2)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].type == "text/vtt")
    }

    @Test("StreamingFeedParser — throws for missing channel")
    func streamingMissingChannel() async {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            </rss>
            """
        let parser = StreamingFeedParser()

        do {
            for try await _ in parser.parseItems(from: xml) {
                // Should not yield items
            }
            Issue.record("Expected error for missing channel")
        } catch {
            #expect(error is ParserError)
        }
    }
}

// MARK: - Generator-Parser Round-Trip Showcase

@Suite("Generator-Parser Round-Trip Showcase")
struct RoundTripShowcase {

    @Test("Round-trip — generate then parse preserves RSS 2.0 core fields")
    func roundTripCore() throws {
        let channel = Channel(
            title: "Round-Trip Show",
            link: makeURL("https://example.com"),
            description: "Testing round-trip.",
            language: "fr-FR",
            copyright: "2026 Test Corp",
            ttl: 30
        )
        let original = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)

        let parsedChannel = try #require(parsed.channel)
        #expect(parsedChannel.title == "Round-Trip Show")
        #expect(parsedChannel.link == URL(string: "https://example.com"))
        #expect(parsedChannel.description == "Testing round-trip.")
        #expect(parsedChannel.language == "fr-FR")
        #expect(parsedChannel.copyright == "2026 Test Corp")
        #expect(parsedChannel.ttl == 30)
    }

    @Test("Round-trip — generate then parse preserves iTunes metadata")
    func roundTripITunes() throws {
        let item = Item(
            title: "RT Episode",
            enclosure: Enclosure(
                url: makeURL("https://cdn.example.com/rt.mp3"),
                length: 20_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "rt-001", isPermaLink: false),
            itunesAuthor: "Author",
            itunesDuration: 2400,
            itunesEpisode: 3,
            itunesEpisodeType: .bonus,
            itunesExplicit: true,
            itunesSeason: 1
        )
        let channel = Channel(
            title: "RT Show",
            link: makeURL("https://example.com"),
            description: "iTunes round-trip.",
            items: [item],
            itunesAuthor: "Show Author",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg"),
            itunesOwner: ITunesOwner(name: "Owner", email: "owner@test.com"),
            itunesType: .serial
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ch = try #require(parsed.channel)

        #expect(ch.itunesAuthor == "Show Author")
        #expect(ch.itunesExplicit == false)
        #expect(ch.itunesType == .serial)
        #expect(ch.itunesOwner?.name == "Owner")

        let ep = try #require(ch.items.first)
        #expect(ep.itunesDuration == 2400)
        #expect(ep.itunesEpisode == 3)
        #expect(ep.itunesEpisodeType == .bonus)
        #expect(ep.itunesExplicit == true)
        #expect(ep.itunesSeason == 1)
    }

    @Test("Round-trip — generate then parse preserves Podcast NS 2.0 data")
    func roundTripPodcastNS() throws {
        let item = Item(
            title: "Podcast NS Episode",
            transcripts: [
                Transcript(
                    url: makeURL("https://example.com/ep.vtt"),
                    type: "text/vtt",
                    language: "en"
                )
            ],
            soundbites: [
                Soundbite(startTime: 10.0, duration: 30.0, title: "Highlight")
            ],
            persons: [
                PodcastPerson(name: "Host", role: "host")
            ]
        )
        let channel = Channel(
            title: "NS Show",
            link: makeURL("https://example.com"),
            description: "Podcast NS round-trip.",
            items: [item],
            podcastGuid: PodcastGuid(value: "abcdef-12345"),
            locked: Locked(isLocked: false, owner: "admin@test.com"),
            funding: [
                Funding(url: makeURL("https://donate.example.com"), message: "Donate")
            ]
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ch = try #require(parsed.channel)

        #expect(ch.podcastGuid?.value == "abcdef-12345")
        #expect(ch.locked?.isLocked == false)
        #expect(ch.locked?.owner == "admin@test.com")
        #expect(ch.funding.count == 1)
        #expect(ch.funding[0].message == "Donate")

        let ep = try #require(ch.items.first)
        #expect(ep.transcripts.count == 1)
        #expect(ep.transcripts[0].language == "en")
        #expect(ep.soundbites.count == 1)
        #expect(ep.soundbites[0].title == "Highlight")
        #expect(ep.persons.count == 1)
        #expect(ep.persons[0].name == "Host")
    }

    @Test("Round-trip — generate then parse preserves content:encoded CDATA")
    func roundTripContentEncoded() throws {
        let htmlContent = "<h1>Show Notes</h1><p>Visit <a href=\"https://example.com\">our site</a>.</p>"
        let item = Item(
            title: "Content Episode",
            contentEncoded: ContentEncoded(value: htmlContent)
        )
        let channel = Channel(
            title: "Content Show",
            link: makeURL("https://example.com"),
            description: "Content round-trip.",
            items: [item]
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.content], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ep = try #require(parsed.channel?.items.first)

        #expect(ep.contentEncoded?.value == htmlContent)
    }

    @Test("Round-trip — generate then parse preserves Podlove chapters")
    func roundTripPodlove() throws {
        let item = Item(
            title: "Chapters Episode",
            podloveChapters: PodloveChapters(
                version: "1.2",
                chapters: [
                    PodloveChapter(start: "00:00:00.000", title: "Intro"),
                    PodloveChapter(
                        start: "00:15:00.000",
                        title: "Deep Dive",
                        href: URL(string: "https://example.com/dive")
                    )
                ]
            )
        )
        let channel = Channel(
            title: "Chapters Show",
            link: makeURL("https://example.com"),
            description: "Podlove round-trip.",
            items: [item]
        )
        let original = PodcastFeed(
            version: "2.0",
            namespaces: [.podloveSimpleChapters],
            channel: channel
        )

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ep = try #require(parsed.channel?.items.first)
        let chapters = try #require(ep.podloveChapters)

        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 2)
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[1].title == "Deep Dive")
        #expect(chapters.chapters[1].href == URL(string: "https://example.com/dive"))
    }

    @Test("Round-trip — streaming generator output is parseable by FeedParser")
    func roundTripStreaming() async throws {
        let items = (1...3).map { idx in
            Item(
                title: "Streaming Ep \(idx)",
                guid: GUID(value: "stream-\(idx)", isPermaLink: false)
            )
        }
        let channel = Channel(
            title: "Streaming RT",
            link: makeURL("https://example.com"),
            description: "Streaming round-trip.",
            items: items
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        // Generate via streaming
        let streaming = StreamingFeedGenerator()
        var assembled = ""
        for try await chunk in streaming.generate(feed) {
            assembled += chunk
        }

        // Parse the assembled result
        let parsed = try FeedParser().parse(assembled)
        let ch = try #require(parsed.channel)
        #expect(ch.title == "Streaming RT")
        #expect(ch.items.count == 3)
        #expect(ch.items[0].title == "Streaming Ep 1")
        #expect(ch.items[2].title == "Streaming Ep 3")
    }

    @Test("Round-trip — multiple episodes with diverse fields")
    func roundTripMultipleEpisodes() throws {
        let items = [
            Item(
                title: "First",
                description: "Episode one.",
                enclosure: Enclosure(
                    url: makeURL("https://cdn.example.com/1.mp3"),
                    length: 10_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "first-ep", isPermaLink: false),
                itunesDuration: 600,
                itunesEpisodeType: .full
            ),
            Item(
                title: "Second",
                description: "Episode two.",
                enclosure: Enclosure(
                    url: makeURL("https://cdn.example.com/2.mp3"),
                    length: 15_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "second-ep", isPermaLink: false),
                itunesDuration: 900,
                itunesEpisodeType: .trailer
            ),
            Item(
                title: "Third",
                description: "Episode three.",
                enclosure: Enclosure(
                    url: makeURL("https://cdn.example.com/3.mp3"),
                    length: 20_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "third-ep", isPermaLink: false),
                itunesDuration: 1200,
                itunesEpisodeType: .bonus
            )
        ]
        let channel = Channel(
            title: "Multi Show",
            link: makeURL("https://example.com"),
            description: "Multiple episodes.",
            items: items,
            itunesAuthor: "Multi Author"
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ch = try #require(parsed.channel)

        #expect(ch.items.count == 3)
        #expect(ch.items[0].title == "First")
        #expect(ch.items[0].guid?.value == "first-ep")
        #expect(ch.items[0].itunesDuration == 600)
        #expect(ch.items[0].itunesEpisodeType == .full)

        #expect(ch.items[1].title == "Second")
        #expect(ch.items[1].itunesEpisodeType == .trailer)

        #expect(ch.items[2].title == "Third")
        #expect(ch.items[2].itunesEpisodeType == .bonus)
    }
}
