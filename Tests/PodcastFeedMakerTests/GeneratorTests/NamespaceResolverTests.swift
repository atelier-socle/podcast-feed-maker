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

struct NamespaceResolverTests {

    // MARK: - Helpers

    private func minimalChannel() -> Channel {
        Channel(
            title: "Test",
            link: makeURL("https://example.com"),
            description: "Test feed"
        )
    }

    private func feedWith(channel: Channel) -> PodcastFeed {
        PodcastFeed(channel: channel)
    }

    // MARK: - Tests

    @Test("Minimal channel has no extra namespaces")
    func minimalChannelNoNamespaces() {
        let feed = feedWith(channel: minimalChannel())
        let resolved = NamespaceResolver.resolve(feed)
        #expect(resolved.isEmpty)
    }

    @Test("Feed with no channel returns empty")
    func noChannelReturnsEmpty() {
        let feed = PodcastFeed()
        let resolved = NamespaceResolver.resolve(feed)
        #expect(resolved.isEmpty)
    }

    @Test("Detects iTunes namespace from channel property")
    func detectsITunesFromChannel() {
        var ch = minimalChannel()
        ch.itunesAuthor = "Host"
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.itunes))
        #expect(!resolved.contains(.atom))
        #expect(!resolved.contains(.podcast))
    }

    @Test("Detects iTunes namespace from item property")
    func detectsITunesFromItem() {
        var ch = minimalChannel()
        ch.items = [Item(itunesDuration: 3600)]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.itunes))
    }

    @Test("Detects Atom namespace")
    func detectsAtom() {
        var ch = minimalChannel()
        let feedURL = makeURL("https://example.com/feed.xml")
        ch.atomLinks = [AtomLink.selfLink(href: feedURL)]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.atom))
        #expect(!resolved.contains(.itunes))
    }

    @Test("Detects Podcast namespace from channel property")
    func detectsPodcastFromChannel() {
        var ch = minimalChannel()
        ch.podcastGuid = PodcastGuid(value: "abc-123")
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.podcast))
    }

    @Test("Detects Podcast namespace from item property")
    func detectsPodcastFromItem() {
        var ch = minimalChannel()
        let transcriptURL = makeURL("https://example.com/t.vtt")
        ch.items = [Item(transcripts: [Transcript(url: transcriptURL, type: "text/vtt")])]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.podcast))
    }

    @Test("Detects Dublin Core namespace")
    func detectsDublinCore() {
        var ch = minimalChannel()
        ch.dublinCore = DublinCore(creator: "Jane")
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.dublinCore))
    }

    @Test("Detects Dublin Core from item")
    func detectsDublinCoreFromItem() {
        var ch = minimalChannel()
        ch.items = [Item(dublinCore: DublinCore(creator: "Jane"))]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.dublinCore))
    }

    @Test("Detects Content namespace from item")
    func detectsContent() {
        var ch = minimalChannel()
        ch.items = [Item(contentEncoded: ContentEncoded(value: "<p>Hello</p>"))]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.content))
    }

    @Test("Detects Podlove namespace from item")
    func detectsPodlove() {
        var ch = minimalChannel()
        ch.items = [Item(podloveChapters: PodloveChapters(chapters: [PodloveChapter(start: "00:00:00", title: "Intro")]))]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.podloveSimpleChapters))
    }

    @Test("Full feed detects all 6 standard namespaces")
    func fullFeedAllNamespaces() {
        var ch = minimalChannel()
        ch.itunesAuthor = "Host"
        let feedURL = makeURL("https://example.com/feed.xml")
        ch.atomLinks = [AtomLink.selfLink(href: feedURL)]
        ch.podcastGuid = PodcastGuid(value: "abc-123")
        ch.dublinCore = DublinCore(creator: "Host")
        ch.items = [
            Item(
                contentEncoded: ContentEncoded(value: "<p>Content</p>"),
                podloveChapters: PodloveChapters(chapters: [PodloveChapter(start: "00:00:00", title: "Intro")])
            )
        ]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.count == 6)
        #expect(resolved.contains(.itunes))
        #expect(resolved.contains(.atom))
        #expect(resolved.contains(.podcast))
        #expect(resolved.contains(.dublinCore))
        #expect(resolved.contains(.content))
        #expect(resolved.contains(.podloveSimpleChapters))
    }

    @Test("Custom namespaces are preserved")
    func customNamespacesPreserved() {
        var ch = minimalChannel()
        ch.itunesAuthor = "Host"
        var feed = feedWith(channel: ch)
        feed.namespaces = [.itunes, .custom(#"xmlns:custom="https://example.com/ns""#)]
        let resolved = NamespaceResolver.resolve(feed)
        #expect(resolved.contains(.itunes))
        #expect(resolved.contains(.custom(#"xmlns:custom="https://example.com/ns""#)))
    }

    @Test("Detects Podcast namespace from various channel properties")
    func detectsPodcastFromVariousChannelProps() {
        // locked
        var ch1 = minimalChannel()
        ch1.locked = Locked(isLocked: true)
        #expect(NamespaceResolver.resolve(feedWith(channel: ch1)).contains(.podcast))

        // funding
        var ch2 = minimalChannel()
        let fundingURL = makeURL("https://example.com")
        ch2.funding = [Funding(url: fundingURL, message: "Support")]
        #expect(NamespaceResolver.resolve(feedWith(channel: ch2)).contains(.podcast))

        // medium
        var ch3 = minimalChannel()
        ch3.medium = .podcast
        #expect(NamespaceResolver.resolve(feedWith(channel: ch3)).contains(.podcast))

        // trailers
        var ch4 = minimalChannel()
        let trailerURL = makeURL("https://example.com/t.mp3")
        ch4.trailers = [Trailer(title: "T", url: trailerURL, pubDate: Date())]
        #expect(NamespaceResolver.resolve(feedWith(channel: ch4)).contains(.podcast))
    }
}
