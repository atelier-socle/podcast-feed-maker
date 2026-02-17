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

// MARK: - Feed Converter

/// Tests for ``OPMLFeedConverter`` — bidirectional PodcastFeed ↔ OPMLOutline.
@Suite("OPML Feed Converter Showcase")
struct OPMLFeedConverterShowcase {

    @Test("PodcastFeed → OPMLOutline — converts channel metadata")
    func feedToOutline() throws {
        let feedURL = makeURL("https://example.com/feed.xml")
        let siteURL = makeURL("https://example.com")

        var channel = Channel(
            title: "Tech Talk",
            link: siteURL,
            description: "A technology podcast"
        )
        channel.language = "en-US"
        channel.atomLinks = [
            AtomLink(href: feedURL, rel: "self", type: "application/rss+xml")
        ]

        let feed = PodcastFeed(channel: channel)
        let outline = try #require(OPMLFeedConverter.outline(from: feed))

        #expect(outline.text == "Tech Talk")
        #expect(outline.type == "rss")
        #expect(outline.xmlUrl == feedURL)
        #expect(outline.htmlUrl == siteURL)
        #expect(outline.description == "A technology podcast")
        #expect(outline.language == "en-US")
        #expect(outline.title == "Tech Talk")
    }

    @Test("PodcastFeed → OPMLOutline — falls back to channel link")
    func feedToOutlineFallback() throws {
        let siteURL = makeURL("https://example.com")
        let channel = Channel(
            title: "Fallback", link: siteURL, description: "desc"
        )
        let feed = PodcastFeed(channel: channel)
        let outline = try #require(OPMLFeedConverter.outline(from: feed))
        #expect(outline.xmlUrl == siteURL)
    }

    @Test("PodcastFeed → OPMLOutline — returns nil without channel")
    func feedToOutlineNil() {
        #expect(OPMLFeedConverter.outline(from: PodcastFeed()) == nil)
    }

    @Test("OPMLOutline → PodcastFeed — creates feed stub")
    func outlineToFeed() throws {
        let outline = OPMLOutline(
            text: "My Podcast",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            htmlUrl: makeURL("https://example.com"),
            description: "A great show",
            language: "en"
        )

        let feed = try #require(OPMLFeedConverter.feed(from: outline))
        let channel = try #require(feed.channel)

        #expect(channel.title == "My Podcast")
        #expect(channel.link == makeURL("https://example.com"))
        #expect(channel.description == "A great show")
        #expect(channel.language == "en")
        #expect(channel.atomLinks.first?.href == makeURL("https://example.com/feed.xml"))
        #expect(channel.atomLinks.first?.rel == "self")
    }

    @Test("OPMLOutline → PodcastFeed — uses title over text")
    func outlineToFeedUsesTitle() throws {
        let outline = OPMLOutline(
            text: "Short", type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            title: "Full Title"
        )
        let feed = try #require(OPMLFeedConverter.feed(from: outline))
        #expect(feed.channel?.title == "Full Title")
    }

    @Test("OPMLOutline → PodcastFeed — falls back to xmlUrl for link")
    func outlineToFeedFallbackLink() throws {
        let feedURL = makeURL("https://example.com/feed.xml")
        let outline = OPMLOutline(
            text: "Feed", type: "rss", xmlUrl: feedURL
        )
        let feed = try #require(OPMLFeedConverter.feed(from: outline))
        #expect(feed.channel?.link == feedURL)
    }

    @Test("OPMLOutline → PodcastFeed — returns nil without xmlUrl")
    func outlineToFeedNilWithoutUrl() {
        let outline = OPMLOutline(text: "No URL", type: "rss")
        #expect(OPMLFeedConverter.feed(from: outline) == nil)
    }

    @Test("Multiple feeds → OPMLDocument — creates subscription list")
    func feedsToDocument() throws {
        let feed1 = PodcastFeed(
            channel: Channel(
                title: "Feed 1",
                link: makeURL("https://example.com/1"),
                description: "desc 1"
            )
        )
        let feed2 = PodcastFeed(
            channel: Channel(
                title: "Feed 2",
                link: makeURL("https://example.com/2"),
                description: "desc 2"
            )
        )

        let doc = OPMLFeedConverter.document(
            from: [feed1, feed2],
            title: "My Subs",
            ownerName: "John"
        )

        #expect(doc.head?.title == "My Subs")
        #expect(doc.head?.ownerName == "John")
        #expect(doc.head?.dateCreated != nil)
        #expect(doc.outlines.count == 2)
    }

    @Test("Document → feeds — extracts from nested outlines")
    func documentToFeeds() throws {
        let feed1 = OPMLOutline(
            text: "Feed 1", type: "rss",
            xmlUrl: makeURL("https://example.com/1.xml")
        )
        let feed2 = OPMLOutline(
            text: "Feed 2", type: "rss",
            xmlUrl: makeURL("https://example.com/2.xml")
        )
        let category = OPMLOutline(text: "Tech", children: [feed2])
        let doc = OPMLDocument(outlines: [feed1, category])

        let feeds = OPMLFeedConverter.feeds(from: doc)
        #expect(feeds.count == 2)
    }

    @Test("Bidirectional — feed → outline → feed preserves data")
    func bidirectional() throws {
        let siteURL = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")

        var channel = Channel(
            title: "Round-Trip",
            link: siteURL,
            description: "Test"
        )
        channel.language = "en"
        channel.atomLinks = [
            AtomLink(href: feedURL, rel: "self", type: "application/rss+xml")
        ]

        let originalFeed = PodcastFeed(channel: channel)
        let outline = try #require(OPMLFeedConverter.outline(from: originalFeed))
        let reconverted = try #require(OPMLFeedConverter.feed(from: outline))

        #expect(reconverted.channel?.title == "Round-Trip")
        #expect(reconverted.channel?.link == siteURL)
        #expect(reconverted.channel?.language == "en")
        #expect(reconverted.channel?.atomLinks.first?.href == feedURL)
    }

    @Test("Document from feeds — skips feeds without channel")
    func documentSkipsBadFeeds() {
        let good = PodcastFeed(
            channel: Channel(
                title: "Good",
                link: makeURL("https://example.com"),
                description: "ok"
            )
        )
        let doc = OPMLFeedConverter.document(from: [good, PodcastFeed()])
        #expect(doc.outlines.count == 1)
    }
}
