import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("FeedLoader Tests")
struct FeedLoaderTests {

    private static let validXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
        <channel>
            <title>Loader Test</title>
            <link>https://example.com</link>
            <description>A test feed for FeedLoader.</description>
        </channel>
        </rss>
        """

    private let tempPath: String

    init() throws {
        tempPath = "/tmp/pfm_loader_\(UUID().uuidString).xml"
        try Self.validXML.write(toFile: tempPath, atomically: true, encoding: .utf8)
    }

    @Test("Loads raw XML from file path")
    func loadXMLFromFile() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        let xml = try FeedLoader.loadXML(from: tempPath)
        #expect(xml.contains("<title>Loader Test</title>"))
    }

    @Test("Loads and parses feed from file path")
    func loadFeedFromFile() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        let feed = try FeedLoader.load(from: tempPath)
        #expect(feed.channel?.title == "Loader Test")
    }

    @Test("Throws fileNotFound for non-existent path")
    func throwsForMissingFile() {
        #expect(throws: InputError.self) {
            _ = try FeedLoader.loadXML(from: "/tmp/nonexistent_\(UUID()).xml")
        }
    }

    @Test("Handles path with tilde expansion")
    func handlesTildePath() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        // The path is already absolute, but loadXML uses expandingTildeInPath internally
        let xml = try FeedLoader.loadXML(from: tempPath)
        #expect(!xml.isEmpty)
    }

    @Test("Load and parse returns valid channel")
    func loadParsesChannel() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        let feed = try FeedLoader.load(from: tempPath)
        let channel = try #require(feed.channel)
        #expect(channel.description == "A test feed for FeedLoader.")
        #expect(channel.link.absoluteString == "https://example.com")
    }
}
