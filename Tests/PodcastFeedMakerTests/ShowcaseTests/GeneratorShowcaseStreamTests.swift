import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Streaming Feed Generator Showcase

@Suite("Streaming Feed Generator Showcase")
struct StreamingGeneratorShowcase {

    @Test("StreamingFeedGenerator — async chunk generation yields multiple chunks")
    func streamingChunks() async throws {
        let items = (1...5).map { idx in
            Item(
                title: "Stream Episode \(idx)",
                guid: GUID(value: "stream-\(idx)", isPermaLink: false)
            )
        }
        let channel = Channel(
            title: "Streaming Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Streaming test.",
            items: items
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        let streaming = StreamingFeedGenerator()
        var chunks: [String] = []
        for try await chunk in streaming.generate(feed) {
            chunks.append(chunk)
        }

        // N+2 chunks: 1 header + 5 items + 1 footer = 7
        #expect(chunks.count == 7)
    }

    @Test("StreamingFeedGenerator — chunks assemble into valid parseable XML")
    func streamingAssembly() async throws {
        let items = [
            Item(
                title: "Assembled Episode 1",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/a1.mp3")),
                    length: 10_000_000,
                    type: "audio/mpeg"
                )
            ),
            Item(
                title: "Assembled Episode 2",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/a2.mp3")),
                    length: 12_000_000,
                    type: "audio/mpeg"
                )
            )
        ]
        let channel = Channel(
            title: "Assembled Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Assembly test.",
            items: items
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)

        let streaming = StreamingFeedGenerator()
        var assembled = ""
        for try await chunk in streaming.generate(feed) {
            assembled += chunk
        }

        // Verify the assembled string is parseable
        let parser = FeedParser()
        let parsed = try parser.parse(assembled)
        let parsedChannel = try #require(parsed.channel)
        #expect(parsedChannel.title == "Assembled Show")
        #expect(parsedChannel.items.count == 2)
        #expect(parsedChannel.items[0].title == "Assembled Episode 1")
        #expect(parsedChannel.items[1].title == "Assembled Episode 2")
    }

    @Test("StreamingFeedGenerator — pretty-print and minified modes")
    func streamingPrettyPrintModes() async throws {
        let channel = Channel(
            title: "Mode Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Mode test."
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        // Pretty-print
        let prettyGen = StreamingFeedGenerator(prettyPrint: true)
        var prettyChunks = ""
        for try await chunk in prettyGen.generate(feed) { prettyChunks += chunk }
        #expect(prettyChunks.contains("\t"))

        // Minified
        let minGen = StreamingFeedGenerator(prettyPrint: false)
        var minChunks = ""
        for try await chunk in minGen.generate(feed) { minChunks += chunk }
        #expect(!minChunks.contains("\t"))
    }

    @Test("StreamingFeedGenerator — throws missingChannel when no channel")
    func streamingMissingChannel() async {
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
        let streaming = StreamingFeedGenerator()

        do {
            for try await _ in streaming.generate(feed) {
                // Should not yield
            }
            Issue.record("Expected GeneratorError.missingChannel to be thrown")
        } catch {
            #expect(error is GeneratorError)
        }
    }

    @Test("StreamingFeedGenerator — init with all configuration options")
    func streamingInit() {
        let gen = StreamingFeedGenerator(
            prettyPrint: false,
            includeXMLDeclaration: false,
            encoding: "ISO-8859-1",
            namespaceMode: .auto
        )
        #expect(gen.prettyPrint == false)
        #expect(gen.includeXMLDeclaration == false)
        #expect(gen.encoding == "ISO-8859-1")
        #expect(gen.namespaceMode == .auto)
    }
}
