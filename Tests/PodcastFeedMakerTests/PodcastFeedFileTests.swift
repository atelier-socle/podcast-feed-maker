import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFeedFileTests {

    @Test
    func test_writeFeedToTemporaryFile_andDeleteAfter() async throws {
        let feed = PodcastFeedMaker(MockFeed.applePodcasts)
        let xml = try feed.xmlRepresentation()

        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp-feed.xml")

        try xml.write(to: fileURL, atomically: true, encoding: .utf8)

        // Confirm file was written
        #expect(fileManager.fileExists(atPath: fileURL.path))

        // Read it back and confirm content
        let read = try String(contentsOf: fileURL, encoding: .utf8)
        #expect(read.contains("<rss version=\"2.0\""))

        // Clean up
        try fileManager.removeItem(at: fileURL)
        #expect(!fileManager.fileExists(atPath: fileURL.path))
    }

    @Test
    func test_writeAndCleanTemporaryFeedFile() async throws {
        let feed = PodcastFeedMaker(MockFeed.applePodcasts)
        let xml = try feed.xmlRepresentation()

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp-feed-\(UUID().uuidString).xml")

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        try xml.write(to: fileURL, atomically: true, encoding: .utf8)

        // Ensure file exists and is not empty
        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        let contents = try String(contentsOf: fileURL)
        #expect(contents.contains("<rss version=\"2.0\""))
    }

//    @Test func testCompleteFeed() async throws {
//        let xml = try MockFeed.complete.xmlRepresentation()
//        print(xml)
//
//        try xml.write(
//            toFile: "/tmp/feed-full-\(Date.now.timeIntervalSince1970).xml",
//            atomically: true,
//            encoding: .utf8
//        )
//    }

//    @Test func testFeed() async throws {
//        // let xml = try PodcastFeedMaker(MockFeed.default).xmlRepresentation()
//        let xml = try PodcastFeedMaker(MockFeed.applePodcasts).xmlRepresentation()
//        print(xml)
//
//        try xml.write(
//            toFile: "/tmp/feed-\(Date.now.timeIntervalSince1970).xml",
//            atomically: true,
//            encoding: .utf8
//        )
//    }
}
