import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("AddEpisodeCommand Tests")
struct AddEpisodeCommandTests {

    @Test("Parses required options")
    func parsesRequired() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "Episode 43",
            "--audio", "https://example.com/ep43.mp3",
            "--output", "updated.xml"
        ])
        #expect(command.feed == "feed.xml")
        #expect(command.title == "Episode 43")
        #expect(command.audio == "https://example.com/ep43.mp3")
        #expect(command.output == "updated.xml")
        #expect(command.type == "audio/mpeg")
        #expect(command.explicit == false)
    }

    @Test("Parses optional fields")
    func parsesOptional() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "EP",
            "--audio", "https://example.com/ep.mp3",
            "--output", "out.xml",
            "--length", "52000000",
            "--duration", "4200",
            "--description", "A great episode",
            "--guid", "custom-guid-123",
            "--explicit"
        ])
        #expect(command.length == 52_000_000)
        #expect(command.duration == 4200)
        #expect(command.description == "A great episode")
        #expect(command.guid == "custom-guid-123")
        #expect(command.explicit == true)
    }

    @Test("Parses custom MIME type")
    func parsesMIMEType() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "EP",
            "--audio", "https://example.com/ep.m4a",
            "--output", "out.xml",
            "--type", "audio/mp4"
        ])
        #expect(command.type == "audio/mp4")
    }
}
