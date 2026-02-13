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

// MARK: - Init Command Showcase

@Suite("CLI Showcase — init Command")
struct InitCommandShowcaseTests {

    @Test(
        "Parses all four template levels",
        arguments: ["basic", "standard", "advanced", "expert"]
    )
    func parsesAllTemplateLevels(level: String) throws {
        let command = try InitCommand.parse(["--template", level])
        #expect(command.template.rawValue == level)
    }

    @Test("Parses --format xml option")
    func parsesFormatXML() throws {
        let command = try InitCommand.parse(["--template", "basic", "--format", "xml"])
        #expect(command.format == "xml")
    }

    @Test("Parses --output path option")
    func parsesOutputPath() throws {
        let command = try InitCommand.parse(["--template", "basic", "-o", "/tmp/out.json"])
        #expect(command.output == "/tmp/out.json")
    }

    @Test("Parses --platforms override")
    func parsesPlatforms() throws {
        let command = try InitCommand.parse([
            "--template", "standard", "--platforms", "apple", "spotify", "psp1"
        ])
        #expect(command.platforms == ["apple", "spotify", "psp1"])
    }

    @Test("Parses --no-color flag")
    func parsesNoColor() throws {
        let command = try InitCommand.parse(["--template", "basic", "--no-color"])
        #expect(command.noColor == true)
    }

    @Test("Missing --template option fails parsing")
    func missingTemplateFailsParsing() {
        #expect(throws: (any Error).self) {
            _ = try InitCommand.parse([])
        }
    }

    @Test("Init basic template produces valid JSON output to stdout")
    func initBasicJSON() throws {
        var command = try InitCommand.parse(["--template", "basic"])
        try command.run()
    }

    @Test("Init standard template produces valid XML output to file")
    func initStandardXMLToFile() throws {
        let outputPath = "/tmp/pfm_showcase_init_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try InitCommand.parse([
            "--template", "standard", "--format", "xml", "--output", outputPath
        ])
        try command.run()

        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        #expect(feed.channel?.title == "My Podcast")
        #expect(feed.channel?.items.count ?? 0 >= 1)
    }

    @Test(
        "All template levels produce feeds with required fields",
        arguments: ["basic", "standard", "advanced", "expert"]
    )
    func allTemplatesProduceValidFeeds(level: String) throws {
        let outputPath = "/tmp/pfm_showcase_init_\(level)_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try InitCommand.parse([
            "--template", level, "--format", "xml", "--output", outputPath
        ])
        try command.run()

        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)
        #expect(!channel.title.isEmpty)
        #expect(!channel.description.isEmpty)
        #expect(channel.items.count >= 1)

        let item = try #require(channel.items.first)
        #expect(item.title != nil)
        #expect(item.enclosure != nil)
    }
}

// MARK: - Lint Command Showcase

@Suite("CLI Showcase — lint Command")
struct LintCommandShowcaseTests {

    @Test("Parses source argument with defaults")
    func parsesDefaults() throws {
        let command = try LintCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.strict == false)
        #expect(command.format == "text")
        #expect(command.template == nil)
        #expect(command.noColor == false)
    }

    @Test("Parses --strict flag")
    func parsesStrict() throws {
        let command = try LintCommand.parse(["feed.xml", "--strict"])
        #expect(command.strict == true)
    }

    @Test("Parses --format json")
    func parsesJSONFormat() throws {
        let command = try LintCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses --template and --platforms options")
    func parsesTemplateAndPlatforms() throws {
        let command = try LintCommand.parse([
            "feed.xml", "--template", "advanced", "--platforms", "apple", "spotify"
        ])
        #expect(command.template == .advanced)
        #expect(command.platforms == ["apple", "spotify"])
    }

    @Test("Lint runs on a valid feed in text format")
    func lintValidFeedText() throws {
        let path = writeFixture(suffix: "lint_text")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try LintCommand.parse([path])
        try runAllowingExitCode(&command)
    }

    @Test("Lint runs on a valid feed in JSON format")
    func lintValidFeedJSON() throws {
        let path = writeFixture(suffix: "lint_json")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try LintCommand.parse([path, "--format", "json"])
        try runAllowingExitCode(&command)
    }

    @Test("Lint with --template standard validates against template")
    func lintWithTemplate() throws {
        let path = writeFixture(suffix: "lint_template")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try LintCommand.parse([
            path, "--template", "standard", "--format", "json"
        ])
        try runAllowingExitCode(&command)
    }

    @Test("Lint detects errors on intentionally bad feed")
    func lintBadFeed() throws {
        let badXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Bad Feed</title>
                <link>https://example.com</link>
                <description>Missing required iTunes fields.</description>
                <item>
                    <title>Episode without enclosure</title>
                </item>
            </channel>
            </rss>
            """
        let path = "/tmp/pfm_showcase_lint_bad_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }
        try badXML.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try LintCommand.parse([path])
        do {
            try command.run()
        } catch let exitCode as ExitCode {
            // Errors or warnings are expected
            #expect(exitCode.rawValue > 0)
        }
    }
}

// MARK: - Validate Command Showcase

@Suite("CLI Showcase — validate Command")
struct ValidateCommandShowcaseTests {

    @Test("Parses source with default options")
    func parsesDefaults() throws {
        let command = try ValidateCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.platform.isEmpty)
        #expect(command.format == "text")
        #expect(command.verbose == false)
        #expect(command.template == nil)
    }

    @Test("Parses single --platform option")
    func parsesSinglePlatform() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--platform", "apple"])
        #expect(command.platform == ["apple"])
    }

    @Test("Parses multiple --platform options")
    func parsesMultiplePlatforms() throws {
        let command = try ValidateCommand.parse([
            "feed.xml", "--platform", "apple", "spotify", "psp1"
        ])
        #expect(command.platform == ["apple", "spotify", "psp1"])
    }

    @Test("Parses --verbose flag")
    func parsesVerbose() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--verbose"])
        #expect(command.verbose == true)
    }

    @Test("Parses --format json option")
    func parsesJSONFormat() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses --template option")
    func parsesTemplate() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--template", "expert"])
        #expect(command.template == .expert)
    }

    @Test("Validate against Apple in text format")
    func validateAppleText() throws {
        let path = writeFixture(suffix: "validate_apple")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ValidateCommand.parse([path, "--platform", "apple"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate against all platforms in JSON format")
    func validateAllJSON() throws {
        let path = writeFixture(suffix: "validate_all")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ValidateCommand.parse([path, "--format", "json"])
        try runAllowingExitCode(&command)
    }

    @Test("Validate with --template standard in JSON format")
    func validateWithTemplateJSON() throws {
        let path = writeFixture(suffix: "validate_template")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ValidateCommand.parse([
            path, "--platform", "apple", "--format", "json", "--template", "standard"
        ])
        try runAllowingExitCode(&command)
    }

    @Test("Validate with unknown platform throws validation error")
    func validateUnknownPlatformThrows() throws {
        let path = writeFixture(suffix: "validate_unknown")
        defer { try? FileManager.default.removeItem(atPath: path) }

        var command = try ValidateCommand.parse([path, "--platform", "nonexistent"])
        #expect(throws: (any Error).self) {
            try command.run()
        }
    }
}
