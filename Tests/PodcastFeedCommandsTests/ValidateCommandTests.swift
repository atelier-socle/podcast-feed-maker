import ArgumentParser
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
}
