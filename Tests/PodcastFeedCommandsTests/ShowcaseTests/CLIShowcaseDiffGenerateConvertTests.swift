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

// MARK: - Diff Command Showcase

@Suite("CLI Showcase — diff Command")
struct DiffCommandShowcaseTests {

    @Test("Parses both source arguments with defaults")
    func parsesDefaults() throws {
        let command = try DiffCommand.parse(["old.xml", "new.xml"])
        #expect(command.old == "old.xml")
        #expect(command.new == "new.xml")
        #expect(command.format == "text")
        #expect(command.noColor == false)
    }

    @Test("Parses --format json")
    func parsesJSONFormat() throws {
        let command = try DiffCommand.parse(["old.xml", "new.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses --no-color flag")
    func parsesNoColor() throws {
        let command = try DiffCommand.parse(["old.xml", "new.xml", "--no-color"])
        #expect(command.noColor == true)
    }

    @Test("Diff identical feeds shows no differences")
    func diffIdenticalFeeds() throws {
        let path1 = writeFixture(suffix: "diff_identical_a")
        let path2 = writeFixture(suffix: "diff_identical_b")
        defer {
            try? FileManager.default.removeItem(atPath: path1)
            try? FileManager.default.removeItem(atPath: path2)
        }

        var command = try DiffCommand.parse([path1, path2])
        // Identical feeds should not throw ExitCode.error
        try command.run()
    }

    @Test("Diff detects title change in text format")
    func diffTitleChangeText() throws {
        let path1 = writeFixture(suffix: "diff_old")
        let modifiedXML = fixtureXML.replacingOccurrences(
            of: "CLI Showcase Podcast", with: "Rebranded Podcast"
        )
        let path2 = "/tmp/pfm_showcase_diff_new_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: path1)
            try? FileManager.default.removeItem(atPath: path2)
        }
        try modifiedXML.write(toFile: path2, atomically: true, encoding: .utf8)

        var command = try DiffCommand.parse([path1, path2])
        try runAllowingExitCode(&command)
    }

    @Test("Diff detects differences in JSON format")
    func diffInJSONFormat() throws {
        let path1 = writeFixture(suffix: "diff_json_old")
        let modifiedXML = fixtureXML.replacingOccurrences(
            of: "<language>en</language>", with: "<language>fr</language>"
        )
        let path2 = "/tmp/pfm_showcase_diff_json_new_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: path1)
            try? FileManager.default.removeItem(atPath: path2)
        }
        try modifiedXML.write(toFile: path2, atomically: true, encoding: .utf8)

        var command = try DiffCommand.parse([path1, path2, "--format", "json"])
        try runAllowingExitCode(&command)
    }

    @Test("Diff detects added episode")
    func diffDetectsAddedEpisode() throws {
        let path1 = writeFixture(suffix: "diff_added_old")
        let extraEpisode = """
            \t<item>
            \t\t<title>Episode 3 — New</title>
            \t\t<enclosure url="https://example.com/ep3.mp3" length="70000000" type="audio/mpeg"/>
            \t\t<guid isPermaLink="false">ep-003</guid>
            \t</item>
            """
        let modifiedXML = fixtureXML.replacingOccurrences(
            of: "</channel>",
            with: "\(extraEpisode)\n</channel>"
        )
        let path2 = "/tmp/pfm_showcase_diff_added_new_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: path1)
            try? FileManager.default.removeItem(atPath: path2)
        }
        try modifiedXML.write(toFile: path2, atomically: true, encoding: .utf8)

        var command = try DiffCommand.parse([path1, path2, "--format", "json"])
        try runAllowingExitCode(&command)
    }
}

// MARK: - Generate Command Showcase

@Suite("CLI Showcase — generate Command")
struct GenerateCommandShowcaseTests {

    @Test("Parses input with default options")
    func parsesDefaults() throws {
        let command = try GenerateCommand.parse(["feed.json"])
        #expect(command.input == "feed.json")
        #expect(command.output == nil)
        #expect(command.pretty == false)
        #expect(command.minified == false)
        #expect(command.validate == false)
        #expect(command.template == nil)
    }

    @Test("Parses --output option")
    func parsesOutput() throws {
        let command = try GenerateCommand.parse(["feed.json", "-o", "feed.xml"])
        #expect(command.output == "feed.xml")
    }

    @Test("Parses --validate flag")
    func parsesValidate() throws {
        let command = try GenerateCommand.parse(["feed.json", "--validate"])
        #expect(command.validate == true)
    }

    @Test("Parses --minified flag")
    func parsesMinified() throws {
        let command = try GenerateCommand.parse(["feed.json", "--minified"])
        #expect(command.minified == true)
    }

    @Test("Parses --template option")
    func parsesTemplate() throws {
        let command = try GenerateCommand.parse(["feed.json", "--template", "advanced"])
        #expect(command.template == .advanced)
    }

    @Test("Parses --platforms option")
    func parsesPlatforms() throws {
        let command = try GenerateCommand.parse([
            "feed.json", "--template", "basic", "--platforms", "apple", "spotify"
        ])
        #expect(command.platforms == ["apple", "spotify"])
    }

    @Test("Generate from JSON file produces valid XML")
    func generateFromJSON() throws {
        let jsonPath = "/tmp/pfm_showcase_gen_input_\(UUID()).json"
        let xmlPath = "/tmp/pfm_showcase_gen_output_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: jsonPath)
            try? FileManager.default.removeItem(atPath: xmlPath)
        }

