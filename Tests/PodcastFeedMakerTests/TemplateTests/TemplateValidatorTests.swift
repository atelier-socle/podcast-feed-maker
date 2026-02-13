import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("TemplateValidator")
struct TemplateValidatorTests {

    private let validator = TemplateValidator()

    // MARK: - Helpers

    private static func makeTestURL() throws -> URL {
        try #require(URL(string: "https://example.com"))
    }

    private static func makeImageURL() throws -> URL {
        try #require(URL(string: "https://example.com/art.jpg"))
    }

    private func makeMinimalFeed() throws -> PodcastFeed {
        let testURL = try Self.makeTestURL()
        let channel = Channel(
            title: "Test", link: testURL, description: "A test podcast"
        )
        return PodcastFeed(channel: channel)
    }

    private func makeBasicCompliantFeed() throws -> PodcastFeed {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
        return PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.category(.technology).explicit(false).image(imageURL.absoluteString)
        }
    }

    private func makeStandardCompliantFeed() throws -> PodcastFeed {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
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
    func basicCompliant() throws {
        let feed = try makeBasicCompliantFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        #expect(report.isCompliant)
    }

    @Test("missing itunesImage produces error")
    func missingItunesImage() throws {
        let testURL = try Self.makeTestURL()
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
    func missingCategory() throws {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
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
    func missingExplicit() throws {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
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
    func recommendedWarnings() throws {
        let feed = try makeBasicCompliantFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        // language is recommended for basic -- should be a warning
        let languageWarning = report.warnings.first { $0.tag == .language }
        #expect(languageWarning != nil)
        // Still compliant because warnings don't affect compliance
        #expect(report.isCompliant)
    }

    // MARK: - Standard Validation

    @Test("standard compliant feed has no errors")
    func standardCompliant() throws {
        let feed = try makeStandardCompliantFeed()
        let report = validator.validate(feed, against: StandardTemplate())
        #expect(report.isCompliant)
    }

    @Test("standard template detects missing podcastGuid")
    func missingPodcastGuid() throws {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
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
    func missingItemTags() throws {
        var feed = try makeBasicCompliantFeed()
        // Add an item without title or enclosure
        feed.channel?.items = [Item()]
        let report = validator.validate(feed, against: BasicTemplate())
        let titleError = report.errors.first { $0.tag == .itemTitle }
        let enclosureError = report.errors.first { $0.tag == .itemEnclosure }
        #expect(titleError != nil)
        #expect(enclosureError != nil)
    }

    @Test("item with all required basic tags passes")
    func itemWithRequiredTags() throws {
        var feed = try makeBasicCompliantFeed()
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
    func detectBasic() throws {
        let feed = try makeBasicCompliantFeed()
        let level = validator.detectLevel(feed)
        #expect(level == .basic)
    }

    @Test("detectLevel returns standard for PSP-1 compliant feed")
    func detectStandard() throws {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
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
    func levelMismatch() throws {
        var feed = try makeBasicCompliantFeed()
        feed.channel?.value = PodcastValue(
            type: "lightning", method: "keysend", recipients: []
        )
        let report = validator.validate(feed, against: BasicTemplate())
        let infos = report.infos.filter { $0.tag == .podcastValue }
        #expect(!infos.isEmpty)
    }

    @Test("level mismatch info has suggestedLevel populated")
    func levelMismatchSuggestedLevel() throws {
        var feed = try makeBasicCompliantFeed()
        feed.channel?.value = PodcastValue(
            type: "lightning", method: "keysend", recipients: []
        )
        let report = validator.validate(feed, against: BasicTemplate())
        let valueInfo = report.infos.first { $0.tag == .podcastValue }
        #expect(valueInfo?.suggestedLevel == .expert)
    }

    @Test("error results have nil suggestedLevel")
    func errorResultsNilSuggestedLevel() throws {
        let testURL = try Self.makeTestURL()
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
    func warningResultsNilSuggestedLevel() throws {
        let feed = try makeBasicCompliantFeed()
        let report = validator.validate(feed, against: BasicTemplate())
        for warning in report.warnings {
            #expect(warning.suggestedLevel == nil)
        }
    }

    // MARK: - Standard = PSP1Configuration

    @Test("standard template + PSP-1 fields passes PSP-1 validation")
    func standardMatchesPSP1() throws {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
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
