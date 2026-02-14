import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - OPML Document Model

/// Comprehensive tests for ``OPMLDocument`` — the root model for OPML files.
@Suite("OPML Document Showcase")
struct OPMLDocumentShowcase {

    @Test("OPMLDocument — version, head, outlines, all properties")
    func documentAllProperties() throws {
        let feedURL = makeURL("https://example.com/feed.xml")
        let siteURL = makeURL("https://example.com")

        let head = OPMLHead(
            title: "My Podcasts",
            dateCreated: Date(timeIntervalSince1970: 1_700_000_000),
            ownerName: "Jane"
        )
        let outline = OPMLOutline(
            text: "Tech Podcast",
            type: "rss",
            xmlUrl: feedURL,
            htmlUrl: siteURL
        )

        let doc = OPMLDocument(
            version: "2.0",
            head: head,
            outlines: [outline]
        )

        #expect(doc.version == "2.0")
        #expect(doc.head?.title == "My Podcasts")
        #expect(doc.head?.ownerName == "Jane")
        #expect(doc.outlines.count == 1)
        #expect(doc.outlines[0].text == "Tech Podcast")
    }

    @Test("OPMLDocument — default initializer produces empty 2.0 document")
    func documentDefaults() {
        let doc = OPMLDocument()
        #expect(doc.version == "2.0")
        #expect(doc.head == nil)
        #expect(doc.outlines.isEmpty)
    }

    @Test("OPMLDocument — podcastFeeds filters to RSS outlines with xmlUrl")
    func podcastFeedsComputed() {
        let feedOutline = OPMLOutline(
            text: "Feed",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml")
        )
        let categoryOutline = OPMLOutline(text: "Category")
        let linkOutline = OPMLOutline(
            text: "Link",
            type: "link",
            xmlUrl: makeURL("https://example.com/link")
        )
        let rssNoUrl = OPMLOutline(text: "NoURL", type: "rss")

        let doc = OPMLDocument(
            outlines: [feedOutline, categoryOutline, linkOutline, rssNoUrl]
        )

        #expect(doc.podcastFeeds.count == 1)
        #expect(doc.podcastFeeds[0].text == "Feed")
    }

    @Test("OPMLDocument — podcastFeeds finds nested RSS outlines")
    func podcastFeedsNested() {
        let nested = OPMLOutline(
            text: "Nested Feed",
            type: "rss",
            xmlUrl: makeURL("https://example.com/nested.xml")
        )
        let category = OPMLOutline(text: "Tech", children: [nested])
        let doc = OPMLDocument(outlines: [category])

        #expect(doc.podcastFeeds.count == 1)
        #expect(doc.podcastFeeds[0].text == "Nested Feed")
    }

    @Test("OPMLDocument — totalOutlineCount counts all levels")
    func totalOutlineCount() {
        let child1 = OPMLOutline(text: "Child 1")
        let child2 = OPMLOutline(text: "Child 2")
        let parent = OPMLOutline(text: "Parent", children: [child1, child2])
        let standalone = OPMLOutline(text: "Standalone")

        let doc = OPMLDocument(outlines: [parent, standalone])
        // parent(1) + child1(1) + child2(1) + standalone(1) = 4
        #expect(doc.totalOutlineCount == 4)
    }

    @Test("OPMLDocument — feedURLs returns unique feed URLs")
    func feedURLs() {
        let feed1 = OPMLOutline(
            text: "F1", type: "rss",
            xmlUrl: makeURL("https://example.com/1.xml")
        )
        let feed2 = OPMLOutline(
            text: "F2", type: "rss",
            xmlUrl: makeURL("https://example.com/2.xml")
        )
        let doc = OPMLDocument(outlines: [feed1, feed2])
        #expect(doc.feedURLs.count == 2)
    }

    @Test("OPMLDocument — title convenience reads head title")
    func titleConvenience() {
        let doc1 = OPMLDocument(head: OPMLHead(title: "Subs"))
        #expect(doc1.title == "Subs")

        let doc2 = OPMLDocument()
        #expect(doc2.title == nil)
    }

