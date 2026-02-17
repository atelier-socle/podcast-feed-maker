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

@Suite("TemplateValidator")
struct TemplateValidatorTests {

    private let validator = TemplateValidator()

    // MARK: - Helpers

    private static func makeTestURL() -> URL {
        makeURL("https://example.com")
    }

    private static func makeImageURL() -> URL {
        makeURL("https://example.com/art.jpg")
    }

    private func makeMinimalFeed() -> PodcastFeed {
        let testURL = Self.makeTestURL()
        let channel = Channel(
            title: "Test", link: testURL, description: "A test podcast"
        )
        return PodcastFeed(channel: channel)
    }

    private func makeBasicCompliantFeed() -> PodcastFeed {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        return PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.category(.technology).explicit(false).image(imageURL.absoluteString)
        }
    }

    private func makeStandardCompliantFeed() -> PodcastFeed {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        return PodcastFeed.standard(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: "https://example.com/feed.xml", rel: "self")
                .image(imageURL.absoluteString)
                .language("en")
        }
    }

    // MARK: - Basic Validation

    @Test("compliant basic feed has no errors")
    func basicCompliant() {
        let feed = makeBasicCompliantFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        #expect(report.isCompliant)
    }

    @Test("missing itunesImage produces error")
    func missingItunesImage() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.category(.technology).explicit(false)
        }
        let report = validator.validate(feed, against: BasicTemplate())
        #expect(!report.isCompliant)
        let imageError = report.errors.first { $0.tag == .itunesImage }
        #expect(imageError != nil)
    }

    @Test("missing itunesCategory produces error")
    func missingCategory() {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.explicit(false).image(imageURL.absoluteString)
        }
        let report = validator.validate(feed, against: BasicTemplate())
        let categoryError = report.errors.first { $0.tag == .itunesCategory }
        #expect(categoryError != nil)
    }

    @Test("missing itunesExplicit produces error")
    func missingExplicit() {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.category(.technology).image(imageURL.absoluteString)
        }
        let report = validator.validate(feed, against: BasicTemplate())
        let explicitError = report.errors.first { $0.tag == .itunesExplicit }
        #expect(explicitError != nil)
    }

    @Test("missing recommended tags produce warnings not errors")
    func recommendedWarnings() {
        let feed = makeBasicCompliantFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        // language is recommended for basic -- should be a warning
        let languageWarning = report.warnings.first { $0.tag == .language }
        #expect(languageWarning != nil)
        // Still compliant because warnings don't affect compliance
        #expect(report.isCompliant)
    }

    // MARK: - Standard Validation

    @Test("standard compliant feed has no errors")
    func standardCompliant() {
        let feed = makeStandardCompliantFeed()
        let report = validator.validate(feed, against: StandardTemplate())
        #expect(report.isCompliant)
    }

    @Test("standard template detects missing podcastGuid")
    func missingPodcastGuid() {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        let feed = PodcastFeed.standard(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .atomLink(href: "https://example.com/feed.xml", rel: "self")
                .image(imageURL.absoluteString)
                .language("en")
        }
        let report = validator.validate(feed, against: StandardTemplate())
        let guidError = report.errors.first { $0.tag == .podcastGuid }
        #expect(guidError != nil)
    }

    // MARK: - Item Validation

    @Test("missing required item tags produce errors")
    func missingItemTags() {
        var feed = makeBasicCompliantFeed()
        // Add an item without title or enclosure
        feed.channel?.items = [Item()]
        let report = validator.validate(feed, against: BasicTemplate())
        let titleError = report.errors.first { $0.tag == .itemTitle }
        let enclosureError = report.errors.first { $0.tag == .itemEnclosure }
        #expect(titleError != nil)
        #expect(enclosureError != nil)
    }

    @Test("item with all required basic tags passes")
    func itemWithRequiredTags() {
        var feed = makeBasicCompliantFeed()
        feed.channel?.items = [
            Item(
                title: "Episode 1",
                enclosure: Enclosure.mp3(url: "https://example.com/ep1.mp3", length: 1000)
            )
        ]
        let report = validator.validate(feed, against: BasicTemplate())
        let itemErrors = report.errors.filter {
            $0.message.contains("item[")
        }
        #expect(itemErrors.isEmpty)
    }

    // MARK: - No Channel

    @Test("feed without channel produces error")
    func noChannel() {
        let feed = PodcastFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        #expect(!report.isCompliant)
        #expect(report.errors.count == 1)
        #expect(report.errors[0].message.contains("no channel"))
    }

    // MARK: - Level Detection

    @Test("detectLevel returns basic for minimal feed")
    func detectBasic() {
        let feed = makeBasicCompliantFeed()
        let level = validator.detectLevel(feed)
        #expect(level == .basic)
    }

    @Test("detectLevel returns standard for PSP-1 compliant feed")
    func detectStandard() {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        let feedURL = makeURL("https://example.com/feed.xml")
        let config = PSP1Configuration(
            title: "Show",
            link: testURL,
            description: "About",
            feedURL: feedURL,
            author: "Host",
            ownerName: "Host",
            ownerEmail: "h@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "aaaa-bbbb-cccc"
        )
        let feed = PodcastFeed.psp1Compliant(config: config)
        let level = validator.detectLevel(feed)
        // PSP-1 feeds match standard (may match higher if more tags present)
        #expect(level >= .standard)
    }

    // MARK: - Level Mismatch Detection

    @Test("expert tag in basic feed produces info")
    func levelMismatch() {
        var feed = makeBasicCompliantFeed()
        feed.channel?.value = PodcastValue(
            type: "lightning", method: "keysend", recipients: []
        )
        let report = validator.validate(feed, against: BasicTemplate())
        let infos = report.infos.filter { $0.tag == .podcastValue }
        #expect(!infos.isEmpty)
    }

    @Test("level mismatch info has suggestedLevel populated")
    func levelMismatchSuggestedLevel() {
        var feed = makeBasicCompliantFeed()
        feed.channel?.value = PodcastValue(
            type: "lightning", method: "keysend", recipients: []
        )
        let report = validator.validate(feed, against: BasicTemplate())
        let valueInfo = report.infos.first { $0.tag == .podcastValue }
        #expect(valueInfo?.suggestedLevel == .expert)
    }

    @Test("error results have nil suggestedLevel")
    func errorResultsNilSuggestedLevel() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.category(.technology).explicit(false)
        }
        let report = validator.validate(feed, against: BasicTemplate())
        for error in report.errors {
            #expect(error.suggestedLevel == nil)
        }
    }

    @Test("warning results have nil suggestedLevel")
    func warningResultsNilSuggestedLevel() {
        let feed = makeBasicCompliantFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        for warning in report.warnings {
            #expect(warning.suggestedLevel == nil)
        }
    }

    // MARK: - Standard = PSP1Configuration

    @Test("standard template + PSP-1 fields passes PSP-1 validation")
    func standardMatchesPSP1() {
        let testURL = Self.makeTestURL()
        let imageURL = Self.makeImageURL()
        let feed = PodcastFeed.standard(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: "https://example.com/feed.xml", rel: "self")
                .image(imageURL.absoluteString)
                .language("en")
        }
        let report = FeedValidator().validate(feed, for: .psp1)
        #expect(report.isValid)
        #expect(report.errors.isEmpty)
    }
}
