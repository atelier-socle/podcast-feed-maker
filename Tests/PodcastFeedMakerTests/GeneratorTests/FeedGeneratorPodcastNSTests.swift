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

// MARK: - Helpers

private func minimalChannel() -> Channel {
    Channel(
        title: "Test Podcast",
        link: makeURL("https://example.com"),
        description: "A test podcast"
    )
}

private func minimalFeed(channel: Channel? = nil) -> PodcastFeed {
    PodcastFeed(channel: channel ?? minimalChannel())
}

// MARK: - Podcast NS 2.0 Channel Tests

struct FeedGeneratorPodcastChannelTests {

    @Test("Podcast GUID")
    func podcastGuid() throws {
        var ch = minimalChannel()
        ch.podcastGuid = PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>"))
    }

    @Test("Podcast locked")
    func podcastLocked() throws {
        var ch = minimalChannel()
        ch.locked = Locked(isLocked: true, owner: "owner@example.com")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:locked owner="owner@example.com">yes</podcast:locked>"#))
    }

    @Test("Podcast medium")
    func podcastMedium() throws {
        var ch = minimalChannel()
        ch.medium = .podcast
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:medium>podcast</podcast:medium>"))
    }

    @Test("Podcast funding")
    func podcastFunding() throws {
        var ch = minimalChannel()
        let donateURL = makeURL("https://example.com/donate")
        ch.funding = [Funding(url: donateURL, message: "Support Us")]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:funding url="https://example.com/donate">Support Us</podcast:funding>"#))
    }

