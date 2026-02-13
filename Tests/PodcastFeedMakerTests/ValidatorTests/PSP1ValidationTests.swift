import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - PSP1ValidationTests

@Suite("PSP-1 Validation Tests")
struct PSP1ValidationTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func psp1Feed(
        title: String = "Podcast",
        description: String = "A podcast",
        atomLinks: [AtomLink]? = nil,
        locked: Locked? = Locked(isLocked: false),
        podcastGuid: PodcastGuid? = PodcastGuid(value: "abc-123"),
        itunesImage: URL? = URL(string: "https://example.com/art.jpg"),
        itunesCategories: [ITunesCategory] = [ITunesCategory(text: "Technology")],
        itunesExplicit: Bool? = false,
        language: String? = "en",
        itunesAuthor: String? = "Host",
        items: [Item] = []
    ) throws -> PodcastFeed {
        let url = makeURL("https://example.com")
        let resolvedAtomLinks: [AtomLink]
        if let atomLinks {
            resolvedAtomLinks = atomLinks
        } else {
            let feedURL = makeURL("https://example.com/feed.xml")
            resolvedAtomLinks = [.selfLink(href: feedURL)]
        }
        return PodcastFeed(
            channel: Channel(
                title: title,
                link: url,
                description: description,
                language: language,
                items: items,
                itunesAuthor: itunesAuthor,
                itunesCategories: itunesCategories,
                itunesExplicit: itunesExplicit,
                itunesImage: itunesImage,
                atomLinks: resolvedAtomLinks,
                podcastGuid: podcastGuid,
                locked: locked
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

    // MARK: - Full Compliance

    @Test("Fully compliant PSP-1 feed passes")
    func fullyCompliant() throws {
        let feed = try psp1Feed(items: [validItem()])
        let report = validator.validate(feed, for: .psp1)
        #expect(report.isValid)
    }

    // MARK: - Missing Required Fields

    @Test("Missing title is error")
    func missingTitle() throws {
        let feed = try psp1Feed(title: "")
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() throws {
        let feed = try psp1Feed(description: "")
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("Missing atom:link rel=self is error")
    func missingAtomLinkSelf() throws {
        let feed = try psp1Feed(atomLinks: [])
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.atomLinks" })
    }

    @Test("atom:link without rel=self is error")
    func atomLinkNoSelf() throws {
        let linkURL = makeURL("https://example.com")
        let link = AtomLink(
            href: linkURL, rel: "alternate"
        )
        let feed = try psp1Feed(atomLinks: [link])
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.atomLinks" })
    }

    @Test("Missing podcast:locked is error")
    func missingLocked() throws {
        let feed = try psp1Feed(locked: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.locked" })
    }

    @Test("Missing podcast:guid is error")
    func missingGuid() throws {
        let feed = try psp1Feed(podcastGuid: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.podcastGuid" })
    }

    @Test("Missing itunes:image is error")
    func missingImage() throws {
        let feed = try psp1Feed(itunesImage: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesImage"
            })
    }

    @Test("Missing itunes:category is error")
    func missingCategory() throws {
        let feed = try psp1Feed(itunesCategories: [])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is error")
    func missingExplicit() throws {
        let feed = try psp1Feed(itunesExplicit: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    // MARK: - Recommended Fields

    @Test("Missing language is error")
    func missingLanguage() throws {
        let feed = try psp1Feed(language: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.language" })
    }

    @Test("Missing itunes:author is warning")
    func missingAuthor() throws {
        let feed = try psp1Feed(itunesAuthor: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor"
            })
    }

    // MARK: - Item Checks

    @Test("Item without title or description is error")
    func itemNoTitleOrDesc() throws {
        let item = Item()
        let feed = try psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0]"
            })
    }

    @Test("Item without enclosure is error")
    func itemNoEnclosure() throws {
        let item = Item(title: "Episode")
        let feed = try psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure"
            })
    }

    @Test("Item without GUID is error")
    func itemNoGuid() throws {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = try psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].guid"
            })
    }

    // MARK: - Whitespace

    @Test("Leading whitespace in title is warning")
    func leadingWhitespaceTitle() throws {
        let feed = try psp1Feed(title: " My Podcast")
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("whitespace")
            })
    }

    @Test("Trailing whitespace in description is warning")
    func trailingWhitespaceDescription() throws {
        let feed = try psp1Feed(description: "A podcast ")
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description"
                    && $0.message.contains("whitespace")
            })
    }

    // MARK: - Text Length

    @Test("Title over 255 chars is warning")
    func longTitle() throws {
        let longTitle = String(repeating: "x", count: 300)
        let feed = try psp1Feed(title: longTitle)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("255")
            })
    }

    // MARK: - Missing Channel

    @Test("Missing channel is error")
    func missingChannel() {
        let feed = PodcastFeed(channel: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(!report.isValid)
    }

    // MARK: - Item-Level Whitespace

    @Test("Item title with leading whitespace is warning")
    func itemTitleWhitespace() throws {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: " Episode Title",
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024, type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = try psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].title"
                    && $0.message.contains("whitespace")
            })
    }

    // MARK: - Item-Level Title Length

    @Test("Item title over 255 chars is warning")
    func itemLongTitle() throws {
        let longTitle = String(repeating: "x", count: 300)
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: longTitle,
            enclosure: Enclosure(
                url: enclosureURL,
                length: 1024, type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = try psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].title"
                    && $0.message.contains("255")
            })
    }
}
