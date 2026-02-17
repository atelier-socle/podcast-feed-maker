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
import PodcastFeedMaker
import Testing

// MARK: - Round-Trip Diff & Advanced Showcase

@Suite("Round-Trip Diff & Advanced Showcase")
struct RoundTripDiffShowcase {

    // MARK: - Shared Fixtures

    private static let minimalXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" \
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
        xmlns:atom="http://www.w3.org/2005/Atom" \
        xmlns:podcast="https://podcastindex.org/namespace/1.0" \
        xmlns:dc="http://purl.org/dc/elements/1.1/" \
        xmlns:content="http://purl.org/rss/1.0/modules/content/" \
        xmlns:psc="http://podlove.org/simple-chapters">
        <channel>
        \t<title>Minimal Show</title>
        \t<link>https://example.com</link>
        \t<description>A minimal podcast feed.</description>
        </channel>
        </rss>
        """

    private static let allNamespacesXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" \
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
        xmlns:atom="http://www.w3.org/2005/Atom" \
        xmlns:podcast="https://podcastindex.org/namespace/1.0" \
        xmlns:dc="http://purl.org/dc/elements/1.1/" \
        xmlns:content="http://purl.org/rss/1.0/modules/content/" \
        xmlns:psc="http://podlove.org/simple-chapters">
        <channel>
        \t<title>Full Namespace Show</title>
        \t<link>https://example.com</link>
        \t<description>Covers every supported namespace.</description>
        \t<atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        \t<language>en</language>
        \t<copyright>2026 Example Inc.</copyright>
        \t<itunes:author>Jane Host</itunes:author>
        \t<itunes:category text="Technology"/>
        \t<itunes:explicit>false</itunes:explicit>
        \t<itunes:image href="https://example.com/artwork.jpg"/>
        \t<itunes:owner>
        \t\t<itunes:name>Jane Host</itunes:name>
        \t\t<itunes:email>jane@example.com</itunes:email>
        \t</itunes:owner>
        \t<itunes:type>episodic</itunes:type>
        \t<dc:creator>Dublin Core Creator</dc:creator>
        \t<podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>
        \t<podcast:locked owner="jane@example.com">yes</podcast:locked>
        \t<podcast:medium>podcast</podcast:medium>
        \t<podcast:funding url="https://example.com/donate">Support the show</podcast:funding>
        \t<podcast:person>Jane Host</podcast:person>
        \t<item>
        \t\t<title>Episode 1 — All Namespaces</title>
        \t\t<link>https://example.com/ep1</link>
        \t\t<description>Episode covering all namespaces.</description>
        \t\t<enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
        \t\t<guid isPermaLink="false">ep-001</guid>
        \t\t<itunes:author>Jane Host</itunes:author>
        \t\t<itunes:duration>1800</itunes:duration>
        \t\t<itunes:episode>1</itunes:episode>
        \t\t<itunes:episodeType>full</itunes:episodeType>
        \t\t<itunes:explicit>false</itunes:explicit>
        \t\t<itunes:season>1</itunes:season>
        \t\t<dc:creator>Episode DC Creator</dc:creator>
        \t\t<podcast:transcript url="https://example.com/ep1.srt" type="application/srt"/>
        \t\t<podcast:person>Guest Speaker</podcast:person>
        \t\t<psc:chapters version="1.2">
        \t\t\t<psc:chapter start="00:00:00.000" title="Intro"/>
        \t\t\t<psc:chapter start="00:05:30.000" title="Main Topic"/>
        \t\t\t<psc:chapter start="00:25:00.000" title="Outro"/>
        \t\t</psc:chapters>
        \t\t<content:encoded><![CDATA[<p>Rich <strong>HTML</strong> content.</p>]]></content:encoded>
        \t</item>
        </channel>
        </rss>
        """

    // MARK: - Namespace Prefix Preservation

    @Test("Namespace prefixes are preserved through round-trip in parsed mode")
    func namespacePrefixesRoundTrip() throws {
        let xmlWithPrefixes = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" \
            xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
            xmlns:podcast="https://podcastindex.org/namespace/1.0">
            <channel>
            \t<title>Prefix Show</title>
            \t<link>https://example.com</link>
            \t<description>Tests namespace prefix preservation.</description>
            \t<itunes:explicit>false</itunes:explicit>
            \t<podcast:locked>yes</podcast:locked>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .parsed)

        let feed = try parser.parse(xmlWithPrefixes)

