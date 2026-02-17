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

// MARK: - AmazonValidationTests

@Suite("Amazon Validation Tests")
struct AmazonValidationTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func amazonFeed(items: [Item] = []) -> PodcastFeed {
        let linkURL = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: linkURL,
                description: "A podcast",
                items: items,
                itunesCategories: [ITunesCategory(text: "Tech")],
                itunesExplicit: false,
                itunesImage: imageURL
            ))
    }

    private func validItem() -> Item {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        return Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
    }

    // MARK: - Valid Feed

    @Test("Valid Amazon feed passes")
    func validFeedPasses() {
        let feed = amazonFeed(items: [validItem()])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.isValid)
    }

    // MARK: - Required Fields

    @Test("Missing title is error")
    func missingTitle() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "",
            link: url,
            description: "desc",
            items: [validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "",
            items: [validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("No items is error")
    func noItems() {
        let feed = amazonFeed(items: [])
        let report = validator.validate(feed, for: .amazon)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    // MARK: - Format Flexibility

    @Test("M4A enclosure has no error for Amazon")
    func m4aAccepted() {
        let enclosureURL = makeURL("https://example.com/ep.m4a")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/x-m4a"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        let typeErrors = report.errors.filter {
            $0.field.contains("enclosure.type")
        }
        #expect(typeErrors.isEmpty)
    }

    // MARK: - Recommended Fields

    @Test("Missing itunes:image is warning")
    func missingImageWarning() {
        let url = makeURL("https://example.com")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [validItem()]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesImage"
            })
    }

    @Test("Missing GUID on item is warning")
    func missingGuidWarning() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].guid"
            })
    }

    // MARK: - Missing Channel

    @Test("Missing channel is error")
    func missingChannel() {
        let feed = PodcastFeed(channel: nil)
        let report = validator.validate(feed, for: .amazon)
        #expect(!report.isValid)
    }

    // MARK: - Missing Recommended

    @Test("Missing itunes:category is warning")
    func missingCategoryWarning() {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [validItem()],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is warning")
    func missingExplicitWarning() {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    @Test("Item without enclosure is error")
    func itemNoEnclosure() {
        let item = Item(title: "Episode")
        let feed = amazonFeed(items: [item])
        let report = validator.validate(feed, for: .amazon)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure"
            })
    }
}
