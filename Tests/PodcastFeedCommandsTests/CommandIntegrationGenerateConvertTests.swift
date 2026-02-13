import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// MARK: - Shared Helpers

/// Comprehensive feed XML that passes all 5 platform validations with 0 errors.
private let integrationFixtureXML = """
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

private func makeIntegrationFixturePath() throws -> String {
    let path = "/tmp/pfm_integration_\(UUID().uuidString).xml"
    try integrationFixtureXML.write(toFile: path, atomically: true, encoding: .utf8)
    return path
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

// MARK: - Diff and Generate Integration Tests

@Suite("Command Integration — Diff and Generate")
struct CommandIntegrationDiffGenerateTests {

    private let fixturePath: String

    init() throws {
        fixturePath = try makeIntegrationFixturePath()
    }

    /// Runs a command, accepting ExitCode throws as expected behavior.
    private func runAllowingExitCode(_ command: inout some ParsableCommand) throws {
        do {
            try command.run()
        } catch is ExitCode {
            // Expected: command signals status via ExitCode
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
        let modifiedXML = integrationFixtureXML.replacingOccurrences(
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
        let modifiedXML = integrationFixtureXML.replacingOccurrences(
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
}

// MARK: - Convert, AddEpisode, and FeedLoader Integration Tests

@Suite("Command Integration — Convert, AddEpisode, FeedLoader")
struct CommandIntegrationConvertAddEpisodeTests {

    private let fixturePath: String

    init() throws {
        fixturePath = try makeIntegrationFixturePath()
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
        try integrationFixtureXML.write(toFile: txtPath, atomically: true, encoding: .utf8)

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
}
