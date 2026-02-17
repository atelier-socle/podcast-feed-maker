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

// MARK: - NetworkValidator Tests

@Suite("NetworkValidator Tests")
struct NetworkValidatorTests {

    private let validator = NetworkValidator()

    // MARK: - Helpers

    private func feedWithArtwork(
        channelImage: URL? = nil,
        itemImages: [URL] = []
    ) throws -> PodcastFeed {
        let items = itemImages.enumerated().map { idx, url in
            Item(title: "Episode \(idx)", itunesImage: url)
        }
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: makeURL("https://example.com"),
                description: "Desc",
                items: items,
                itunesImage: channelImage
            ))
    }

    private func feedWithEnclosures(_ enclosures: [(URL, String)]) -> PodcastFeed {
        let items = enclosures.enumerated().map { idx, pair in
            Item(
                title: "Episode \(idx)",
                enclosure: Enclosure(
                    url: pair.0,
                    length: 1024,
                    type: pair.1
                )
            )
        }
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: makeURL("https://example.com"),
                description: "Desc",
                items: items
            ))
    }

    // MARK: - URL Extraction: Artwork

    @Test("Extracts channel artwork URL")
    func extractChannelArtwork() throws {
        let url = makeURL("https://example.com/art.jpg")
        let feed = try feedWithArtwork(channelImage: url)
        let entries = validator.extractArtworkURLs(from: feed)
        #expect(entries.count == 1)
        #expect(entries[0].url == url)
        #expect(entries[0].field == "channel.itunesImage")
    }

    @Test("Extracts item artwork URLs")
    func extractItemArtwork() throws {
        let url1 = makeURL("https://example.com/ep1.jpg")
        let url2 = makeURL("https://example.com/ep2.jpg")
        let feed = try feedWithArtwork(itemImages: [url1, url2])
        let entries = validator.extractArtworkURLs(from: feed)
        #expect(entries.count == 2)
        #expect(entries[0].field == "channel.items[0].itunesImage")
        #expect(entries[1].field == "channel.items[1].itunesImage")
    }

    // MARK: - URL Extraction: Enclosures

    @Test("Extracts enclosure URLs with expected types")
    func extractEnclosures() {
        let url = makeURL("https://example.com/ep.mp3")
        let feed = feedWithEnclosures([(url, "audio/mpeg")])
        let entries = validator.extractEnclosureEntries(from: feed)
        #expect(entries.count == 1)
        #expect(entries[0].url == url)
        #expect(entries[0].expectedType == "audio/mpeg")
        #expect(entries[0].field == "channel.items[0].enclosure.url")
    }

    // MARK: - URL Extraction: All URLs

    @Test("extractAllURLEntries includes artwork, enclosures, atom links, and funding")
    func extractAllURLs() {
        let linkURL = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let itemImageURL = makeURL("https://example.com/ep.jpg")
        let atomLinkURL = makeURL("https://example.com/feed.xml")
        let fundingURL = makeURL("https://example.com/fund")
        let channel = Channel(
            title: "Podcast",
            link: linkURL,
            description: "Desc",
            items: [
                Item(
                    title: "Episode",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1024,
                        type: "audio/mpeg"
                    ),
                    itunesImage: itemImageURL
                )
            ],
            itunesImage: URL(string: "https://example.com/art.jpg"),
            atomLinks: [
                AtomLink(
                    href: atomLinkURL,
                    rel: "self"
                )
            ],
            funding: [
                Funding(
                    url: fundingURL,
                    message: "Support"
                )
            ]
        )
        let feed = PodcastFeed(channel: channel)
        let entries = validator.extractAllURLEntries(from: feed)

        // 1 channel image + 1 item image + 1 enclosure + 1 atom link + 1 funding = 5
        #expect(entries.count == 5)
    }

    // MARK: - Empty Feed

    @Test("Empty feed returns no entries")
    func emptyFeed() {
        let feed = PodcastFeed(channel: nil)
        let entries = validator.extractAllURLEntries(from: feed)
        #expect(entries.isEmpty)
    }

    // MARK: - Init Defaults

    @Test("Default init uses reasonable defaults")
    func defaultInit() {
        let nv = NetworkValidator()
        // Just verifying it constructs without error
        let feed = PodcastFeed(channel: nil)
        let entries = nv.extractArtworkURLs(from: feed)
        #expect(entries.isEmpty)
    }
}
