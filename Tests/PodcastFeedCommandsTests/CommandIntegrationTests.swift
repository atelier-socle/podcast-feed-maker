import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// swiftlint:disable type_body_length file_length

@Suite("Command Integration Tests")
struct CommandIntegrationTests {

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

    /// Creates a temporary JSON feed file and returns the path.
    private func writeJSONFeed() throws -> String {
        let jsonPath = "/tmp/pfm_json_\(UUID().uuidString).json"
        let url = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed(
            version: "2.0",
            namespaces: PodcastNamespace.allStandard,
            channel: Channel(
                title: "Generated Podcast",
                link: url,
                description: "A generated podcast feed."
            )
        )
        let data = try JSONEncoder().encode(feed)
        try data.write(to: URL(fileURLWithPath: jsonPath))
        return jsonPath
    }

    /// Creates a temporary JSON chapters file and returns the path.
    private func writeJSONChapters() throws -> String {
        let jsonPath = "/tmp/pfm_chapters_\(UUID().uuidString).json"
        let chapters = JSONChapterList(
            version: "1.2.0",
            chapters: [
                JSONChapter(startTime: 0, title: "Intro"),
                JSONChapter(startTime: 300, title: "Main Topic"),
                JSONChapter(
                    startTime: 1500.5,
                    title: "Outro",
                    url: URL(string: "https://example.com/link"),
                    img: URL(string: "https://example.com/img.jpg")
                )
            ]
        )
        let data = try JSONEncoder().encode(chapters)
        try data.write(to: URL(fileURLWithPath: jsonPath))
        return jsonPath
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

    // MARK: - DiffCommand

    @Test("Diff identical feeds text format — no differences")
    func diffIdenticalText() throws {
        var command = try DiffCommand.parse([fixturePath, fixturePath])
        try command.run()
    }

    @Test("Diff identical feeds JSON format — no differences")
    func diffIdenticalJson() throws {
        var command = try DiffCommand.parse([fixturePath, fixturePath, "--format", "json"])
        try command.run()
    }

    @Test("Diff different feeds text format throws ExitCode 1")
    func diffDifferentText() throws {
        let modifiedXML = Self.fixtureXML.replacingOccurrences(
            of: "Integration Test Podcast",
            with: "Modified Podcast Title"
        )
        let modifiedPath = "/tmp/pfm_modified_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: modifiedPath) }
        try modifiedXML.write(toFile: modifiedPath, atomically: true, encoding: .utf8)

        var command = try DiffCommand.parse([fixturePath, modifiedPath])
        do {
            try command.run()
            Issue.record("Expected ExitCode throw for different feeds")
        } catch let exitCode as ExitCode {
            #expect(exitCode.rawValue == ExitCodes.error)
        }
    }

    @Test("Diff different feeds JSON format")
    func diffDifferentJson() throws {
        let modifiedXML = Self.fixtureXML.replacingOccurrences(
            of: "Integration Test Podcast",
            with: "Modified Podcast Title"
        )
        let modifiedPath = "/tmp/pfm_modified_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: modifiedPath) }
        try modifiedXML.write(toFile: modifiedPath, atomically: true, encoding: .utf8)

        var command = try DiffCommand.parse([fixturePath, modifiedPath, "--format", "json"])
        try runAllowingExitCode(&command)
    }

    // MARK: - GenerateCommand

    @Test("Generate XML from JSON feed to file")
    func generateToFile() throws {
        let jsonPath = try writeJSONFeed()
        let outputPath = "/tmp/pfm_gen_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: jsonPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try GenerateCommand.parse([jsonPath, "-o", outputPath])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: outputPath))
    }

    @Test("Generate XML from JSON feed to stdout")
    func generateToStdout() throws {
        let jsonPath = try writeJSONFeed()
        defer { try? FileManager.default.removeItem(atPath: jsonPath) }

        var command = try GenerateCommand.parse([jsonPath])
        try command.run()
    }

    @Test("Generate with minified flag")
    func generateMinified() throws {
        let jsonPath = try writeJSONFeed()
        defer { try? FileManager.default.removeItem(atPath: jsonPath) }

        var command = try GenerateCommand.parse([jsonPath, "--minified"])
        try command.run()
    }

    @Test("Generate with validation")
    func generateWithValidation() throws {
        let jsonPath = try writeJSONFeed()
        defer { try? FileManager.default.removeItem(atPath: jsonPath) }

        var command = try GenerateCommand.parse([jsonPath, "--validate"])
        try runAllowingExitCode(&command)
    }

    @Test("Generate rejects URL input")
    func generateRejectsUrl() {
        #expect(throws: (any Error).self) {
            var command = try GenerateCommand.parse(["https://example.com/feed.json"])
            try command.run()
        }
    }