    @Test("OPMLDocument — Codable JSON round-trip")
    func codableRoundTrip() throws {
        let doc = OPMLDocument(
            version: "2.0",
            head: OPMLHead(title: "Test"),
            outlines: [
                OPMLOutline(
                    text: "Feed",
                    type: "rss",
                    xmlUrl: makeURL("https://example.com/feed.xml")
                )
            ]
        )

        let data = try JSONEncoder().encode(doc)
        let decoded = try JSONDecoder().decode(OPMLDocument.self, from: data)

        #expect(decoded == doc)
    }

    @Test("OPMLDocument — Sendable, Equatable, Hashable conformance")
    func protocolConformance() {
        let doc1 = OPMLDocument(
            head: OPMLHead(title: "A"),
            outlines: [OPMLOutline(text: "X")]
        )
        let doc2 = OPMLDocument(
            head: OPMLHead(title: "A"),
            outlines: [OPMLOutline(text: "X")]
        )
        let doc3 = OPMLDocument(
            head: OPMLHead(title: "B"),
            outlines: [OPMLOutline(text: "Y")]
        )

        // Equatable
        #expect(doc1 == doc2)
        #expect(doc1 != doc3)

        // Hashable
        #expect(doc1.hashValue == doc2.hashValue)

        // Sendable — compiles
        let sendable: any Sendable = doc1
        #expect(sendable is OPMLDocument)
    }
}

// MARK: - OPML Head

/// Tests for ``OPMLHead`` metadata.
@Suite("OPML Head Showcase")
struct OPMLHeadShowcase {

    @Test("OPMLHead — title, dateCreated, dateModified, ownerName, ownerEmail, ownerId, docs")
    func headCoreProperties() throws {
        let ownerIdURL = makeURL("https://example.com/owner")
        let docsURL = makeURL("http://dev.opml.org/spec2.html")
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let modified = Date(timeIntervalSince1970: 1_700_100_000)

        let head = OPMLHead(
            title: "Podcast List",
            dateCreated: created,
            dateModified: modified,
            ownerName: "Jane Doe",
            ownerEmail: "jane@example.com",
            ownerId: ownerIdURL,
            docs: docsURL
        )

        #expect(head.title == "Podcast List")
        #expect(head.dateCreated == created)
        #expect(head.dateModified == modified)
        #expect(head.ownerName == "Jane Doe")
        #expect(head.ownerEmail == "jane@example.com")
        #expect(head.ownerId == ownerIdURL)
        #expect(head.docs == docsURL)
    }

    @Test("OPMLHead — expansionState, vertScrollState, window coordinates")
    func headWindowState() {
        let head = OPMLHead(
            expansionState: "1,3,5",
            vertScrollState: 42,
            windowTop: 100,
            windowLeft: 200,
            windowBottom: 600,
            windowRight: 800
        )

        #expect(head.expansionState == "1,3,5")
        #expect(head.vertScrollState == 42)
        #expect(head.windowTop == 100)
        #expect(head.windowLeft == 200)
        #expect(head.windowBottom == 600)
        #expect(head.windowRight == 800)
    }

    @Test("OPMLHead — default initializer all nil")
    func headDefaults() {
        let head = OPMLHead()
        #expect(head.title == nil)
        #expect(head.dateCreated == nil)
        #expect(head.ownerName == nil)
        #expect(head.expansionState == nil)
        #expect(head.windowTop == nil)
    }

    @Test("OPMLHead — Codable JSON round-trip with dates")
    func headCodable() throws {
        let head = OPMLHead(
            title: "Subs",
            dateCreated: Date(timeIntervalSince1970: 1_700_000_000),
            ownerName: "Test"
        )
        let data = try JSONEncoder().encode(head)
        let decoded = try JSONDecoder().decode(OPMLHead.self, from: data)
        #expect(decoded == head)
    }
}

// MARK: - OPML Outline

/// Tests for ``OPMLOutline`` — the recursive tree node.
@Suite("OPML Outline Showcase")
struct OPMLOutlineShowcase {

