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

// MARK: - Engine Diff & Workflow Showcase

@Suite("PodcastFeedEngine Diff & Workflow Showcase")
struct EngineDiffWorkflowShowcase {

    // MARK: - Shared Fixtures

    /// A well-formed feed suitable for most engine tests.
    private static let sampleXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" \
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
        xmlns:atom="http://www.w3.org/2005/Atom" \
        xmlns:podcast="https://podcastindex.org/namespace/1.0">
        <channel>
        \t<title>Engine Test Podcast</title>
        \t<link>https://example.com</link>
        \t<description>A podcast for testing the PodcastFeedEngine.</description>
        \t<atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        \t<language>en</language>
        \t<itunes:author>Engine Tester</itunes:author>
        \t<itunes:category text="Technology"/>
        \t<itunes:explicit>false</itunes:explicit>
        \t<itunes:image href="https://example.com/artwork.jpg"/>
        \t<itunes:owner>
        \t\t<itunes:name>Engine Tester</itunes:name>
        \t\t<itunes:email>tester@example.com</itunes:email>
        \t</itunes:owner>
        \t<itunes:type>episodic</itunes:type>
        \t<podcast:guid>aabbccdd-1234-5678-9abc-def012345678</podcast:guid>
        \t<podcast:locked owner="tester@example.com">yes</podcast:locked>
        \t<item>
        \t\t<title>Episode 1</title>
        \t\t<description>First episode.</description>
        \t\t<enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
        \t\t<guid isPermaLink="false">ep-001</guid>
        \t\t<itunes:duration>1800</itunes:duration>
        \t\t<itunes:episode>1</itunes:episode>
        \t\t<itunes:episodeType>full</itunes:episodeType>
        \t\t<itunes:explicit>false</itunes:explicit>
        \t</item>
        \t<item>
        \t\t<title>Episode 2</title>
        \t\t<description>Second episode.</description>
        \t\t<enclosure url="https://example.com/ep2.mp3" length="60000000" type="audio/mpeg"/>
        \t\t<guid isPermaLink="false">ep-002</guid>
        \t\t<itunes:duration>2400</itunes:duration>
        \t\t<itunes:episode>2</itunes:episode>
        \t\t<itunes:episodeType>full</itunes:episodeType>
        \t\t<itunes:explicit>false</itunes:explicit>
        \t</item>
        </channel>
        </rss>
        """

    /// Builds a feed model programmatically for generation tests.
    private static func buildSampleFeed() -> PodcastFeed {
        let channel = Channel(
            title: "Programmatic Show",
            link: makeURL("https://example.com"),
            description: "Built from Swift structs.",
            language: "en",
            items: [
                Item(
                    title: "Pilot Episode",
                    description: "The very first episode.",
                    enclosure: Enclosure(
                        url: makeURL("https://example.com/pilot.mp3"),
                        length: 25_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "pilot-001", isPermaLink: false),
                    itunesDuration: 900,
                    itunesEpisode: 1,
                    itunesEpisodeType: .full,
                    itunesExplicit: false
                )
            ],
            itunesAuthor: "Swift Dev",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            itunesOwner: ITunesOwner(name: "Swift Dev", email: "dev@example.com"),
            itunesType: .episodic,
            atomLinks: [
                AtomLink(
                    href: makeURL("https://example.com/feed.xml"),
                    rel: "self",
                    type: "application/rss+xml"
                )
            ],
            podcastGuid: PodcastGuid(value: "12345678-abcd-efgh-ijkl-000000000000"),
            locked: Locked(isLocked: true, owner: "dev@example.com")
        )
        return PodcastFeed(channel: channel)
    }

    // MARK: - Normalization

    @Test("Engine normalizes feed by round-tripping through parse and generate")
    func engineNormalize() throws {
        let engine = PodcastFeedEngine()

        // Messy XML with inconsistent formatting
        let messyXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
              <channel>
                <title>Messy   Show</title>
                  <link>https://example.com</link>
               <description>Inconsistent   indentation.</description>
               <itunes:explicit>false</itunes:explicit>
                       <itunes:category text="Technology"/>
              </channel>
            </rss>
            """

        let normalized = try engine.normalize(messyXML)

