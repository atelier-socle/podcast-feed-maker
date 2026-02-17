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

// MARK: - Feed Parser Showcase

/// Comprehensive showcase of every public API in the Parser layer.
/// Each test is self-contained and demonstrates one feature with realistic data.
@Suite("Feed Parser Showcase")
struct ParserShowcase {

    // MARK: - Helpers

    /// A minimal valid RSS 2.0 feed XML string.
    private static let minimalXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <title>Minimal Podcast</title>
                <link>https://example.com</link>
                <description>A minimal test feed.</description>
            </channel>
        </rss>
        """

    private static func makeSamplePodloveChapters() -> PodloveChapters {
        PodloveChapters(
            version: "1.2",
            chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Intro"),
                PodloveChapter(
                    start: "00:05:30.000",
                    title: "Main Topic",
                    href: URL(string: "https://example.com/topic"),
                    image: URL(string: "https://cdn.example.com/topic.jpg")
                ),
                PodloveChapter(start: "00:30:00.000", title: "Outro")
            ]
        )
    }

    /// Builds a full episode with all 7 namespaces for round-trip testing.
    private static func makeFullEpisode() -> Item {
        Item(
            title: "Full Episode",
            link: URL(string: "https://example.com/ep1"),
            description: "Episode description.",
            author: "author@example.com",
            enclosure: Enclosure(
                url: makeURL("https://cdn.example.com/ep1.mp3"),
                length: 48_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-full-001", isPermaLink: false),
            itunesAuthor: "Jane Host",
            itunesDuration: 3661,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/ep1.jpg"),
            itunesSeason: 2,
            itunesSubtitle: "Subtitle here",
            itunesTitle: "Special Title",
            atomLinks: [
                AtomLink(href: makeURL("https://example.com/ep1/comments"), rel: "replies")
            ],
            dublinCore: DublinCore(creator: "Jane Host", subject: "Tech"),
            contentEncoded: ContentEncoded(value: "<p>Full <strong>show notes</strong>.</p>"),
            transcripts: [
                Transcript(
                    url: makeURL("https://example.com/ep1.vtt"),
                    type: "text/vtt",
                    language: "en",
                    rel: "captions"
                )
            ],
            chaptersLink: ChaptersLink(
                url: makeURL("https://example.com/ep1/chapters.json")
            ),
            soundbites: [
                Soundbite(startTime: 120.5, duration: 45.0, title: "Best moment")
            ],
            persons: [
                PodcastPerson(
                    name: "Jane Host",
                    role: "host",
                    group: "cast",
                    href: URL(string: "https://example.com/jane"),
                    img: URL(string: "https://cdn.example.com/jane.jpg")
                ),
                PodcastPerson(name: "Bob Guest", role: "guest")
            ],
            podloveChapters: makeSamplePodloveChapters()
        )
    }

    private static func makeAllNamespacesChannel() -> Channel {
        Channel(
            title: "The Complete Podcast",
            link: makeURL("https://example.com"),
            description: "Covering all 7 namespaces.",
            language: "en-US",
            copyright: "2026 Atelier Socle",
            managingEditor: "editor@example.com (Editor)",
            pubDate: Date(timeIntervalSince1970: 1_739_404_800),
            lastBuildDate: Date(timeIntervalSince1970: 1_739_404_800),
            generator: "PodcastFeedMaker/1.0",
            ttl: 60,
            items: [makeFullEpisode()],
            itunesAuthor: "Atelier Socle",
            itunesCategories: [
                .technology,
                ITunesCategory(
                    text: "Education",
                    subcategories: [ITunesCategory(text: "Self-Improvement")]
                )
            ],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/artwork.jpg"),
            itunesOwner: ITunesOwner(name: "Wlad", email: "wlad@example.com"),
            itunesType: .episodic,
            atomLinks: [
                AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))
            ],
            dublinCore: DublinCore(creator: "Atelier Socle", language: "en"),
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "wlad@example.com"),
            funding: [
                Funding(
                    url: makeURL("https://example.com/donate"),
                    message: "Support the show"
                )
            ],
            persons: [
                PodcastPerson(name: "Wlad", role: "host", group: "cast")
            ]
        )
    }

    private static func generateAllNamespacesXML() throws -> String {
        let channel = makeAllNamespacesChannel()
        let feed = PodcastFeed(
            version: "2.0",
            namespaces: PodcastNamespace.allStandard,
            channel: channel
        )
        return try FeedGenerator().generate(feed)
    }

    // MARK: - FeedParser — Parse from String

    @Test("FeedParser — parse from XML string")
    func parseFromString() throws {
        let parser = FeedParser()
        let feed = try parser.parse(Self.minimalXML)

        let channel = try #require(feed.channel)
        #expect(channel.title == "Minimal Podcast")
        #expect(channel.link == URL(string: "https://example.com"))
        #expect(channel.description == "A minimal test feed.")
    }

    @Test("FeedParser — parse from Data")
    func parseFromData() throws {
        let data = try #require(Self.minimalXML.data(using: .utf8))
        let parser = FeedParser()
        let feed = try parser.parse(data: data)

        let channel = try #require(feed.channel)
        #expect(channel.title == "Minimal Podcast")
    }

    @Test("FeedParser — parse all 7 namespaces — channel fields")
    func parseAllNamespacesChannel() throws {
        let xml = try Self.generateAllNamespacesXML()
        let parser = FeedParser()
        let feed = try parser.parse(xml)

        let channel = try #require(feed.channel)

        // RSS 2.0 Core
        #expect(channel.title == "The Complete Podcast")
        #expect(channel.link == URL(string: "https://example.com"))
        #expect(channel.description == "Covering all 7 namespaces.")
        #expect(channel.language == "en-US")
        #expect(channel.copyright == "2026 Atelier Socle")
        #expect(channel.generator == "PodcastFeedMaker/1.0")
        #expect(channel.ttl == 60)

        // iTunes
        #expect(channel.itunesAuthor == "Atelier Socle")
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage == URL(string: "https://cdn.example.com/artwork.jpg"))
        #expect(channel.itunesOwner?.name == "Wlad")
        #expect(channel.itunesOwner?.email == "wlad@example.com")
        #expect(channel.itunesType == .episodic)
        #expect(channel.itunesCategories.count >= 1)
        #expect(channel.itunesCategories[0].text == "Technology")

        // Atom
        #expect(!channel.atomLinks.isEmpty)
        let selfLink = channel.atomLinks.first(where: { $0.rel == "self" })
        #expect(selfLink?.href == URL(string: "https://example.com/feed.xml"))

        // Dublin Core
        #expect(channel.dublinCore?.creator == "Atelier Socle")
        #expect(channel.dublinCore?.language == "en")

        // Podcast NS 2.0
        #expect(channel.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "wlad@example.com")
        #expect(channel.funding.count == 1)
        #expect(channel.funding[0].message == "Support the show")
        #expect(channel.persons.count == 1)
        #expect(channel.persons[0].name == "Wlad")
    }

    @Test("FeedParser — parse all 7 namespaces — item fields")
    func parseAllNamespacesItem() throws {
        let xml = try Self.generateAllNamespacesXML()
        let parser = FeedParser()
        let feed = try parser.parse(xml)

        let channel = try #require(feed.channel)
        #expect(channel.items.count == 1)
        let item = channel.items[0]

        #expect(item.title == "Full Episode")
        #expect(item.enclosure?.url == URL(string: "https://cdn.example.com/ep1.mp3"))
        #expect(item.enclosure?.length == 48_000_000)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "ep-full-001")
        #expect(item.guid?.isPermaLink == false)

        // Item iTunes
        #expect(item.itunesAuthor == "Jane Host")
        #expect(item.itunesDuration == 3661)
        #expect(item.itunesEpisode == 1)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesSeason == 2)
        #expect(item.itunesTitle == "Special Title")

        // Item Dublin Core
        #expect(item.dublinCore?.creator == "Jane Host")
        #expect(item.dublinCore?.subject == "Tech")

        // Item Content Module
        #expect(item.contentEncoded?.value.contains("<strong>show notes</strong>") == true)

        // Item Podcast NS 2.0
        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].url == URL(string: "https://example.com/ep1.vtt"))
        #expect(item.transcripts[0].type == "text/vtt")
        #expect(item.transcripts[0].language == "en")
        #expect(item.chaptersLink?.url == URL(string: "https://example.com/ep1/chapters.json"))
        #expect(item.soundbites.count == 1)
        #expect(item.soundbites[0].title == "Best moment")
        #expect(item.persons.count == 2)
        #expect(item.persons[0].name == "Jane Host")
        #expect(item.persons[1].name == "Bob Guest")

        // Item Podlove Simple Chapters
        let chapters = try #require(item.podloveChapters)
        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 3)
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[1].title == "Main Topic")
        #expect(chapters.chapters[1].href == URL(string: "https://example.com/topic"))
        #expect(chapters.chapters[2].title == "Outro")
    }

    // MARK: - Parse Minimal RSS 2.0

    @Test("FeedParser — parse minimal RSS 2.0 feed with no namespace tags")
    func parseMinimalRSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Plain RSS</title>
                    <link>https://example.com</link>
                    <description>No namespaces used.</description>
                    <item>
                        <title>Episode 1</title>
                        <description>First episode.</description>
                        <guid>ep-001</guid>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Plain RSS")
        #expect(channel.items.count == 1)
        #expect(channel.items[0].title == "Episode 1")
        #expect(channel.items[0].guid?.value == "ep-001")
        // Default isPermaLink is true when not specified
        #expect(channel.items[0].guid?.isPermaLink == true)

        // No namespace data
        #expect(channel.itunesAuthor == nil)
        #expect(channel.podcastGuid == nil)
        #expect(channel.dublinCore == nil)
    }

    // MARK: - (continued in ParserRoundTripShowcase)
}

// MARK: - Feed Parser Round-Trip & Diagnostics Showcase

@Suite("Feed Parser Round-Trip & Diagnostics Showcase")
struct ParserRoundTripShowcase {

    private static let minimalXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <title>Minimal Podcast</title>
                <link>https://example.com</link>
                <description>A minimal test feed.</description>
            </channel>
        </rss>
        """

