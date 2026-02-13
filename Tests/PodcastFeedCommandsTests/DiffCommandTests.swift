import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("DiffCommand Tests")
struct DiffCommandTests {

    @Test("Parses both arguments")
    func parsesBothArgs() throws {
        let command = try DiffCommand.parse(["feed-v1.xml", "feed-v2.xml"])
        #expect(command.old == "feed-v1.xml")
        #expect(command.new == "feed-v2.xml")
        #expect(command.format == "text")
    }

    @Test("Parses JSON format")
    func parsesJSONFormat() throws {
        let command = try DiffCommand.parse(["a.xml", "b.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses no-color flag")
    func parsesNoColor() throws {
        let command = try DiffCommand.parse(["a.xml", "b.xml", "--no-color"])
        #expect(command.noColor == true)
    }
}
