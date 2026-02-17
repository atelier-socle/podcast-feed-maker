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

struct ITunesSummaryTests {

    // MARK: - Channel

    @Test
    func test_channel_itunesSummary_shouldStoreValue() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesSummary: "Swift & SwiftUI explained in detail"
        )
        #expect(channel.itunesSummary == "Swift & SwiftUI explained in detail")
    }

    @Test
    func test_channel_itunesSummary_defaultsToNil() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast"
        )
        #expect(channel.itunesSummary == nil)
    }

    @Test
    func test_channel_itunesSummary_withEmptyString() {
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesSummary: ""
        )
        #expect(channel.itunesSummary == "")
    }

    @Test
    func test_channel_itunesSummary_withHTMLContent() {
        let htmlContent = "<p><strong>SwiftUI</strong> explained</p>"
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesSummary: htmlContent
        )
        #expect(channel.itunesSummary == htmlContent)
    }

    @Test
    func test_channel_itunesSummary_withLongText() {
        let longText = String(repeating: "A long summary. ", count: 100)
        let channel = Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast",
            itunesSummary: longText
        )
        #expect(channel.itunesSummary == longText)
    }

    // MARK: - Equatable

    @Test
    func test_channel_equatable_sameSummary() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSummary: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSummary: "A"
        )
        #expect(channelA == channelB)
    }

    @Test
    func test_channel_equatable_differentSummary() {
        let link = makeURL("https://example.com")
        let channelA = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSummary: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSummary: "B"
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
            itunesSummary: "A"
        )
        let channelB = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSummary: "A"
        )
        let channelC = Channel(
            title: "Podcast",
            link: link,
            description: "Desc",
            itunesSummary: "B"
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
