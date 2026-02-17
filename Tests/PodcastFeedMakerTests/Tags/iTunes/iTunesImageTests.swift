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

struct ITunesImageTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesImage_shouldStoreURL() {
        let url = makeURL("https://example.com/podcast.jpg")
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesImage: url
        )
        #expect(channel.itunesImage == url)
    }

    @Test
    func test_channel_itunesImage_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesImage == nil)
    }

    @Test
    func test_channel_itunesImage_withHTTPSUrl() {
        let url = makeURL("https://cdn.example.com/artwork-3000x3000.png")
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesImage: url
        )
        #expect(channel.itunesImage?.absoluteString == "https://cdn.example.com/artwork-3000x3000.png")
    }

    // MARK: - Item

    @Test
    func test_item_itunesImage_shouldStoreURL() {
        let url = makeURL("https://example.com/episode.jpg")
        let item = Item(itunesImage: url)
        #expect(item.itunesImage == url)
    }

    @Test
    func test_item_itunesImage_defaultsToNil() {
        let item = Item()
        #expect(item.itunesImage == nil)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameImage() {
        let url = makeURL("https://example.com/1.jpg")
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesImage: url
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesImage: url
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentImage() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesImage: makeURL("https://example.com/1.jpg")
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesImage: makeURL("https://example.com/2.jpg")
        )
        #expect(channelA != channelB)
    }

    @Test
    func test_item_equatable_sameImage() {
        let url = makeURL("https://example.com/ep.jpg")
        let itemA = Item(itunesImage: url)
        let itemB = Item(itunesImage: url)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentImage() {
        let itemA = Item(itunesImage: makeURL("https://example.com/1.jpg"))
        let itemB = Item(itunesImage: makeURL("https://example.com/2.jpg"))
        #expect(itemA != itemB)
    }

    // MARK: - Hashable

    @Test
    func test_item_hashable() {
        let url1 = makeURL("https://example.com/1.jpg")
        let url2 = makeURL("https://example.com/2.jpg")
        let itemA = Item(itunesImage: url1)
        let itemB = Item(itunesImage: url1)
        let itemC = Item(itunesImage: url2)
        let set: Set = [itemA, itemB, itemC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable

    @Test
    func test_channelSendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Channel.self)
    }

    @Test
    func test_itemSendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Item.self)
    }
}
