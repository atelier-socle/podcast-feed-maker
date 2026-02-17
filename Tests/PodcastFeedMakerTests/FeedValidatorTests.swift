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

// MARK: - Feed Validator — Core

@Suite("Feed Validator — Core")
struct FeedValidatorCoreTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func minimalValidFeed() -> PodcastFeed {
        let enclosureURL = makeURL("https://example.com/ep1.mp3")
        let itemImageURL = makeURL("https://example.com/ep1.jpg")
        let linkURL = makeURL("https://example.com")
        let artworkURL = makeURL("https://example.com/art.jpg")
        let feedURL = makeURL("https://example.com/feed.xml")
        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 300,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: itemImageURL
        )
        let channel = Channel(
            title: "My Podcast",
            link: linkURL,
            description: "A great podcast",
            language: "en",
            items: [item],
            itunesAuthor: "Host Name",
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false,
            itunesImage: artworkURL,
            itunesOwner: ITunesOwner(name: "Host", email: "host@example.com"),
            itunesType: .episodic,
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "abc-123"),
            locked: Locked(isLocked: false)
        )
        return PodcastFeed(channel: channel)
    }

    private func emptyFeed() -> PodcastFeed {
        PodcastFeed(channel: nil)
    }

    private func minimalChannelFeed() -> PodcastFeed {
        let url = makeURL("https://example.com")
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "desc"
            ))
    }

    // MARK: - Fully Compliant Feed

    @Test("Fully compliant feed passes all platforms")
    func fullyCompliantFeedPassesAll() {
        let feed = minimalValidFeed()
        let reports = validator.validateAll(feed)
        for report in reports {
            #expect(
                report.isValid,
                "Feed should be valid for \(report.platform)"
            )
        }
    }

    // MARK: - Empty Feed (No Channel)

    @Test("Empty feed generates errors for all platforms")
    func emptyFeedErrors() {
        let feed = emptyFeed()
        let reports = validator.validateAll(feed)
        for report in reports {
            #expect(!report.isValid)
            #expect(report.errors.contains { $0.field == "channel" })
        }
    }

    // MARK: - Single Platform

    @Test("Validate against single platform returns one report")
    func singlePlatformReport() {
        let feed = minimalValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.platform == .apple)
    }

    // MARK: - Multiple Platforms

    @Test("Validate against multiple platforms returns correct count")
    func multiplePlatformReports() {
        let feed = minimalValidFeed()
        let reports = validator.validate(
            feed, for: [.apple, .spotify, .psp1]
        )
        #expect(reports.count == 3)
        #expect(reports[0].platform == .apple)
        #expect(reports[1].platform == .spotify)
        #expect(reports[2].platform == .psp1)
    }

    // MARK: - ValidateAll

    @Test("validateAll returns reports for all 5 platforms")
    func validateAllReturns5Reports() {
        let feed = minimalValidFeed()
        let reports = validator.validateAll(feed)
        #expect(reports.count == 5)
        let platforms = Set(reports.map(\.platform))
        #expect(platforms.count == 5)
    }

    // MARK: - Report Structure

    @Test("Results are sorted by severity (errors first)")
    func resultsSortedBySeverity() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .apple)
        guard report.results.count >= 2 else { return }
        for i in 0..<(report.results.count - 1) {
            #expect(
                report.results[i].severity >= report.results[i + 1].severity
            )
        }
    }

    @Test("isValid is true when no errors")
    func isValidNoErrors() {
        let feed = minimalValidFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(report.isValid)
    }

    @Test("isValid is false when errors present")
    func isValidFalseWithErrors() {
        let feed = emptyFeed()
        let report = validator.validate(feed, for: .apple)
        #expect(!report.isValid)
    }
}

// MARK: - Feed Validator — Platform

@Suite("Feed Validator — Platform")
struct FeedValidatorPlatformTests {

    private let validator = FeedValidator()

    private func minimalChannelFeed() -> PodcastFeed {
        let url = makeURL("https://example.com")
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "desc"
            ))
    }

    // MARK: - Apple Specific

    @Test("Missing itunes:image is error for Apple")
    func missingItunesImageApple() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.itunesImage" })
    }

    @Test("Missing itunes:category is error for Apple")
    func missingItunesCategoryApple() {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is error for Apple")
    func missingItunesExplicitApple() {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    @Test("Feed with no items is error for Apple")
    func noItemsApple() {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    @Test("HTTP enclosure URL is error for Apple")
    func httpEnclosureApple() {
        let enclosureURL = makeURL("http://example.com/ep.mp3")
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [item],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure.url"
            })
    }

    // MARK: - PSP-1 Specific

    @Test("Missing atom:link rel=self is error for PSP-1")
    func missingAtomLinkSelfPSP1() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.atomLinks"
            })
    }

    @Test("Missing podcast:locked is error for PSP-1")
    func missingLockedPSP1() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.locked" })
    }

    @Test("Missing podcast:guid is error for PSP-1")
    func missingGuidPSP1() {
        let feed = minimalChannelFeed()
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.podcastGuid"
            })
    }

    // MARK: - Spotify Specific

    @Test("MP3 enclosure has no format warning for Spotify")
    func mp3NoWarningSpotify() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let url = makeURL("https://example.com")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        let typeWarnings = report.warnings.filter {
            $0.field.contains("enclosure.type")
        }
        #expect(typeWarnings.isEmpty)
    }

    @Test("M4A enclosure generates warning for Spotify")
    func m4aWarningSpotify() {
        let enclosureURL = makeURL("https://example.com/ep.m4a")
        let url = makeURL("https://example.com")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/x-m4a"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.type"
            })
    }

    @Test("Oversized enclosure generates warning for Spotify")
    func oversizedEnclosureSpotify() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let url = makeURL("https://example.com")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 250_000_000,
                type: "audio/mpeg"
            )
        )
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.length"
            })
    }

    // MARK: - Podcast Index Specific

    @Test("podcast:value without recipients is warning for Podcast Index")
    func valueWithoutRecipients() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            value: PodcastValue(type: "lightning", method: "keysend")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.value.recipients"
            })
    }

    // MARK: - Cross-Cutting

    @Test("Duplicate GUIDs generate warning")
    func duplicateGuids() {
        let url = makeURL("https://example.com")
        let items = [
            Item(
                title: "Ep 1",
                guid: GUID(value: "same-guid", isPermaLink: false)
            ),
            Item(
                title: "Ep 2",
                guid: GUID(value: "same-guid", isPermaLink: false)
            )
        ]
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: items
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[1].guid"
                    && $0.message.contains("Duplicate")
            })
    }
}
