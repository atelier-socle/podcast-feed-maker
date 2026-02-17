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

// MARK: - Apple Validation — Required Fields

@Suite("Apple Validation — Required Fields")
struct AppleRequiredFieldsTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func appleFeed(
        items: [Item] = [],
        itunesAuthor: String? = "Author",
        itunesCategories: [ITunesCategory] = [ITunesCategory(text: "Technology")],
        itunesExplicit: Bool? = false,
        itunesImage: URL? = URL(string: "https://example.com/art.jpg"),
        itunesOwner: ITunesOwner? = ITunesOwner(name: "Host", email: "h@e.com"),
        language: String? = "en",
        itunesType: ITunesShowType? = .episodic
    ) throws -> PodcastFeed {
        let url = makeURL("https://example.com")
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "A great podcast",
                language: language,
                items: items,
                itunesAuthor: itunesAuthor,
                itunesCategories: itunesCategories,
                itunesExplicit: itunesExplicit,
                itunesImage: itunesImage,
                itunesOwner: itunesOwner,
                itunesType: itunesType
            ))
    }

    private func validItem(index: Int = 0) throws -> Item {
        let enclosureURL = try #require(URL(string: "https://example.com/ep\(index).mp3"))
        let imageURL = try #require(URL(string: "https://example.com/ep\(index).jpg"))
        return Item(
            title: "Episode \(index)",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-\(index)", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 600,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: imageURL
        )
    }

    // MARK: - All Required Present

    @Test("Valid Apple feed passes")
    func validFeedPasses() throws {
        let feed = try appleFeed(items: [validItem()])
        let report = validator.validate(feed, for: .apple)
        #expect(report.isValid)
    }

    // MARK: - Missing Required Fields

    @Test("Missing title is error")
    func missingTitle() throws {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "",
            link: url,
            description: "desc",
            items: [try validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() throws {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "",
            items: [try validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("Missing itunes:image is error")
    func missingImage() throws {
        let feed = try appleFeed(items: [validItem()], itunesImage: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.itunesImage" })
    }

    @Test("Missing itunes:category is error")
    func missingCategory() throws {
        let feed = try appleFeed(items: [validItem()], itunesCategories: [])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is error")
    func missingExplicit() throws {
        let feed = try appleFeed(items: [validItem()], itunesExplicit: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    @Test("No items with enclosure is error")
    func noItemsWithEnclosure() throws {
        let itemNoEnclosure = Item(title: "Ep")
        let feed = try appleFeed(items: [itemNoEnclosure])
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    // MARK: - HTTPS Enforcement

    @Test("HTTP artwork URL is error")
    func httpArtworkURL() throws {
        let feed = try appleFeed(
            items: [validItem()],
            itunesImage: URL(string: "http://example.com/art.jpg")
        )
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesImage"
                    && $0.message.contains("HTTPS")
            })
    }

    @Test("HTTP enclosure URL is error")
    func httpEnclosureURL() throws {
        let enclosureURL = makeURL("http://example.com/ep.mp3")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = try appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure.url"
            })
    }

    @Test("HTTPS enclosure URL passes")
    func httpsEnclosureURL() throws {
        let feed = try appleFeed(items: [validItem()])
        let report = validator.validate(feed, for: .apple)
        let urlErrors = report.errors.filter {
            $0.field.contains("enclosure.url")
        }
        #expect(urlErrors.isEmpty)
    }

    // MARK: - Audio Type

    @Test("Unsupported audio type is error")
    func unsupportedAudioType() throws {
        let enclosureURL = makeURL("https://example.com/ep.wma")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/x-ms-wma"
            )
        )
        let feed = try appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure.type"
            })
    }

    // MARK: - Recommended Fields

    @Test("Missing itunes:author is warning")
    func missingAuthorWarning() throws {
        let feed = try appleFeed(items: [validItem()], itunesAuthor: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor"
            })
    }

    @Test("Missing itunes:owner is warning")
    func missingOwnerWarning() throws {
        let feed = try appleFeed(items: [validItem()], itunesOwner: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesOwner"
            })
    }

    @Test("Missing language is warning")
    func missingLanguageWarning() throws {
        let feed = try appleFeed(items: [validItem()], language: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.language"
            })
    }

    @Test("Missing itunes:type is info")
    func missingTypeInfo() throws {
        let feed = try appleFeed(items: [validItem()], itunesType: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(report.infos.contains { $0.field == "channel.itunesType" })
    }
}

// MARK: - Apple Validation — Content Rules

