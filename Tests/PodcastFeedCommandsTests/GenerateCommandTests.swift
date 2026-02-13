import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("GenerateCommand Tests")
struct GenerateCommandTests {

    @Test("Parses input with defaults")
    func parsesDefaults() throws {
        let command = try GenerateCommand.parse(["feed.json"])
        #expect(command.input == "feed.json")
        #expect(command.output == nil)
        #expect(command.pretty == false)
        #expect(command.minified == false)
        #expect(command.validate == false)
    }

    @Test("Parses output option")
    func parsesOutput() throws {
        let command = try GenerateCommand.parse(["feed.json", "-o", "feed.xml"])
        #expect(command.output == "feed.xml")
    }

    @Test("Parses validate flag")
    func parsesValidate() throws {
        let command = try GenerateCommand.parse(["feed.json", "--validate"])
        #expect(command.validate == true)
    }

    @Test("Parses minified flag")
    func parsesMinified() throws {
        let command = try GenerateCommand.parse(["feed.json", "--minified"])
        #expect(command.minified == true)
    }
}
