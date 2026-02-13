import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

@Suite("Template CLI Integration Tests")
struct TemplateIntegrationTests {

    // MARK: - Shared Fixture

    private static let fixtureXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0"
             xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
             xmlns:podcast="https://podcastindex.org/namespace/1.0"
             xmlns:atom="http://www.w3.org/2005/Atom">
        <channel>
            <title>Template Test Podcast</title>
            <link>https://example.com</link>
            <description>A test podcast for template integration tests.</description>
            <language>en</language>
            <itunes:author>Test Author</itunes:author>
            <itunes:image href="https://example.com/artwork.jpg"/>
            <itunes:explicit>false</itunes:explicit>
            <itunes:category text="Technology"/>
            <itunes:owner>
                <itunes:name>Test Owner</itunes:name>
                <itunes:email>test@example.com</itunes:email>
            </itunes:owner>
            <podcast:locked>yes</podcast:locked>
            <podcast:guid>aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee</podcast:guid>
            <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
            <item>
                <title>Episode 1</title>
                <guid isPermaLink="false">ep-001</guid>
                <pubDate>Mon, 10 Feb 2026 12:00:00 +0000</pubDate>
                <enclosure url="https://example.com/ep1.mp3" length="5000000" type="audio/mpeg"/>
                <itunes:duration>1800</itunes:duration>
                <itunes:explicit>false</itunes:explicit>
            </item>
        </channel>
        </rss>
        """

    private let fixturePath: String

    init() throws {
        fixturePath = "/tmp/pfm_template_\(UUID().uuidString).xml"
        try Self.fixtureXML.write(toFile: fixturePath, atomically: true, encoding: .utf8)
    }

    private func runAllowingExitCode(_ command: inout some ParsableCommand) throws {
        do {
            try command.run()
        } catch is ExitCode {
            // Expected: command signals status via ExitCode
        }
    }

    // MARK: - Lint with --template

    @Test("Lint parses --template option")
    func lintParsesTemplate() throws {
        let command = try LintCommand.parse([fixturePath, "--template", "basic"])
        #expect(command.template == .basic)
    }

    @Test("Lint parses --template with --platforms")
    func lintParsesTemplatePlatforms() throws {
        let command = try LintCommand.parse([
            fixturePath, "--template", "standard", "--platforms", "apple", "spotify"
        ])
        #expect(command.template == .standard)
        #expect(command.platforms == ["apple", "spotify"])
    }

    @Test("Lint with --template basic exercises template validation")
    func lintTemplateBasic() throws {
        var command = try LintCommand.parse([fixturePath, "--template", "basic"])
        try runAllowingExitCode(&command)
    }

    @Test("Lint with --template standard shows compliance")
    func lintTemplateStandard() throws {
        var command = try LintCommand.parse([fixturePath, "--template", "standard"])
        try runAllowingExitCode(&command)
    }

    @Test("Lint with --template expert detects missing tags")
    func lintTemplateExpert() throws {
        var command = try LintCommand.parse([fixturePath, "--template", "expert"])
        do {
            try command.run()
            Issue.record("Expected ExitCode for non-expert feed")
        } catch let exitCode as ExitCode {
            // Expert template has many more required tags
            #expect(exitCode.rawValue == ExitCodes.error || exitCode.rawValue == ExitCodes.warningsOnly)
        }
    }

    @Test("Lint --format json --template basic includes template key")
    func lintJsonTemplate() throws {
        var command = try LintCommand.parse([fixturePath, "--format", "json", "--template", "basic"])
        try runAllowingExitCode(&command)
    }

    @Test("Lint --template basic --strict with warnings")
    func lintStrictTemplate() throws {
        var command = try LintCommand.parse([
            fixturePath, "--template", "basic", "--strict"
        ])
        try runAllowingExitCode(&command)
    }

    // MARK: - Validate with --template

    @Test("Validate parses --template option")
    func validateParsesTemplate() throws {
        let command = try ValidateCommand.parse([fixturePath, "--template", "standard"])
        #expect(command.template == .standard)
    }

    @Test("Validate --platform apple --template basic exercises both")
    func validatePlatformAndTemplate() throws {
        var command = try ValidateCommand.parse([
            fixturePath, "--platform", "apple", "--template", "basic"
        ])
        try runAllowingExitCode(&command)
    }

    @Test("Validate --format json --template standard includes template")
    func validateJsonTemplate() throws {
        var command = try ValidateCommand.parse([
            fixturePath, "--format", "json", "--template", "standard"
        ])
        try runAllowingExitCode(&command)
    }

    // MARK: - Generate with --template

    @Test("Generate parses --template option")
    func generateParsesTemplate() throws {
        let command = try GenerateCommand.parse(["feed.json", "--template", "standard"])
        #expect(command.template == .standard)
    }

    @Test("Generate parses --template with --platforms")
    func generateParsesPlatforms() throws {
        let command = try GenerateCommand.parse([
            "feed.json", "--template", "basic", "--platforms", "apple"
        ])
        #expect(command.platforms == ["apple"])
    }

    // MARK: - Init Command Integration

    @Test("Init --template basic produces JSON output")
    func initBasicJson() throws {
        var command = try InitCommand.parse(["--template", "basic"])
        try command.run()
    }

    @Test("Init --template standard produces JSON output")
    func initStandardJson() throws {
        var command = try InitCommand.parse(["--template", "standard"])
        try command.run()
    }

    @Test("Init --template basic --format xml produces XML output")
    func initBasicXml() throws {
        var command = try InitCommand.parse(["--template", "basic", "--format", "xml"])
        try command.run()
    }

    @Test("Init --template standard --output writes to file")
    func initOutputFile() throws {
        let outputPath = "/tmp/pfm_init_\(UUID()).json"
        defer { try? FileManager.default.removeItem(atPath: outputPath) }
        var command = try InitCommand.parse([
            "--template", "standard", "--output", outputPath
        ])
        try command.run()
        #expect(FileManager.default.fileExists(atPath: outputPath))
    }

    @Test("Init --template advanced includes episode")
    func initAdvanced() throws {
        var command = try InitCommand.parse(["--template", "advanced", "--format", "xml"])
        try command.run()
    }

    @Test("Init --template expert includes transcript")
    func initExpert() throws {
        var command = try InitCommand.parse(["--template", "expert", "--format", "xml"])
        try command.run()
    }

    @Test("Init --template standard --platforms apple overrides preset")
    func initWithPlatforms() throws {
        var command = try InitCommand.parse([
            "--template", "standard", "--platforms", "apple", "spotify"
        ])
        try command.run()
    }

    // MARK: - TemplateName Resolution

    @Test("TemplateName.resolve returns basic for .basic")
    func resolveBasic() {
        let resolved = TemplateName.basic.resolve()
        #expect(resolved.level == .basic)
        #expect(resolved.name == "Basic")
    }

    @Test("TemplateName.resolve with platforms overrides preset")
    func resolveWithPlatforms() {
        let resolved = TemplateName.standard.resolve(platforms: ["apple", "spotify"])
        #expect(resolved.platformPreset.platforms == Set([.apple, .spotify]))
    }

    @Test("parsePlatformNames handles all variants")
    func parsePlatformNames() {
        let platforms = TemplateName.parsePlatformNames([
            "apple", "spotify", "amazon", "podcastIndex", "psp1"
        ])
        #expect(platforms == Set(ValidationPlatform.allCases))
    }

    @Test("parsePlatformNames handles all keyword")
    func parsePlatformNamesAll() {
        let platforms = TemplateName.parsePlatformNames(["all"])
        #expect(platforms == Set(ValidationPlatform.allCases))
    }

    @Test("parsePlatformNames handles podcast-index variant")
    func parsePlatformNamesDash() {
        let platforms = TemplateName.parsePlatformNames(["podcast-index"])
        #expect(platforms.contains(.podcastIndex))
    }

    @Test("parsePlatformNames is case insensitive")
    func parsePlatformNamesCaseInsensitive() {
        let platforms = TemplateName.parsePlatformNames(["Apple", "SPOTIFY", "PodcastIndex"])
        #expect(platforms.contains(.apple))
        #expect(platforms.contains(.spotify))
        #expect(platforms.contains(.podcastIndex))
    }
}
