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

struct ITunesVerifyTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesVerify_true() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesVerify: true
        )
        #expect(channel.itunesVerify == true)
    }

    @Test
    func test_channel_itunesVerify_false() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesVerify: false
        )
        #expect(channel.itunesVerify == false)
    }

    @Test
    func test_channel_itunesVerify_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesVerify == nil)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameVerify() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentVerify() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: false
        )
        #expect(channelA != channelB)
    }

    // MARK: - Hashable

    @Test
    func test_channel_hashable() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: false
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesVerify: true
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