@Suite("Apple Validation — Content Rules")
struct AppleContentRulesTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func appleFeed(items: [Item] = []) -> PodcastFeed {
        let url = makeURL("https://example.com")
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "A great podcast",
                language: "en",
                items: items,
                itunesAuthor: "Author",
                itunesCategories: [ITunesCategory(text: "Technology")],
                itunesExplicit: false,
                itunesImage: URL(string: "https://example.com/art.jpg"),
                itunesOwner: ITunesOwner(name: "Host", email: "h@e.com"),
                itunesType: .episodic
            ))
    }

    private func validItem(index: Int = 0) throws -> Item {
        let enclosureURL = try #require(URL(string: "https://example.com/ep\(index).mp3"))
        let imageURL = try #require(URL(string: "https://example.com/ep\(index).jpg"))
        return Item(
            title: "Episode \(index)",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-\(index)", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 600,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: imageURL
        )
    }

    // MARK: - Item Recommendations

    @Test("Item missing GUID generates warning")
    func itemMissingGuid() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].guid"
            })
    }

    @Test("Item missing pubDate generates warning")
    func itemMissingPubDate() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].pubDate"
            })
    }

    // MARK: - Length Checks

    @Test("Title over 255 chars generates warning")
    func longTitle() throws {
        let longTitle = String(repeating: "a", count: 300)
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: longTitle,
            link: url,
            description: "desc",
            items: [try validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("255")
            })
    }

    @Test("Description over 4000 chars generates warning")
    func longDescription() throws {
        let longDesc = String(repeating: "a", count: 4500)
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: longDesc,
            items: [try validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: imageURL
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description" && $0.message.contains("4000")
            })
    }

    // MARK: - Cross-Field Validation

    @Test("Duration without enclosure is warning")
    func durationWithoutEnclosure() {
        let item = Item(title: "Episode", itunesDuration: 600)
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.message.contains("duration") && $0.message.contains("enclosure")
            })
    }

    @Test("Serial show without season/episode tags is info")
    func serialNoSeasonEpisode() throws {
        let item = try validItem()
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "A great podcast",
                language: "en",
                items: [item],
                itunesAuthor: "Author",
                itunesCategories: [ITunesCategory(text: "Technology")],
                itunesExplicit: false,
                itunesImage: URL(string: "https://example.com/art.jpg"),
                itunesOwner: ITunesOwner(name: "Host", email: "h@e.com"),
                itunesType: .serial
            ))
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.infos.contains {
                $0.message.contains("Serial") && $0.message.contains("season")
            })
    }

    @Test("Serial show with season tag does not warn")
    func serialWithSeason() throws {
        var item = try validItem()
        item.itunesSeason = 1
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "A great podcast",
                language: "en",
                items: [item],
                itunesAuthor: "Author",
                itunesCategories: [ITunesCategory(text: "Technology")],
                itunesExplicit: false,
                itunesImage: URL(string: "https://example.com/art.jpg"),
                itunesOwner: ITunesOwner(name: "Host", email: "h@e.com"),
                itunesType: .serial
            ))
        let report = validator.validate(feed, for: .apple)
        #expect(
            !report.infos.contains {
                $0.message.contains("Serial") && $0.message.contains("season")
            })
    }

    // MARK: - Item Without Title or Description

    @Test("Item with neither title nor description is error for Apple")
    func itemNoTitleNoDescription() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0]"
                    && $0.message.contains("title or description")
            })
    }

    @Test("Item with only description but no title passes Apple title check")
    func itemWithDescriptionOnly() {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            description: "An episode description",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-desc", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 300,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/ep.jpg")
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            !report.errors.contains {
                $0.field == "channel.items[0]"
                    && $0.message.contains("title or description")
            })
    }

    // MARK: - Non-ASCII Enclosure URL

    @Test("Percent-encoded URL does not trigger non-ASCII warning")
    func percentEncodedEnclosureURL() {
        // Foundation's URL(string:) percent-encodes non-ASCII chars,
        // so absoluteString remains ASCII. Verify no false positive.
        let encodedURL = makeURL("https://example.com/%C3%A9pisode.mp3")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: encodedURL,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-enc", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 300,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/ep.jpg")
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            !report.warnings.contains {
                $0.message.contains("non-ASCII")
            })
    }

    @Test("ASCII enclosure URL does not trigger non-ASCII warning")
    func asciiEnclosureURL() throws {
        let feed = try appleFeed(items: [validItem()])
        let report = validator.validate(feed, for: .apple)
        #expect(
            !report.warnings.contains {
                $0.message.contains("non-ASCII")
            })
    }

    // MARK: - Item Description Length

    @Test("Item description over 4000 bytes generates warning")
    func itemLongDescription() throws {
        var item = try validItem()
        item.description = String(repeating: "x", count: 4500)
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].description"
                    && $0.message.contains("4000")
            })
    }
}
