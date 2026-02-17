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

// MARK: - ChannelRSSCoreTests

/// Tests for the ``Channel`` struct — RSS core properties.
///
/// `Channel` is the main feed-level container with ~50 typed properties.
/// Required fields: `title: String`, `link: URL`, `description: String`.
/// All other fields default to `nil` or empty arrays.
/// Conforms to `Sendable`, `Hashable`, and `Equatable`.
@Suite("Channel — RSS Core")
struct ChannelRSSCoreTests {

    // MARK: - Helpers

    /// Creates a minimal channel with only the required fields.
    private func makeMinimalChannel(
        title: String = "My Podcast",
        link: URL? = URL(string: "https://podcast.example.com"),
        description: String = "A podcast about Swift"
    ) throws -> Channel {
        let resolvedLink = try #require(link)
        return Channel(title: title, link: resolvedLink, description: description)
    }

    // MARK: - Required Fields Initialization

    @Test("Channel can be initialized with only required fields")
    func channelInitWithRequiredFields() throws {
        let channel = try makeMinimalChannel()

        #expect(channel.title == "My Podcast")
        let expectedLink = makeURL("https://podcast.example.com")
        #expect(channel.link == expectedLink)
        #expect(channel.description == "A podcast about Swift")
    }

    @Test("Channel optional RSS fields default to nil")
    func channelOptionalRssFieldsDefaultToNil() throws {
        let channel = try makeMinimalChannel()

        #expect(channel.language == nil)
        #expect(channel.copyright == nil)
        #expect(channel.managingEditor == nil)
        #expect(channel.webMaster == nil)
        #expect(channel.pubDate == nil)
        #expect(channel.lastBuildDate == nil)
        #expect(channel.generator == nil)
        #expect(channel.docs == nil)
        #expect(channel.cloud == nil)
        #expect(channel.ttl == nil)
        #expect(channel.image == nil)
        #expect(channel.textInput == nil)
        #expect(channel.skipSchedule == nil)
    }

    @Test("Channel array properties default to empty")
    func channelArrayPropertiesDefaultToEmpty() throws {
        let channel = try makeMinimalChannel()

        #expect(channel.categories.isEmpty)
        #expect(channel.items.isEmpty)
        #expect(channel.itunesCategories.isEmpty)
        #expect(channel.itunesKeywords.isEmpty)
        #expect(channel.atomLinks.isEmpty)
        #expect(channel.funding.isEmpty)
        #expect(channel.persons.isEmpty)
        #expect(channel.podcastBlocks.isEmpty)
        #expect(channel.txtRecords.isEmpty)
        #expect(channel.trailers.isEmpty)
        #expect(channel.liveItems.isEmpty)
    }

    // MARK: - Initialization with Optional Fields

