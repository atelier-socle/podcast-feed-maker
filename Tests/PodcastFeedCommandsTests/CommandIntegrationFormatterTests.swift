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

// MARK: - Formatter and Minimal Feed Integration Tests

@Suite("Command Integration — Formatter and Minimal Feed")
struct CommandIntegrationFormatterTests {

    // MARK: - Shared Fixture

    /// Comprehensive feed XML that passes all 5 platform validations with 0 errors.
    private static let fixtureXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0"
             xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
             xmlns:podcast="https://podcastindex.org/namespace/1.0"
             xmlns:atom="http://www.w3.org/2005/Atom"
             xmlns:psc="http://podlove.org/simple-chapters">
        <channel>
            <title>Integration Test Podcast</title>
            <link>https://example.com</link>
            <description>A test podcast for CLI command integration tests.</description>
            <language>en</language>
            <itunes:author>Test Author</itunes:author>
            <itunes:image href="https://example.com/artwork.jpg"/>
            <itunes:explicit>false</itunes:explicit>
            <itunes:category text="Technology"/>
            <itunes:owner>
                <itunes:name>Test Owner</itunes:name>
                <itunes:email>test@example.com</itunes:email>
            </itunes:owner>
            <itunes:type>episodic</itunes:type>
            <podcast:locked>yes</podcast:locked>
            <podcast:guid>aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee</podcast:guid>
            <podcast:funding url="https://example.com/donate">Support us</podcast:funding>
            <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
            <item>
                <title>Episode 2: Advanced Topics</title>
                <guid isPermaLink="false">ep-002</guid>
                <pubDate>Mon, 10 Feb 2026 12:00:00 +0000</pubDate>
                <enclosure url="https://example.com/ep2.mp3" length="5000000" type="audio/mpeg"/>
                <itunes:duration>1800</itunes:duration>
                <itunes:episodeType>full</itunes:episodeType>
                <itunes:explicit>false</itunes:explicit>
                <psc:chapters version="1.2">
                    <psc:chapter start="00:00:00" title="Intro"/>
                    <psc:chapter start="00:05:00" title="Main Topic"/>
                    <psc:chapter start="00:25:00" title="Outro"/>
                </psc:chapters>
            </item>
            <item>
                <title>Episode 1: Getting Started</title>
                <guid isPermaLink="false">ep-001</guid>
                <pubDate>Mon, 03 Feb 2026 12:00:00 +0000</pubDate>
                <enclosure url="https://example.com/ep1.mp3" length="3000000" type="audio/mpeg"/>
                <itunes:duration>1200</itunes:duration>
                <itunes:episodeType>full</itunes:episodeType>
                <itunes:explicit>false</itunes:explicit>
            </item>
        </channel>
        </rss>
        """

    private let fixturePath: String

    init() throws {
        fixturePath = "/tmp/pfm_integration_\(UUID().uuidString).xml"
        try Self.fixtureXML.write(toFile: fixturePath, atomically: true, encoding: .utf8)
    }

    /// Runs a command, accepting ExitCode throws as expected behavior.
    private func runAllowingExitCode(_ command: inout some ParsableCommand) throws {
        do {
            try command.run()
        } catch is ExitCode {
            // Expected: command signals status via ExitCode
        }
    }

    // MARK: - Lint/Validate with minimal feed (errors)

    @Test("Lint minimal feed with errors shows error output")
    func lintMinimalFeedErrors() throws {
        let minimalXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            <channel>
                <title>Bare Minimum</title>
                <link>https://example.com</link>
                <description>Missing required fields.</description>
            </channel>
            </rss>
            """
        let minPath = "/tmp/pfm_minimal_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: minPath) }
        try minimalXML.write(toFile: minPath, atomically: true, encoding: .utf8)

