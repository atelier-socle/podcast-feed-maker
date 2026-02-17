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

struct ITunesKeywordsTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesKeywords_shouldStoreValues() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesKeywords: ["News", "Technology", "Innovation"]
        )
        #expect(channel.itunesKeywords == ["News", "Technology", "Innovation"])
    }

    @Test
    func test_channel_itunesKeywords_defaultsToEmpty() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesKeywords.isEmpty)
    }

    @Test
    func test_channel_itunesKeywords_withEmptyArray() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesKeywords: []
        )
        #expect(channel.itunesKeywords.isEmpty)
    }

    @Test
    func test_channel_itunesKeywords_withSingleKeyword() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesKeywords: ["Swift"]
        )
        #expect(channel.itunesKeywords.count == 1)
        #expect(channel.itunesKeywords.first == "Swift")
    }

    // MARK: - Item

    @Test
    func test_item_itunesKeywords_shouldStoreValues() {
        let item = Item(itunesKeywords: ["Music", "Sound", "Audio"])
        #expect(item.itunesKeywords == ["Music", "Sound", "Audio"])
    }

    @Test
    func test_item_itunesKeywords_defaultsToEmpty() {
        let item = Item()
        #expect(item.itunesKeywords.isEmpty)
    }

    @Test
    func test_item_itunesKeywords_withSingleKeyword() {
        let item = Item(itunesKeywords: ["Podcast"])
        #expect(item.itunesKeywords.count == 1)
        #expect(item.itunesKeywords.first == "Podcast")
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameKeywords() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesKeywords: ["a", "b", "c"]
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesKeywords: ["a", "b", "c"]
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentKeywords() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesKeywords: ["a", "b"]
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesKeywords: ["x", "y"]
        )
        #expect(channelA != channelB)
    }

    @Test
    func test_item_equatable_sameKeywords() {
        let itemA = Item(itunesKeywords: ["a", "b"])
        let itemB = Item(itunesKeywords: ["a", "b"])
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentKeywords() {
        let itemA = Item(itunesKeywords: ["a", "b"])
        let itemB = Item(itunesKeywords: ["x", "y"])
        #expect(itemA != itemB)
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
