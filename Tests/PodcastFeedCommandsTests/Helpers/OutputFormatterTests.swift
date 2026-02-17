// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

@Suite("OutputFormatter Tests")
struct OutputFormatterTests {

    // MARK: - Feed Summary

    @Test("Feed summary shows title and episode count")
    func feedSummary() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "My Podcast",
                link: makeURL("https://example.com"),
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
    func truncatesDescription() {
        let longDesc = String(repeating: "x", count: 500)
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: makeURL("https://example.com"),
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
