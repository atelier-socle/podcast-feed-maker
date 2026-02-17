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

struct ITunesNewFeedUrlTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesNewFeedUrl_shouldStoreURL() {
        let url = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesNewFeedUrl: url
        )
        #expect(channel.itunesNewFeedUrl == url)
    }

    @Test
    func test_channel_itunesNewFeedUrl_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesNewFeedUrl == nil)
    }

    @Test
    func test_channel_itunesNewFeedUrl_absoluteString() {
        let url = makeURL("https://newhost.example.com/podcast/feed.xml")
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesNewFeedUrl: url
        )
        #expect(channel.itunesNewFeedUrl?.absoluteString == "https://newhost.example.com/podcast/feed.xml")
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameNewFeedUrl() {
        let url = makeURL("https://example.com/feed.xml")
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: url
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: url
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentNewFeedUrl() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: makeURL("https://a.com/feed.xml")
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: makeURL("https://b.com/feed.xml")
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() {
        let urlA = makeURL("https://a.com/feed.xml")
        let urlB = makeURL("https://b.com/feed.xml")
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: urlA
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: urlA
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesNewFeedUrl: urlB
        )
        let set: Set = [channelA, channelB, channelC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Channel.self)
    }
}