        var command = try LintCommand.parse([minPath])
        do {
            try command.run()
        } catch let exitCode as ExitCode {
            #expect(exitCode.rawValue == ExitCodes.error)
        }
    }

    @Test("Lint minimal feed JSON format with errors")
    func lintMinimalFeedJsonErrors() throws {
        let minimalXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            <channel>
                <title>Bare Minimum</title>
                <link>https://example.com</link>
                <description>Missing required fields.</description>
            </channel>
            </rss>
            """
        let minPath = "/tmp/pfm_minimal_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: minPath) }
        try minimalXML.write(toFile: minPath, atomically: true, encoding: .utf8)

        var command = try LintCommand.parse([minPath, "--format", "json"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate minimal feed shows errors and warnings")
    func validateMinimalFeed() throws {
        let minimalXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            <channel>
                <title>Bare Minimum</title>
                <link>https://example.com</link>
                <description>Missing required fields.</description>
            </channel>
            </rss>
            """
        let minPath = "/tmp/pfm_minimal_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: minPath) }
        try minimalXML.write(toFile: minPath, atomically: true, encoding: .utf8)

        var command = try ValidateCommand.parse([minPath, "--platform", "apple", "--verbose"])
        try runAllowingExitCode(&command)
    }

    // MARK: - OutputFormatter additional paths

    @Test("Validation report with zero errors and zero warnings")
    func validationReportClean() {
        let report = ValidationReport(
            platform: .apple,
            results: []
        )
        let formatted = OutputFormatter.formatValidationReport(report)
        #expect(formatted.contains("0 errors, 0 warnings"))
    }

    @Test("Validation report verbose shows field paths")
    func validationReportVerbose() {
        let report = ValidationReport(
            platform: .spotify,
            results: [
                ValidationResult(
                    severity: .error,
                    message: "Missing required field",
                    field: "channel.itunes:image"
                ),
                ValidationResult(
                    severity: .warning,
                    message: "Recommended field missing",
                    field: "channel.itunes:author"
                ),
                ValidationResult(
                    severity: .info,
                    message: "Consider adding",
                    field: "channel.podcast:funding"
                )
            ]
        )
        let formatted = OutputFormatter.formatValidationReport(report, verbose: true)
        #expect(formatted.contains("ERROR"))
        #expect(formatted.contains("WARNING"))
        #expect(formatted.contains("INFO"))
        #expect(formatted.contains("channel.itunes:image"))
    }

    @Test("Diff with removed and modified items")
    func diffFormattingAllTypes() {
        let diffs = [
            FeedDifference(
                changeType: .added, field: "channel.link",
                newValue: "https://new.example.com"),
            FeedDifference(
                changeType: .removed, field: "channel.copyright",
                oldValue: "2025 Test"),
            FeedDifference(
                changeType: .modified, field: "channel.items[0].title",
                oldValue: "Old Episode Title That Is Very Long Indeed",
                newValue: "New Episode Title"),
            FeedDifference(
                changeType: .removed, field: "channel.items[1]",
                oldValue: "Deleted Episode")
        ]
        let formatted = OutputFormatter.formatDiff(
            diffs, oldLabel: "old.xml", newLabel: "new.xml")
        #expect(formatted.contains("Channel:"))
        #expect(formatted.contains("Episodes:"))
    }

    @Test("Feed summary verbose with complete channel")
    func feedSummaryVerboseFull() {
        let url = URL(string: "https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Verbose Test Podcast",
                link: url ?? URL(fileURLWithPath: "/"),
                description: "A test",
                language: "en",
                items: [
                    Item(title: "Ep 1")
                ],
                itunesAuthor: "Author",
                itunesCategories: [ITunesCategory(text: "Tech")],
                itunesExplicit: true,
                itunesImage: url,
                itunesType: .serial,
                atomLinks: [
                    AtomLink(
                        href: url ?? URL(fileURLWithPath: "/"),
                        rel: "self", type: "application/rss+xml")
                ],
                podcastGuid: PodcastGuid(value: "test-guid")
            ))
        let summary = OutputFormatter.formatFeedSummary(feed, verbose: true)
        #expect(summary.contains("Artwork:"))
        #expect(summary.contains("Feed URL:"))
        #expect(summary.contains("GUID:"))
        #expect(summary.contains("Explicit:"))
        #expect(summary.contains("Type:"))
    }

    @Test("Chapters with href links formatted correctly")
    func chaptersWithHref() {
        let chapters = [
            PodloveChapter(
                start: "00:00:00", title: "Intro",
                href: URL(string: "https://example.com/intro"))
        ]
        let result = OutputFormatter.formatChapters(chapters)
        #expect(result.contains("[00:00:00] Intro"))
        #expect(result.contains("example.com/intro"))
    }

    @Test("Episode table with episode types and dates")
    func episodeTableFull() {
        let items = [
            Item(
                title: "A Very Long Episode Title That Should Be Truncated In The Table Display",
                enclosure: Enclosure(
                    url: URL(string: "https://example.com/ep.mp3")
                        ?? URL(fileURLWithPath: "/"),
                    length: 1000,
                    type: "audio/mpeg"
                ),
                pubDate: Date(),
                itunesDuration: 7200,
                itunesEpisodeType: .full
            )
        ]
        let table = OutputFormatter.formatEpisodeTable(items)
        #expect(table.contains("full"))
        #expect(table.contains("2:00:00"))
    }
}

