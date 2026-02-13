import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("EpisodesCommand Tests")
struct EpisodesCommandTests {

    @Test("Parses source with defaults")
    func parsesDefaults() throws {
        let command = try EpisodesCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "text")
        #expect(command.limit == nil)
        #expect(command.sort == "newest")
    }

    @Test("Parses limit option")
    func parsesLimit() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--limit", "10"])
        #expect(command.limit == 10)
    }

    @Test("Parses sort option")
    func parsesSort() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--sort", "oldest"])
        #expect(command.sort == "oldest")
    }

    @Test("Parses JSON format with short flag")
    func parsesShortFormat() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "-f", "json", "-n", "5"])
        #expect(command.format == "json")
        #expect(command.limit == 5)
    }
}
