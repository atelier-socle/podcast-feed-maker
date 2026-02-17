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

// MARK: - PubDateTests

/// Tests for the `pubDate` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.pubDate` and `Item.pubDate` are both
/// optional `Date?` properties. Dates are formatted to RFC 822 in XML.
@Suite("RSS PubDate Property Tests")
struct PubDateTests {

    // MARK: - Channel PubDate

    @Test("Channel pubDate defaults to nil")
    func channelPubDateDefaultsToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        #expect(channel.pubDate == nil)
    }

    @Test("Channel pubDate can be set at initialization")
    func channelPubDateCanBeSet() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            pubDate: date
        )

        #expect(channel.pubDate == date)
    }

    @Test("Channel pubDate is mutable")
    func channelPubDateIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let date = Date(timeIntervalSince1970: 500_000)
        channel.pubDate = date
        #expect(channel.pubDate == date)
    }

    @Test("Channel XML contains pubDate tag with RFC 822 format")
    func channelXmlContainsPubDateFormatted() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try #require(formatter.date(from: "2025-03-24 18:30:00"))

        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            pubDate: date
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<pubDate>"))
        #expect(xml.contains("Mon, 24 Mar 2025 18:30:00"))
        #expect(xml.contains("</pubDate>"))
    }

    @Test("Channel XML omits pubDate tag when nil")
    func channelXmlOmitsPubDateWhenNil() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(!xml.contains("<pubDate>"))
    }

    // MARK: - Item PubDate

    @Test("Item pubDate defaults to nil")
    func itemPubDateDefaultsToNil() {
        let item = Item()
        #expect(item.pubDate == nil)
    }

    @Test("Item pubDate can be set at initialization")
    func itemPubDateCanBeSet() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let item = Item(pubDate: date)
        #expect(item.pubDate == date)
    }

    @Test("Item XML contains pubDate tag when set")
    func itemXmlContainsPubDateWhenSet() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try #require(formatter.date(from: "2025-03-24 18:30:00"))

        let item = Item(pubDate: date)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<pubDate>"))
        #expect(xml.contains("Mon, 24 Mar 2025 18:30:00"))
    }

    @Test("Item XML omits pubDate tag when nil")
    func itemXmlOmitsPubDateWhenNil() {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(!xml.contains("<pubDate>"))
    }

    // MARK: - Equatable

    @Test("Channels with same pubDate are equal")
    func channelsWithSamePubDateAreEqual() {
        let url = makeURL("https://example.com")
        let date = Date(timeIntervalSince1970: 100)
        let channel1 = Channel(title: "T", link: url, description: "D", pubDate: date)
        let channel2 = Channel(title: "T", link: url, description: "D", pubDate: date)
        #expect(channel1 == channel2)
    }

    @Test("Channels with different pubDates are not equal")
    func channelsWithDifferentPubDatesAreNotEqual() {
        let url = makeURL("https://example.com")
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)
        let channel1 = Channel(title: "T", link: url, description: "D", pubDate: date1)
        let channel2 = Channel(title: "T", link: url, description: "D", pubDate: date2)
        #expect(channel1 != channel2)
    }

    // MARK: - Hashable

    @Test("Channel pubDate contributes to hash value")
    func channelPubDateHashable() {
        let url = makeURL("https://example.com")
        let date = Date(timeIntervalSince1970: 100)
        let channel = Channel(title: "T", link: url, description: "D", pubDate: date)
        let set: Set = [channel]
        #expect(set.contains(channel))
    }
}
