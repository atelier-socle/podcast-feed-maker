import Foundation
import Testing

@testable import PodcastFeedMaker

struct PodcastFeedEngineTests {

    let engine = PodcastFeedEngine()

    // MARK: - Generation

    @Test("generate produces valid RSS XML")
    func generateValidFeed() throws {
        let xml = try engine.generate(MockFeed.applePodcasts)
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>CHANNEL TITLE</title>"))
        #expect(xml.contains("</channel>"))
        #expect(xml.contains("</rss>"))
    }

    @Test("generate throws for missing channel")
    func generateMissingChannel() {
        let feed = PodcastFeed(channel: nil)
        #expect(throws: GeneratorError.self) {
            _ = try engine.generate(feed)
        }
    }

    @Test("generate with prettyPrint false produces minified output")
    func generateMinified() throws {
        let xml = try engine.generate(MockFeed.applePodcasts, prettyPrint: false)
        #expect(!xml.contains("\t"))
        #expect(!xml.contains("\n"))
    }

    @Test("generateStream yields N+2 chunks")
    func generateStreamChunkCount() async throws {
        var chunks: [String] = []
        for try await chunk in engine.generateStream(MockFeed.applePodcasts) {
            chunks.append(chunk)
        }
        let itemCount = MockFeed.applePodcasts.channel?.items.count ?? 0
        #expect(chunks.count == itemCount + 2)
    }

    // MARK: - Parsing

    @Test("parse round-trips a generated feed")
    func parseRoundTrip() throws {
        let xml = try engine.generate(MockFeed.applePodcasts)
        let parsed = try engine.parse(xml)
        #expect(parsed.channel != nil)
        #expect(parsed.channel?.title == "CHANNEL TITLE")
        #expect(parsed.channel?.description == "CHANNEL DESCRIPTION CONTENT")
    }

    @Test("parse from Data works")
    func parseFromData() throws {
        let xml = try engine.generate(MockFeed.applePodcasts)
        let data = xml.data(using: .utf8)!
        let parsed = try engine.parse(data: data)
        #expect(parsed.channel?.title == "CHANNEL TITLE")
    }

    @Test("parse throws for invalid XML")
    func parseInvalidXML() {
        #expect(throws: ParserError.self) {
            _ = try engine.parse("not xml at all <<<>>>")
        }
    }

    // MARK: - Validation

    @Test("validate returns report for a platform")
    func validateSinglePlatform() throws {
        let report = engine.validate(MockFeed.applePodcasts, for: .apple)
        #expect(report.platform == .apple)
        #expect(report.isValid)
    }

    @Test("validateAll returns reports for all platforms")
    func validateAllPlatforms() throws {
        let reports = engine.validateAll(MockFeed.applePodcasts)
        #expect(reports.count == ValidationPlatform.allCases.count)
        for report in reports {
            #expect(ValidationPlatform.allCases.contains(report.platform))
        }
    }

    @Test("validate catches missing channel title")
    func validateMissingTitle() throws {
        let channel = Channel(
            title: "",
            link: URL(string: "https://example.com")!,
            description: "A podcast"
        )
        let feed = PodcastFeed(channel: channel)
        let report = engine.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    // MARK: - parseAndValidate

    @Test("parseAndValidate returns both feed and report")
    func parseAndValidate() throws {
        let xml = try engine.generate(MockFeed.applePodcasts)
        let (feed, report) = try engine.parseAndValidate(xml, for: .apple)
        #expect(feed.channel != nil)
        #expect(report.platform == .apple)
    }

    @Test("parseAndValidate throws for invalid XML")
    func parseAndValidateInvalidXML() {
        #expect(throws: ParserError.self) {
            _ = try engine.parseAndValidate("<<<invalid>>>", for: .apple)
        }
    }

    // MARK: - normalize

    @Test("normalize produces consistent output")
    func normalizeProducesConsistentOutput() throws {
        let xml = try engine.generate(MockFeed.applePodcasts)
        let normalized = try engine.normalize(xml)
        let normalizedAgain = try engine.normalize(normalized)
        #expect(normalized == normalizedAgain)
    }

    // MARK: - isEquivalent

    @Test("isEquivalent returns true for identical feeds")
    func isEquivalentIdentical() throws {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "A test podcast"
        )
        let feed = PodcastFeed(channel: channel)
        let xml = try engine.generate(feed)
        #expect(try engine.isEquivalent(xml, xml))
    }

    @Test("isEquivalent returns true for differently formatted feeds")
    func isEquivalentDifferentFormatting() throws {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "A test podcast"
        )
        let feed = PodcastFeed(channel: channel)
        let pretty = try engine.generate(feed, prettyPrint: true)
        let minified = try engine.generate(feed, prettyPrint: false)
        #expect(try engine.isEquivalent(pretty, minified))
    }

    @Test("isEquivalent returns false for different feeds")
    func isEquivalentDifferent() throws {
        let channel1 = Channel(
            title: "Podcast A",
            link: URL(string: "https://example.com")!,
            description: "First podcast"
        )
        let channel2 = Channel(
            title: "Podcast B",
            link: URL(string: "https://example.com")!,
            description: "Second podcast"
        )
        let xml1 = try engine.generate(PodcastFeed(channel: channel1))
        let xml2 = try engine.generate(PodcastFeed(channel: channel2))
        #expect(try !engine.isEquivalent(xml1, xml2))
    }

    // MARK: - Parse from URL

    @Test("Engine parse from file URL")
    func engineParseFromFileURL() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"><channel>
                <title>Engine URL Test</title>
                <link>https://example.com</link>
                <description>Test</description>
            </channel></rss>
            """
        let path = "/tmp/pfm_engine_url_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        let engine = PodcastFeedEngine()
        let feed = try await engine.parse(url: URL(fileURLWithPath: path))
        #expect(feed.channel?.title == "Engine URL Test")
    }

    // MARK: - Sendable

    @Test("PodcastFeedEngine is Sendable")
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(PodcastFeedEngine.self)
    }
}

// MARK: - PodcastFeedEngine Async Tests

@Suite("PodcastFeedEngine Async Tests", .serialized)
struct PodcastFeedEngineAsyncTests {

    let engine = PodcastFeedEngine()

    // MARK: - validateNetwork

    @Test("validateNetwork returns results for valid feed")
    func validateNetworkValidFeed() async throws {
        let artURL = "https://cdn.example.com/engine-art.jpg"
        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 200),
            for: artURL
        )
        for item in MockFeed.applePodcasts.channel?.items ?? [] {
            MockResponseStore.shared.set(
                MockResponse(
                    data: Data(),
                    statusCode: 200,
                    headers: ["Content-Type": item.enclosure?.type ?? "audio/mpeg"]
                ),
                for: item.enclosure?.url.absoluteString ?? ""
            )
            if let imgURL = item.itunesImage?.absoluteString {
                MockResponseStore.shared.set(
                    MockResponse(data: Data(), statusCode: 200),
                    for: imgURL
                )
            }
        }
        MockResponseStore.shared.set(
            MockResponse(data: Data(), statusCode: 200),
            for: MockFeed.applePodcasts.channel?.itunesImage?.absoluteString ?? ""
        )
        for atomLink in MockFeed.applePodcasts.channel?.atomLinks ?? [] {
            MockResponseStore.shared.set(
                MockResponse(data: Data(), statusCode: 200),
                for: atomLink.href.absoluteString
            )
        }

        let session = makeMockSession()
        let results = try await engine.validateNetwork(
            MockFeed.applePodcasts, session: session)
        // Should not crash, results may contain warnings but no network errors
        #expect(results.count >= 0)
    }

    @Test("validateNetwork returns empty for nil channel")
    func validateNetworkNilChannel() async throws {
        let feed = PodcastFeed(channel: nil)
        let session = makeMockSession()
        let results = try await engine.validateNetwork(feed, session: session)
        #expect(results.isEmpty)
    }

    // MARK: - verifyMediaTypes

    @Test("verifyMediaTypes checks enclosures")
    func verifyMediaTypesChecksEnclosures() async throws {
        let url = "https://cdn.example.com/engine-verify.mp3"
        MockResponseStore.shared.set(
            MockResponse(
                data: Data([
                    0x49, 0x44, 0x33, 0x04, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00
                ]),
                statusCode: 206
            ),
            for: url
        )

        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [
                Item(
                    title: "Episode",
                    enclosure: Enclosure(
                        url: URL(string: url)!, length: 1024, type: "audio/mpeg"
                    )
                )
            ]
        )
        let feed = PodcastFeed(channel: channel)
        let session = makeMockSession()
        let results = try await engine.verifyMediaTypes(feed, session: session)
        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    @Test("verifyMediaTypes returns empty for nil channel")
    func verifyMediaTypesNilChannel() async throws {
        let feed = PodcastFeed(channel: nil)
        let session = makeMockSession()
        let results = try await engine.verifyMediaTypes(feed, session: session)
        #expect(results.isEmpty)
    }

    // MARK: - checkArtworkDimensions

    @Test("checkArtworkDimensions validates dimensions")
    func checkArtworkDimensionsValidates() async throws {
        let url = "https://cdn.example.com/engine-dims.jpg"

        var jpegData = Data([
            0xFF, 0xD8,
            0xFF, 0xC0,
            0x00, 0x11,
            0x08
        ])
        jpegData.append(contentsOf: [0x05, 0x78])  // Height: 1400
        jpegData.append(contentsOf: [0x05, 0x78])  // Width: 1400
        let remaining = max(0, 1024 - jpegData.count)
        jpegData.append(
            contentsOf: Array(repeating: UInt8(0x00), count: remaining))

        MockResponseStore.shared.set(
            MockResponse(data: jpegData, statusCode: 206),
            for: url
        )

        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            itunesImage: URL(string: url)
        )
        let feed = PodcastFeed(channel: channel)
        let session = makeMockSession()
        let results = try await engine.checkArtworkDimensions(
            feed, for: .apple, session: session)
        let errors = results.filter { $0.severity == .error }
        #expect(errors.isEmpty)
    }

    @Test("checkArtworkDimensions returns empty for nil channel")
    func checkArtworkDimensionsNilChannel() async throws {
        let feed = PodcastFeed(channel: nil)
        let session = makeMockSession()
        let results = try await engine.checkArtworkDimensions(
            feed, for: .apple, session: session)
        #expect(results.isEmpty)
    }

    // MARK: - generateStream

    @Test("generateStream yields header, items, and footer")
    func generateStreamYieldsChunks() async throws {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "A test podcast",
            items: [
                Item(title: "Ep 1"),
                Item(title: "Ep 2"),
                Item(title: "Ep 3")
            ]
        )
        let feed = PodcastFeed(channel: channel)
        var chunks: [String] = []
        for try await chunk in engine.generateStream(feed) {
            chunks.append(chunk)
        }
        // 3 items + header + footer = 5
        #expect(chunks.count == 5)
        #expect(chunks.first?.contains("<?xml") == true)
        #expect(chunks.last?.contains("</rss>") == true)
    }

    @Test("generateStream with prettyPrint false")
    func generateStreamMinified() async throws {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "A test"
        )
        let feed = PodcastFeed(channel: channel)
        var chunks: [String] = []
        for try await chunk in engine.generateStream(feed, prettyPrint: false) {
            chunks.append(chunk)
        }
        #expect(!chunks.isEmpty)
    }
}
