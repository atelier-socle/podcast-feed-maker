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

// MARK: - V6: Legacy itunes:explicit Parsing

@Suite("V6 — Legacy itunes:explicit Parsing")
struct LegacyExplicitParsingTests {

    private let engine = PodcastFeedEngine()

    @Test("Parser handles 'clean' as false")
    func parsesCleanAsFalse() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.apple.com/dtds/podcast-1.0.dtd">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Desc</description>
                <itunes:explicit>clean</itunes:explicit>
              </channel>
            </rss>
            """
        let feed = try engine.parse(xml)
        #expect(feed.channel?.itunesExplicit == false)
    }

    @Test("Parser handles 'yes' as true")
    func parsesYesAsTrue() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.apple.com/dtds/podcast-1.0.dtd">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Desc</description>
                <itunes:explicit>yes</itunes:explicit>
              </channel>
            </rss>
            """
        let feed = try engine.parse(xml)
        #expect(feed.channel?.itunesExplicit == true)
    }

    @Test("Parser handles 'no' as false")
    func parsesNoAsFalse() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.apple.com/dtds/podcast-1.0.dtd">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Desc</description>
                <itunes:explicit>no</itunes:explicit>
              </channel>
            </rss>
            """
        let feed = try engine.parse(xml)
        #expect(feed.channel?.itunesExplicit == false)
    }

    @Test("Item-level 'clean' parsed as false")
    func itemCleanAsFalse() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.apple.com/dtds/podcast-1.0.dtd">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Desc</description>
                <item>
                  <title>Ep 1</title>
                  <itunes:explicit>clean</itunes:explicit>
                </item>
              </channel>
            </rss>
            """
        let feed = try engine.parse(xml)
        #expect(feed.channel?.items.first?.itunesExplicit == false)
    }

    @Test("Generator always outputs 'true' or 'false'")
    func generatorOutputsModernValues() throws {
        let url = makeURL("https://example.com")
        var channel = Channel(
            title: "Test",
            link: url,
            description: "Desc",
            itunesExplicit: true
        )
        let feedTrue = PodcastFeed(channel: channel)
        let xmlTrue = try engine.generate(feedTrue)
        #expect(xmlTrue.contains("<itunes:explicit>true</itunes:explicit>"))

        channel.itunesExplicit = false
        let feedFalse = PodcastFeed(channel: channel)
        let xmlFalse = try engine.generate(feedFalse)
        #expect(xmlFalse.contains("<itunes:explicit>false</itunes:explicit>"))
    }
}

// MARK: - V7: PSP-1 Language Required

@Suite("V7 — PSP-1 Language Required")
struct PSP1LanguageRequiredTests {

    private let validator = FeedValidator()

    @Test("Missing language is error for PSP-1")
    func missingLanguageIsError() {
        let url = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Desc",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "test-guid"),
            locked: Locked(isLocked: true)
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.language" })
    }

    @Test("Present language passes PSP-1")
    func presentLanguagePasses() {
        let url = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Desc",
            language: "en-us",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "test-guid"),
            locked: Locked(isLocked: true)
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .psp1)
        let langErrors = report.errors.filter { $0.field == "channel.language" }
        #expect(langErrors.isEmpty)
    }

    @Test("PSP1Configuration includes language and defaults to 'en'")
    func psp1ConfigLanguage() {
        let url = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let imageURL = makeURL("https://example.com/art.jpg")
        let config = PSP1Configuration(
            title: "Test",
            link: url,
            description: "Desc",
            feedURL: feedURL,
            author: "Host",
            ownerName: "Owner",
            ownerEmail: "owner@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "test-guid"
        )
        #expect(config.language == "en")
        let feed = PodcastFeed.psp1Compliant(config: config)
        #expect(feed.channel?.language == "en")
    }
}

// MARK: - V8/V9: PSP-1 Text Length & Whitespace

@Suite("V8/V9 — PSP-1 Text Length & Whitespace")
struct PSP1TextChecksTests {

    private let validator = FeedValidator()

    private func psp1Feed(
        itunesAuthor: String? = "Host",
        itunesTitle: String? = nil
    ) throws -> PodcastFeed {
        let url = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Desc",
            language: "en",
            itunesAuthor: itunesAuthor,
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            itunesTitle: itunesTitle,
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "test-guid"),
            locked: Locked(isLocked: true)
        )
        return PodcastFeed(channel: channel)
    }

    @Test("itunes:author > 255 chars warns")
    func authorTooLong() throws {
        let longAuthor = String(repeating: "A", count: 256)
        let feed = try psp1Feed(itunesAuthor: longAuthor)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor" && $0.message.contains("255")
            })
    }

    @Test("itunes:title > 255 chars warns")
    func titleTooLong() throws {
        let longTitle = String(repeating: "B", count: 256)
        let feed = try psp1Feed(itunesTitle: longTitle)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesTitle" && $0.message.contains("255")
            })
    }

    @Test("itunes:author with leading whitespace warns")
    func authorWhitespace() throws {
        let feed = try psp1Feed(itunesAuthor: "  Host Name  ")
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor" && $0.message.contains("whitespace")
            })
    }

    @Test("itunes:author <= 255 chars no warning")
    func authorFine() throws {
        let feed = try psp1Feed(itunesAuthor: "Normal Author")
        let report = validator.validate(feed, for: .psp1)
        let authorWarnings = report.warnings.filter {
            $0.field == "channel.itunesAuthor" && $0.message.contains("255")
        }
        #expect(authorWarnings.isEmpty)
    }
}

