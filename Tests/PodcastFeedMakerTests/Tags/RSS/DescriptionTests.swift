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

// MARK: - DescriptionTests

/// Tests for the `description` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.description` is a required `String` and
/// `Item.description` is an optional `String?`. The old `DescriptionType`
/// enum has been removed.
@Suite("RSS Description Property Tests")
struct DescriptionTests {

    // MARK: - Channel Description

    @Test("Channel requires a description at initialization")
    func channelDescriptionIsRequired() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "A great podcast about Swift"
        )

        #expect(channel.description == "A great podcast about Swift")
    }

    @Test("Channel description is mutable")
    func channelDescriptionIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Title",
            link: link,
            description: "Original"
        )

        channel.description = "Updated description"
        #expect(channel.description == "Updated description")
    }

    @Test("Channel XML contains description tag")
    func channelXmlContainsDescription() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "This is my show"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<description>This is my show</description>"))
    }

    @Test("Channel XML wraps HTML-containing description in CDATA")
    func channelXmlWrapsHtmlDescriptionInCDATA() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "This is a <b>great</b> & useful podcast"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<![CDATA[This is a <b>great</b> & useful podcast]]>"))
    }

    // MARK: - Item Description

    @Test("Item description defaults to nil")
    func itemDescriptionDefaultsToNil() {
        let item = Item()
        #expect(item.description == nil)
    }

    @Test("Item description can be set at initialization")
    func itemDescriptionCanBeSet() {
        let item = Item(description: "Episode summary")
        #expect(item.description == "Episode summary")
    }

    @Test("Item description is mutable")
    func itemDescriptionIsMutable() {
        var item = Item(description: "Old summary")
        item.description = "New summary"
        #expect(item.description == "New summary")
    }

    @Test("Item XML contains description tag when set")
    func itemXmlContainsDescriptionWhenSet() {
        let item = Item(description: "Episode summary text")
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<description>Episode summary text</description>"))
    }

    @Test("Item XML omits description tag when nil")
    func itemXmlOmitsDescriptionWhenNil() {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(!xml.contains("<description>"))
    }

    @Test("Item XML wraps HTML-containing description in CDATA")
    func itemXmlWrapsHtmlDescriptionInCDATA() {
        let item = Item(description: "Swift & Objective-C <comparison>")
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<![CDATA[Swift & Objective-C <comparison>]]>"))
    }

    // MARK: - Equatable

    @Test("Channels with same description are equal")
    func channelsWithSameDescriptionAreEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "Same")
        let channel2 = Channel(title: "T", link: url, description: "Same")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different descriptions are not equal")
    func channelsWithDifferentDescriptionsAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "A")
        let channel2 = Channel(title: "T", link: url, description: "B")
        #expect(channel1 != channel2)
    }

    @Test("Items with same description are equal")
    func itemsWithSameDescriptionAreEqual() {
        let item1 = Item(description: "Summary")
        let item2 = Item(description: "Summary")
        #expect(item1 == item2)
    }

    @Test("Items with different descriptions are not equal")
    func itemsWithDifferentDescriptionsAreNotEqual() {
        let item1 = Item(description: "A")
        let item2 = Item(description: "B")
        #expect(item1 != item2)
    }
}
