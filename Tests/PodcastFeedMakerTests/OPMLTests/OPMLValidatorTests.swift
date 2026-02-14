import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("OPMLValidator Tests")
struct OPMLValidatorTests {

    private let validator = OPMLValidator()

    // MARK: - Valid Documents

    @Test("Valid document with head and feeds passes")
    func validDocument() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "My Podcasts"),
            outlines: [
                OPMLOutline(
                    text: "Feed", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml"))
            ]
        )
        let report = validator.validate(doc)

        #expect(report.isValid)
        #expect(report.errors.isEmpty)
    }

    // MARK: - Version Checks

    @Test("Unrecognized version produces warning")
    func unrecognizedVersion() {
        let doc = OPMLDocument(
            version: "3.0",
            head: OPMLHead(title: "Test"),
            outlines: [OPMLOutline(text: "Feed")]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "opml.version" })
    }

    @Test("Valid versions produce no version warning")
    func validVersions() {
        for version in ["1.0", "1.1", "2.0"] {
            let doc = OPMLDocument(
                version: version,
                head: OPMLHead(title: "Test"),
                outlines: [OPMLOutline(text: "Feed")]
            )
            let report = validator.validate(doc)
            #expect(!report.warnings.contains { $0.field == "opml.version" })
        }
    }

    // MARK: - Head Checks

    @Test("Missing head produces warning")
    func missingHead() {
        let doc = OPMLDocument(
            outlines: [OPMLOutline(text: "Feed")]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "opml.head" })
    }

    @Test("Missing title in head produces warning")
    func missingTitle() {
        let doc = OPMLDocument(
            head: OPMLHead(),
            outlines: [OPMLOutline(text: "Feed")]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "opml.head.title" })
    }

    // MARK: - Outline Checks

    @Test("Empty outlines produces warning")
    func emptyOutlines() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: []
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "opml.body" })
    }

    @Test("Empty text produces warning")
    func emptyText() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [OPMLOutline(text: "")]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "outlines[0]" })
    }

    @Test("RSS type without xmlUrl produces error")
    func rssWithoutXmlUrl() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [OPMLOutline(text: "Feed", type: "rss")]
        )
        let report = validator.validate(doc)

        #expect(!report.isValid)
        #expect(report.errors.contains { $0.field == "outlines[0].xmlUrl" })
    }

    @Test("xmlUrl without type produces warning")
    func xmlUrlWithoutType() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed",
                    xmlUrl: makeURL("https://example.com/feed.xml"))
            ]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "outlines[0].type" })
    }

    @Test("HTTP feed URL produces warning")
    func httpFeedUrl() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed", type: "rss",
                    xmlUrl: makeURL("http://example.com/feed.xml"))
            ]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.field == "outlines[0].xmlUrl" })
    }

    // MARK: - Duplicate Checks

    @Test("Duplicate feed URLs produce warning")
    func duplicateFeeds() {
        let url = makeURL("https://example.com/feed.xml")
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(text: "Feed 1", type: "rss", xmlUrl: url),
                OPMLOutline(text: "Feed 2", type: "rss", xmlUrl: url)
            ]
        )
        let report = validator.validate(doc)

        #expect(report.warnings.contains { $0.message.contains("Duplicate") })
    }

    @Test("Unique feed URLs produce no duplicate warning")
    func uniqueFeeds() {
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed 1", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed1.xml")),
                OPMLOutline(
                    text: "Feed 2", type: "rss",
                    xmlUrl: makeURL("https://example.com/feed2.xml"))
            ]
        )
        let report = validator.validate(doc)

        #expect(!report.warnings.contains { $0.message.contains("Duplicate") })
    }

    // MARK: - Nested Validation

    @Test("Validates nested outlines")
    func validatesNested() {
        let badFeed = OPMLOutline(text: "Bad", type: "rss")
        let category = OPMLOutline(text: "Tech", children: [badFeed])
        let doc = OPMLDocument(
            head: OPMLHead(title: "Test"),
            outlines: [category]
        )
        let report = validator.validate(doc)

        #expect(!report.isValid)
        #expect(report.errors.contains { $0.field.contains("children[0].xmlUrl") })
    }
}
