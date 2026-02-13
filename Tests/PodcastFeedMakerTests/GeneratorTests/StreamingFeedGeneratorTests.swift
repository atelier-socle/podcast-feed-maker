import Foundation
import Testing

@testable import PodcastFeedMaker

struct StreamingFeedGeneratorTests {

    // MARK: - Helpers

    private func minimalChannel() -> Channel {
        Channel(
            title: "Test Podcast",
            link: makeURL("https://example.com"),
            description: "A test podcast"
        )
    }

    private func feedWithItems(_ count: Int) throws -> PodcastFeed {
        var ch = minimalChannel()
        ch.items = try (0..<count).map { i in
            Item(
                title: "Episode \(i)",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://example.com/ep\(i).mp3")),
                    length: 12345,
                    type: "audio/mpeg"
                ))
        }
        return PodcastFeed(channel: ch)
    }

    private func collectChunks(_ stream: AsyncThrowingStream<String, Error>) async throws -> [String] {
        var chunks: [String] = []
        for try await chunk in stream {
            chunks.append(chunk)
        }
        return chunks
    }

    // MARK: - Tests

    @Test("Streaming output matches sync output")
    func streamingMatchesSync() async throws {
        let feed = try feedWithItems(3)
        let syncGen = FeedGenerator()
        let streamGen = StreamingFeedGenerator()

        let syncXML = try syncGen.generate(feed)
        let chunks = try await collectChunks(streamGen.generate(feed))
        let streamXML = chunks.joined()

        #expect(syncXML == streamXML)
    }

    @Test("Chunk count: N items yields N+2 chunks")
    func chunkCount() async throws {
        let feed = try feedWithItems(5)
        let streamGen = StreamingFeedGenerator()
        let chunks = try await collectChunks(streamGen.generate(feed))
        #expect(chunks.count == 7)  // 5 items + header + footer
    }

    @Test("Empty items yields 2 chunks")
    func emptyItems() async throws {
        let feed = try feedWithItems(0)
        let streamGen = StreamingFeedGenerator()
        let chunks = try await collectChunks(streamGen.generate(feed))
        #expect(chunks.count == 2)  // header + footer
    }

    @Test("Single item yields 3 chunks")
    func singleItem() async throws {
        let feed = try feedWithItems(1)
        let streamGen = StreamingFeedGenerator()
        let chunks = try await collectChunks(streamGen.generate(feed))
        #expect(chunks.count == 3)  // header + 1 item + footer
    }

    @Test("Missing channel throws error")
    func missingChannel() async {
        let feed = PodcastFeed()
        let streamGen = StreamingFeedGenerator()
        do {
            let chunks = try await collectChunks(streamGen.generate(feed))
            Issue.record("Expected error, got \(chunks.count) chunks")
        } catch {
            #expect(error is GeneratorError)
        }
    }

    @Test("Header chunk contains XML declaration and channel open")
    func headerChunkContent() async throws {
        let feed = try feedWithItems(1)
        let streamGen = StreamingFeedGenerator()
        let chunks = try await collectChunks(streamGen.generate(feed))
        let header = chunks[0]
        #expect(header.contains("<?xml"))
        #expect(header.contains("<channel>"))
        #expect(header.contains("<title>Test Podcast</title>"))
        #expect(!header.contains("</channel>"))
    }

    @Test("Item chunks contain item content")
    func itemChunkContent() async throws {
        let feed = try feedWithItems(2)
        let streamGen = StreamingFeedGenerator()
        let chunks = try await collectChunks(streamGen.generate(feed))
        #expect(chunks[1].contains("<item>"))
        #expect(chunks[1].contains("Episode 0"))
        #expect(chunks[1].contains("</item>"))
        #expect(chunks[2].contains("Episode 1"))
    }

    @Test("Footer chunk closes channel and rss")
    func footerChunkContent() async throws {
        let feed = try feedWithItems(1)
        let streamGen = StreamingFeedGenerator()
        let chunks = try await collectChunks(streamGen.generate(feed))
        let footer = try #require(chunks.last)
        #expect(footer.contains("</channel>"))
        #expect(footer.contains("</rss>"))
    }

    @Test("Streaming with complex items")
    func streamingComplexItems() async throws {
        var ch = minimalChannel()
        ch.itunesAuthor = "Host"
        ch.items = [
            Item(
                title: "Episode 1",
                itunesAuthor: "Host",
                itunesDuration: 3600,
                contentEncoded: ContentEncoded(value: "<p>HTML content</p>")
            )
        ]
        let feed = PodcastFeed(channel: ch)
        let syncGen = FeedGenerator()
        let streamGen = StreamingFeedGenerator()

        let syncXML = try syncGen.generate(feed)
        let chunks = try await collectChunks(streamGen.generate(feed))
        let streamXML = chunks.joined()

        #expect(syncXML == streamXML)
    }

    @Test("Minified streaming matches sync")
    func minifiedStreaming() async throws {
        let feed = try feedWithItems(2)
        let syncGen = FeedGenerator(prettyPrint: false)
        let streamGen = StreamingFeedGenerator(prettyPrint: false)

        let syncXML = try syncGen.generate(feed)
        let chunks = try await collectChunks(streamGen.generate(feed))
        let streamXML = chunks.joined()

        #expect(syncXML == streamXML)
    }
}
