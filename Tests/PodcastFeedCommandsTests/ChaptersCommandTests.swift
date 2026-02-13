import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("ChaptersCommand Tests")
struct ChaptersCommandTests {

    @Test("Parses source with defaults")
    func parsesDefaults() throws {
        let command = try ChaptersCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.episode == nil)
        #expect(command.format == "text")
        #expect(command.export == nil)
    }

    @Test("Parses episode by index")
    func parsesEpisodeIndex() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "--episode", "0"])
        #expect(command.episode == "0")
    }

    @Test("Parses episode by title")
    func parsesEpisodeTitle() throws {
        let command = try ChaptersCommand.parse(["feed.xml", "-e", "intro"])
        #expect(command.episode == "intro")
    }

    @Test("Parses export option")
    func parsesExport() throws {
        let command = try ChaptersCommand.parse([
            "feed.xml", "-e", "0", "--export", "chapters.json"
        ])
        #expect(command.export == "chapters.json")
    }
}
