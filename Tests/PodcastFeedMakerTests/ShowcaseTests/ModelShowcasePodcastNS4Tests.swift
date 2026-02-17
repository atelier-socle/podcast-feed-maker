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

// MARK: - Podcast NS 2.0 Phase 4+

@Suite("Podcast NS 2.0 -- Phase 4 Value")
struct PodcastNS20Phase4ValueShowcase {

    // MARK: - PodcastGuid

    @Test("PodcastGuid holds a UUID string")
    func podcastGuidValue() {
        let guid = PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(guid.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
    }

    // MARK: - PodcastValue

    private static func makeCompleteValue() -> PodcastValue {
        let remoteURL = makeURL("https://other.example.com/feed.xml")
        return PodcastValue(
            type: "lightning",
            method: "keysend",
            suggested: "0.00000005000",
            recipients: [
                ValueRecipient(
                    name: "Host",
                    type: "node",
                    address: "02d5c1d52fd3a6a2f4ba0637a6d10b085af94c5b15f2a3f7a7e7b38e4be2f44e8a",
                    customKey: "696969",
                    customValue: "podcaster",
                    split: 90,
                    fee: false
                ),
                ValueRecipient(
                    name: "App Developer",
                    type: "node",
                    address: "03ae9f91a0cb8ff43840e3c322c4c61f019d8c1c3cea15a25cfc425ac605e61f31",
                    split: 10,
                    fee: true
                )
            ],
            timeSplits: [
                ValueTimeSplit(
                    startTime: 60.0,
                    duration: 120.0,
                    recipients: [
                        ValueRecipient(name: "Guest", type: "node", address: "04abc123def456", split: 50)
                    ],
                    remoteItem: RemoteItem(
                        feedGuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
                        feedUrl: remoteURL,
                        itemGuid: "remote-ep-001",
                        medium: "music"
                    ),
                    remotePercentage: 70
                )
            ]
        )
    }

    @Test("PodcastValue with recipients and time splits")
    func podcastValueComplete() {
        let value = Self.makeCompleteValue()
        let remoteURL = makeURL("https://other.example.com/feed.xml")

        #expect(value.type == "lightning")
        #expect(value.method == "keysend")
        #expect(value.suggested == "0.00000005000")
        #expect(value.recipients.count == 2)

        let host = value.recipients[0]
        #expect(host.name == "Host")
        #expect(host.type == "node")
        #expect(host.address.hasPrefix("02d5c"))
        #expect(host.customKey == "696969")
        #expect(host.customValue == "podcaster")
        #expect(host.split == 90)
        #expect(host.fee == false)

        let appDev = value.recipients[1]
        #expect(appDev.split == 10)
        #expect(appDev.fee == true)
        #expect(appDev.customKey == nil)
        #expect(appDev.customValue == nil)

        #expect(value.timeSplits.count == 1)
        let split = value.timeSplits[0]
        #expect(split.startTime == 60.0)
        #expect(split.duration == 120.0)
        #expect(split.recipients.count == 1)
        #expect(split.remoteItem?.feedGuid == "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        #expect(split.remoteItem?.feedUrl == remoteURL)
        #expect(split.remoteItem?.itemGuid == "remote-ep-001")
        #expect(split.remoteItem?.medium == "music")
        #expect(split.remotePercentage == 70)
    }

    @Test("PodcastValue with minimal configuration")
    func podcastValueMinimal() {
        let value = PodcastValue(type: "paypal", method: "direct")

        #expect(value.type == "paypal")
        #expect(value.method == "direct")
        #expect(value.suggested == nil)
        #expect(value.recipients.isEmpty)
        #expect(value.timeSplits.isEmpty)
    }

    @Test("ValueRecipient with minimal properties")
    func valueRecipientMinimal() {
        let recipient = ValueRecipient(type: "wallet", address: "wallet-address-123", split: 100)

        #expect(recipient.name == nil)
        #expect(recipient.type == "wallet")
        #expect(recipient.address == "wallet-address-123")
        #expect(recipient.customKey == nil)
        #expect(recipient.customValue == nil)
        #expect(recipient.split == 100)
        #expect(recipient.fee == nil)
    }

    @Test("ValueTimeSplit with minimal properties")
    func valueTimeSplitMinimal() {
        let split = ValueTimeSplit(startTime: 0.0, duration: 30.0)

        #expect(split.startTime == 0.0)
        #expect(split.duration == 30.0)
        #expect(split.recipients.isEmpty)
        #expect(split.remoteItem == nil)
        #expect(split.remotePercentage == nil)
    }

    // MARK: - PodcastMedium

    @Test("PodcastMedium has all 19 cases (10 core + 9 list variants)")
    func podcastMediumAllCases() {
        let allCases = PodcastMedium.allCases
        #expect(allCases.count == 19)

        // Core types
        #expect(PodcastMedium.podcast.rawValue == "podcast")
        #expect(PodcastMedium.music.rawValue == "music")
        #expect(PodcastMedium.video.rawValue == "video")
        #expect(PodcastMedium.film.rawValue == "film")
        #expect(PodcastMedium.audiobook.rawValue == "audiobook")
        #expect(PodcastMedium.newsletter.rawValue == "newsletter")
        #expect(PodcastMedium.blog.rawValue == "blog")
        #expect(PodcastMedium.publisher.rawValue == "publisher")
        #expect(PodcastMedium.course.rawValue == "course")
        #expect(PodcastMedium.mixed.rawValue == "mixed")

        // List variants
        #expect(PodcastMedium.podcastL.rawValue == "podcastL")
        #expect(PodcastMedium.musicL.rawValue == "musicL")
        #expect(PodcastMedium.videoL.rawValue == "videoL")
        #expect(PodcastMedium.filmL.rawValue == "filmL")
        #expect(PodcastMedium.audiobookL.rawValue == "audiobookL")
        #expect(PodcastMedium.newsletterL.rawValue == "newsletterL")
        #expect(PodcastMedium.blogL.rawValue == "blogL")
        #expect(PodcastMedium.courseL.rawValue == "courseL")
        #expect(PodcastMedium.publisherL.rawValue == "publisherL")
    }

    // MARK: - PodcastLiveItem

    @Test("PodcastLiveItem with full configuration")
    func liveItemFull() {
        let enclosureURL = makeURL("https://stream.example.com/live.mp3")
        let chatURL = makeURL("https://example.com/chat")
        let artworkURL = makeURL("https://example.com/live-art.jpg")
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)
        let endDate = Date(timeIntervalSince1970: 1_700_007_200)

        let liveItem = PodcastLiveItem(
            status: .live,
            start: startDate,
            end: endDate,
            title: "Live Q&A Session",
            description: "Ask us anything about Swift 6",
            enclosure: Enclosure(url: enclosureURL, length: 0, type: "audio/mpeg"),
            guid: GUID(value: "live-2025-001", isPermaLink: false),
            contentLinks: [
                ContentLink(href: chatURL, title: "Join the Chat")
            ],
            persons: [PodcastPerson(name: "Wlad", role: "host")],
            alternateEnclosures: [
                AlternateEnclosure(type: "audio/opus", sources: [PodcastSource(uri: "https://stream.example.com/live.opus")])
            ],
            itunesImage: artworkURL,
            value: PodcastValue(type: "lightning", method: "keysend"),
            socialInteractions: [
                SocialInteract(uri: "https://mastodon.social/@host/live", protocol: "activitypub")
            ]
        )

        #expect(liveItem.status == .live)
        #expect(liveItem.start == startDate)
        #expect(liveItem.end == endDate)
        #expect(liveItem.title == "Live Q&A Session")
        #expect(liveItem.description?.contains("Swift 6") == true)
        #expect(liveItem.enclosure?.url == enclosureURL)
        #expect(liveItem.guid?.value == "live-2025-001")
        #expect(liveItem.contentLinks.count == 1)
        #expect(liveItem.contentLinks[0].title == "Join the Chat")
        #expect(liveItem.persons.count == 1)
        #expect(liveItem.alternateEnclosures.count == 1)
        #expect(liveItem.itunesImage == artworkURL)
        #expect(liveItem.value?.type == "lightning")
        #expect(liveItem.socialInteractions.count == 1)
    }

