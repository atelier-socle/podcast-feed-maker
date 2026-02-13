import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - FeedDiff Channel Edge Cases

@Suite("FeedDiff Channel Edge Cases")
struct FeedDiffChannelEdgeCaseTests {

    private func makeChannel(
        title: String = "Test",
        link: String = "https://example.com",
        description: String = "Desc"
    ) -> Channel {
        Channel(
            title: title,
            link: URL(string: link) ?? URL(fileURLWithPath: "/"),
            description: description
        )
    }

    private func makeFeed(channel: Channel) -> PodcastFeed {
        PodcastFeed(channel: channel)
    }

    @Test("detects channel removed")
    func detectsChannelRemoved() {
        let full = makeFeed(channel: makeChannel())
        let empty = PodcastFeed(channel: nil)
        let diffs = FeedDiff().diff(full, empty)
        #expect(diffs.count == 1)
        #expect(diffs[0].changeType == .removed)
        #expect(diffs[0].field == "channel")
    }

    @Test("both nil channels produce no differences")
    func bothNilChannelsNoDiff() {
        let lhs = PodcastFeed(channel: nil)
        let rhs = PodcastFeed(channel: nil)
        let diffs = FeedDiff().diff(lhs, rhs)
        #expect(diffs.isEmpty)
    }

    @Test("detects link change")
    func detectsLinkChange() {
        let lhs = makeFeed(channel: makeChannel(link: "https://old.example.com"))
        let rhs = makeFeed(channel: makeChannel(link: "https://new.example.com"))
        let diffs = FeedDiff().diff(lhs, rhs)
        let linkDiff = diffs.first { $0.field == "channel.link" }
        #expect(linkDiff?.changeType == .modified)
        #expect(linkDiff?.oldValue == "https://old.example.com")
        #expect(linkDiff?.newValue == "https://new.example.com")
    }

    @Test("detects copyright added")
    func detectsCopyrightAdded() {
        var lhsCh = makeChannel()
        lhsCh.copyright = nil
        var rhsCh = makeChannel()
        rhsCh.copyright = "2025 Acme"
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let copyrightDiff = diffs.first { $0.field == "channel.copyright" }
        #expect(copyrightDiff?.changeType == .added)
        #expect(copyrightDiff?.newValue == "2025 Acme")
    }

    @Test("detects itunesImage change")
    func detectsItunesImageChange() {
        var lhsCh = makeChannel()
        lhsCh.itunesImage = URL(string: "https://example.com/old.jpg")
        var rhsCh = makeChannel()
        rhsCh.itunesImage = URL(string: "https://example.com/new.jpg")
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let imgDiff = diffs.first { $0.field == "channel.itunesImage" }
        #expect(imgDiff?.changeType == .modified)
    }

    @Test("detects itunesType change")
    func detectsItunesTypeChange() {
        var lhsCh = makeChannel()
        lhsCh.itunesType = .episodic
        var rhsCh = makeChannel()
        rhsCh.itunesType = .serial
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let typeDiff = diffs.first { $0.field == "channel.itunesType" }
        #expect(typeDiff?.changeType == .modified)
        #expect(typeDiff?.oldValue == "episodic")
        #expect(typeDiff?.newValue == "serial")
    }

    @Test("detects podcastGuid change")
    func detectsPodcastGuidChange() {
        var lhsCh = makeChannel()
        lhsCh.podcastGuid = PodcastGuid(value: "old-guid")
        var rhsCh = makeChannel()
        rhsCh.podcastGuid = PodcastGuid(value: "new-guid")
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let guidDiff = diffs.first { $0.field == "channel.podcastGuid" }
        #expect(guidDiff?.changeType == .modified)
        #expect(guidDiff?.oldValue == "old-guid")
        #expect(guidDiff?.newValue == "new-guid")
    }

    @Test("detects locked change")
    func detectsLockedChange() {
        var lhsCh = makeChannel()
        lhsCh.locked = Locked(isLocked: false)
        var rhsCh = makeChannel()
        rhsCh.locked = Locked(isLocked: true, owner: "owner@example.com")
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let lockedDiff = diffs.first { $0.field == "channel.locked" }
        #expect(lockedDiff?.changeType == .modified)
    }

    @Test("detects itunesCategories change")
    func detectsCategoriesChange() {
        var lhsCh = makeChannel()
        lhsCh.itunesCategories = [.technology]
        var rhsCh = makeChannel()
        rhsCh.itunesCategories = [.music()]
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let catsDiff = diffs.first { $0.field == "channel.itunesCategories" }
        #expect(catsDiff?.changeType == .modified)
    }

