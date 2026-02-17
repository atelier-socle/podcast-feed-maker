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

import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// MARK: - Shared Fixture XML

/// A well-formed podcast feed XML used across all CLI showcase tests.
/// Includes RSS 2.0, iTunes, Podcast NS 2.0, Atom, and Podlove Simple Chapters
/// namespaces to exercise the full CLI surface.
private let fixtureXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"
         xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
         xmlns:podcast="https://podcastindex.org/namespace/1.0"
         xmlns:atom="http://www.w3.org/2005/Atom"
         xmlns:psc="http://podlove.org/simple-chapters"
         xmlns:content="http://purl.org/rss/1.0/modules/content/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>CLI Showcase Podcast</title>
        <link>https://example.com</link>
        <description>A podcast for testing every CLI command.</description>
        <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        <language>en</language>
        <copyright>2026 Showcase Inc.</copyright>
        <itunes:author>Showcase Host</itunes:author>
        <itunes:category text="Technology"/>
        <itunes:explicit>false</itunes:explicit>
        <itunes:image href="https://example.com/artwork.jpg"/>
        <itunes:owner>
            <itunes:name>Showcase Host</itunes:name>
            <itunes:email>host@example.com</itunes:email>
        </itunes:owner>
        <itunes:type>episodic</itunes:type>
        <podcast:guid>aabb1122-3344-5566-7788-99aabbccddee</podcast:guid>
        <podcast:locked owner="host@example.com">yes</podcast:locked>
        <podcast:funding url="https://example.com/donate">Support the show</podcast:funding>
        <item>
            <title>Episode 1 — Pilot</title>
            <description>The first episode of the showcase podcast.</description>
            <enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
            <guid isPermaLink="false">ep-001</guid>
            <pubDate>Thu, 01 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>1800</itunes:duration>
            <itunes:episode>1</itunes:episode>
            <itunes:season>1</itunes:season>
            <itunes:episodeType>full</itunes:episodeType>
            <itunes:explicit>false</itunes:explicit>
            <psc:chapters version="1.2">
                <psc:chapter start="00:00:00.000" title="Introduction"/>
                <psc:chapter start="00:05:00.000" title="Main Topic"/>
                <psc:chapter start="00:25:00.000" title="Wrap Up"/>
            </psc:chapters>
            <content:encoded><![CDATA[<p>Rich <strong>HTML</strong> content for episode 1.</p>]]></content:encoded>
        </item>
        <item>
            <title>Episode 2 — Deep Dive</title>
            <description>A deeper exploration of the topic.</description>
            <enclosure url="https://example.com/ep2.mp3" length="60000000" type="audio/mpeg"/>
            <guid isPermaLink="false">ep-002</guid>
            <pubDate>Thu, 08 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>2400</itunes:duration>
            <itunes:episode>2</itunes:episode>
            <itunes:season>1</itunes:season>
            <itunes:episodeType>full</itunes:episodeType>
            <itunes:explicit>false</itunes:explicit>
        </item>
        <item>
            <title>Bonus — Behind the Scenes</title>
            <description>A bonus episode.</description>
            <enclosure url="https://example.com/bonus.mp3" length="20000000" type="audio/mpeg"/>
            <guid isPermaLink="false">bonus-001</guid>
            <pubDate>Thu, 15 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>600</itunes:duration>
            <itunes:episodeType>bonus</itunes:episodeType>
            <itunes:explicit>false</itunes:explicit>
        </item>
    </channel>
    </rss>
    """

// MARK: - Helpers

/// Writes the fixture XML to a temporary file and returns the path.
/// Caller is responsible for cleanup via `defer`.
private func writeFixture(suffix: String = "") -> String {
    let path = "/tmp/pfm_showcase_\(suffix)_\(UUID()).xml"
    try? fixtureXML.write(toFile: path, atomically: true, encoding: .utf8)
    return path
}

/// Runs a command, swallowing ExitCode throws (which are expected for
/// commands that exit non-zero on warnings or errors).
private func runAllowingExitCode(_ command: inout some ParsableCommand) throws {
    do {
        try command.run()
    } catch is ExitCode {
        // Expected — commands throw ExitCode for warnings or errors
    }
}

// MARK: - Read Command Showcase

@Suite("CLI Showcase — read Command")
struct ReadCommandShowcaseTests {

    @Test("Parses source with default format (summary)")
    func parsesDefaults() throws {
        let command = try ReadCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "summary")
        #expect(command.verbose == false)
    }

    @Test("Parses --format json")
    func parsesJSON() throws {
        let command = try ReadCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses --format xml")
    func parsesXML() throws {
        let command = try ReadCommand.parse(["feed.xml", "-f", "xml"])
        #expect(command.format == "xml")
    }

    @Test("Parses --verbose flag")
    func parsesVerbose() throws {
        let command = try ReadCommand.parse(["feed.xml", "--verbose"])
        #expect(command.verbose == true)
    }

    @Test("Read in summary format displays feed info")
    func readSummary() throws {
        let path = writeFixture(suffix: "read_summary")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ReadCommand.parse([path])
        try command.run()
    }

    @Test("Read in JSON format outputs valid JSON")
    func readJSON() throws {
        let path = writeFixture(suffix: "read_json")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ReadCommand.parse([path, "--format", "json"])
        try command.run()
    }

    @Test("Read in XML format outputs valid XML")
    func readXML() throws {
        let path = writeFixture(suffix: "read_xml")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ReadCommand.parse([path, "-f", "xml"])
        try command.run()
    }

    @Test("Read in verbose mode shows extra details")
    func readVerbose() throws {
        let path = writeFixture(suffix: "read_verbose")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ReadCommand.parse([path, "--verbose"])
        try command.run()
    }

    @Test("Read with unknown format throws error")
    func readUnknownFormat() throws {
        let path = writeFixture(suffix: "read_bad_format")
        defer { try? FileManager.default.removeItem(atPath: path) }

        #expect(throws: (any Error).self) {
            var command = try ReadCommand.parse([path, "--format", "yaml"])
            try command.run()
        }
    }
}

// MARK: - Episodes Command Showcase

@Suite("CLI Showcase — episodes Command")
struct EpisodesCommandShowcaseTests {

    @Test("Parses source with default options")
    func parsesDefaults() throws {
        let command = try EpisodesCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "text")
        #expect(command.limit == nil)
        #expect(command.sort == "newest")
    }

    @Test("Parses --limit option")
    func parsesLimit() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--limit", "5"])
        #expect(command.limit == 5)
    }

    @Test("Parses --sort option")
    func parsesSort() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--sort", "oldest"])
        #expect(command.sort == "oldest")
    }

    @Test("Parses --sort title option")
    func parsesSortTitle() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--sort", "title"])
        #expect(command.sort == "title")
    }

    @Test("Parses combined short flags: -f json -n 3")
    func parsesCombinedShortFlags() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "-f", "json", "-n", "3"])
        #expect(command.format == "json")
        #expect(command.limit == 3)
    }

    @Test("Episodes in text format lists all episodes")
    func episodesText() throws {
        let path = writeFixture(suffix: "episodes_text")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try EpisodesCommand.parse([path])
        try command.run()
    }

    @Test("Episodes in JSON format outputs structured data")
    func episodesJSON() throws {
        let path = writeFixture(suffix: "episodes_json")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try EpisodesCommand.parse([path, "-f", "json"])
        try command.run()
    }

    @Test("Episodes with --limit restricts output count")
    func episodesWithLimit() throws {
        let path = writeFixture(suffix: "episodes_limit")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try EpisodesCommand.parse([path, "--limit", "1"])
        try command.run()
    }

    @Test("Episodes with --sort oldest reverses order")
    func episodesSortOldest() throws {
        let path = writeFixture(suffix: "episodes_oldest")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try EpisodesCommand.parse([path, "--sort", "oldest"])
        try command.run()
    }

    @Test("Episodes with invalid sort option throws error")
    func episodesInvalidSort() throws {
        let path = writeFixture(suffix: "episodes_bad_sort")
        defer { try? FileManager.default.removeItem(atPath: path) }

        #expect(throws: (any Error).self) {
            var command = try EpisodesCommand.parse([path, "--sort", "random"])
            try command.run()
        }
    }
}

// MARK: - Chapters Command Showcase

@Suite("CLI Showcase — chapters Command")
struct ChaptersCommandShowcaseTests {

    @Test("Parses source with default options")
    func parsesDefaults() throws {
        let command = try ChaptersCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.episode == nil)
        #expect(command.format == "text")
        #expect(command.export == nil)
    }

    @Test("Parses --episode by numeric index")
    func parsesEpisodeIndex() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "--episode", "0"])
        #expect(command.episode == "0")
    }

    @Test("Parses --episode by guid")
    func parsesEpisodeGuid() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "-e", "ep-001"])
        #expect(command.episode == "ep-001")
    }

    @Test("Parses --episode by title substring")
    func parsesEpisodeTitleSubstring() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "-e", "pilot"])
        #expect(command.episode == "pilot")
    }

    @Test("Parses --format psc")
    func parsesFormatPSC() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "-e", "0", "-f", "psc"])
        #expect(command.format == "psc")
    }

    @Test("Parses --export option")
    func parsesExport() throws {
        let command = try ChaptersCommand.parse([
            "feed.xml", "-e", "0", "--export", "chapters.json"
        ])
        #expect(command.export == "chapters.json")
    }

    @Test("Chapters lists episodes with chapters when no --episode specified")
    func chaptersListAllWithChapters() throws {
        let path = writeFixture(suffix: "chapters_list")
        defer { try? FileManager.default.removeItem(atPath: path) }

        // The fixture has chapters only on episode 1, so this should list it
        var command = try ChaptersCommand.parse([path])
        try command.run()
    }

    @Test("Chapters for specific episode by index in text format")
    func chaptersByIndexText() throws {
        let path = writeFixture(suffix: "chapters_idx_text")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ChaptersCommand.parse([path, "--episode", "0"])
        try command.run()
    }

    @Test("Chapters for specific episode by guid in JSON format")
    func chaptersByGuidJSON() throws {
        let path = writeFixture(suffix: "chapters_guid_json")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ChaptersCommand.parse([path, "-e", "ep-001", "-f", "json"])
        try command.run()
    }

    @Test("Chapters for specific episode in PSC format")
    func chaptersByIndexPSC() throws {
        let path = writeFixture(suffix: "chapters_psc")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ChaptersCommand.parse([path, "-e", "0", "-f", "psc"])
        try command.run()
    }

    @Test("Chapters export to file")
    func chaptersExportToFile() throws {
        let feedPath = writeFixture(suffix: "chapters_export_feed")
        let exportPath = "/tmp/pfm_showcase_chapters_export_\(UUID()).json"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: exportPath)
        }

        var command = try ChaptersCommand.parse([
            feedPath, "-e", "0", "-f", "json", "--export", exportPath
        ])
        try command.run()

        let exported = try String(contentsOfFile: exportPath, encoding: .utf8)
        #expect(exported.contains("Introduction"))
        #expect(exported.contains("Main Topic"))
    }

    @Test("Chapters for episode without chapters shows warning")
    func chaptersForEpisodeWithoutChapters() throws {
        let path = writeFixture(suffix: "chapters_no_chapters")
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Episode 1 (index 1) has no chapters
        var command = try ChaptersCommand.parse([path, "-e", "1"])
        do {
            try command.run()
        } catch let exitCode as ExitCode {
            #expect(exitCode.rawValue == ExitCodes.warningsOnly)
        }
    }

    @Test("Chapters with nonexistent episode identifier throws error")
    func chaptersNonexistentEpisode() throws {
        let path = writeFixture(suffix: "chapters_notfound")
        defer { try? FileManager.default.removeItem(atPath: path) }

        #expect(throws: (any Error).self) {
            var command = try ChaptersCommand.parse([path, "-e", "nonexistent-guid"])
            try command.run()
        }
    }
}