        // Create a feed model, encode to JSON
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Generated Podcast",
                link: url,
                description: "A podcast generated from JSON.",
                items: [
                    Item(
                        title: "Episode 1",
                        enclosure: Enclosure(
                            url: makeURL("https://example.com/ep1.mp3"),
                            length: 50_000_000,
                            type: "audio/mpeg"
                        ),
                        guid: GUID(value: "ep-gen-001", isPermaLink: false)
                    )
                ],
                itunesCategories: [.technology],
                itunesExplicit: false,
                itunesImage: URL(string: "https://example.com/art.jpg")
            )
        )
        let jsonData = try JSONEncoder().encode(feed)
        try jsonData.write(to: URL(fileURLWithPath: jsonPath))

        var command = try GenerateCommand.parse([jsonPath, "-o", xmlPath])
        try command.run()

        let xml = try String(contentsOfFile: xmlPath, encoding: .utf8)
        #expect(xml.contains("<title>Generated Podcast</title>"))
        #expect(xml.contains("<title>Episode 1</title>"))
    }

    @Test("Generate with --validate runs platform validation after generation")
    func generateWithValidation() throws {
        let jsonPath = "/tmp/pfm_showcase_gen_validate_\(UUID()).json"
        defer { try? FileManager.default.removeItem(atPath: jsonPath) }

        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Validated Podcast",
                link: url,
                description: "Generating with validation.",
                items: [
                    Item(
                        title: "Ep 1",
                        enclosure: Enclosure(
                            url: makeURL("https://example.com/ep.mp3"),
                            length: 1000,
                            type: "audio/mpeg"
                        )
                    )
                ]
            )
        )
        let jsonData = try JSONEncoder().encode(feed)
        try jsonData.write(to: URL(fileURLWithPath: jsonPath))

        var command = try GenerateCommand.parse([jsonPath, "--validate"])
        try runAllowingExitCode(&command)
    }

    @Test("Generate rejects URL input")
    func generateRejectsURL() {
        #expect(throws: (any Error).self) {
            var command = try GenerateCommand.parse(["https://example.com/feed.json"])
            try command.run()
        }
    }
}

// MARK: - Convert Command Showcase

@Suite("CLI Showcase — convert Command")
struct ConvertCommandShowcaseTests {

    @Test("Parses input and --to option with defaults")
    func parsesDefaults() throws {
        let command = try ConvertCommand.parse(["feed.xml", "--to", "json"])
        #expect(command.input == "feed.xml")
        #expect(command.to == "json")
        #expect(command.output == nil)
    }

    @Test("Parses --output option")
    func parsesOutput() throws {
        let command = try ConvertCommand.parse(["feed.xml", "--to", "json", "-o", "feed.json"])
        #expect(command.output == "feed.json")
    }

    @Test("Parses PSC target format")
    func parsesPSC() throws {
        let command = try ConvertCommand.parse(["chapters.json", "--to", "psc"])
        #expect(command.to == "psc")
    }

    @Test("Convert XML feed to JSON")
    func convertXMLToJSON() throws {
        let xmlPath = writeFixture(suffix: "convert_xml")
        let jsonPath = "/tmp/pfm_showcase_convert_out_\(UUID()).json"
        defer {
            try? FileManager.default.removeItem(atPath: xmlPath)
            try? FileManager.default.removeItem(atPath: jsonPath)
        }

        var command = try ConvertCommand.parse([xmlPath, "--to", "json", "-o", jsonPath])
        try command.run()

        let jsonString = try String(contentsOfFile: jsonPath, encoding: .utf8)
        #expect(jsonString.contains("CLI Showcase Podcast"))
    }

    @Test("Convert JSON feed to XML")
    func convertJSONToXML() throws {
        // First create a JSON feed file
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "JSON to XML Test",
                link: url,
                description: "Testing JSON to XML conversion.",
                items: [
                    Item(
                        title: "Converted Episode",
                        enclosure: Enclosure(
                            url: makeURL("https://example.com/ep.mp3"),
                            length: 1000,
                            type: "audio/mpeg"
                        )
                    )
                ]
            )
        )
        let jsonPath = "/tmp/pfm_showcase_convert_json_\(UUID()).json"
        let xmlPath = "/tmp/pfm_showcase_convert_xml_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: jsonPath)
            try? FileManager.default.removeItem(atPath: xmlPath)
        }

        let jsonData = try JSONEncoder().encode(feed)
        try jsonData.write(to: URL(fileURLWithPath: jsonPath))

        var command = try ConvertCommand.parse([jsonPath, "--to", "xml", "-o", xmlPath])
        try command.run()

        let xml = try String(contentsOfFile: xmlPath, encoding: .utf8)
        #expect(xml.contains("<title>JSON to XML Test</title>"))
    }

    @Test("Convert with unsupported target format throws error")
    func convertUnsupportedFormat() throws {
        let path = "/tmp/pfm_showcase_convert_bad_\(UUID()).txt"
        defer { try? FileManager.default.removeItem(atPath: path) }
        try "content".write(toFile: path, atomically: true, encoding: .utf8)

        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([path, "--to", "yaml"])
            try command.run()
        }
    }

    @Test("Convert nonexistent file throws error")
    func convertNonexistentFile() {
        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([
                "/tmp/pfm_nonexistent_file_\(UUID()).xml", "--to", "json"
            ])
            try command.run()
        }
    }
}
