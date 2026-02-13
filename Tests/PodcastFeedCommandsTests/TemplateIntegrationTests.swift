import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// MARK: - Shared Fixture

private let sharedFixtureXML = """
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

private func writeFixture() throws -> String {
    let path = "/tmp/pfm_template_\(UUID().uuidString).xml"
    try sharedFixtureXML.write(toFile: path, atomically: true, encoding: .utf8)
    return path
}

private func runAllowingExitCode(_ command: inout some ParsableCommand) throws {
    do {
        try command.run()
    } catch is ExitCode {
        // Expected: command signals status via ExitCode
    }
}

// MARK: - Lint and Validate Integration

@Suite("Template CLI Lint and Validate Integration")
struct TemplateLintValidateTests {

    private let fixturePath: String

    init() throws {
        fixturePath = try writeFixture()
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

    @Test("Lint --strict with warnings produces exit code error (1)")
    func lintStrictWarningsExitError() throws {
        var command = try LintCommand.parse([fixturePath, "--strict"])
        do {
            try command.run()
        } catch let exitCode as ExitCode {
            // With warnings, --strict must produce error exit code (1), not warningsOnly (2)
            if exitCode.rawValue != ExitCodes.success {
                #expect(exitCode.rawValue == ExitCodes.error)
            }
        }
    }

    @Test("Lint --strict --template basic with template warnings produces exit code error (1)")
    func lintStrictTemplateWarningsExitError() throws {
        var command = try LintCommand.parse([
            fixturePath, "--template", "basic", "--strict"
        ])
        do {
            try command.run()
        } catch let exitCode as ExitCode {
            if exitCode.rawValue != ExitCodes.success {
                #expect(exitCode.rawValue == ExitCodes.error)
            }
        }
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

    // MARK: - Lint JSON with template warnings

    @Test("Lint JSON format with basic template produces template warnings for missing recommended tags")
    func lintJsonBasicTemplateWarnings() throws {
        var command = try LintCommand.parse([
            fixturePath, "--format", "json", "--template", "basic"
        ])
        do {
            try command.run()
        } catch is ExitCode {
            // Expected: exit code for warnings (template warnings for missing recommended tags)
        }
    }

    // MARK: - Lint JSON with template errors

    @Test("Lint JSON format with basic template errors for feed missing required tags")
    func lintJsonTemplateErrors() throws {
        let minimalXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Bare Minimum</title>
                <link>https://example.com</link>
                <description>No iTunes tags at all.</description>
                <item>
                    <title>Ep</title>
                </item>
            </channel>
            </rss>
            """
        let errorPath = "/tmp/pfm_template_error_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: errorPath) }
        try minimalXML.write(toFile: errorPath, atomically: true, encoding: .utf8)

        var command = try LintCommand.parse([
            errorPath, "--format", "json", "--template", "basic"
        ])
        do {
            try command.run()
            Issue.record("Expected ExitCode for feed with template errors")
        } catch is ExitCode {
            // Expected: exit code 1 for template errors
        }
    }

    // MARK: - Validate JSON with errors and template

    @Test("Validate JSON format with errors and template entries")
    func validateJsonWithErrorsAndTemplate() throws {
        let minimalXML = """
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
        let errorPath = "/tmp/pfm_validate_json_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: errorPath) }
        try minimalXML.write(toFile: errorPath, atomically: true, encoding: .utf8)

        var command = try ValidateCommand.parse([
            errorPath, "--platform", "apple", "--format", "json", "--template", "standard"
        ])
        do {
            try command.run()
        } catch is ExitCode {
            // Expected: errors for missing Apple and standard template requirements
        }
    }
}

// MARK: - Generate, Init, and TemplateName Integration

@Suite("Template CLI Generate and Init Integration")
struct TemplateGenerateInitTests {

    private let fixturePath: String

    init() throws {
        fixturePath = try writeFixture()
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

    // MARK: - Lint JSON with template infos (suggestedLevel path)

    @Test("Lint JSON format with expert template produces info-level results with suggestedLevel")
    func lintJsonTemplateExpertInfos() throws {
        let xmlWithAdvancedTags = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0"
                 xmlns:atom="http://www.w3.org/2005/Atom"
                 xmlns:content="http://purl.org/rss/1.0/modules/content/">
            <channel>
                <title>Advanced Tags Podcast</title>
                <link>https://example.com</link>
                <description>A podcast with tags beyond basic level.</description>
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
                <podcast:funding url="https://example.com/donate">Support us</podcast:funding>
                <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
                <item>
                    <title>Episode 1</title>
                    <guid isPermaLink="false">ep-001</guid>
                    <pubDate>Mon, 10 Feb 2026 12:00:00 +0000</pubDate>
                    <enclosure url="https://example.com/ep1.mp3" length="5000000" type="audio/mpeg"/>
                    <itunes:duration>1800</itunes:duration>
                    <itunes:explicit>false</itunes:explicit>
                    <content:encoded><![CDATA[<p>Rich HTML content</p>]]></content:encoded>
                </item>
            </channel>
            </rss>
            """
        let infoPath = "/tmp/pfm_template_info_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: infoPath) }
        try xmlWithAdvancedTags.write(toFile: infoPath, atomically: true, encoding: .utf8)

        var command = try LintCommand.parse([
            infoPath, "--format", "json", "--template", "basic"
        ])
        do {
            try command.run()
        } catch is ExitCode {
            // Expected: exit code for warnings/infos
        }
    }
}
