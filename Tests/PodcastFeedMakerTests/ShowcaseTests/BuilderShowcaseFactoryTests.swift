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

// MARK: - Enclosure Factory Showcase

@Suite("Enclosure Factory Showcase")
struct EnclosureFactoryShowcase {

    @Test("mp3 factory creates audio/mpeg enclosure")
    func mp3Factory() throws {
        let enc = try #require(
            Enclosure.mp3(url: "https://cdn.example.com/ep.mp3", length: 10_000_000)
        )
        #expect(enc.type == "audio/mpeg")
        #expect(enc.length == 10_000_000)
        #expect(enc.url.absoluteString == "https://cdn.example.com/ep.mp3")
    }

    @Test("m4a factory creates audio/m4a enclosure")
    func m4aFactory() throws {
        let enc = try #require(
            Enclosure.m4a(url: "https://cdn.example.com/ep.m4a", length: 8_000_000)
        )
        #expect(enc.type == "audio/m4a")
        #expect(enc.length == 8_000_000)
    }

    @Test("mp4 factory creates video/mp4 enclosure")
    func mp4Factory() throws {
        let enc = try #require(
            Enclosure.mp4(url: "https://cdn.example.com/ep.mp4", length: 50_000_000)
        )
        #expect(enc.type == "video/mp4")
        #expect(enc.length == 50_000_000)
    }

    @Test("Factory returns nil for invalid URL")
    func invalidUrlReturnsNil() {
        let enc = Enclosure.mp3(url: "", length: 100)
        #expect(enc == nil)
    }

    @Test("MIMEType enum covers all common podcast formats")
    func mimeTypeCoverage() {
        let allTypes = Enclosure.MIMEType.allCases
        #expect(allTypes.contains(.mpeg))
        #expect(allTypes.contains(.m4a))
        #expect(allTypes.contains(.aac))
        #expect(allTypes.contains(.ogg))
        #expect(allTypes.contains(.opus))
        #expect(allTypes.contains(.wav))
        #expect(allTypes.contains(.flac))
        #expect(allTypes.contains(.mp4))
        #expect(allTypes.contains(.quicktime))
        #expect(allTypes.contains(.m4v))
        #expect(allTypes.contains(.pdf))
    }

    @Test("Enclosure can be created with typed MIMEType")
    func typedMimeInit() {
        let opusURL = makeURL("https://cdn.example.com/ep.opus")
        let enc = Enclosure(
            url: opusURL,
            length: 5_000_000,
            mimeType: .opus
        )
        #expect(enc.type == "audio/opus")
    }
}

// MARK: - PodcastPerson.Role Showcase

@Suite("PodcastPerson.Role Showcase")
struct PodcastPersonRoleShowcase {

    @Test("Role enum covers all Podcast Taxonomy roles")
    func roleCoverage() {
        let allRoles = PodcastPerson.Role.allCases
        #expect(allRoles.contains(.host))
        #expect(allRoles.contains(.guest))
        #expect(allRoles.contains(.editor))
        #expect(allRoles.contains(.producer))
        #expect(allRoles.contains(.writer))
        #expect(allRoles.contains(.designer))
        #expect(allRoles.contains(.composer))
        #expect(allRoles.contains(.narrator))
        #expect(allRoles.count == 8)
    }

    @Test("Role rawValue matches lowercase string")
    func roleRawValues() {
        #expect(PodcastPerson.Role.host.rawValue == "host")
        #expect(PodcastPerson.Role.guest.rawValue == "guest")
        #expect(PodcastPerson.Role.producer.rawValue == "producer")
    }
}

// MARK: - PSP-1 Compliance Showcase

@Suite("PSP-1 Compliance Showcase")
struct PSP1ComplianceShowcase {