        // Normalized output should be well-formatted
        #expect(normalized.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(normalized.contains("<title>Messy   Show</title>"))
        #expect(normalized.contains("</rss>"))
    }

    @Test("Engine normalize with prettyPrint false produces compact output")
    func engineNormalizeCompact() throws {
        let engine = PodcastFeedEngine()
        let normalized = try engine.normalize(Self.sampleXML, prettyPrint: false)

        #expect(!normalized.contains("\t"), "Compact normalization should not contain tabs")
        #expect(normalized.contains("<title>Engine Test Podcast</title>"))
    }

    // MARK: - Equivalence

    @Test("Engine checks feed equivalence — identical feeds are equivalent")
    func engineIsEquivalentIdentical() throws {
        let engine = PodcastFeedEngine()

        let isEqual = try engine.isEquivalent(Self.sampleXML, Self.sampleXML)
        #expect(isEqual == true, "Same XML should be equivalent")
    }

    @Test("Engine checks feed equivalence — different feeds are not equivalent")
    func engineIsEquivalentDifferent() throws {
        let engine = PodcastFeedEngine()

        let xml2 = Self.sampleXML.replacingOccurrences(
            of: "Engine Test Podcast", with: "Different Podcast"
        )

        let isEqual = try engine.isEquivalent(Self.sampleXML, xml2)
        #expect(isEqual == false, "Feeds with different titles should not be equivalent")
    }

    @Test("Engine equivalence ignores formatting differences")
    func engineIsEquivalentIgnoresFormatting() throws {
        let engine = PodcastFeedEngine()

        // Generate the same content with and without pretty-printing
        let feed = try engine.parse(Self.sampleXML)
        let pretty = try FeedGenerator(prettyPrint: true, namespaceMode: .auto).generate(feed)
        let compact = try FeedGenerator(prettyPrint: false, namespaceMode: .auto).generate(feed)

        let isEqual = try engine.isEquivalent(pretty, compact)
        #expect(isEqual == true, "Formatting differences should not affect equivalence")
    }

    // MARK: - Diff

    @Test("Engine diffs two feed models")
    func engineDiffModels() throws {
        let engine = PodcastFeedEngine()
        let feed1 = try engine.parse(Self.sampleXML)

        var feed2 = feed1
        feed2.channel?.title = "Changed Title"
        feed2.channel?.itunesAuthor = "New Author"

        let differences = engine.diff(feed1, feed2)

        #expect(!differences.isEmpty, "Should detect differences")

        let titleDiff = differences.first { $0.field == "channel.title" }
        #expect(titleDiff?.changeType == .modified)
        #expect(titleDiff?.oldValue == "Engine Test Podcast")
        #expect(titleDiff?.newValue == "Changed Title")

        let authorDiff = differences.first { $0.field == "channel.itunesAuthor" }
        #expect(authorDiff?.changeType == .modified)
        #expect(authorDiff?.newValue == "New Author")
    }

    @Test("Engine diffs two XML strings")
    func engineDiffXMLStrings() throws {
        let engine = PodcastFeedEngine()

        let xml2 = Self.sampleXML.replacingOccurrences(
            of: "<title>Episode 1</title>",
            with: "<title>Episode 1 Remastered</title>"
        )

        let differences = try engine.diff(xml: Self.sampleXML, xml: xml2)

        let epTitleDiff = differences.first {
            $0.field.contains("ep-001") && $0.field.contains("title")
        }
        #expect(epTitleDiff?.changeType == .modified)
        #expect(epTitleDiff?.oldValue == "Episode 1")
        #expect(epTitleDiff?.newValue == "Episode 1 Remastered")
    }

    @Test("Engine diff shows no differences for identical feeds")
    func engineDiffIdentical() throws {
        let engine = PodcastFeedEngine()
        let feed = try engine.parse(Self.sampleXML)

        let differences = engine.diff(feed, feed)
        #expect(differences.isEmpty, "Identical feeds should have no differences")
    }

    // MARK: - Combined Workflows

    @Test("Engine parseAndValidate combines parsing and validation in one call")
    func engineParseAndValidate() throws {
        let engine = PodcastFeedEngine()

        let (feed, report) = try engine.parseAndValidate(
            Self.sampleXML, for: .apple
        )

        // Parsing result
        #expect(feed.channel?.title == "Engine Test Podcast")
        #expect(feed.channel?.items.count == 2)

        // Validation result
        #expect(report.platform == .apple)
    }

    @Test("Engine full pipeline: create model then generate then parse then validate")
    func engineFullPipeline() throws {
        let engine = PodcastFeedEngine()

        // Step 1: Create a feed model
        let feed = Self.buildSampleFeed()

        // Step 2: Generate XML
        let xml = try engine.generate(feed)
        #expect(!xml.isEmpty)

        // Step 3: Parse the generated XML back
        let parsed = try engine.parse(xml)
        #expect(parsed.channel?.title == "Programmatic Show")
        #expect(parsed.channel?.items.count == 1)
        #expect(parsed.channel?.items.first?.title == "Pilot Episode")

        // Step 4: Validate on each platform
        let reports = engine.validateAll(parsed)
        #expect(reports.count == 5, "Should produce one report per platform")

        for report in reports {
            // Log findings (not asserting isValid as requirements vary by platform)
            _ = report.errors.count
            _ = report.warnings.count
        }

        // Step 5: Verify round-trip equivalence
        let regenXML = try engine.generate(parsed)
        let isEquiv = try engine.isEquivalent(xml, regenXML)
        // Note: equivalence compares parsed models, not XML strings
        #expect(isEquiv == true, "Generate -> Parse -> Generate should produce equivalent feeds")
    }

    @Test("Engine pipeline with modification: parse, modify, generate, validate, diff")
    func engineModifyPipeline() throws {
        let engine = PodcastFeedEngine()

        // Parse original
        let original = try engine.parse(Self.sampleXML)

        // Modify
        var modified = original
        modified.channel?.title = "Rebranded Show"
        modified.channel?.itunesAuthor = "New Host"
        modified.channel?.items.append(
            Item(
                title: "Episode 3 — Fresh Start",
                description: "Under new management.",
                enclosure: Enclosure(
                    url: makeURL("https://example.com/ep3.mp3"),
                    length: 45_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "ep-003", isPermaLink: false),
                itunesDuration: 2100,
                itunesEpisode: 3,
                itunesEpisodeType: .full,
                itunesExplicit: false
            )
        )

        // Generate
        let xml = try engine.generate(modified)

        // Re-parse and validate
        let (reparsed, report) = try engine.parseAndValidate(xml, for: .apple)
        #expect(reparsed.channel?.title == "Rebranded Show")
        #expect(reparsed.channel?.items.count == 3)
        _ = report  // Validation report is available

        // Diff original vs modified
        let differences = engine.diff(original, modified)
        #expect(!differences.isEmpty)

        let titleDiff = differences.first { $0.field == "channel.title" }
        #expect(titleDiff?.changeType == .modified)
        #expect(titleDiff?.oldValue == "Engine Test Podcast")
        #expect(titleDiff?.newValue == "Rebranded Show")

        let addedEp = differences.first {
            $0.changeType == .added && $0.field.contains("Episode 3")
        }
        #expect(addedEp != nil, "Should detect the added episode")
    }

    // MARK: - FeedDifference Types

    @Test("FeedDifference change types: added, removed, modified")
    func feedDifferenceChangeTypes() {
        let added = FeedDifference(
            changeType: .added,
            field: "channel.language",
            newValue: "en"
        )
        #expect(added.changeType == .added)
        #expect(added.oldValue == nil)
        #expect(added.newValue == "en")

        let removed = FeedDifference(
            changeType: .removed,
            field: "channel.copyright",
            oldValue: "2025 Acme"
        )
        #expect(removed.changeType == .removed)
        #expect(removed.oldValue == "2025 Acme")
        #expect(removed.newValue == nil)

        let modified = FeedDifference(
            changeType: .modified,
            field: "channel.title",
            oldValue: "Old Title",
            newValue: "New Title"
        )
        #expect(modified.changeType == .modified)
        #expect(modified.field == "channel.title")
    }

    @Test("FeedDifference conforms to Equatable")
    func feedDifferenceEquatable() {
        let diff1 = FeedDifference(
            changeType: .modified,
            field: "channel.title",
            oldValue: "A",
            newValue: "B"
        )
        let diff2 = FeedDifference(
            changeType: .modified,
            field: "channel.title",
            oldValue: "A",
            newValue: "B"
        )
        let diff3 = FeedDifference(
            changeType: .added,
            field: "channel.language",
            newValue: "en"
        )

        #expect(diff1 == diff2)
        #expect(diff1 != diff3)
    }
}