    @Test("detects language removed")
    func detectsLanguageRemoved() {
        var lhsCh = makeChannel()
        lhsCh.language = "fr-FR"
        var rhsCh = makeChannel()
        rhsCh.language = nil
        let diffs = FeedDiff().diff(makeFeed(channel: lhsCh), makeFeed(channel: rhsCh))
        let langDiff = diffs.first { $0.field == "channel.language" }
        #expect(langDiff?.changeType == .removed)
        #expect(langDiff?.oldValue == "fr-FR")
    }
}

// MARK: - FeedDiff Item Edge Cases

@Suite("FeedDiff Item Edge Cases")
struct FeedDiffItemEdgeCaseTests {

    private func makeFeed(items: [Item]) -> PodcastFeed {
        var channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com") ?? URL(fileURLWithPath: "/"),
            description: "Desc"
        )
        channel.items = items
        return PodcastFeed(channel: channel)
    }

    @Test("detects pubDate change")
    func detectsPubDateChange() {
        let date1 = Date(timeIntervalSince1970: 1_000_000)
        let date2 = Date(timeIntervalSince1970: 2_000_000)
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.pubDate = date1
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.pubDate = date2
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let dateDiff = diffs.first { $0.field.contains("pubDate") }
        #expect(dateDiff?.changeType == .modified)
    }

    @Test("detects pubDate added")
    func detectsPubDateAdded() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.pubDate = Date(timeIntervalSince1970: 1_000_000)
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let dateDiff = diffs.first { $0.field.contains("pubDate") }
        #expect(dateDiff?.changeType == .added)
    }

    @Test("detects pubDate removed")
    func detectsPubDateRemoved() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.pubDate = Date(timeIntervalSince1970: 1_000_000)
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let dateDiff = diffs.first { $0.field.contains("pubDate") }
        #expect(dateDiff?.changeType == .removed)
    }

    @Test("detects itunesEpisode change")
    func detectsItunesEpisodeChange() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.itunesEpisode = 1
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.itunesEpisode = 5
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let episodeDiff = diffs.first { $0.field.contains("itunesEpisode") }
        #expect(episodeDiff?.changeType == .modified)
        #expect(episodeDiff?.oldValue == "1")
        #expect(episodeDiff?.newValue == "5")
    }

    @Test("detects itunesEpisodeType change")
    func detectsEpisodeTypeChange() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.itunesEpisodeType = .full
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.itunesEpisodeType = .bonus
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let typeDiff = diffs.first { $0.field.contains("itunesEpisodeType") }
        #expect(typeDiff?.changeType == .modified)
        #expect(typeDiff?.oldValue == "full")
        #expect(typeDiff?.newValue == "bonus")
    }

    @Test("detects item explicit change")
    func detectsItemExplicitChange() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.itunesExplicit = false
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.itunesExplicit = true
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let explDiff = diffs.first { $0.field.contains("itunesExplicit") }
        #expect(explDiff?.changeType == .modified)
    }

    @Test("detects item description change")
    func detectsItemDescriptionChange() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.description = "Old description"
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.description = "New description"
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let descDiff = diffs.first { $0.field.contains(".description") }
        #expect(descDiff?.changeType == .modified)
    }

    @Test("detects item guid change via title matching")
    func detectsItemGuidChange() {
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "guid-old", isPermaLink: false)
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "guid-new", isPermaLink: false)
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        #expect(!diffs.isEmpty)
    }

    @Test("items keyed by index when no guid and no title")
    func itemsKeyedByIndex() {
        var item1 = Item()
        item1.itunesDuration = 100
        var item2 = Item()
        item2.itunesDuration = 200
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let durationDiff = diffs.first { $0.field.contains("itunesDuration") }
        #expect(durationDiff?.changeType == .modified)
        #expect(durationDiff?.field.contains("item[0]") == true)
    }

    @Test("same pubDate within 1 second tolerance produces no diff")
    func pubDateWithinTolerance() {
        let date1 = Date(timeIntervalSince1970: 1_000_000)
        let date2 = Date(timeIntervalSince1970: 1_000_000.5)
        var item1 = Item(title: "Ep 1")
        item1.guid = GUID(value: "ep-1", isPermaLink: false)
        item1.pubDate = date1
        var item2 = Item(title: "Ep 1")
        item2.guid = GUID(value: "ep-1", isPermaLink: false)
        item2.pubDate = date2
        let diffs = FeedDiff().diff(makeFeed(items: [item1]), makeFeed(items: [item2]))
        let dateDiff = diffs.first { $0.field.contains("pubDate") }
        #expect(dateDiff == nil)
    }
}
