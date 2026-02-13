import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - FeedDifference Tests

@Suite("FeedDifference")
struct FeedDifferenceTests {

    @Test("stores changeType, field, oldValue, newValue")
    func storesAllProperties() {
        let diff = FeedDifference(
            changeType: .modified,
            field: "channel.title",
            oldValue: "Old",
            newValue: "New"
        )
        #expect(diff.changeType == .modified)
        #expect(diff.field == "channel.title")
        #expect(diff.oldValue == "Old")
        #expect(diff.newValue == "New")
    }

    @Test("added has nil oldValue")
    func addedHasNilOld() {
        let diff = FeedDifference(changeType: .added, field: "channel.language", newValue: "en-us")
        #expect(diff.oldValue == nil)
        #expect(diff.newValue == "en-us")
    }

    @Test("removed has nil newValue")
    func removedHasNilNew() {
        let diff = FeedDifference(changeType: .removed, field: "channel.copyright", oldValue: "2025 Acme")
        #expect(diff.oldValue == "2025 Acme")
        #expect(diff.newValue == nil)
    }

    @Test("conforms to Equatable")
    func equatable() {
        let a = FeedDifference(changeType: .modified, field: "channel.title", oldValue: "A", newValue: "B")
        let b = FeedDifference(changeType: .modified, field: "channel.title", oldValue: "A", newValue: "B")
        #expect(a == b)
    }
}

// MARK: - FeedDiff Channel Tests

@Suite("FeedDiff Channel")
struct FeedDiffChannelTests {

    private func makeChannel(
        title: String = "Test",
        link: String = "https://example.com",
        description: String = "Desc"
    ) -> Channel {
        Channel(
            title: title,
            link: URL(string: link)!,
            description: description
        )
    }

    private func makeFeed(channel: Channel) -> PodcastFeed {
        PodcastFeed(channel: channel)
    }

    @Test("identical feeds produce no differences")
    func identicalFeedsNoDiff() {
        let feed = makeFeed(channel: makeChannel())
        let diffs = FeedDiff().diff(feed, feed)
        #expect(diffs.isEmpty)
    }

    @Test("detects title change")
    func detectsTitleChange() {
        let lhs = makeFeed(channel: makeChannel(title: "Old Title"))
        let rhs = makeFeed(channel: makeChannel(title: "New Title"))
        let diffs = FeedDiff().diff(lhs, rhs)
        let titleDiff = diffs.first { $0.field == "channel.title" }
        #expect(titleDiff?.changeType == .modified)
        #expect(titleDiff?.oldValue == "Old Title")
        #expect(titleDiff?.newValue == "New Title")
    }

    @Test("detects description change")
    func detectsDescriptionChange() {
        let lhs = makeFeed(channel: makeChannel(description: "Old desc"))
        let rhs = makeFeed(channel: makeChannel(description: "New desc"))
        let diffs = FeedDiff().diff(lhs, rhs)
        let descDiff = diffs.first { $0.field == "channel.description" }
        #expect(descDiff != nil)
        #expect(descDiff?.changeType == .modified)
    }

    @Test("detects language added")
    func detectsLanguageAdded() {
        var lhsCh = makeChannel()
        lhsCh.language = nil
        var rhsCh = makeChannel()
        rhsCh.language = "en-us"
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let langDiff = diffs.first { $0.field == "channel.language" }
        #expect(langDiff?.changeType == .added)
        #expect(langDiff?.newValue == "en-us")
    }

    @Test("detects itunesAuthor removed")
    func detectsAuthorRemoved() {
        var lhsCh = makeChannel()
        lhsCh.itunesAuthor = "Host"
        var rhsCh = makeChannel()
        rhsCh.itunesAuthor = nil
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let authorDiff = diffs.first { $0.field == "channel.itunesAuthor" }
        #expect(authorDiff?.changeType == .removed)
        #expect(authorDiff?.oldValue == "Host")
    }

    @Test("detects itunesExplicit change")
    func detectsExplicitChange() {
        var lhsCh = makeChannel()
        lhsCh.itunesExplicit = false
        var rhsCh = makeChannel()
        rhsCh.itunesExplicit = true
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let explicitDiff = diffs.first { $0.field == "channel.itunesExplicit" }
        #expect(explicitDiff?.changeType == .modified)
    }

    @Test("handles nil channels")
    func handlesNilChannels() {
        let empty = PodcastFeed(channel: nil)
        let full = makeFeed(channel: makeChannel())
        let diffs = FeedDiff().diff(empty, full)
        #expect(diffs.count == 1)
        #expect(diffs[0].changeType == .added)
        #expect(diffs[0].field == "channel")
    }

}

// MARK: - FeedDiff Item Tests

@Suite("FeedDiff Items")
struct FeedDiffItemTests {

    private func makeFeed(items: [Item]) -> PodcastFeed {
        var channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        channel.items = items
        return PodcastFeed(channel: channel)
    }

    @Test("detects added item")
    func detectsAddedItem() {
        let lhs = makeFeed(items: [])
        let rhs = makeFeed(items: [Item(title: "Episode 1")])
        let diffs = FeedDiff().diff(lhs, rhs)
        let addedItem = diffs.first { $0.changeType == .added && $0.field.hasPrefix("items[") }
        #expect(addedItem != nil)
    }

