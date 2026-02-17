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

// MARK: - LastBuildDateTests

/// Tests for the `lastBuildDate` property on ``Channel``.
///
/// In the new model, `Channel.lastBuildDate` is an optional `Date?`.
/// The date is formatted to RFC 822 in XML output.
@Suite("RSS LastBuildDate Property Tests")
struct LastBuildDateTests {

    // MARK: - Initialization

    @Test("Channel lastBuildDate defaults to nil")
    func channelLastBuildDateDefaultsToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        #expect(channel.lastBuildDate == nil)
    }

    @Test("Channel lastBuildDate can be set at initialization")
    func channelLastBuildDateCanBeSet() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            lastBuildDate: date
        )

        #expect(channel.lastBuildDate == date)
    }

    @Test("Channel lastBuildDate is mutable")
    func channelLastBuildDateIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let date = Date(timeIntervalSince1970: 500_000)
        channel.lastBuildDate = date
        #expect(channel.lastBuildDate == date)
    }

    // MARK: - XML Generation

    @Test("Channel XML contains lastBuildDate tag with RFC 822 format")
    func channelXmlContainsLastBuildDateFormatted() throws {
        let components = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2024, month: 3, day: 26,
            hour: 20, minute: 30, second: 0
        )
        let date = try #require(components.date)

        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            lastBuildDate: date
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<lastBuildDate>Tue, 26 Mar 2024 20:30:00 +0000</lastBuildDate>"))
    }

    @Test("Channel XML omits lastBuildDate tag when nil")
    func channelXmlOmitsLastBuildDateWhenNil() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(!xml.contains("<lastBuildDate>"))
    }

    // MARK: - Equatable

    @Test("Channels with same lastBuildDate are equal")
    func channelsWithSameLastBuildDateAreEqual() {
        let url = makeURL("https://example.com")
        let date = Date(timeIntervalSince1970: 100)
        let channel1 = Channel(title: "T", link: url, description: "D", lastBuildDate: date)
        let channel2 = Channel(title: "T", link: url, description: "D", lastBuildDate: date)
        #expect(channel1 == channel2)
    }

    @Test("Channels with different lastBuildDates are not equal")
    func channelsWithDifferentLastBuildDatesAreNotEqual() {
        let url = makeURL("https://example.com")
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)
        let channel1 = Channel(title: "T", link: url, description: "D", lastBuildDate: date1)
        let channel2 = Channel(title: "T", link: url, description: "D", lastBuildDate: date2)
        #expect(channel1 != channel2)
    }
}
