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

// MARK: - ChannelNamespaceTests

/// Tests for the ``Channel`` struct — iTunes, Podcast NS 2.0, and Atom extensions.
@Suite("Channel — Namespace Extensions")
struct ChannelNamespaceTests {

    // MARK: - iTunes Properties

    @Test("Channel iTunes properties default to nil")
    func channelItunesPropertiesDefaultToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(title: "T", link: link, description: "D")

        #expect(channel.itunesAuthor == nil)
        #expect(channel.itunesBlock == nil)
        #expect(channel.itunesComplete == nil)
        #expect(channel.itunesExplicit == nil)
        #expect(channel.itunesImage == nil)
        #expect(channel.itunesNewFeedUrl == nil)
        #expect(channel.itunesOwner == nil)
        #expect(channel.itunesSubtitle == nil)
        #expect(channel.itunesSummary == nil)
        #expect(channel.itunesTitle == nil)
        #expect(channel.itunesType == nil)
        #expect(channel.itunesVerify == nil)
    }

    @Test("Channel can be initialized with iTunes fields")
    func channelInitWithItunesFields() {
        let link = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/image.png")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            itunesAuthor: "John Doe",
            itunesBlock: true,
            itunesCategories: [.technology],
            itunesComplete: false,
            itunesExplicit: false,
            itunesImage: imageURL,
            itunesKeywords: ["swift", "podcast"],
            itunesOwner: ITunesOwner(name: "John", email: "john@example.com"),
            itunesSubtitle: "A subtitle",
            itunesSummary: "A summary",
            itunesTitle: "Show Title Override",
            itunesType: .episodic
        )

        #expect(channel.itunesAuthor == "John Doe")
        #expect(channel.itunesBlock == true)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesComplete == false)
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage == imageURL)
        #expect(channel.itunesKeywords == ["swift", "podcast"])
        #expect(channel.itunesOwner?.name == "John")
        #expect(channel.itunesOwner?.email == "john@example.com")
        #expect(channel.itunesSubtitle == "A subtitle")
        #expect(channel.itunesSummary == "A summary")
        #expect(channel.itunesTitle == "Show Title Override")
        #expect(channel.itunesType == .episodic)
    }

    @Test("Channel can be initialized with serial iTunes type")
    func channelInitWithSerialType() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            itunesType: .serial
        )

        #expect(channel.itunesType == .serial)
    }

    @Test("ITunesShowType has all expected cases")
    func itunesShowTypeCases() {
        #expect(ITunesShowType.episodic.rawValue == "episodic")
        #expect(ITunesShowType.serial.rawValue == "serial")
        #expect(ITunesShowType.allCases.count == 2)
    }

    // MARK: - iTunes XML Generation

    @Test("Channel XML contains iTunes tags when set")
    func channelXmlContainsItunesTags() throws {
        let link = makeURL("https://example.com")
        let artURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            itunesAuthor: "John Doe",
            itunesBlock: true,
            itunesComplete: true,
            itunesExplicit: true,
            itunesImage: artURL,
            itunesKeywords: ["swift", "development"],
            itunesSubtitle: "A short subtitle",
            itunesSummary: "A longer summary",
            itunesTitle: "Title Override",
            itunesType: .serial
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<itunes:author>John Doe</itunes:author>"))
        #expect(xml.contains("<itunes:block>yes</itunes:block>"))
        #expect(xml.contains("<itunes:complete>yes</itunes:complete>"))
        #expect(xml.contains("<itunes:explicit>true</itunes:explicit>"))
        #expect(xml.contains(#"<itunes:image href="https://example.com/art.jpg" />"#))
        #expect(xml.contains("<itunes:keywords>swift,development</itunes:keywords>"))
        #expect(xml.contains("<itunes:subtitle>A short subtitle</itunes:subtitle>"))
        #expect(xml.contains("<itunes:summary>A longer summary</itunes:summary>"))
        #expect(xml.contains("<itunes:title>Title Override</itunes:title>"))
        #expect(xml.contains("<itunes:type>serial</itunes:type>"))
    }

    @Test("Channel XML contains itunes:explicit no when explicit is false")
    func channelXmlContainsItunesExplicitNo() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            itunesExplicit: false
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<itunes:explicit>false</itunes:explicit>"))
    }

    @Test("Channel XML contains iTunes owner when set")
    func channelXmlContainsItunesOwner() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            itunesOwner: ITunesOwner(name: "Jane Doe", email: "jane@example.com")
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<itunes:owner>"))
        #expect(xml.contains("<itunes:name>Jane Doe</itunes:name>"))
        #expect(xml.contains("<itunes:email>jane@example.com</itunes:email>"))
        #expect(xml.contains("</itunes:owner>"))
    }

    // MARK: - Podcast NS 2.0

    @Test("Channel Podcast NS properties default to nil")
    func channelPodcastNsPropertiesDefaultToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(title: "T", link: link, description: "D")

        #expect(channel.podcastGuid == nil)
        #expect(channel.locked == nil)
        #expect(channel.location == nil)
        #expect(channel.license == nil)
        #expect(channel.value == nil)
        #expect(channel.medium == nil)
        #expect(channel.podroll == nil)
        #expect(channel.updateFrequency == nil)
        #expect(channel.podpingEnabled == nil)
        #expect(channel.publisher == nil)
        #expect(channel.chat == nil)
    }

    @Test("Channel can be initialized with Podcast NS 2.0 properties")
    func channelInitWithPodcastNsProperties() {
        let link = makeURL("https://example.com")
        let donateURL = makeURL("https://example.com/donate")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "owner@example.com"),
            funding: [Funding(url: donateURL, message: "Support us")]
        )

        #expect(channel.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "owner@example.com")
        #expect(channel.funding.count == 1)
        #expect(channel.funding[0].message == "Support us")
    }

    @Test("Channel XML contains Podcast NS tags when set")
    func channelXmlContainsPodcastNsTags() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            podcastGuid: PodcastGuid(value: "channel-guid-value"),
            locked: Locked(isLocked: false)
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<podcast:guid>channel-guid-value</podcast:guid>"))
        #expect(xml.contains("<podcast:locked>no</podcast:locked>"))
    }

    @Test("Channel XML contains podcast:locked with owner attribute when set")
    func channelXmlContainsLockedWithOwner() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            locked: Locked(isLocked: true, owner: "john@example.com")
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains(#"<podcast:locked owner="john@example.com">yes</podcast:locked>"#))
    }

    @Test("Channel XML contains funding when set")
    func channelXmlContainsFunding() throws {
        let link = makeURL("https://example.com")
        let donateURL = makeURL("https://example.com/donate")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            funding: [
                Funding(url: donateURL, message: "Support us")
            ]
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains(#"<podcast:funding url="https://example.com/donate">Support us</podcast:funding>"#))
    }

    // MARK: - Atom

    @Test("Channel Dublin Core and Atom properties default to nil or empty")
    func channelDublinCoreAndAtomDefaults() {
        let link = makeURL("https://example.com")
        let channel = Channel(title: "T", link: link, description: "D")

        #expect(channel.dublinCore == nil)
        #expect(channel.atomLinks.isEmpty)
    }

    @Test("Channel can be initialized with Atom links")
    func channelInitWithAtomLinks() {
        let link = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let selfLink = AtomLink.selfLink(href: feedURL)
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            atomLinks: [selfLink]
        )

        #expect(channel.atomLinks.count == 1)
        #expect(channel.atomLinks[0].rel == "self")
        #expect(channel.atomLinks[0].type == "application/rss+xml")
    }

    @Test("Channel XML contains Atom link when set")
    func channelXmlContainsAtomLink() throws {
        let link = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            atomLinks: [
                AtomLink.selfLink(href: feedURL)
            ]
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains(#"<atom:link href="https://example.com/feed.xml""#))
        #expect(xml.contains(#"rel="self""#))
    }

    // MARK: - Sendable (Complex)

    @Test("Channel with complex properties is Sendable")
    func channelWithComplexPropertiesIsSendable() async {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            itunesType: .serial,
            podcastGuid: PodcastGuid(value: "guid"),
            locked: Locked(isLocked: true)
        )
        let result = await Task { channel.podcastGuid?.value }.value
        #expect(result == "guid")
    }

    // MARK: - Equatable (Namespace-specific)

    @Test("Channels with different iTunes types are not equal")
    func channelsWithDifferentItunesTypesAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", itunesType: .episodic)
        let channel2 = Channel(title: "T", link: url, description: "D", itunesType: .serial)
        #expect(channel1 != channel2)
    }

    @Test("Channels with different Podcast NS properties are not equal")
    func channelsWithDifferentPodcastNsPropertiesAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(
            title: "T", link: url, description: "D",
            podcastGuid: PodcastGuid(value: "guid-1")
        )
        let channel2 = Channel(
            title: "T", link: url, description: "D",
            podcastGuid: PodcastGuid(value: "guid-2")
        )
        #expect(channel1 != channel2)
    }

    // MARK: - Hashable (Namespace-specific)

    @Test("Channels with different Podcast NS fields produce different hashes")
    func channelHashDiffersWithPodcastNs() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(
            title: "T", link: url, description: "D",
            locked: Locked(isLocked: true)
        )
        let channel2 = Channel(
            title: "T", link: url, description: "D",
            locked: Locked(isLocked: false)
        )
        let set: Set = [channel1, channel2]
        #expect(set.count == 2)
    }
}
