import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

@Suite("OutputFormatter Tests")
struct OutputFormatterTests {

    // MARK: - Feed Summary

    @Test("Feed summary shows title and episode count")
    func feedSummary() throws {
        let feed = PodcastFeed(
            channel: Channel(
                title: "My Podcast",
                link: try #require(URL(string: "https://example.com")),
                description: "A podcast about things",
                items: [
                    Item(title: "Episode 1"),
                    Item(title: "Episode 2")
                ],
                itunesAuthor: "Author Name"
            ))
        let summary = OutputFormatter.formatFeedSummary(feed)
        #expect(summary.contains("My Podcast"))
        #expect(summary.contains("Author: Author Name"))
        #expect(summary.contains("Episodes: 2"))
    }

    @Test("Feed summary with no channel")
    func noChannel() {
        let feed = PodcastFeed(channel: nil)
        let summary = OutputFormatter.formatFeedSummary(feed)
        #expect(summary.contains("no channel"))
    }

    @Test("Feed summary truncates long description")
    func truncatesDescription() throws {
        let longDesc = String(repeating: "x", count: 500)
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: try #require(URL(string: "https://example.com")),
                description: longDesc
            ))
        let summary = OutputFormatter.formatFeedSummary(feed, verbose: false)
        #expect(summary.contains("..."))
    }

    // MARK: - Episode Table

    @Test("Episode table with items")
    func episodeTable() {
        let items = [
            Item(title: "Episode 1", itunesDuration: 3600),
            Item(title: "Episode 2", itunesDuration: 1800)
        ]
        let table = OutputFormatter.formatEpisodeTable(items)
        #expect(table.contains("Episode 1"))
        #expect(table.contains("Episode 2"))
        #expect(table.contains("1:00:00"))
        #expect(table.contains("30:00"))
    }

    @Test("Episode table respects limit")
    func episodeTableLimit() {
        let items = (1...10).map { Item(title: "Episode \($0)") }
        let table = OutputFormatter.formatEpisodeTable(items, limit: 3)
        #expect(table.contains("Episode 1"))
        #expect(table.contains("(10 episodes total)"))
    }

    @Test("Empty episodes shows message")
    func emptyEpisodes() {
        let table = OutputFormatter.formatEpisodeTable([])
        #expect(table == "No episodes found.")
    }

    // MARK: - Chapter Formatting

    @Test("Formats Podlove chapters")
    func formatPodloveChapters() {
        let chapters = [
            PodloveChapter(start: "00:00:00", title: "Intro"),
            PodloveChapter(start: "00:05:30", title: "Main Topic")
        ]
        let result = OutputFormatter.formatChapters(chapters)
        #expect(result.contains("[00:00:00] Intro"))
        #expect(result.contains("[00:05:30] Main Topic"))
    }

    @Test("Formats JSON chapters")
    func formatJSONChapters() {
        let chapters = [
            JSONChapter(startTime: 0, title: "Intro"),
            JSONChapter(startTime: 300, title: "Main")
        ]
        let result = OutputFormatter.formatJSONChapters(chapters)
        #expect(result.contains("[0:00] Intro"))
        #expect(result.contains("[5:00] Main"))
    }

    // MARK: - JSON Encoding

    @Test("JSON encoding produces valid output")
    func jsonEncoding() throws {
        struct TestData: Encodable {
            let name: String
            let count: Int
        }
        let json = try OutputFormatter.jsonString(TestData(name: "test", count: 42))
        #expect(json.contains("\"name\""))
        #expect(json.contains("\"test\""))
        #expect(json.contains("42"))
    }

    // MARK: - Diff Formatting

    @Test("Diff formatting with changes")
    func diffFormatting() {
        let diffs = [
            FeedDifference(
                changeType: .modified, field: "channel.title",
                oldValue: "Old Title", newValue: "New Title"),
            FeedDifference(
                changeType: .added, field: "channel.items[2]",
                newValue: "New Episode")
        ]
        let result = OutputFormatter.formatDiff(diffs, oldLabel: "a.xml", newLabel: "b.xml")
        #expect(result.contains("Feed Diff"))
        #expect(result.contains("Old Title"))
        #expect(result.contains("New Title"))
    }

    @Test("Diff formatting with no differences")
    func diffNoChanges() {
        let result = OutputFormatter.formatDiff([], oldLabel: "a.xml", newLabel: "b.xml")
        #expect(result.contains("No differences"))
    }
}