    @Test("PSP1Configuration holds all required fields")
    func configurationFields() {
        let exampleURL = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let imageURL = makeURL("https://cdn.example.com/art.jpg")
        let config = PSP1Configuration(
            title: "PSP-1 Show",
            link: exampleURL,
            description: "A PSP-1 compliant podcast",
            feedURL: feedURL,
            author: "Jane Doe",
            ownerName: "Jane Doe",
            ownerEmail: "jane@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
            language: "en-us"
        )

        #expect(config.title == "PSP-1 Show")
        #expect(config.language == "en-us")
        #expect(config.podcastGUID == "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
    }

    @Test("PSP1Configuration defaults language to en")
    func configurationDefaultLanguage() {
        let exampleURL = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/f")
        let imageURL = makeURL("https://e.com/a.jpg")
        let config = PSP1Configuration(
            title: "T", link: exampleURL,
            description: "D", feedURL: feedURL,
            author: "A", ownerName: "O", ownerEmail: "o@e.com",
            category: .technology, explicit: false,
            imageURL: imageURL,
            podcastGUID: "guid-123"
        )
        #expect(config.language == "en")
    }

    @Test("psp1Compliant factory produces a feed with all PSP-1 required fields")
    func psp1CompliantFactory() throws {
        let exampleURL = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let imageURL = makeURL("https://cdn.example.com/art.jpg")
        let config = PSP1Configuration(
            title: "PSP-1 Show",
            link: exampleURL,
            description: "A PSP-1 compliant podcast",
            feedURL: feedURL,
            author: "Jane Doe",
            ownerName: "Jane Doe",
            ownerEmail: "jane@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        )

        let feed = PodcastFeed.psp1Compliant(config: config)
        let channel = try #require(feed.channel)

        #expect(channel.title == "PSP-1 Show")
        #expect(channel.description == "A PSP-1 compliant podcast")
        #expect(channel.language == "en")
        #expect(channel.itunesAuthor == "Jane Doe")
        #expect(channel.itunesOwner?.name == "Jane Doe")
        #expect(channel.itunesOwner?.email == "jane@example.com")
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage != nil)
        #expect(channel.podcastGuid?.value == "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "jane@example.com")
        #expect(channel.atomLinks.contains { $0.rel == "self" })
        #expect(feed.namespaces == PodcastNamespace.allStandard)
    }

    @Test("PSP-1 compliant feed passes PSP-1 validation with no errors")
    func psp1FeedPassesValidation() {
        let exampleURL = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let imageURL = makeURL("https://cdn.example.com/art.jpg")
        let enclosureURL = makeURL("https://cdn.example.com/ep1.mp3")
        let config = PSP1Configuration(
            title: "Validated Show",
            link: exampleURL,
            description: "Fully PSP-1 compliant",
            feedURL: feedURL,
            author: "Host",
            ownerName: "Host",
            ownerEmail: "host@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        )
        var feed = PodcastFeed.psp1Compliant(config: config)

        let enclosure = Enclosure(
            url: enclosureURL,
            length: 10_000_000,
            type: "audio/mpeg"
        )
        let item = Item(
            title: "Episode 1",
            enclosure: enclosure,
            guid: GUID(value: "ep-001", isPermaLink: false)
        )
        feed.channel?.items = [item]

        let validator = FeedValidator()
        let report = validator.validate(feed, for: .psp1)
        #expect(report.isValid, "PSP-1 feed should pass validation, errors: \(report.errors)")
    }

    @Test("PSP-1 feed also passes Apple validation")
    func psp1FeedPassesApple() {
        let exampleURL = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let imageURL = makeURL("https://cdn.example.com/art.jpg")
        let enclosureURL = makeURL("https://cdn.example.com/ep1.mp3")
        let config = PSP1Configuration(
            title: "Cross-Platform Show",
            link: exampleURL,
            description: "Works everywhere",
            feedURL: feedURL,
            author: "Host",
            ownerName: "Host",
            ownerEmail: "host@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
        )
        var feed = PodcastFeed.psp1Compliant(config: config)

        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 10_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-001", isPermaLink: false)
        )
        feed.channel?.items = [item]

        let validator = FeedValidator()
        let report = validator.validate(feed, for: .apple)
        #expect(report.isValid)
    }
}
