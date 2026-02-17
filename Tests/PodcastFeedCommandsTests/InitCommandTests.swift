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

@Suite("InitCommand Tests")
struct InitCommandTests {

    @Test("Parses --template basic")
    func parsesBasic() throws {
        let command = try InitCommand.parse(["--template", "basic"])
        #expect(command.template == .basic)
        #expect(command.format == "json")
        #expect(command.output == nil)
    }

    @Test("Parses --template standard")
    func parsesStandard() throws {
        let command = try InitCommand.parse(["--template", "standard"])
        #expect(command.template == .standard)
    }

    @Test("Parses --template advanced")
    func parsesAdvanced() throws {
        let command = try InitCommand.parse(["--template", "advanced"])
        #expect(command.template == .advanced)
    }

    @Test("Parses --template expert")
    func parsesExpert() throws {
        let command = try InitCommand.parse(["--template", "expert"])
        #expect(command.template == .expert)
    }

    @Test("Parses --format xml")
    func parsesFormatXml() throws {
        let command = try InitCommand.parse(["--template", "basic", "--format", "xml"])
        #expect(command.format == "xml")
    }

    @Test("Parses --output path")
    func parsesOutput() throws {
        let command = try InitCommand.parse(["--template", "basic", "-o", "/tmp/feed.json"])
        #expect(command.output == "/tmp/feed.json")
    }

    @Test("Parses --platforms")
    func parsesPlatforms() throws {
        let command = try InitCommand.parse([
            "--template", "standard", "--platforms", "apple", "spotify"
        ])
        #expect(command.platforms == ["apple", "spotify"])
    }

    @Test("Missing --template fails parsing")
    func missingTemplate() {
        #expect(throws: (any Error).self) {
            _ = try InitCommand.parse([])
        }
    }

    // MARK: - Scaffold Episode Verification

    @Test(
        "All template levels produce feeds with at least one episode",
        arguments: ["basic", "standard", "advanced", "expert"]
    )
    func scaffoldHasEpisode(level: String) throws {
        let outputPath = "/tmp/pfm_scaffold_\(level)_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try InitCommand.parse([
            "--template", level, "--format", "xml", "--output", outputPath
        ])
        try command.run()

        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        let itemCount = feed.channel?.items.count ?? 0
        #expect(itemCount >= 1, "Template \(level) should produce at least 1 episode, got \(itemCount)")
    }

    @Test("Basic scaffold episode has title, enclosure, and guid")
    func basicScaffoldEpisodeFields() throws {
        let outputPath = "/tmp/pfm_basic_fields_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try InitCommand.parse([
            "--template", "basic", "--format", "xml", "--output", outputPath
        ])
        try command.run()

        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.title != nil)
        #expect(item.enclosure != nil)
        #expect(item.guid != nil)
    }

    @Test("Standard scaffold episode has pubDate, duration, and explicit")
    func standardScaffoldEpisodeFields() throws {
        let outputPath = "/tmp/pfm_standard_fields_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try InitCommand.parse([
            "--template", "standard", "--format", "xml", "--output", outputPath
        ])
        try command.run()

        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.pubDate != nil)
        #expect(item.itunesDuration != nil)
        #expect(item.itunesExplicit != nil)
    }
}