    @Test("Generate with non-existent file throws")
    func generateMissingFile() {
        #expect(throws: (any Error).self) {
            var command = try GenerateCommand.parse(["/tmp/nonexistent_\(UUID()).json"])
            try command.run()
        }
    }

    // MARK: - ConvertCommand

    @Test("Convert feed XML to JSON")
    func convertXmlToJson() throws {
        var command = try ConvertCommand.parse([fixturePath, "--to", "json"])
        try command.run()
    }

    @Test("Convert feed XML to JSON with output file")
    func convertXmlToJsonFile() throws {
        let outputPath = "/tmp/pfm_conv_\(UUID()).json"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }
        var command = try ConvertCommand.parse([fixturePath, "--to", "json", "-o", outputPath])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: outputPath))
    }

    @Test("Convert feed JSON to XML")
    func convertJsonToXml() throws {
        let jsonPath = try writeJSONFeed()
        defer { try? FileManager.default.removeItem(atPath: jsonPath) }

        var command = try ConvertCommand.parse([jsonPath, "--to", "xml"])
        try command.run()
    }

    @Test("Convert JSON chapters to PSC")
    func convertJsonToPsc() throws {
        let jsonPath = try writeJSONChapters()
        defer { try? FileManager.default.removeItem(atPath: jsonPath) }

        var command = try ConvertCommand.parse([jsonPath, "--to", "psc"])
        try command.run()
    }

    @Test("Convert with default fallback to json")
    func convertFallbackJson() throws {
        // Use .txt extension to hit default branch
        let txtPath = "/tmp/pfm_feed_\(UUID()).txt"
        defer { try? FileManager.default.removeItem(atPath: txtPath) }
        try Self.fixtureXML.write(toFile: txtPath, atomically: true, encoding: .utf8)

        var command = try ConvertCommand.parse([txtPath, "--to", "json"])
        try command.run()
    }

    @Test("Convert with default fallback to xml")
    func convertFallbackXml() throws {
        let jsonPath = try writeJSONFeed()
        let txtPath = "/tmp/pfm_feed_\(UUID()).txt"
        defer {
            try? FileManager.default.removeItem(atPath: jsonPath)
            try? FileManager.default.removeItem(atPath: txtPath)
        }
        // Copy JSON content to .txt file for fallback branch
        let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
        try data.write(to: URL(fileURLWithPath: txtPath))

        var command = try ConvertCommand.parse([txtPath, "--to", "xml"])
        try command.run()
    }

    @Test("Convert with default fallback to psc")
    func convertFallbackPsc() throws {
        let jsonPath = try writeJSONChapters()
        let txtPath = "/tmp/pfm_chapters_\(UUID()).txt"
        defer {
            try? FileManager.default.removeItem(atPath: jsonPath)
            try? FileManager.default.removeItem(atPath: txtPath)
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
        try data.write(to: URL(fileURLWithPath: txtPath))

        var command = try ConvertCommand.parse([txtPath, "--to", "psc"])
        try command.run()
    }

    @Test("Convert unsupported target format throws")
    func convertUnsupported() throws {
        let txtPath = "/tmp/pfm_\(UUID()).txt"
        defer { try? FileManager.default.removeItem(atPath: txtPath) }
        try "some content".write(toFile: txtPath, atomically: true, encoding: .utf8)
        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([txtPath, "--to", "html"])
            try command.run()
        }
    }

    @Test("Convert file not found throws")
    func convertMissingFile() {
        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([
                "/tmp/nonexistent_\(UUID()).xml", "--to", "json"
            ])
            try command.run()
        }
    }

    // MARK: - AddEpisodeCommand

    @Test("Add episode to feed with required fields")
    func addEpisode() throws {
        let outputPath = "/tmp/pfm_added_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try AddEpisodeCommand.parse([
            fixturePath,
            "--title", "New Episode",
            "--audio", "https://example.com/new.mp3",
            "-o", outputPath
        ])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: outputPath))

        let content = try String(contentsOfFile: outputPath, encoding: .utf8)
        #expect(content.contains("New Episode"))
    }

    @Test("Add episode with all optional fields")
    func addEpisodeAllFields() throws {
        let outputPath = "/tmp/pfm_added_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try AddEpisodeCommand.parse([
            fixturePath,
            "--title", "Full Episode",
            "--audio", "https://example.com/full.mp3",
            "-o", outputPath,
            "--description", "A detailed episode description",
            "--guid", "custom-guid-123",
            "--duration", "3600",
            "--explicit",
            "--length", "10000000",
            "--pub-date", "Thu, 13 Feb 2026 12:00:00 +0000"
        ])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: outputPath))
    }

    @Test("Add episode with ISO 8601 date")
    func addEpisodeISODate() throws {
        let outputPath = "/tmp/pfm_added_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try AddEpisodeCommand.parse([
            fixturePath,
            "--title", "ISO Date Episode",
            "--audio", "https://example.com/iso.mp3",
            "-o", outputPath,
            "--pub-date", "2026-02-13T12:00:00Z"
        ])
        try command.run()
    }

    @Test("Add episode with custom MIME type")
    func addEpisodeCustomMime() throws {
        let outputPath = "/tmp/pfm_added_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }

        var command = try AddEpisodeCommand.parse([
            fixturePath,
            "--title", "M4A Episode",
            "--audio", "https://example.com/ep.m4a",
            "-o", outputPath,
            "--type", "audio/mp4"
        ])
        try command.run()
    }

    @Test("Add episode with invalid audio URL throws")
    func addEpisodeInvalidUrl() {
        #expect(throws: (any Error).self) {
            var command = try AddEpisodeCommand.parse([
                fixturePath,
                "--title", "Bad",
                "--audio", "",
                "-o", "/tmp/pfm_bad.xml"
            ])
            try command.run()
        }
    }

    @Test("Add episode with unparseable date throws")
    func addEpisodeBadDate() {
        #expect(throws: (any Error).self) {
            var command = try AddEpisodeCommand.parse([
                fixturePath,
                "--title", "Bad Date",
                "--audio", "https://example.com/ep.mp3",
                "-o", "/tmp/pfm_bad.xml",
                "--pub-date", "not-a-date"
            ])
            try command.run()
        }
    }

    @Test("Add episode with local file URL detects file size")
    func addEpisodeLocalFileSize() throws {
        // Create a local audio file to test file size detection
        let audioPath = "/tmp/pfm_audio_\(UUID()).mp3"
        let outputPath = "/tmp/pfm_added_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: audioPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }
        try Data(count: 1024).write(to: URL(fileURLWithPath: audioPath))

        var command = try AddEpisodeCommand.parse([
            fixturePath,
            "--title", "Local File Episode",
            "--audio", "file://\(audioPath)",
            "-o", outputPath
        ])
        try command.run()
    }

    // MARK: - ConvertCommand (PSC)

    @Test("Convert standalone PSC XML to JSON chapters")
    func convertPscToJson() throws {
        let pscXML = """
            <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
              <psc:chapter start="00:00:00" title="Intro"/>
              <psc:chapter start="00:05:00" title="Main Topic"/>
              <psc:chapter start="01:25:30.500" title="Outro"/>
            </psc:chapters>
            """
        let pscPath = "/tmp/pfm_psc_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: pscPath) }
        try pscXML.write(toFile: pscPath, atomically: true, encoding: .utf8)

        var command = try ConvertCommand.parse([pscPath, "--to", "json"])
        try command.run()
    }

    // MARK: - FeedLoader via file:// URL

    @Test("Load feed via file:// URL")
    func loadViaFileURL() throws {
        let fileURL = "file://\(fixturePath)"
        let xml = try FeedLoader.loadXML(from: fileURL)
        #expect(xml.contains("Integration Test Podcast"))
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

// swiftlint:enable type_body_length file_length
