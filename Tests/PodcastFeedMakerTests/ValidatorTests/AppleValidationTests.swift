import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - AppleValidationTests

@Suite("Apple Validation Tests")
struct AppleValidationTests {

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
    ) -> PodcastFeed {
        PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: URL(string: "https://example.com")!,
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

    private func validItem(index: Int = 0) -> Item {
        Item(
            title: "Episode \(index)",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep\(index).mp3")!,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-\(index)", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 600,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/ep\(index).jpg")!
        )
    }

    // MARK: - All Required Present

    @Test("Valid Apple feed passes")
    func validFeedPasses() {
        let feed = appleFeed(items: [validItem()])
        let report = validator.validate(feed, for: .apple)
        #expect(report.isValid)
    }

    // MARK: - Missing Required Fields

    @Test("Missing title is error")
    func missingTitle() {
        let channel = Channel(
            title: "",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() {
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "",
            items: [validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("Missing itunes:image is error")
    func missingImage() {
        let feed = appleFeed(items: [validItem()], itunesImage: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.itunesImage" })
    }

    @Test("Missing itunes:category is error")
    func missingCategory() {
        let feed = appleFeed(items: [validItem()], itunesCategories: [])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is error")
    func missingExplicit() {
        let feed = appleFeed(items: [validItem()], itunesExplicit: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    @Test("No items with enclosure is error")
    func noItemsWithEnclosure() {
        let itemNoEnclosure = Item(title: "Ep")
        let feed = appleFeed(items: [itemNoEnclosure])
        let report = validator.validate(feed, for: .apple)
        #expect(report.errors.contains { $0.field == "channel.items" })
    }

    // MARK: - HTTPS Enforcement

    @Test("HTTP artwork URL is error")
    func httpArtworkURL() {
        let feed = appleFeed(
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
    func httpEnclosureURL() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "http://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure.url"
            })
    }

    @Test("HTTPS enclosure URL passes")
    func httpsEnclosureURL() {
        let feed = appleFeed(items: [validItem()])
        let report = validator.validate(feed, for: .apple)
        let urlErrors = report.errors.filter {
            $0.field.contains("enclosure.url")
        }
        #expect(urlErrors.isEmpty)
    }

    // MARK: - Audio Type

    @Test("Unsupported audio type is error")
    func unsupportedAudioType() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.wma")!,
                length: 1024,
                type: "audio/x-ms-wma"
            )
        )
        let feed = appleFeed(items: [item])
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure.type"
            })
    }

    // MARK: - Recommended Fields

    @Test("Missing itunes:author is warning")
    func missingAuthorWarning() {
        let feed = appleFeed(items: [validItem()], itunesAuthor: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor"
            })
    }

    @Test("Missing itunes:owner is warning")
    func missingOwnerWarning() {
        let feed = appleFeed(items: [validItem()], itunesOwner: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesOwner"
            })
    }

    @Test("Missing language is warning")
    func missingLanguageWarning() {
        let feed = appleFeed(items: [validItem()], language: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.language"
            })
    }

    @Test("Missing itunes:type is info")
    func missingTypeInfo() {
        let feed = appleFeed(items: [validItem()], itunesType: nil)
        let report = validator.validate(feed, for: .apple)
        #expect(report.infos.contains { $0.field == "channel.itunesType" })
    }

    // MARK: - Item Recommendations

    @Test("Item missing GUID generates warning")
    func itemMissingGuid() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
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
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
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
    func longTitle() {
        let longTitle = String(repeating: "a", count: 300)
        let channel = Channel(
            title: longTitle,
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("255")
            })
    }

    @Test("Description over 4000 chars generates warning")
    func longDescription() {
        let longDesc = String(repeating: "a", count: 4500)
        let channel = Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: longDesc,
            items: [validItem()],
            itunesCategories: [ITunesCategory(text: "Tech")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")!
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
    func serialNoSeasonEpisode() {
        let item = validItem()
        let feed = appleFeed(items: [item], itunesType: .serial)
        let report = validator.validate(feed, for: .apple)
        #expect(
            report.infos.contains {
                $0.message.contains("Serial") && $0.message.contains("season")
            })
    }

    @Test("Serial show with season tag does not warn")
    func serialWithSeason() {
        var item = validItem()
        item.itunesSeason = 1
        let feed = appleFeed(items: [item], itunesType: .serial)
        let report = validator.validate(feed, for: .apple)
        #expect(
            !report.infos.contains {
                $0.message.contains("Serial") && $0.message.contains("season")
            })
    }

    // MARK: - Item Without Title or Description

    @Test("Item with neither title nor description is error for Apple")
    func itemNoTitleNoDescription() {
        let item = Item(
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
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
        let item = Item(
            description: "An episode description",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
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
        let encodedURL = URL(string: "https://example.com/%C3%A9pisode.mp3")!
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
    func asciiEnclosureURL() {
        let feed = appleFeed(items: [validItem()])
        let report = validator.validate(feed, for: .apple)
        #expect(
            !report.warnings.contains {
                $0.message.contains("non-ASCII")
            })
    }

    // MARK: - Item Description Length

    @Test("Item description over 4000 bytes generates warning")
    func itemLongDescription() {
        var item = validItem()
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
