import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFeedFileTests {

    @Test
    func test_writeFeedToTemporaryFile_andDeleteAfter() throws {
        let maker = PodcastFeedMaker(MockFeed.applePodcasts)
        let xml = try maker.xmlRepresentation()

        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp-feed.xml")

        try xml.write(to: fileURL, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: fileURL.path))

        let read = try String(contentsOf: fileURL, encoding: .utf8)
        #expect(read.contains("<rss version=\"2.0\""))

        try fileManager.removeItem(at: fileURL)
        #expect(!fileManager.fileExists(atPath: fileURL.path))
    }

    @Test
    func test_writeAndCleanTemporaryFeedFile() throws {
        let maker = PodcastFeedMaker(MockFeed.applePodcasts)
        let xml = try maker.xmlRepresentation()

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp-feed-\(UUID().uuidString).xml")

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        try xml.write(to: fileURL, atomically: true, encoding: .utf8)

        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        let contents = try String(contentsOf: fileURL)
        #expect(contents.contains("<rss version=\"2.0\""))
    }
}