    @Test("Podcast person")
    func podcastPerson() throws {
        var ch = minimalChannel()
        let personHref = makeURL("https://example.com/jane")
        let personImg = makeURL("https://example.com/jane.jpg")
        ch.persons = [
            PodcastPerson(
                name: "Jane Host",
                role: "host",
                group: "cast",
                href: personHref,
                img: personImg
            )
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:person role="host" group="cast""#))
        #expect(xml.contains(#"img="https://example.com/jane.jpg""#))
        #expect(xml.contains(">Jane Host</podcast:person>"))
    }

    @Test("Podcast location")
    func podcastLocation() throws {
        var ch = minimalChannel()
        ch.location = PodcastLocation(name: "Austin, TX", geo: "geo:30.2672,-97.7431", osm: "R113314")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:location geo="geo:30.2672,-97.7431" osm="R113314">Austin, TX</podcast:location>"#))
    }

    @Test("Podcast license with and without URL")
    func podcastLicense() throws {
        var ch = minimalChannel()
        let licenseURL = makeURL("https://creativecommons.org/licenses/by/4.0/")
        ch.license = PodcastLicense(identifier: "cc-by-4.0", url: licenseURL)
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:license url="https://creativecommons.org/licenses/by/4.0/">cc-by-4.0</podcast:license>"#))
    }

    @Test("Podcast value with recipients")
    func podcastValue() throws {
        var ch = minimalChannel()
        ch.value = PodcastValue(
            type: "lightning",
            method: "keysend",
            suggested: "0.00000005",
            recipients: [
                ValueRecipient(name: "Host", type: "node", address: "02d5c...", split: 90),
                ValueRecipient(type: "node", address: "03ae9...", split: 10, fee: true)
            ]
        )
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:value type="lightning" method="keysend" suggested="0.00000005">"#))
        #expect(xml.contains(#"<podcast:valueRecipient name="Host" type="node" address="02d5c..." split="90" />"#))
        #expect(xml.contains(#"type="node" address="03ae9..." split="10" fee="true" />"#))
        #expect(xml.contains("</podcast:value>"))
    }

    @Test("Podcast block with platform id")
    func podcastBlock() throws {
        var ch = minimalChannel()
        ch.podcastBlocks = [
            PodcastBlock(isBlocked: true, id: "google"),
            PodcastBlock(isBlocked: true)
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:block id="google">yes</podcast:block>"#))
        #expect(xml.contains("<podcast:block>yes</podcast:block>"))
    }

    @Test("Podcast txt records")
    func podcastTxt() throws {
        var ch = minimalChannel()
        ch.txtRecords = [
            PodcastTxt(value: "verify=abc123", purpose: "verify"),
            PodcastTxt(value: "some text")
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:txt purpose="verify">verify=abc123</podcast:txt>"#))
        #expect(xml.contains("<podcast:txt>some text</podcast:txt>"))
    }

    @Test("Podcast podroll with remote items")
    func podcastPodroll() throws {
        var ch = minimalChannel()
        let feedURL = makeURL("https://example.com/feed.xml")
        ch.podroll = Podroll(remoteItems: [
            RemoteItem(feedGuid: "abc-123", feedUrl: feedURL),
            RemoteItem(feedGuid: "def-456")
        ])
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:podroll>"))
        #expect(xml.contains(#"<podcast:remoteItem feedGuid="abc-123" feedUrl="https://example.com/feed.xml" />"#))
        #expect(xml.contains(#"<podcast:remoteItem feedGuid="def-456" />"#))
        #expect(xml.contains("</podcast:podroll>"))
    }

    @Test("Podcast update frequency")
    func updateFrequency() throws {
        var ch = minimalChannel()
        ch.updateFrequency = UpdateFrequency(label: "Weekly on Fridays", rrule: "FREQ=WEEKLY;BYDAY=FR")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:updateFrequency rrule="FREQ=WEEKLY;BYDAY=FR">Weekly on Fridays</podcast:updateFrequency>"#))
    }

    @Test("Podcast podping")
    func podping() throws {
        var ch = minimalChannel()
        ch.podpingEnabled = true
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:podping>true</podcast:podping>"))
    }

    @Test("Podcast publisher")
    func publisher() throws {
        var ch = minimalChannel()
        ch.publisher = PodcastPublisher(
            remoteItem: RemoteItem(
                feedGuid: "pub-guid-123",
                feedUrl: URL(string: "https://network.com/feed.xml"),
                medium: "publisher"
            ))
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:publisher>"))
        #expect(xml.contains(#"feedGuid="pub-guid-123""#))
        #expect(xml.contains(#"medium="publisher""#))
        #expect(xml.contains("</podcast:publisher>"))
    }

    @Test("Podcast chat")
    func chat() throws {
        var ch = minimalChannel()
        ch.chat = PodcastChat(server: "irc.zeronode.net", protocol: "irc", accountId: "host", space: "#podcast")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(##"<podcast:chat server="irc.zeronode.net" protocol="irc" accountId="host" space="#podcast" />"##))
    }
}

// MARK: - Podcast NS 2.0 Item Tests

struct FeedGeneratorPodcastItemTests {

    @Test("Podcast trailer")
    func trailer() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 8
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: components))

        var ch = minimalChannel()
        let trailerURL = makeURL("https://example.com/trailer.mp3")
        ch.trailers = [
            Trailer(
                title: "Season 2 Trailer",
                url: trailerURL,
                pubDate: date,
                length: 12_345_678,
                type: "audio/mpeg",
                season: 2
            )
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:trailer url="https://example.com/trailer.mp3""#))
        #expect(xml.contains(#"pubdate="Wed, 01 Jan 2025 08:00:00 +0000""#))
        #expect(xml.contains(#"length="12345678""#))
        #expect(xml.contains(#"type="audio/mpeg""#))
        #expect(xml.contains(#"season="2""#))
        #expect(xml.contains(">Season 2 Trailer</podcast:trailer>"))
    }

    @Test("Podcast live item")
    func liveItem() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let startDate = try #require(calendar.date(from: components))

        var ch = minimalChannel()
        let liveURL = makeURL("https://example.com/live.mp3")
        let chatURL = makeURL("https://example.com/chat")
        ch.liveItems = [
            PodcastLiveItem(
                status: .live,
                start: startDate,
                title: "Live Show",
                enclosure: Enclosure(url: liveURL, length: 0, type: "audio/mpeg"),
                contentLinks: [ContentLink(href: chatURL, title: "Chat Room")]
            )
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:liveItem status="live" start="2025-06-15T14:00:00Z">"#))
        #expect(xml.contains("<title>Live Show</title>"))
        #expect(xml.contains(#"<podcast:contentLink href="https://example.com/chat">Chat Room</podcast:contentLink>"#))
        #expect(xml.contains("</podcast:liveItem>"))
    }

    @Test("Item transcripts")
    func transcripts() throws {
        var ch = minimalChannel()
        let transcriptURL = makeURL("https://example.com/t.vtt")
        ch.items = [
            Item(transcripts: [
                Transcript(url: transcriptURL, type: "text/vtt", language: "en")
            ])
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:transcript url="https://example.com/t.vtt" type="text/vtt" language="en" />"#))
    }

    @Test("Item chapters link")
    func chaptersLink() throws {
        var ch = minimalChannel()
        let chaptersURL = makeURL("https://example.com/chapters.json")
        ch.items = [Item(chaptersLink: ChaptersLink(url: chaptersURL))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:chapters url="https://example.com/chapters.json" type="application/json+chapters" />"#))
    }

    @Test("Item soundbites")
    func soundbites() throws {
        var ch = minimalChannel()
        ch.items = [
            Item(soundbites: [
                Soundbite(startTime: 30.5, duration: 60.0, title: "Best Moment"),
                Soundbite(startTime: 120.0, duration: 45.0)
            ])
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:soundbite startTime="30.5" duration="60.0">Best Moment</podcast:soundbite>"#))
        #expect(xml.contains(#"<podcast:soundbite startTime="120.0" duration="45.0" />"#))
    }

    @Test("Item alternate enclosure with source and integrity")
    func alternateEnclosure() throws {
        var ch = minimalChannel()
        ch.items = [
            Item(alternateEnclosures: [
                AlternateEnclosure(
                    type: "audio/opus",
                    length: 54321,
                    bitrate: 128000,
                    title: "High Quality",
                    isDefault: true,
                    sources: [PodcastSource(uri: "https://example.com/ep.opus")],
                    integrity: PodcastIntegrity(type: "sri", value: "sha256-abc123")
                )
            ])
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:alternateEnclosure type="audio/opus" length="54321" bitrate="128000" title="High Quality" default="true">"#))
        #expect(xml.contains(#"<podcast:source uri="https://example.com/ep.opus" />"#))
        #expect(xml.contains(#"<podcast:integrity type="sri" value="sha256-abc123" />"#))
        #expect(xml.contains("</podcast:alternateEnclosure>"))
    }

    @Test("Item social interact")
    func socialInteract() throws {
        var ch = minimalChannel()
        let accountURL = makeURL("https://mastodon.social/@host")
        ch.items = [
            Item(socialInteractions: [
                SocialInteract(
                    uri: "https://mastodon.social/@host/12345",
                    protocol: "activitypub",
                    accountId: "@host@mastodon.social",
                    accountUrl: accountURL,
                    priority: 1
                )
            ])
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:socialInteract uri="https://mastodon.social/@host/12345" protocol="activitypub""#))
        #expect(xml.contains(#"accountId="@host@mastodon.social""#))
        #expect(xml.contains(#"priority="1""#))
    }

    @Test("Item podcast season and episode")
    func podcastSeasonEpisode() throws {
        var ch = minimalChannel()
        ch.items = [
            Item(
                podcastSeason: PodcastSeason(number: 3, name: "Mysteries"),
                podcastEpisode: PodcastEpisode(number: 5, display: "EP5")
            )
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:season name="Mysteries">3</podcast:season>"#))
        #expect(xml.contains(#"<podcast:episode display="EP5">5</podcast:episode>"#))
    }

    @Test("Podcast episode with decimal number")
    func podcastEpisodeDecimal() throws {
        var ch = minimalChannel()
        ch.items = [Item(podcastEpisode: PodcastEpisode(number: 3.5))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:episode>3.5</podcast:episode>"))
    }

    @Test("Value time split with remote item")
    func valueTimeSplit() throws {
        var ch = minimalChannel()
        ch.items = [
            Item(
                value: PodcastValue(
                    type: "lightning",
                    method: "keysend",
                    recipients: [ValueRecipient(type: "node", address: "addr1", split: 100)],
                    timeSplits: [
                        ValueTimeSplit(
                            startTime: 60.0,
                            duration: 120.0,
                            recipients: [ValueRecipient(type: "node", address: "addr2", split: 50)],
                            remoteItem: RemoteItem(feedGuid: "remote-guid"),
                            remotePercentage: 75
                        )
                    ]
                ))
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:valueTimeSplit startTime="60.0" duration="120.0" remotePercentage="75">"#))
        #expect(xml.contains(#"<podcast:remoteItem feedGuid="remote-guid" />"#))
        #expect(xml.contains("</podcast:valueTimeSplit>"))
    }
}

// MARK: - Podlove Tests

struct FeedGeneratorPodloveTests {

    @Test("Podlove Simple Chapters")
    func podloveChapters() throws {
        var ch = minimalChannel()
        let topicURL = makeURL("https://example.com/topic")
        let imageURL = makeURL("https://example.com/img.jpg")
        ch.items = [
            Item(
                podloveChapters: PodloveChapters(
                    version: "1.2",
                    chapters: [
                        PodloveChapter(start: "00:00:00.000", title: "Intro"),
                        PodloveChapter(
                            start: "00:05:30.000", title: "Main Topic",
                            href: topicURL,
                            image: imageURL)
                    ]
                ))
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<psc:chapters version="1.2">"#))
        #expect(xml.contains(#"<psc:chapter start="00:00:00.000" title="Intro" />"#))
        #expect(
            xml.contains(
                #"<psc:chapter start="00:05:30.000" title="Main Topic" href="https://example.com/topic" image="https://example.com/img.jpg" />"#))
        #expect(xml.contains("</psc:chapters>"))
    }
}