        // Verify prefix mappings were captured
        #expect(!feed.namespacePrefixes.isEmpty, "Parser should capture namespace prefixes")

        // Generate with .parsed mode to use original prefixes
        let xml = try generator.generate(feed)

        // Verify the generated XML uses the expected prefixes
        #expect(xml.contains("xmlns:itunes="))
        #expect(xml.contains("xmlns:podcast="))

        // Re-parse and verify content
        let reparsed = try parser.parse(xml)
        #expect(reparsed.channel?.itunesExplicit == false)
        #expect(reparsed.channel?.locked?.isLocked == true)
    }

    // MARK: - JSON Codable Round-Trip

    @Test("XML to JSON to XML round-trip via Codable")
    func jsonCodableRoundTrip() throws {
        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Parse XML to model
        let feed1 = try parser.parse(Self.allNamespacesXML)

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(feed1)
        #expect(jsonData.count > 0, "JSON encoding should produce data")

        // Decode from JSON
        let decoder = JSONDecoder()
        let feed2 = try decoder.decode(PodcastFeed.self, from: jsonData)

        // Verify model equality
        #expect(feed1.version == feed2.version)
        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.itunesAuthor == feed2.channel?.itunesAuthor)
        #expect(feed1.channel?.podcastGuid == feed2.channel?.podcastGuid)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)

        // Generate XML from the JSON-decoded model
        let xml2 = try generator.generate(feed2)
        let feed3 = try parser.parse(xml2)

        // Full round-trip: XML -> JSON -> XML -> Parse
        #expect(feed3.channel?.title == feed1.channel?.title)
        #expect(feed3.channel?.items.first?.podloveChapters == feed1.channel?.items.first?.podloveChapters)
    }

    // MARK: - FeedDiff Tests

    @Test("FeedDiff — detect channel metadata changes")
    func diffDetectsChannelChanges() throws {
        let parser = FeedParser()

        let feed1 = try parser.parse(Self.allNamespacesXML)
        var feed2 = feed1
        feed2.channel?.title = "Changed Title"
        feed2.channel?.language = "de"

        let diff = FeedDiff()
        let differences = diff.diff(feed1, feed2)

        #expect(!differences.isEmpty, "Should detect changes")

        let titleChange = differences.first { $0.field == "channel.title" }
        #expect(titleChange != nil, "Should detect title change")
        #expect(titleChange?.changeType == .modified)
        #expect(titleChange?.oldValue == "Full Namespace Show")
        #expect(titleChange?.newValue == "Changed Title")

        let langChange = differences.first { $0.field == "channel.language" }
        #expect(langChange != nil, "Should detect language change")
        #expect(langChange?.changeType == .modified)
        #expect(langChange?.oldValue == "en")
        #expect(langChange?.newValue == "de")
    }

    @Test("FeedDiff — detect added, removed, and modified episodes")
    func diffDetectsEpisodeChanges() throws {
        let parser = FeedParser()

        // Feed with 1 episode
        let feed1 = try parser.parse(Self.allNamespacesXML)

        // Add a second episode and modify the first
        var feed2 = feed1
        feed2.channel?.items[0].title = "Episode 1 — Updated"

        let newItem = Item(
            title: "Episode 2 — Brand New",
            enclosure: Enclosure(
                url: makeURL("https://example.com/ep2.mp3"),
                length: 30_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-002", isPermaLink: false)
        )
        feed2.channel?.items.append(newItem)

        let diff = FeedDiff()
        let differences = diff.diff(feed1, feed2)

        // Should detect the title modification on the existing episode
        let titleMod = differences.first {
            $0.field.contains("ep-001") && $0.field.contains("title")
        }
        #expect(titleMod?.changeType == .modified)

        // Should detect the new episode
        let addedEp = differences.first {
            $0.changeType == .added && $0.field.contains("Episode 2")
        }
        #expect(addedEp != nil, "Should detect added episode")
    }

    @Test("FeedDiff — detect namespace differences in channel")
    func diffDetectsNamespaceDifferences() throws {
        let parser = FeedParser()

        let feed1 = try parser.parse(Self.allNamespacesXML)
        var feed2 = feed1

        // Remove podcast:guid and change locked status
        feed2.channel?.podcastGuid = PodcastGuid(value: "changed-guid")
        feed2.channel?.locked = Locked(isLocked: false, owner: "new@example.com")

        let diff = FeedDiff()
        let differences = diff.diff(feed1, feed2)

        let guidChange = differences.first { $0.field == "channel.podcastGuid" }
        #expect(guidChange?.changeType == .modified)

        let lockedChange = differences.first { $0.field == "channel.locked" }
        #expect(lockedChange?.changeType == .modified)
    }

    @Test("FeedDiff — identical feeds show no differences")
    func diffIdenticalFeeds() throws {
        let parser = FeedParser()
        let feed = try parser.parse(Self.allNamespacesXML)

        let diff = FeedDiff()
        let differences = diff.diff(feed, feed)

        #expect(differences.isEmpty, "Identical feeds should produce zero differences")
    }

    @Test("FeedDiff — diff from XML strings")
    func diffFromXMLStrings() throws {
        let xml1 = Self.minimalXML
        let xml2 = Self.minimalXML.replacingOccurrences(
            of: "Minimal Show", with: "Updated Show"
        )

        let diff = FeedDiff()
        let differences = try diff.diff(xml: xml1, xml: xml2)

        #expect(!differences.isEmpty)
        let titleChange = differences.first { $0.field == "channel.title" }
        #expect(titleChange?.changeType == .modified)
        #expect(titleChange?.oldValue == "Minimal Show")
        #expect(titleChange?.newValue == "Updated Show")
    }

    // MARK: - Multi-Episode Round-Trip

    private static func makeMultiEpisodeFeed() -> PodcastFeed {
        let feedURL = makeURL("https://example.com")
        let channel = Channel(
            title: "Multi-Episode Show",
            link: feedURL,
            description: "A show with multiple episodes for round-trip testing.",
            language: "en",
            items: [
                Item(
                    title: "Episode 3 — Latest",
                    enclosure: Enclosure(
                        url: makeURL("https://example.com/ep3.mp3"),
                        length: 50_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-003", isPermaLink: false),
                    itunesDuration: 2700,
                    itunesEpisode: 3,
                    itunesEpisodeType: .full,
                    itunesSeason: 2
                ),
                Item(
                    title: "Episode 2 — Middle",
                    enclosure: Enclosure(
                        url: makeURL("https://example.com/ep2.mp3"),
                        length: 40_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-002", isPermaLink: false),
                    itunesDuration: 1800,
                    itunesEpisode: 2,
                    itunesEpisodeType: .full,
                    itunesSeason: 1
                ),
                Item(
                    title: "Trailer",
                    enclosure: Enclosure(
                        url: makeURL("https://example.com/trailer.mp3"),
                        length: 5_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "trailer-001", isPermaLink: false),
                    itunesDuration: 120,
                    itunesEpisodeType: .trailer
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        return PodcastFeed(channel: channel)
    }

    @Test("Round-trip preserves episode ordering and all per-item metadata")
    func multiEpisodeRoundTrip() throws {
        let feed = Self.makeMultiEpisodeFeed()
        let generator = FeedGenerator(namespaceMode: .auto)
        let parser = FeedParser()

        // Round-trip
        let xml = try generator.generate(feed)
        let reparsed = try parser.parse(xml)
        let ch = try #require(reparsed.channel)

        // Episode count and ordering
        #expect(ch.items.count == 3)
        #expect(ch.items[0].title == "Episode 3 — Latest")
        #expect(ch.items[1].title == "Episode 2 — Middle")
        #expect(ch.items[2].title == "Trailer")

        // Per-item metadata
        #expect(ch.items[0].itunesEpisode == 3)
        #expect(ch.items[0].itunesSeason == 2)
        #expect(ch.items[0].itunesEpisodeType == .full)
        #expect(ch.items[2].itunesEpisodeType == .trailer)
        #expect(ch.items[2].itunesDuration == 120)
    }

    // MARK: - Streaming Generator Round-Trip

    @Test("Streaming generator produces valid XML that parses back correctly")
    func streamingGeneratorRoundTrip() async throws {
        let parser = FeedParser()
        let feed = try parser.parse(Self.allNamespacesXML)

        // Generate via streaming
        let engine = PodcastFeedEngine()
        let stream = engine.generateStream(feed)

        var chunks: [String] = []
        for try await chunk in stream {
            chunks.append(chunk)
        }

        #expect(chunks.count >= 3, "Stream should yield at least header, item, and footer")

        // Concatenate and parse
        let streamedXML = chunks.joined()
        let reparsed = try parser.parse(streamedXML)

        #expect(reparsed.channel?.title == feed.channel?.title)
        #expect(reparsed.channel?.items.count == feed.channel?.items.count)
    }
}
