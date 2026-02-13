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
        atomLinks: [AtomLink] = [
            .selfLink(href: URL(string: "https://example.com/feed.xml")!)
        ],
        locked: Locked? = Locked(isLocked: false),
        podcastGuid: PodcastGuid? = PodcastGuid(value: "abc-123"),
        itunesImage: URL? = URL(string: "https://example.com/art.jpg"),
        itunesCategories: [ITunesCategory] = [ITunesCategory(text: "Technology")],
        itunesExplicit: Bool? = false,
        language: String? = "en",
        itunesAuthor: String? = "Host",
        items: [Item] = []
    ) -> PodcastFeed {
        PodcastFeed(
            channel: Channel(
                title: title,
                link: URL(string: "https://example.com")!,
                description: description,
                language: language,
                items: items,
                itunesAuthor: itunesAuthor,
                itunesCategories: itunesCategories,
                itunesExplicit: itunesExplicit,
                itunesImage: itunesImage,
                atomLinks: atomLinks,
                podcastGuid: podcastGuid,
                locked: locked
            ))
    }

    private func validItem() -> Item {
        Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
    }

    // MARK: - Full Compliance

    @Test("Fully compliant PSP-1 feed passes")
    func fullyCompliant() {
        let feed = psp1Feed(items: [validItem()])
        let report = validator.validate(feed, for: .psp1)
        #expect(report.isValid)
    }

    // MARK: - Missing Required Fields

    @Test("Missing title is error")
    func missingTitle() {
        let feed = psp1Feed(title: "")
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.title" })
    }

    @Test("Missing description is error")
    func missingDescription() {
        let feed = psp1Feed(description: "")
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.description" })
    }

    @Test("Missing atom:link rel=self is error")
    func missingAtomLinkSelf() {
        let feed = psp1Feed(atomLinks: [])
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.atomLinks" })
    }

    @Test("atom:link without rel=self is error")
    func atomLinkNoSelf() {
        let link = AtomLink(
            href: URL(string: "https://example.com")!, rel: "alternate"
        )
        let feed = psp1Feed(atomLinks: [link])
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.atomLinks" })
    }

    @Test("Missing podcast:locked is error")
    func missingLocked() {
        let feed = psp1Feed(locked: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.locked" })
    }

    @Test("Missing podcast:guid is error")
    func missingGuid() {
        let feed = psp1Feed(podcastGuid: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.podcastGuid" })
    }

    @Test("Missing itunes:image is error")
    func missingImage() {
        let feed = psp1Feed(itunesImage: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesImage"
            })
    }

    @Test("Missing itunes:category is error")
    func missingCategory() {
        let feed = psp1Feed(itunesCategories: [])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesCategories"
            })
    }

    @Test("Missing itunes:explicit is error")
    func missingExplicit() {
        let feed = psp1Feed(itunesExplicit: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.itunesExplicit"
            })
    }

    // MARK: - Recommended Fields

    @Test("Missing language is error")
    func missingLanguage() {
        let feed = psp1Feed(language: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(report.errors.contains { $0.field == "channel.language" })
    }

    @Test("Missing itunes:author is warning")
    func missingAuthor() {
        let feed = psp1Feed(itunesAuthor: nil)
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.itunesAuthor"
            })
    }

    // MARK: - Item Checks

    @Test("Item without title or description is error")
    func itemNoTitleOrDesc() {
        let item = Item()
        let feed = psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0]"
            })
    }

    @Test("Item without enclosure is error")
    func itemNoEnclosure() {
        let item = Item(title: "Episode")
        let feed = psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure"
            })
    }

    @Test("Item without GUID is error")
    func itemNoGuid() {
        let item = Item(
            title: "Episode",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024,
                type: "audio/mpeg"
            )
        )
        let feed = psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].guid"
            })
    }

    // MARK: - Whitespace

    @Test("Leading whitespace in title is warning")
    func leadingWhitespaceTitle() {
        let feed = psp1Feed(title: " My Podcast")
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.title" && $0.message.contains("whitespace")
            })
    }

    @Test("Trailing whitespace in description is warning")
    func trailingWhitespaceDescription() {
        let feed = psp1Feed(description: "A podcast ")
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.description"
                    && $0.message.contains("whitespace")
            })
    }

    // MARK: - Text Length

    @Test("Title over 255 chars is warning")
    func longTitle() {
        let longTitle = String(repeating: "x", count: 300)
        let feed = psp1Feed(title: longTitle)
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
    func itemTitleWhitespace() {
        let item = Item(
            title: " Episode Title",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024, type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].title"
                    && $0.message.contains("whitespace")
            })
    }

    // MARK: - Item-Level Title Length

    @Test("Item title over 255 chars is warning")
    func itemLongTitle() {
        let longTitle = String(repeating: "x", count: 300)
        let item = Item(
            title: longTitle,
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep.mp3")!,
                length: 1024, type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false)
        )
        let feed = psp1Feed(items: [item])
        let report = validator.validate(feed, for: .psp1)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].title"
                    && $0.message.contains("255")
            })
    }
}