    @Test("PodcastLiveItem.LiveStatus has all three cases")
    func liveStatusCases() {
        let allCases = PodcastLiveItem.LiveStatus.allCases
        #expect(allCases.count == 3)
        #expect(PodcastLiveItem.LiveStatus.pending.rawValue == "pending")
        #expect(PodcastLiveItem.LiveStatus.live.rawValue == "live")
        #expect(PodcastLiveItem.LiveStatus.ended.rawValue == "ended")
    }

    @Test("ContentLink holds href and title")
    func contentLinkProperties() {
        let url = makeURL("https://example.com/show-notes")
        let link = ContentLink(href: url, title: "Show Notes")

        #expect(link.href == url)
        #expect(link.title == "Show Notes")
    }

    // MARK: - SocialInteract

    @Test("SocialInteract with all properties")
    func socialInteractFull() {
        let accountURL = makeURL("https://mastodon.social/@podcasthost")

        let social = SocialInteract(
            uri: "https://mastodon.social/@podcasthost/109876543210",
            protocol: "activitypub",
            accountId: "@podcasthost@mastodon.social",
            accountUrl: accountURL,
            priority: 1
        )

        #expect(social.uri == "https://mastodon.social/@podcasthost/109876543210")
        #expect(social.protocol == "activitypub")
        #expect(social.accountId == "@podcasthost@mastodon.social")
        #expect(social.accountUrl == accountURL)
        #expect(social.priority == 1)
    }

    @Test("SocialInteract with required properties only")
    func socialInteractMinimal() {
        let social = SocialInteract(uri: "https://twitter.com/host/status/12345", protocol: "twitter")

        #expect(social.accountId == nil)
        #expect(social.accountUrl == nil)
        #expect(social.priority == nil)
    }
}
