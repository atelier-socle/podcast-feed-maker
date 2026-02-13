import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("ReadCommand Tests")
struct ReadCommandTests {

    @Test("Parses source argument with default format")
    func parsesSourceDefault() throws {
        let command = try ReadCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "summary")
        #expect(command.verbose == false)
    }

    @Test("Parses JSON format")
    func parsesJSON() throws {
        let command = try ReadCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses XML format")
    func parsesXML() throws {
        let command = try ReadCommand.parse(["feed.xml", "-f", "xml"])
        #expect(command.format == "xml")
    }

    @Test("Parses verbose flag")
    func parsesVerbose() throws {
        let command = try ReadCommand.parse(["feed.xml", "--verbose"])
        #expect(command.verbose == true)
    }
}
