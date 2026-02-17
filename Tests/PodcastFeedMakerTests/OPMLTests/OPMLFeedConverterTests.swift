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

@Suite("OPMLFeedConverter Tests")
struct OPMLFeedConverterTests {

    // MARK: - Feed → Outline

    @Test("Converts feed to outline with atom:link self as xmlUrl")
    func feedToOutlineWithAtomLink() {
        let feedURL = makeURL("https://example.com/feed.xml")
        let siteURL = makeURL("https://example.com")

        var channel = Channel(
            title: "My Podcast",
            link: siteURL,
            description: "A great podcast"
        )
        channel.language = "en-US"
        channel.atomLinks = [
            AtomLink(href: feedURL, rel: "self", type: "application/rss+xml")
        ]

        let feed = PodcastFeed(channel: channel)
        let outline = OPMLFeedConverter.outline(from: feed)

        #expect(outline?.text == "My Podcast")
        #expect(outline?.type == "rss")
        #expect(outline?.xmlUrl == feedURL)
        #expect(outline?.htmlUrl == siteURL)
        #expect(outline?.description == "A great podcast")
        #expect(outline?.language == "en-US")
        #expect(outline?.title == "My Podcast")
    }

    @Test("Falls back to channel link when no atom:link self")
    func feedToOutlineFallback() {
        let siteURL = makeURL("https://example.com")
        let channel = Channel(
            title: "Fallback", link: siteURL, description: "desc"
        )
        let feed = PodcastFeed(channel: channel)
        let outline = OPMLFeedConverter.outline(from: feed)

        #expect(outline?.xmlUrl == siteURL)
    }

    @Test("Returns nil for feed without channel")
    func feedToOutlineNilChannel() {
        let feed = PodcastFeed()
        #expect(OPMLFeedConverter.outline(from: feed) == nil)
    }

    // MARK: - Feeds → Document

    @Test("Creates document from multiple feeds")
    func feedsToDocument() {
        let feed1 = PodcastFeed(
            channel: Channel(
                title: "Feed 1",
                link: makeURL("https://example.com/1"),
                description: "desc 1"
            ))
        let feed2 = PodcastFeed(
            channel: Channel(
                title: "Feed 2",
                link: makeURL("https://example.com/2"),
                description: "desc 2"
            ))

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

    @Test("Skips feeds without channel")
    func feedsToDocumentSkipsNil() {
        let goodFeed = PodcastFeed(
            channel: Channel(
                title: "Good", link: makeURL("https://example.com"), description: "ok"
            ))
        let badFeed = PodcastFeed()

        let doc = OPMLFeedConverter.document(from: [goodFeed, badFeed])
        #expect(doc.outlines.count == 1)
    }

    // MARK: - Outline → Feed

    @Test("Converts RSS outline to feed stub")
    func outlineToFeed() {
        let outline = OPMLOutline(
            text: "My Podcast",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            htmlUrl: makeURL("https://example.com"),
            description: "A podcast",
            language: "en"
        )

        let feed = OPMLFeedConverter.feed(from: outline)

        #expect(feed?.channel?.title == "My Podcast")
        #expect(feed?.channel?.link == makeURL("https://example.com"))
        #expect(feed?.channel?.description == "A podcast")
        #expect(feed?.channel?.language == "en")
        #expect(feed?.channel?.atomLinks.first?.href == makeURL("https://example.com/feed.xml"))
        #expect(feed?.channel?.atomLinks.first?.rel == "self")
    }

    @Test("Uses title attribute over text for channel title")
    func outlineToFeedUsesTitle() {
        let outline = OPMLOutline(
            text: "Short Name",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            title: "Full Podcast Title"
        )

        let feed = OPMLFeedConverter.feed(from: outline)
        #expect(feed?.channel?.title == "Full Podcast Title")
    }

    @Test("Falls back to xmlUrl when htmlUrl is nil")
    func outlineToFeedFallbackLink() {
        let feedURL = makeURL("https://example.com/feed.xml")
        let outline = OPMLOutline(
            text: "Feed", type: "rss", xmlUrl: feedURL
        )

        let feed = OPMLFeedConverter.feed(from: outline)
        #expect(feed?.channel?.link == feedURL)
    }

    @Test("Returns nil for outline without xmlUrl")
    func outlineToFeedNilWithoutUrl() {
        let outline = OPMLOutline(text: "No URL", type: "rss")
        #expect(OPMLFeedConverter.feed(from: outline) == nil)
    }

    // MARK: - Document → Feeds

    @Test("Extracts feeds from document including nested")
    func documentToFeeds() {
        let feed1 = OPMLOutline(
            text: "Feed 1", type: "rss",
            xmlUrl: makeURL("https://example.com/1.xml"))
        let feed2 = OPMLOutline(
            text: "Feed 2", type: "rss",
            xmlUrl: makeURL("https://example.com/2.xml"))
        let category = OPMLOutline(text: "Tech", children: [feed2])

        let doc = OPMLDocument(outlines: [feed1, category])
        let feeds = OPMLFeedConverter.feeds(from: doc)

        #expect(feeds.count == 2)
    }
}