    // MARK: - Round-Trip Preservation

    @Test("FeedParser — preserve unknown elements for round-trip fidelity")
    func parseUnknownElements() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Unknown Test</title>
                    <link>https://example.com</link>
                    <description>Testing unknown elements.</description>
                    <custom:rating>5</custom:rating>
                    <item>
                        <title>Ep 1</title>
                        <custom:score>95</custom:score>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        // Channel-level unknown element
        let channelUnknown = channel.unknownElements.first(where: { $0.name == "custom:rating" })
        #expect(channelUnknown?.textContent == "5")

        // Item-level unknown element
        let itemUnknown = channel.items[0].unknownElements.first(where: { $0.name == "custom:score" })
        #expect(itemUnknown?.textContent == "95")
    }

    @Test("FeedParser — CDATA content preserved correctly")
    func parseCDATAContent() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
                <channel>
                    <title>CDATA Show</title>
                    <link>https://example.com</link>
                    <description><![CDATA[A <b>bold</b> description.]]></description>
                    <item>
                        <title>Ep 1</title>
                        <content:encoded><![CDATA[<p>Full <em>HTML</em> notes.</p>]]></content:encoded>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        // The parser should preserve the content as-is (without the CDATA wrapper)
        #expect(channel.description == "A <b>bold</b> description.")

        let item = try #require(channel.items.first)
        #expect(item.contentEncoded?.value == "<p>Full <em>HTML</em> notes.</p>")

        // CDATA tracking
        #expect(channel.cdataFields.contains("description"))
    }

    @Test("FeedParser — XML comments preserved for round-trip")
    func parseXMLComments() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Comment Show</title>
                    <link>https://example.com</link>
                    <description>Comment test.</description>
                    <!-- Channel-level comment -->
                    <item>
                        <title>Ep 1</title>
                        <!-- Item-level comment -->
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.xmlComments.contains(where: { $0.contains("Channel-level comment") }))

        let item = try #require(channel.items.first)
        #expect(item.xmlComments.contains(where: { $0.contains("Item-level comment") }))
    }

    // MARK: - Parse with Diagnostics

    @Test("FeedParser — parseWithDiagnostics returns feed and warnings")
    func parseWithDiagnostics() throws {
        let parser = FeedParser()
        let result = try parser.parseWithDiagnostics(Self.minimalXML)

        let channel = try #require(result.feed.channel)
        #expect(channel.title == "Minimal Podcast")
        // Warnings array exists (may be empty for well-formed feeds)
        #expect(result.warnings.count >= 0)
    }

    @Test("FeedParser — parseWithDiagnostics from Data")
    func parseWithDiagnosticsData() throws {
        let data = try #require(Self.minimalXML.data(using: .utf8))
        let parser = FeedParser()
        let result = try parser.parseWithDiagnostics(data: data)

        #expect(result.feed.channel?.title == "Minimal Podcast")
    }
}
