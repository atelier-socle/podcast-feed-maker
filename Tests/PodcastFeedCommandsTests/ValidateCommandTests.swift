import ArgumentParser
import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("ValidateCommand Tests")
struct ValidateCommandTests {

    @Test("Parses source argument")
    func parsesSource() throws {
        let command = try ValidateCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.platform.isEmpty)
    }

    @Test("Parses single platform")
    func parsesSinglePlatform() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--platform", "apple"])
        #expect(command.platform == ["apple"])
    }

    @Test("Parses multiple platforms")
    func parsesMultiplePlatforms() throws {
        let command = try ValidateCommand.parse([
            "feed.xml", "--platform", "apple", "spotify"
        ])
        #expect(command.platform == ["apple", "spotify"])
    }

    @Test("Parses verbose flag")
    func parsesVerbose() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--verbose"])
        #expect(command.verbose == true)
    }

    @Test("Parses JSON format")
    func parsesJSONFormat() throws {
        let command = try ValidateCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    // MARK: - JSON output with validation errors and template

    @Test("Validate JSON format with Apple errors and standard template")
    func validateJsonAppleErrorsAndTemplate() throws {
        let path = "/tmp/pfm_validate_errors_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Intentionally bad feed: missing itunes:image, itunes:category, etc.
        let badFeed = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Minimal</title>
                <link>https://example.com</link>
                <description>Test</description>
                <item>
                    <title>Ep</title>
                </item>
            </channel>
            </rss>
            """
        try badFeed.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try ValidateCommand.parse([
            path, "--platform", "apple", "--format", "json", "--template", "standard"
        ])
        do {
            try command.run()
            Issue.record("Expected ExitCode for validation errors")
        } catch is ExitCode {
            // Expected: Apple validation errors + template errors
        }
    }
}
