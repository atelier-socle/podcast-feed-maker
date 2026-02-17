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
import Testing

@testable import PodcastFeedMaker

@Suite("OPMLDocument Tests")
struct OPMLDocumentTests {

    // MARK: - Initialization

    @Test("Default initialization creates empty document with version 2.0")
    func defaultInit() {
        let doc = OPMLDocument()
        #expect(doc.version == "2.0")
        #expect(doc.head == nil)
        #expect(doc.outlines.isEmpty)
    }

    @Test("Custom initialization preserves all values")
    func customInit() {
        let head = OPMLHead(title: "My Podcasts")
        let outline = OPMLOutline(text: "Test Feed", type: "rss")
        let doc = OPMLDocument(version: "1.0", head: head, outlines: [outline])

        #expect(doc.version == "1.0")
        #expect(doc.head?.title == "My Podcasts")
        #expect(doc.outlines.count == 1)
    }

    // MARK: - Computed Properties

    @Test("title returns head title")
    func titleFromHead() {
        let doc = OPMLDocument(head: OPMLHead(title: "Subscriptions"))
        #expect(doc.title == "Subscriptions")
    }

    @Test("title returns nil when head is nil")
    func titleNilWithoutHead() {
        let doc = OPMLDocument()
        #expect(doc.title == nil)
    }

    @Test("podcastFeeds returns only RSS outlines with xmlUrl")
    func podcastFeedsFilter() {
        let feed1 = OPMLOutline(
            text: "Feed 1", type: "rss",
            xmlUrl: makeURL("https://example.com/feed1.xml"))
        let feed2 = OPMLOutline(
            text: "Feed 2", type: "rss",
            xmlUrl: makeURL("https://example.com/feed2.xml"))
        let nonFeed = OPMLOutline(text: "Category")
        let rssNoUrl = OPMLOutline(text: "No URL", type: "rss")

        let doc = OPMLDocument(outlines: [feed1, nonFeed, feed2, rssNoUrl])
        #expect(doc.podcastFeeds.count == 2)
    }

    @Test("podcastFeeds includes nested feeds")
    func podcastFeedsNested() {
        let feed = OPMLOutline(
            text: "Nested Feed", type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"))
        let category = OPMLOutline(text: "Tech", children: [feed])
        let doc = OPMLDocument(outlines: [category])

        #expect(doc.podcastFeeds.count == 1)
        #expect(doc.podcastFeeds.first?.text == "Nested Feed")
    }

    @Test("totalOutlineCount counts all levels")
    func totalOutlineCount() {
        let leaf = OPMLOutline(text: "Leaf")
        let child = OPMLOutline(text: "Child", children: [leaf])
        let parent = OPMLOutline(text: "Parent", children: [child])
        let doc = OPMLDocument(outlines: [parent])

        #expect(doc.totalOutlineCount == 3)
    }

    @Test("feedURLs returns all unique feed URLs")
    func feedURLs() {
        let url1 = makeURL("https://example.com/feed1.xml")
        let url2 = makeURL("https://example.com/feed2.xml")
        let feed1 = OPMLOutline(text: "Feed 1", type: "rss", xmlUrl: url1)
        let feed2 = OPMLOutline(text: "Feed 2", type: "rss", xmlUrl: url2)
        let doc = OPMLDocument(outlines: [feed1, feed2])

        #expect(doc.feedURLs.count == 2)
        #expect(doc.feedURLs.contains(url1))
        #expect(doc.feedURLs.contains(url2))
    }

    // MARK: - Equatable & Hashable

    @Test("Equatable compares all fields")
    func equatable() {
        let doc1 = OPMLDocument(head: OPMLHead(title: "A"), outlines: [])
        let doc2 = OPMLDocument(head: OPMLHead(title: "A"), outlines: [])
        let doc3 = OPMLDocument(head: OPMLHead(title: "B"), outlines: [])

        #expect(doc1 == doc2)
        #expect(doc1 != doc3)
    }

    @Test("Codable round-trip preserves all fields")
    func codableRoundTrip() throws {
        let doc = OPMLDocument(
            version: "2.0",
            head: OPMLHead(title: "Test"),
            outlines: [OPMLOutline(text: "Feed", type: "rss")]
        )

        let data = try JSONEncoder().encode(doc)
        let decoded = try JSONDecoder().decode(OPMLDocument.self, from: data)
        #expect(doc == decoded)
    }
}
