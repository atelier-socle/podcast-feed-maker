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

// MARK: - TimeToLiveTests

/// Tests for the `ttl` property on ``Channel``.
///
/// In the new model, `Channel.ttl` is an optional `Int?`
/// representing time-to-live in minutes.
@Suite("RSS TimeToLive Property Tests")
struct TimeToLiveTests {

    // MARK: - Initialization

    @Test("Channel ttl defaults to nil")
    func channelTtlDefaultsToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        #expect(channel.ttl == nil)
    }

    @Test("Channel ttl can be set at initialization")
    func channelTtlCanBeSet() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            ttl: 60
        )

        #expect(channel.ttl == 60)
    }

    @Test("Channel ttl is mutable")
    func channelTtlIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        channel.ttl = 30
        #expect(channel.ttl == 30)
    }

    // MARK: - XML Generation

    @Test("Channel XML contains ttl tag when set")
    func channelXmlContainsTtl() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            ttl: 60
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<ttl>60</ttl>"))
    }

    @Test("Channel XML omits ttl tag when nil")
    func channelXmlOmitsTtlWhenNil() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(!xml.contains("<ttl>"))
    }

    @Test("Channel XML renders various ttl values correctly")
    func channelXmlRendersVariousTtlValues() throws {
        let link = makeURL("https://example.com")
        for minutes in [15, 30, 60, 120, 1440] {
            let channel = Channel(
                title: "Title",
                link: link,
                description: "Description",
                ttl: minutes
            )

            let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
            #expect(xml.contains("<ttl>\(minutes)</ttl>"))
        }
    }

    // MARK: - Equatable

    @Test("Channels with same ttl are equal")
    func channelsWithSameTtlAreEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", ttl: 30)
        let channel2 = Channel(title: "T", link: url, description: "D", ttl: 30)
        #expect(channel1 == channel2)
    }

    @Test("Channels with different ttl values are not equal")
    func channelsWithDifferentTtlAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", ttl: 30)
        let channel2 = Channel(title: "T", link: url, description: "D", ttl: 90)
        #expect(channel1 != channel2)
    }

    // MARK: - Hashable

    @Test("Channel ttl contributes to hash value")
    func channelTtlHashable() {
        let url = makeURL("https://example.com")
        let channel = Channel(title: "T", link: url, description: "D", ttl: 15)
        let set: Set = [channel]
        #expect(set.contains(Channel(title: "T", link: url, description: "D", ttl: 15)))
    }
}
