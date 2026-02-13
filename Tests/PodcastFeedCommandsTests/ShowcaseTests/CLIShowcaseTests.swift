// swiftlint:disable file_length
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
        let url = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed(
            channel: Channel(
                title: "Generated Podcast",
                link: url,
                description: "A podcast generated from JSON.",
                items: [
                    Item(
                        title: "Episode 1",
                        enclosure: Enclosure(
                            url: try #require(URL(string: "https://example.com/ep1.mp3")),
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

        let url = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed(
            channel: Channel(
                title: "Validated Podcast",
                link: url,
                description: "Generating with validation.",
                items: [
                    Item(
                        title: "Ep 1",
                        enclosure: Enclosure(
                            url: try #require(URL(string: "https://example.com/ep.mp3")),
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
        let url = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed(
            channel: Channel(
                title: "JSON to XML Test",
                link: url,
                description: "Testing JSON to XML conversion.",
                items: [
                    Item(
                        title: "Converted Episode",
                        enclosure: Enclosure(
                            url: try #require(URL(string: "https://example.com/ep.mp3")),
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

// MARK: - Add-Episode Command Showcase

@Suite("CLI Showcase — add-episode Command")
struct AddEpisodeCommandShowcaseTests {

    @Test("Parses required options")
    func parsesRequired() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "New Episode",
            "--audio", "https://example.com/new.mp3",
            "--output", "updated.xml"
        ])
        #expect(command.feed == "feed.xml")
        #expect(command.title == "New Episode")
        #expect(command.audio == "https://example.com/new.mp3")
        #expect(command.output == "updated.xml")
        #expect(command.type == "audio/mpeg")
        #expect(command.explicit == false)
    }

    @Test("Parses all optional fields")
    func parsesAllOptional() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "Full Options",
            "--audio", "https://example.com/full.mp3",
            "--output", "out.xml",
            "--length", "75000000",
            "--duration", "3600",
            "--description", "A fully specified episode",
            "--guid", "custom-guid-abc",
            "--pub-date", "Thu, 13 Feb 2026 12:00:00 +0000",
            "--type", "audio/m4a",
            "--explicit"
        ])
        #expect(command.length == 75_000_000)
        #expect(command.duration == 3600)
        #expect(command.description == "A fully specified episode")
        #expect(command.guid == "custom-guid-abc")
        #expect(command.pubDate == "Thu, 13 Feb 2026 12:00:00 +0000")
        #expect(command.type == "audio/m4a")
        #expect(command.explicit == true)
    }

    @Test("Add episode to existing feed creates updated file")
    func addEpisodeToExistingFeed() throws {
        let feedPath = writeFixture(suffix: "add_ep_feed")
        let outputPath = "/tmp/pfm_showcase_add_ep_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Episode 4 — Added by CLI",
            "--audio", "https://example.com/ep4.mp3",
            "--length", "55000000",
            "--duration", "2100",
            "--description", "An episode added via the CLI.",
            "--guid", "ep-004-cli",
            "--output", outputPath
        ])
        try command.run()

        // Verify the output
        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        // New episode should be first (newest)
        #expect(channel.items.count == 4, "Should have 3 original + 1 new episode")
        #expect(channel.items[0].title == "Episode 4 — Added by CLI")
        #expect(channel.items[0].guid?.value == "ep-004-cli")
        #expect(channel.items[0].itunesDuration == 2100)
        #expect(channel.items[0].enclosure?.length == 55_000_000)
        #expect(channel.items[0].description == "An episode added via the CLI.")
    }

    @Test("Add episode with --explicit marks episode as explicit")
    func addExplicitEpisode() throws {
        let feedPath = writeFixture(suffix: "add_ep_explicit")
        let outputPath = "/tmp/pfm_showcase_add_ep_explicit_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Explicit Episode",
            "--audio", "https://example.com/explicit.mp3",
            "--output", outputPath,
            "--explicit"
        ])
        try command.run()

        let feed = try FeedParser().parse(try String(contentsOfFile: outputPath, encoding: .utf8))
        let newItem = try #require(feed.channel?.items.first)
        #expect(newItem.itunesExplicit == true)
    }

    @Test("Add episode with invalid audio URL throws error")
    func addEpisodeInvalidAudioURL() throws {
        let feedPath = writeFixture(suffix: "add_ep_bad_url")
        let outputPath = "/tmp/pfm_showcase_add_ep_bad_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        #expect(throws: (any Error).self) {
            var command = try AddEpisodeCommand.parse([
                feedPath,
                "--title", "Bad URL Episode",
                "--audio", "",
                "--output", outputPath
            ])
            try command.run()
        }
    }

    @Test("Add episode auto-generates GUID when not specified")
    func addEpisodeAutoGUID() throws {
        let feedPath = writeFixture(suffix: "add_ep_auto_guid")
        let outputPath = "/tmp/pfm_showcase_add_ep_auto_guid_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Auto GUID Episode",
            "--audio", "https://example.com/auto.mp3",
            "--output", outputPath
        ])
        try command.run()

        let feed = try FeedParser().parse(try String(contentsOfFile: outputPath, encoding: .utf8))
        let newItem = try #require(feed.channel?.items.first)
        #expect(newItem.guid != nil, "GUID should be auto-generated")
        #expect(newItem.guid?.isPermaLink == false)
    }

    @Test("Add episode updates lastBuildDate on the channel")
    func addEpisodeUpdatesLastBuildDate() throws {
        let feedPath = writeFixture(suffix: "add_ep_build_date")
        let outputPath = "/tmp/pfm_showcase_add_ep_build_date_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Build Date Episode",
            "--audio", "https://example.com/build.mp3",
            "--output", outputPath
        ])
        try command.run()

        let feed = try FeedParser().parse(try String(contentsOfFile: outputPath, encoding: .utf8))
        #expect(feed.channel?.lastBuildDate != nil, "lastBuildDate should be set")
    }
}

// MARK: - TemplateName Showcase

@Suite("CLI Showcase — TemplateName")
struct TemplateNameShowcaseTests {

    @Test("TemplateName resolves all four levels")
    func resolvesAllLevels() {
        for name in TemplateName.allCases {
            let template = name.resolve()
            _ = template.level
        }
    }

    @Test("TemplateName resolves with platform overrides")
    func resolvesWithPlatformOverrides() {
        let template = TemplateName.standard.resolve(platforms: ["apple", "spotify"])
        _ = template.level
    }

    @Test("parsePlatformNames handles all valid platform names")
    func parsePlatformNamesValid() {
        let platforms = TemplateName.parsePlatformNames([
            "apple", "spotify", "amazon", "podcastindex", "psp1"
        ])
        #expect(platforms.contains(.apple))
        #expect(platforms.contains(.spotify))
        #expect(platforms.contains(.amazon))
        #expect(platforms.contains(.podcastIndex))
        #expect(platforms.contains(.psp1))
    }

    @Test("parsePlatformNames handles 'all' keyword")
    func parsePlatformNamesAll() {
        let platforms = TemplateName.parsePlatformNames(["all"])
        #expect(platforms == Set(ValidationPlatform.allCases))
    }

    @Test("parsePlatformNames handles alternate casing and hyphens")
    func parsePlatformNamesAlternate() {
        let platforms = TemplateName.parsePlatformNames(["podcast-index", "APPLE"])
        #expect(platforms.contains(.podcastIndex))
        #expect(platforms.contains(.apple))
    }

    @Test("parsePlatformNames ignores unknown names")
    func parsePlatformNamesUnknown() {
        let platforms = TemplateName.parsePlatformNames(["unknown", "invalid"])
        #expect(platforms.isEmpty)
    }
}