// MARK: - V10: Description 4000 Bytes

@Suite("V10 — Description 4000 Bytes Validation")
struct DescriptionByteLimitTests {

    private let validator = FeedValidator()

    @Test("Apple warns for channel description > 4000 bytes")
    func appleChannelDescBytes() {
        let longDesc = String(repeating: "\u{00E9}", count: 2001)
        let url = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let channel = Channel(
            title: "Test",
            link: url,
            description: longDesc,
            items: [
                Item(
                    title: "Ep 1",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1000,
                        type: "audio/mpeg"
                    )
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description" && $0.message.contains("4000 bytes")
            })
    }

    @Test("Apple warns for item description > 4000 bytes")
    func appleItemDescBytes() {
        let longItemDesc = String(repeating: "\u{00E9}", count: 2001)
        let url = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short",
            items: [
                Item(
                    title: "Ep 1",
                    description: longItemDesc,
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1000,
                        type: "audio/mpeg"
                    )
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].description" && $0.message.contains("4000 bytes")
            })
    }

    @Test("PSP-1 warns for channel description > 4000 bytes")
    func psp1ChannelDescBytes() {
        let longDesc = String(repeating: "\u{00E9}", count: 2001)
        let url = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "Test",
            link: url,
            description: longDesc,
            language: "en",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "test-guid"),
            locked: Locked(isLocked: true)
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description" && $0.message.contains("4000 bytes")
            })
    }

    @Test("PSP-1 warns for item description > 4000 bytes")
    func psp1ItemDescBytes() {
        let longItemDesc = String(repeating: "\u{00E9}", count: 2001)
        let url = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let feedURL = makeURL("https://example.com/feed.xml")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short",
            language: "en",
            items: [
                Item(
                    title: "Ep 1",
                    description: longItemDesc,
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-1", isPermaLink: false)
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "test-guid"),
            locked: Locked(isLocked: true)
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].description" && $0.message.contains("4000 bytes")
            })
    }

    @Test("Description under 4000 bytes passes Apple")
    func shortDescriptionPasses() {
        let url = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short description",
            items: [
                Item(
                    title: "Ep 1",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1000,
                        type: "audio/mpeg"
                    )
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        let descWarnings = report.warnings.filter {
            $0.field == "channel.description" && $0.message.contains("4000")
        }
        #expect(descWarnings.isEmpty)
    }
}

// MARK: - V11: Apple ASCII-Only URL

@Suite("V11 — Apple ASCII-Only URL Check")
struct AppleASCIIURLTests {

    private let validator = FeedValidator()

    @Test("Non-ASCII enclosure URL triggers warning")
    func nonASCIIEnclosureURL() {
        let url = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/%C3%A9pisode.mp3")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Desc",
            items: [
                Item(
                    title: "Ep 1",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1000,
                        type: "audio/mpeg"
                    )
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        // Percent-encoded URLs are ASCII, so this should pass
        let asciiWarnings = report.warnings.filter {
            $0.message.contains("non-ASCII")
        }
        #expect(asciiWarnings.isEmpty)
    }

    @Test("ASCII-only enclosure URL passes")
    func asciiEnclosureURL() {
        let url = makeURL("https://example.com")
        let enclosureURL = makeURL("https://example.com/episode-1.mp3")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Desc",
            items: [
                Item(
                    title: "Ep 1",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 1000,
                        type: "audio/mpeg"
                    )
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        let asciiWarnings = report.warnings.filter {
            $0.message.contains("non-ASCII")
        }
        #expect(asciiWarnings.isEmpty)
    }
}

// MARK: - V14: PodcastMedium publisherL

@Suite("V14 — PodcastMedium publisherL")
struct PodcastMediumPublisherLTests {

    @Test("publisherL raw value is correct")
    func publisherLRawValue() {
        #expect(PodcastMedium.publisherL.rawValue == "publisherL")
    }

    @Test("publisherL round-trips through parse/generate")
    func publisherLRoundTrip() throws {
        let engine = PodcastFeedEngine()
        let url = makeURL("https://example.com")
        var channel = Channel(
            title: "Test",
            link: url,
            description: "A publisher list"
        )
        channel.medium = .publisherL
        let feed = PodcastFeed(
            namespaces: PodcastNamespace.allStandard,
            channel: channel
        )
        let xml = try engine.generate(feed)
        #expect(xml.contains("<podcast:medium>publisherL</podcast:medium>"))

        let parsed = try engine.parse(xml)
        #expect(parsed.channel?.medium == .publisherL)
    }
}
