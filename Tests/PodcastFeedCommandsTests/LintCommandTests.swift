import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("LintCommand Tests")
struct LintCommandTests {

    @Test("Parses source argument")
    func parsesSource() throws {
        let command = try LintCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.strict == false)
        #expect(command.format == "text")
    }

    @Test("Parses strict flag")
    func parsesStrict() throws {
        let command = try LintCommand.parse(["feed.xml", "--strict"])
        #expect(command.strict == true)
    }

    @Test("Parses JSON format option")
    func parsesJSONFormat() throws {
        let command = try LintCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses no-color flag")
    func parsesNoColor() throws {
        let command = try LintCommand.parse(["feed.xml", "--no-color"])
        #expect(command.noColor == true)
    }
}
