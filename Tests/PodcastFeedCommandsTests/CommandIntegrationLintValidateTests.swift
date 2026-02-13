import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// MARK: - Lint, Validate, Read, Episodes, Chapters Integration Tests

@Suite("Command Integration — Lint, Validate, Read, Episodes, Chapters")
struct CommandIntegrationLintValidateTests {

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

    // MARK: - LintCommand

    @Test("Lint text format exercises all output paths")
    func lintTextFormat() throws {
        var command = try LintCommand.parse([fixturePath])
        try runAllowingExitCode(&command)
    }

    @Test("Lint JSON format exercises JSON output path")
    func lintJsonFormat() throws {
        var command = try LintCommand.parse([fixturePath, "--format", "json"])
        try runAllowingExitCode(&command)
    }

    @Test("Lint with strict flag")
    func lintStrict() throws {
        var command = try LintCommand.parse([fixturePath, "--strict"])
        try runAllowingExitCode(&command)
    }

    @Test("Lint clean feed shows valid message")
    func lintCleanFeed() throws {
        // The fixture has all required fields — should pass with 0 errors, 0 warnings
        var command = try LintCommand.parse([fixturePath])
        try command.run()
    }

    @Test("Lint feed with warnings but no errors")
    func lintWarningsOnly() throws {
        // Feed with all REQUIRED fields but missing RECOMMENDED itunes:author
        let warningXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0"
                 xmlns:atom="http://www.w3.org/2005/Atom">
            <channel>
                <title>Warning Test</title>
                <link>https://example.com</link>
                <description>Missing recommended fields.</description>
                <language>en</language>
                <itunes:image href="https://example.com/art.jpg"/>
                <itunes:explicit>false</itunes:explicit>
                <itunes:category text="Technology"/>
                <podcast:locked>yes</podcast:locked>
                <podcast:guid>bbbbbbbb-cccc-dddd-eeee-ffffffffffff</podcast:guid>
                <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
                <item>
                    <title>Episode 1</title>
                    <guid isPermaLink="false">ep-001</guid>
                    <enclosure url="https://example.com/ep.mp3" length="1000000" type="audio/mpeg"/>
                    <itunes:explicit>false</itunes:explicit>
                </item>
            </channel>
            </rss>
            """
        let warnPath = "/tmp/pfm_warn_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: warnPath) }
        try warningXML.write(toFile: warnPath, atomically: true, encoding: .utf8)

        var command = try LintCommand.parse([warnPath])
        do {
            try command.run()
        } catch let exitCode as ExitCode {
            // Exit code 2 = warnings only
            #expect(exitCode.rawValue == ExitCodes.warningsOnly)
        }
    }

    @Test("Lint non-existent file throws")
    func lintMissingFile() {
        #expect(throws: (any Error).self) {
            var command = try LintCommand.parse(["/tmp/nonexistent_\(UUID()).xml"])
            try command.run()
        }
    }

    // MARK: - ValidateCommand

    @Test("Validate single platform text format")
    func validateSinglePlatform() throws {
        var command = try ValidateCommand.parse([fixturePath, "--platform", "apple"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate defaults to all platforms")
    func validateAllPlatformsDefault() throws {
        var command = try ValidateCommand.parse([fixturePath])
        try runAllowingExitCode(&command)
    }

    @Test("Validate with explicit all keyword")
    func validateAllKeyword() throws {
        var command = try ValidateCommand.parse([fixturePath, "--platform", "all"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate JSON format with verbose")
    func validateJsonVerbose() throws {
        var command = try ValidateCommand.parse([fixturePath, "--format", "json", "--verbose"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate text format with verbose")
    func validateTextVerbose() throws {
        var command = try ValidateCommand.parse([fixturePath, "--verbose"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate invalid platform throws")
    func validateInvalidPlatform() {
        #expect(throws: (any Error).self) {
            var command = try ValidateCommand.parse([fixturePath, "--platform", "badplatform"])
            try command.run()
        }
    }

    // MARK: - ReadCommand

    @Test("Read feed as summary")
    func readSummary() throws {
        var command = try ReadCommand.parse([fixturePath])
        try command.run()
    }

    @Test("Read feed as verbose summary")
    func readVerboseSummary() throws {
        var command = try ReadCommand.parse([fixturePath, "--verbose"])
        try command.run()
    }

    @Test("Read feed as JSON")
    func readJson() throws {
        var command = try ReadCommand.parse([fixturePath, "--format", "json"])
        try command.run()
    }

    @Test("Read feed as XML")
    func readXml() throws {
        var command = try ReadCommand.parse([fixturePath, "--format", "xml"])
        try command.run()
    }

    @Test("Read with invalid format throws")
    func readInvalidFormat() {
        #expect(throws: (any Error).self) {
            var command = try ReadCommand.parse([fixturePath, "--format", "yaml"])
            try command.run()
        }
    }

    // MARK: - EpisodesCommand

    @Test("Episodes text format with default sort")
    func episodesDefault() throws {
        var command = try EpisodesCommand.parse([fixturePath])
        try command.run()
    }

    @Test("Episodes with limit")
    func episodesLimit() throws {
        var command = try EpisodesCommand.parse([fixturePath, "-n", "1"])
        try command.run()
    }

    @Test("Episodes sorted by title")
    func episodesSortTitle() throws {
        var command = try EpisodesCommand.parse([fixturePath, "--sort", "title"])
        try command.run()
    }

    @Test("Episodes sorted oldest first")
    func episodesSortOldest() throws {
        var command = try EpisodesCommand.parse([fixturePath, "--sort", "oldest"])
        try command.run()
    }

    @Test("Episodes as JSON")
    func episodesJson() throws {
        var command = try EpisodesCommand.parse([fixturePath, "--format", "json"])
        try command.run()
    }

    @Test("Episodes with invalid sort throws")
    func episodesInvalidSort() {
        #expect(throws: (any Error).self) {
            var command = try EpisodesCommand.parse([fixturePath, "--sort", "invalid"])
            try command.run()
        }
    }

    // MARK: - ChaptersCommand

    @Test("Chapters for episode by numeric index")
    func chaptersByIndex() throws {
        var command = try ChaptersCommand.parse([fixturePath, "--episode", "0"])
        try command.run()
    }

    @Test("Chapters for episode by guid")
    func chaptersByGuid() throws {
        var command = try ChaptersCommand.parse([fixturePath, "--episode", "ep-002"])
        try command.run()
    }

    @Test("Chapters for episode by title substring")
    func chaptersByTitle() throws {
        var command = try ChaptersCommand.parse([fixturePath, "--episode", "advanced"])
        try command.run()
    }

    @Test("Chapters as JSON format")
    func chaptersJson() throws {
        var command = try ChaptersCommand.parse([fixturePath, "--episode", "0", "--format", "json"])
        try command.run()
    }

    @Test("Chapters as PSC format")
    func chaptersPsc() throws {
        var command = try ChaptersCommand.parse([fixturePath, "--episode", "0", "--format", "psc"])
        try command.run()
    }

    @Test("Chapters export to file")
    func chaptersExport() throws {
        let exportPath = "/tmp/pfm_chapters_export_\(UUID()).json"
        defer { try? FileManager.default.removeItem(atPath: exportPath) }
        var command = try ChaptersCommand.parse([
            fixturePath, "--episode", "0", "--export", exportPath
        ])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: exportPath))
    }

    @Test("Chapters lists all episodes with chapters")
    func chaptersListAll() throws {
        var command = try ChaptersCommand.parse([fixturePath])
        try runAllowingExitCode(&command)
    }

    @Test("Chapters for episode without chapters throws ExitCode")
    func chaptersNoChapters() {
        #expect(throws: (any Error).self) {
            // Episode at index 1 has no chapters
            var command = try ChaptersCommand.parse([fixturePath, "--episode", "1"])
            try command.run()
        }
    }

    @Test("Chapters for unknown episode throws")
    func chaptersUnknownEpisode() {
        #expect(throws: (any Error).self) {
            var command = try ChaptersCommand.parse([
                fixturePath, "--episode", "nonexistent-guid-xyz"
            ])
            try command.run()
        }
    }
}