    @Test("Channel can be initialized with optional RSS fields")
    func channelInitWithOptionalFields() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            language: "en-us",
            copyright: "2025",
            managingEditor: "editor@example.com",
            pubDate: date,
            lastBuildDate: date,
            generator: "PodcastFeedMaker",
            ttl: 60
        )

        #expect(channel.language == "en-us")
        #expect(channel.copyright == "2025")
        #expect(channel.managingEditor == "editor@example.com")
        #expect(channel.pubDate == date)
        #expect(channel.lastBuildDate == date)
        #expect(channel.generator == "PodcastFeedMaker")
        #expect(channel.ttl == 60)
    }

    @Test("Channel can be initialized with items")
    func channelInitWithItems() {
        let item1 = Item(title: "Episode 1")
        let item2 = Item(title: "Episode 2")
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            items: [item1, item2]
        )

        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == "Episode 1")
        #expect(channel.items[1].title == "Episode 2")
    }

    // MARK: - Mutability

    @Test("Channel properties are mutable")
    func channelPropertiesAreMutable() throws {
        var channel = try makeMinimalChannel()

        channel.title = "New Title"
        channel.language = "fr"
        channel.ttl = 120
        channel.itunesExplicit = true
        channel.itunesType = .serial
        channel.items = [Item(title: "Ep1")]
        channel.podcastGuid = PodcastGuid(value: "new-guid")
        channel.locked = Locked(isLocked: false)

        #expect(channel.title == "New Title")
        #expect(channel.language == "fr")
        #expect(channel.ttl == 120)
        #expect(channel.itunesExplicit == true)
        #expect(channel.itunesType == .serial)
        #expect(channel.items.count == 1)
        #expect(channel.podcastGuid?.value == "new-guid")
        #expect(channel.locked?.isLocked == false)
    }

    // MARK: - XML Generation

    @Test("Channel XML contains required RSS tags")
    func channelXmlContainsRequiredTags() throws {
        let channel = try makeMinimalChannel()
        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))

        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>My Podcast</title>"))
        #expect(xml.contains("<link>https://podcast.example.com</link>"))
        #expect(xml.contains("<description>A podcast about Swift</description>"))
        #expect(xml.contains("</channel>"))
    }

    @Test("Channel XML contains optional RSS tags when set")
    func channelXmlContainsOptionalTags() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            language: "en-us",
            copyright: "2025 Example",
            generator: "PodcastFeedMaker",
            ttl: 60
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<language>en-us</language>"))
        #expect(xml.contains("<copyright>2025 Example</copyright>"))
        #expect(xml.contains("<generator>PodcastFeedMaker</generator>"))
        #expect(xml.contains("<ttl>60</ttl>"))
    }

    @Test("Channel XML includes item elements")
    func channelXmlIncludesItems() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            items: [
                Item(title: "Episode 1"),
                Item(title: "Episode 2")
            ]
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<item>"))
        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<title>Episode 2</title>"))
        #expect(xml.contains("</item>"))
    }

    @Test("Channel XML omits optional tags when nil")
    func channelXmlOmitsNilOptionalTags() throws {
        let channel = try makeMinimalChannel()
        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))

        #expect(!xml.contains("<language>"))
        #expect(!xml.contains("<copyright>"))
        #expect(!xml.contains("<managingEditor>"))
        #expect(!xml.contains("<generator>"))
        #expect(!xml.contains("<ttl>"))
        #expect(!xml.contains("<itunes:author>"))
        #expect(!xml.contains("<itunes:block>"))
        #expect(!xml.contains("<itunes:complete>"))
        #expect(!xml.contains("<itunes:explicit>"))
        #expect(!xml.contains("<itunes:image"))
        #expect(!xml.contains("<itunes:keywords>"))
        #expect(!xml.contains("<itunes:type>"))
        #expect(!xml.contains("<podcast:guid>"))
        #expect(!xml.contains("<podcast:locked>"))
        #expect(!xml.contains("<podcast:funding"))
        #expect(!xml.contains("<item>"))
    }

    // MARK: - Sendable

    @Test("Channel is Sendable")
    func channelIsSendable() async throws {
        let channel = try makeMinimalChannel()
        let result = await Task { channel.title }.value
        #expect(result == "My Podcast")
    }

    // MARK: - Equatable

    @Test("Channels with identical properties are equal")
    func channelsWithIdenticalPropertiesAreEqual() throws {
        let channel1 = try makeMinimalChannel()
        let channel2 = try makeMinimalChannel()
        #expect(channel1 == channel2)
    }

    @Test("Channels with different required fields are not equal")
    func channelsWithDifferentRequiredFieldsAreNotEqual() throws {
        let channel1 = try makeMinimalChannel(title: "A")
        let channel2 = try makeMinimalChannel(title: "B")
        #expect(channel1 != channel2)
    }

    @Test("Channels with different optional fields are not equal")
    func channelsWithDifferentOptionalFieldsAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", language: "en")
        let channel2 = Channel(title: "T", link: url, description: "D", language: "fr")
        #expect(channel1 != channel2)
    }

    // MARK: - Hashable

    @Test("Channel is Hashable and can be stored in a Set")
    func channelHashable() throws {
        let channel1 = try makeMinimalChannel(title: "A")
        let channel2 = try makeMinimalChannel(title: "B")
        let set: Set = [channel1, channel2]
        #expect(set.count == 2)
        #expect(set.contains(channel1))
        #expect(set.contains(channel2))
    }

    @Test("Duplicate channels collapse in a Set")
    func duplicateChannelsCollapseInSet() throws {
        let channel1 = try makeMinimalChannel()
        let channel2 = try makeMinimalChannel()
        let set: Set = [channel1, channel2]
        #expect(set.count == 1)
    }
}