    @Test("detects removed item")
    func detectsRemovedItem() {
        let lhs = makeFeed(items: [Item(title: "Episode 1")])
        let rhs = makeFeed(items: [])
        let diffs = FeedDiff().diff(lhs, rhs)
        let removedItem = diffs.first { $0.changeType == .removed && $0.field.hasPrefix("items[") }
        #expect(removedItem != nil)
    }

    @Test("detects modified item title")
    func detectsModifiedItemTitle() {
        var item1 = Item(title: "Old Title")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        var item2 = Item(title: "New Title")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        let lhs = makeFeed(items: [item1])
        let rhs = makeFeed(items: [item2])
        let diffs = FeedDiff().diff(lhs, rhs)
        let titleDiff = diffs.first { $0.field.contains(".title") }
        #expect(titleDiff?.changeType == .modified)
        #expect(titleDiff?.oldValue == "Old Title")
        #expect(titleDiff?.newValue == "New Title")
    }

    @Test("matches items by guid")
    func matchesByGuid() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "guid-1", isPermaLink: false)
        item1.itunesDuration = 100
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "guid-1", isPermaLink: false)
        item2.itunesDuration = 200
        let lhs = makeFeed(items: [item1])
        let rhs = makeFeed(items: [item2])
        let diffs = FeedDiff().diff(lhs, rhs)
        let durationDiff = diffs.first { $0.field.contains("itunesDuration") }
        #expect(durationDiff?.changeType == .modified)
        #expect(durationDiff?.oldValue == "100")
        #expect(durationDiff?.newValue == "200")
    }

    @Test("matches items by title when no guid")
    func matchesByTitle() {
        var item1 = Item(title: "Episode 1")
        item1.itunesSeason = 1
        var item2 = Item(title: "Episode 1")
        item2.itunesSeason = 2
        let lhs = makeFeed(items: [item1])
        let rhs = makeFeed(items: [item2])
        let diffs = FeedDiff().diff(lhs, rhs)
        let seasonDiff = diffs.first { $0.field.contains("itunesSeason") }
        #expect(seasonDiff?.changeType == .modified)
    }

    @Test("detects enclosure URL change")
    func detectsEnclosureURLChange() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.enclosure = Enclosure.mp3(url: "https://example.com/old.mp3", length: 1000)
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.enclosure = Enclosure.mp3(url: "https://example.com/new.mp3", length: 1000)
        let lhs = makeFeed(items: [item1])
        let rhs = makeFeed(items: [item2])
        let diffs = FeedDiff().diff(lhs, rhs)
        let encDiff = diffs.first { $0.field.contains("enclosure.url") }
        #expect(encDiff?.changeType == .modified)
    }

}

// MARK: - FeedDiff XML Tests

@Suite("FeedDiff XML")
struct FeedDiffXMLTests {

    @Test("diff(xml:xml:) parses and compares")
    func diffXMLParsesAndCompares() throws {
        let xml1 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Old Title</title>
                <link>https://example.com</link>
                <description>Description</description>
              </channel>
            </rss>
            """
        let xml2 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>New Title</title>
                <link>https://example.com</link>
                <description>Description</description>
              </channel>
            </rss>
            """
        let diffs = try FeedDiff().diff(xml: xml1, xml: xml2)
        let titleDiff = diffs.first { $0.field == "channel.title" }
        #expect(titleDiff?.changeType == .modified)
        #expect(titleDiff?.oldValue == "Old Title")
        #expect(titleDiff?.newValue == "New Title")
    }

    @Test("diff(xml:xml:) throws on invalid XML")
    func diffXMLThrowsOnInvalid() {
        #expect(throws: (any Error).self) {
            try FeedDiff().diff(xml: "not xml", xml: "also not xml")
        }
    }
}

// MARK: - PodcastFeedEngine Diff Integration

@Suite("PodcastFeedEngine Diff")
struct PodcastFeedEngineDiffTests {

    @Test("engine diff(model) delegates to FeedDiff")
    func engineDiffModel() {
        let engine = PodcastFeedEngine()
        var ch1 = Channel(
            title: "Old",
            link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        ch1.language = "en"
        let ch2 = Channel(
            title: "Old",
            link: URL(string: "https://example.com")!,
            description: "Desc"
        )
        let feed1 = PodcastFeed(channel: ch1)
        let feed2 = PodcastFeed(channel: ch2)
        let diffs = engine.diff(feed1, feed2)
        let langDiff = diffs.first { $0.field == "channel.language" }
        #expect(langDiff?.changeType == .removed)
    }

    @Test("engine diff(xml) delegates to FeedDiff")
    func engineDiffXML() throws {
        let engine = PodcastFeedEngine()
        let xml1 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Title</title>
                <link>https://example.com</link>
                <description>Old Desc</description>
              </channel>
            </rss>
            """
        let xml2 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Title</title>
                <link>https://example.com</link>
                <description>New Desc</description>
              </channel>
            </rss>
            """
        let diffs = try engine.diff(xml: xml1, xml: xml2)
        let descDiff = diffs.first { $0.field == "channel.description" }
        #expect(descDiff?.changeType == .modified)
    }
}