    @Test("OPMLOutline — all standard OPML 2.0 attributes")
    func allAttributes() throws {
        let outline = OPMLOutline(
            text: "Tech Podcast",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            htmlUrl: makeURL("https://example.com"),
            description: "A technology podcast",
            language: "en-US",
            title: "Tech Podcast Full Title",
            version: "RSS2",
            created: Date(timeIntervalSince1970: 1_700_000_000),
            category: "/Technology/Software",
            isComment: false,
            isBreakpoint: false,
            url: makeURL("https://example.com/opml-include.opml")
        )

        #expect(outline.text == "Tech Podcast")
        #expect(outline.type == "rss")
        #expect(outline.xmlUrl == makeURL("https://example.com/feed.xml"))
        #expect(outline.htmlUrl == makeURL("https://example.com"))
        #expect(outline.description == "A technology podcast")
        #expect(outline.language == "en-US")
        #expect(outline.title == "Tech Podcast Full Title")
        #expect(outline.version == "RSS2")
        #expect(outline.created != nil)
        #expect(outline.category == "/Technology/Software")
        #expect(outline.isComment == false)
        #expect(outline.isBreakpoint == false)
        #expect(outline.url != nil)
    }

    @Test("OPMLOutline — recursive children (nested categories)")
    func nestedChildren() {
        let feed1 = OPMLOutline(
            text: "Feed 1", type: "rss",
            xmlUrl: makeURL("https://example.com/1.xml")
        )
        let feed2 = OPMLOutline(
            text: "Feed 2", type: "rss",
            xmlUrl: makeURL("https://example.com/2.xml")
        )
        let subcategory = OPMLOutline(text: "Software", children: [feed2])
        let category = OPMLOutline(
            text: "Technology",
            children: [feed1, subcategory]
        )

        #expect(category.children.count == 2)
        #expect(category.children[1].children.count == 1)
        #expect(category.children[1].children[0].text == "Feed 2")
    }

    @Test("OPMLOutline — customAttributes for non-standard attributes")
    func customAttributes() {
        let outline = OPMLOutline(
            text: "Overcast Feed",
            type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml"),
            customAttributes: [
                "overcastId": "12345",
                "notify": "true"
            ]
        )

        #expect(outline.customAttributes.count == 2)
        #expect(outline.customAttributes["overcastId"] == "12345")
        #expect(outline.customAttributes["notify"] == "true")
    }

    @Test("OPMLOutline — isLeaf (no children) vs container (has children)")
    func isLeaf() {
        let leaf = OPMLOutline(text: "Leaf")
        let container = OPMLOutline(
            text: "Container",
            children: [OPMLOutline(text: "Child")]
        )

        #expect(leaf.isLeaf == true)
        #expect(container.isLeaf == false)
    }

    @Test("OPMLOutline — isPodcastFeed detects RSS outlines with xmlUrl")
    func isPodcastFeed() {
        let rssFeed = OPMLOutline(
            text: "Feed", type: "rss",
            xmlUrl: makeURL("https://example.com/feed.xml")
        )
        let rssUppercase = OPMLOutline(
            text: "Feed", type: "RSS",
            xmlUrl: makeURL("https://example.com/feed.xml")
        )
        let rssNoUrl = OPMLOutline(text: "NoURL", type: "rss")
        let linkType = OPMLOutline(
            text: "Link", type: "link",
            xmlUrl: makeURL("https://example.com")
        )
        let noType = OPMLOutline(text: "Plain")

        #expect(rssFeed.isPodcastFeed == true)
        #expect(rssUppercase.isPodcastFeed == true)
        #expect(rssNoUrl.isPodcastFeed == false)
        #expect(linkType.isPodcastFeed == false)
        #expect(noType.isPodcastFeed == false)
    }

    @Test("OPMLOutline — allLeaves returns depth-first leaf nodes")
    func allLeaves() {
        let leaf1 = OPMLOutline(text: "Leaf 1")
        let leaf2 = OPMLOutline(text: "Leaf 2")
        let leaf3 = OPMLOutline(text: "Leaf 3")
        let inner = OPMLOutline(text: "Inner", children: [leaf2, leaf3])
        let root = OPMLOutline(text: "Root", children: [leaf1, inner])

        let leaves = root.allLeaves
        #expect(leaves.count == 3)
        #expect(leaves[0].text == "Leaf 1")
        #expect(leaves[1].text == "Leaf 2")
        #expect(leaves[2].text == "Leaf 3")
    }

    @Test("OPMLOutline — allOutlines returns self + all descendants")
    func allOutlines() {
        let child = OPMLOutline(text: "Child")
        let parent = OPMLOutline(text: "Parent", children: [child])

        let all = parent.allOutlines
        #expect(all.count == 2)
        #expect(all[0].text == "Parent")
        #expect(all[1].text == "Child")
    }
}
