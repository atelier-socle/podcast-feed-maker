import ArgumentParser
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
}
