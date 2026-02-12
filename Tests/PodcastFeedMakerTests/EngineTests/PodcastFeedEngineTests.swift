import Foundation
@testable import PodcastFeedMaker
import Testing

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

    // MARK: - Sendable

    @Test("PodcastFeedEngine is Sendable")
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(PodcastFeedEngine.self)
    }
}