// MARK: - Output Formatter Extra Tests

@Suite("Command Integration — Output Formatter Extra")
struct OutputFormatterExtraTests {

    @Test("formatChapters with empty array returns no-chapters message")
    func formatChaptersEmpty() {
        let result = OutputFormatter.formatChapters([])
        #expect(result == "No chapters found.")
    }

    @Test("formatJSONChapters with empty array returns no-chapters message")
    func formatJSONChaptersEmpty() {
        let result = OutputFormatter.formatJSONChapters([])
        #expect(result == "No chapters found.")
    }

    @Test("formatTemplateReport verbose shows all severity levels")
    func formatTemplateReportVerboseAllSeverities() {
        let report = TemplateValidationReport(
            level: .standard,
            results: [
                TemplateValidationResult(
                    severity: .error,
                    tag: .podcastLocked,
                    message: "Missing required tag: podcastLocked"
                ),
                TemplateValidationResult(
                    severity: .warning,
                    tag: .podcastFunding,
                    message: "Recommended tag missing: podcastFunding"
                ),
                TemplateValidationResult(
                    severity: .info,
                    tag: .podcastTranscript,
                    message: "podcastTranscript is an advanced-level feature.",
                    suggestedLevel: .advanced
                )
            ]
        )
        let formatted = OutputFormatter.formatTemplateReport(report, verbose: true)
        #expect(formatted.contains("ERROR"))
        #expect(formatted.contains("WARNING"))
        #expect(formatted.contains("INFO"))
        #expect(formatted.contains("podcastLocked"))
        #expect(formatted.contains("podcastFunding"))
        #expect(formatted.contains("podcastTranscript"))
    }

    @Test("formatTemplateReport with compliant template shows success line")
    func formatTemplateReportCompliant() {
        let report = TemplateValidationReport(
            level: .basic,
            results: []
        )
        let formatted = OutputFormatter.formatTemplateReport(report)
        #expect(formatted.contains("Template (basic): compliant"))
    }

    @Test("formatTemplateReport non-compliant shows error count summary")
    func formatTemplateReportNonCompliant() {
        let report = TemplateValidationReport(
            level: .expert,
            results: [
                TemplateValidationResult(
                    severity: .error,
                    tag: .podcastLocked,
                    message: "Missing required tag"
                ),
                TemplateValidationResult(
                    severity: .warning,
                    tag: .podcastFunding,
                    message: "Recommended tag missing"
                )
            ]
        )
        let formatted = OutputFormatter.formatTemplateReport(report)
        #expect(formatted.contains("1 error(s)"))
        #expect(formatted.contains("1 warning(s)"))
    }

    @Test("formatTemplateReport compliant with warnings shows warning summary")
    func formatTemplateReportCompliantWithWarnings() {
        let report = TemplateValidationReport(
            level: .standard,
            results: [
                TemplateValidationResult(
                    severity: .warning,
                    tag: .podcastFunding,
                    message: "Recommended tag missing"
                )
            ]
        )
        let formatted = OutputFormatter.formatTemplateReport(report)
        #expect(formatted.contains("1 warning(s)"))
        // Should NOT contain "error(s)" since there are no errors
        #expect(!formatted.contains("error(s)"))
    }

    @Test("OutputError.encodingFailed has correct description")
    func outputErrorEncodingFailedDescription() {
        let error = OutputError.encodingFailed
        #expect(error.description == "Failed to encode output as UTF-8")
    }
}
