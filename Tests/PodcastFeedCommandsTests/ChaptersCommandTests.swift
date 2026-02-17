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

@Suite("ChaptersCommand Tests")
struct ChaptersCommandTests {

    @Test("Parses source with defaults")
    func parsesDefaults() throws {
        let command = try ChaptersCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.episode == nil)
        #expect(command.format == "text")
        #expect(command.export == nil)
    }

    @Test("Parses episode by index")
    func parsesEpisodeIndex() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "--episode", "0"])
        #expect(command.episode == "0")
    }

    @Test("Parses episode by title")
    func parsesEpisodeTitle() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "-e", "intro"])
        #expect(command.episode == "intro")
    }

    @Test("Parses export option")
    func parsesExport() throws {
        let command = try ChaptersCommand.parse([
            "feed.xml", "-e", "0", "--export", "chapters.json"
        ])
        #expect(command.export == "chapters.json")
    }

    // MARK: - Feed with episodes but no chapters

    @Test("Feed with episodes but no chapters exits with code 2")
    func feedWithNoChaptersExitsWarning() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>No Chapters Podcast</title>
                <link>https://example.com</link>
                <description>A podcast with no chapters at all.</description>
                <item>
                    <title>Episode 1</title>
                    <guid>ep-001</guid>
                    <enclosure url="https://example.com/ep1.mp3" length="1000" type="audio/mpeg"/>
                </item>
                <item>
                    <title>Episode 2</title>
                    <guid>ep-002</guid>
                    <enclosure url="https://example.com/ep2.mp3" length="2000" type="audio/mpeg"/>
                </item>
            </channel>
            </rss>
            """
        let path = "/tmp/pfm_chapters_nochapters_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try ChaptersCommand.parse([path])
        do {
            try command.run()
            Issue.record("Expected ExitCode throw for feed with no chapters")
        } catch let exitCode as ExitCode {
            #expect(exitCode.rawValue == ExitCodes.warningsOnly)
        }
    }

    // MARK: - Specific episode without embedded chapters but with chaptersLink

    @Test("Episode without embedded chapters shows chaptersLink message")
    func episodeWithoutEmbeddedChaptersShowsLink() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0">
            <channel>
                <title>ChaptersLink Podcast</title>
                <link>https://example.com</link>
                <description>Podcast with chapters link but no embedded chapters.</description>
                <item>
                    <title>Episode With Link</title>
                    <guid>ep-link</guid>
                    <enclosure url="https://example.com/ep.mp3" length="1000" type="audio/mpeg"/>
                    <podcast:chapters url="https://example.com/chapters.json"
                                      type="application/json+chapters"/>
                </item>
            </channel>
            </rss>
            """
        let path = "/tmp/pfm_chapters_link_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try ChaptersCommand.parse([path, "--episode", "0"])
        do {
            try command.run()
            Issue.record("Expected ExitCode throw for episode without embedded chapters")
        } catch let exitCode as ExitCode {
            #expect(exitCode.rawValue == ExitCodes.warningsOnly)
        }
    }

    // MARK: - PSC output with href and image attributes

    @Test("PSC format output includes href and image attributes")
    func pscOutputWithHrefAndImage() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:psc="http://podlove.org/simple-chapters">
            <channel>
                <title>PSC Attributes Podcast</title>
                <link>https://example.com</link>
                <description>Podcast with rich chapters.</description>
                <item>
                    <title>Rich Chapters Episode</title>
                    <guid>ep-rich</guid>
                    <psc:chapters version="1.2">
                        <psc:chapter start="00:00:00" title="Intro"
                            href="https://example.com/intro"
                            image="https://example.com/intro.jpg"/>
                        <psc:chapter start="00:10:00" title="Main Topic"
                            href="https://example.com/main"
                            image="https://example.com/main.jpg"/>
                    </psc:chapters>
                </item>
            </channel>
            </rss>
            """
        let path = "/tmp/pfm_chapters_psc_rich_\(UUID()).xml"
        let exportPath = "/tmp/pfm_chapters_psc_export_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: path)
            try? FileManager.default.removeItem(atPath: exportPath)
        }
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try ChaptersCommand.parse([
            path, "--episode", "0", "--format", "psc", "--export", exportPath
        ])
        try command.run()

        let exported = try String(contentsOfFile: exportPath, encoding: .utf8)
        #expect(exported.contains("href=\"https://example.com/intro\""))
        #expect(exported.contains("image=\"https://example.com/intro.jpg\""))
        #expect(exported.contains("href=\"https://example.com/main\""))
        #expect(exported.contains("image=\"https://example.com/main.jpg\""))
    }
}
