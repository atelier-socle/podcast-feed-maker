import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("ConvertCommand Tests")
struct ConvertCommandTests {

    @Test("Parses input and to option")
    func parsesInputAndTo() throws {
        let command = try ConvertCommand.parse(["feed.xml", "--to", "json"])
        #expect(command.input == "feed.xml")
        #expect(command.to == "json")
        #expect(command.output == nil)
    }

    @Test("Parses output option")
    func parsesOutput() throws {
        let command = try ConvertCommand.parse([
            "feed.xml", "--to", "json", "-o", "feed.json"
        ])
        #expect(command.output == "feed.json")
    }

    @Test("Parses PSC format")
    func parsesPSC() throws {
        let command = try ConvertCommand.parse(["chapters.json", "--to", "psc"])
        #expect(command.to == "psc")
    }
}
