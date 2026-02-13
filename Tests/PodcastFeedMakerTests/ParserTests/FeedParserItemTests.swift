import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Item Parsing Tests

@Suite("FeedParser Item Tests")
struct FeedParserItemTests {

    let parser = FeedParser()

    // MARK: - Items

    @Test("Parses correct item count")
    func itemCount() throws {
        let feed = try parser.parse(maximalFixture())
        #expect(feed.channel?.items.count == 2)
    }

    @Test("Parses item RSS core elements")
    func itemRSSCore() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.title == "Episode 1: Getting Started")
        #expect(item.link?.absoluteString == "https://example.com/ep1")
        #expect(item.description == "First episode of the show")
        #expect(item.author == "john@example.com")
        #expect(item.comments?.absoluteString == "https://example.com/ep1/comments")
        #expect(item.pubDate != nil)
    }

    @Test("Parses item enclosure")
    func itemEnclosure() throws {
        let feed = try parser.parse(maximalFixture())
        let enc = try #require(feed.channel?.items.first?.enclosure)
        #expect(enc.url.absoluteString == "https://example.com/ep1.mp3")
        #expect(enc.length == 50_000_000)
        #expect(enc.type == "audio/mpeg")
    }

    @Test("Parses item GUID")
    func itemGuid() throws {
        let feed = try parser.parse(maximalFixture())
        let guid = try #require(feed.channel?.items.first?.guid)
        #expect(guid.value == "https://example.com/ep1")
        #expect(guid.isPermaLink == true)
    }

    @Test("Parses item GUID with isPermaLink=false")
    func itemGuidNotPermaLink() throws {
        let feed = try parser.parse(maximalFixture())
        let item2 = try #require(feed.channel?.items.last)
        let guid = try #require(item2.guid)
        #expect(guid.value == "ep2-guid-unique")
        #expect(guid.isPermaLink == false)
    }

    @Test("Parses item RSS source")
    func itemSource() throws {
        let feed = try parser.parse(maximalFixture())
        let source = try #require(feed.channel?.items.first?.source)
        #expect(source.title == "Original Feed")
        #expect(source.url.absoluteString == "https://source.example.com/feed.xml")
    }

    @Test("Parses item categories")
    func itemCategories() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.categories.count == 1)
        #expect(item.categories[0].value == "Season 1")
        #expect(item.categories[0].domain == "episodes")
    }

    // MARK: - Item iTunes

    @Test("Parses item iTunes elements")
    func itemITunes() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.itunesAuthor == "John Doe")
        #expect(item.itunesBlock == false)
        #expect(item.itunesDuration == 3661)
        #expect(item.itunesEpisode == 1)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesImage?.absoluteString == "https://example.com/ep1-art.jpg")
        #expect(item.itunesKeywords == ["intro", "welcome"])
        #expect(item.itunesSeason == 1)
        #expect(item.itunesSubtitle == "Welcome to the show")
        #expect(item.itunesSummary == "A detailed summary of episode 1")
        #expect(item.itunesTitle == "Ep 1 Title Override")
    }

    @Test("Parses HH:MM:SS duration format")
    func durationHMS() throws {
        let feed = try parser.parse(maximalFixture())
        let item2 = try #require(feed.channel?.items.last)
        #expect(item2.itunesDuration == 4500)  // 1:15:00 = 4500s
    }

    // MARK: - Item Dublin Core

    @Test("Parses item Dublin Core")
    func itemDublinCore() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.dublinCore?.creator == "John Doe")
        #expect(item.dublinCore?.rights == "CC BY 4.0")
    }

    // MARK: - Item Atom

    @Test("Parses item atom links")
    func itemAtomLinks() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.atomLinks.count == 1)
        #expect(item.atomLinks[0].rel == "alternate")
        #expect(item.atomLinks[0].type == "application/json")
    }

    // MARK: - Item Content Module

    @Test("Parses content:encoded")
    func contentEncoded() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let content = try #require(item.contentEncoded)
        #expect(content.value.contains("<p>Rich"))
        #expect(content.value.contains("<strong>HTML</strong>"))
    }

    // MARK: - Helpers

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}

// MARK: - Podcast NS 2.0 Channel Tests

@Suite("FeedParser Podcast Channel Tests")
struct FeedParserPodcastChannelTests {

    let parser = FeedParser()

    @Test("Parses podcast:guid")
    func podcastGuid() throws {
        let feed = try parser.parse(maximalFixture())
        #expect(feed.channel?.podcastGuid?.value == "abcdef01-2345-6789-abcd-ef0123456789")
    }

    @Test("Parses podcast:locked")
    func podcastLocked() throws {
        let feed = try parser.parse(maximalFixture())
        let locked = try #require(feed.channel?.locked)
        #expect(locked.isLocked == true)
        #expect(locked.owner == "jane@example.com")
    }

    @Test("Parses podcast:medium")
    func podcastMedium() throws {
        let feed = try parser.parse(maximalFixture())
        #expect(feed.channel?.medium == .podcast)
    }

    @Test("Parses podcast:funding")
    func podcastFunding() throws {
        let feed = try parser.parse(maximalFixture())
        let funding = try #require(feed.channel?.funding.first)
        #expect(funding.url.absoluteString == "https://example.com/donate")
        #expect(funding.message == "Support the show")
    }

    @Test("Parses podcast:person at channel level")
    func podcastPersonChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.persons.count == 2)
        let host = ch.persons[0]
        #expect(host.name == "John Doe")
        #expect(host.role == "host")
        #expect(host.group == "cast")
        #expect(host.img?.absoluteString == "https://example.com/john.jpg")
    }

    @Test("Parses podcast:location at channel level")
    func podcastLocationChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let loc = try #require(feed.channel?.location)
        #expect(loc.name == "San Francisco")
        #expect(loc.geo == "geo:37.7749,-122.4194")
        #expect(loc.osm == "R1234567")
    }

    @Test("Parses podcast:license at channel level")
    func podcastLicenseChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let lic = try #require(feed.channel?.license)
        #expect(lic.identifier == "cc-by-4.0")
        #expect(lic.url?.absoluteString == "https://creativecommons.org/licenses/by/4.0/")
    }

    @Test("Parses podcast:value with recipients and time splits")
    func podcastValue() throws {
        let feed = try parser.parse(maximalFixture())
        let value = try #require(feed.channel?.value)
        #expect(value.type == "lightning")
        #expect(value.method == "keysend")
        #expect(value.suggested == "100")
        #expect(value.recipients.count == 2)
        #expect(value.recipients[0].name == "Host")
        #expect(value.recipients[0].split == 90)
        #expect(value.recipients[0].fee == false)
        #expect(value.recipients[1].customKey == "ck1")
        #expect(value.timeSplits.count == 1)
        let split = value.timeSplits[0]
        #expect(split.startTime == 60.0)
        #expect(split.duration == 120.0)
        #expect(split.remotePercentage == 50)
        #expect(split.recipients.count == 1)
        #expect(split.remoteItem?.feedGuid == "remote-guid-123")
    }

    @Test("Parses podcast:block elements")
    func podcastBlocks() throws {
        let feed = try parser.parse(maximalFixture())
        let blocks = try #require(feed.channel?.podcastBlocks)
        #expect(blocks.count == 2)
        #expect(blocks[0].id == "spotify")
        #expect(blocks[0].isBlocked == true)
        #expect(blocks[1].id == nil)
        #expect(blocks[1].isBlocked == false)
    }

    @Test("Parses podcast:txt elements")
    func podcastTxt() throws {
        let feed = try parser.parse(maximalFixture())
        let txts = try #require(feed.channel?.txtRecords)
        #expect(txts.count == 2)
        #expect(txts[0].value == "verification-code-123")
        #expect(txts[0].purpose == "verify")
        #expect(txts[1].value == "general-txt-value")
        #expect(txts[1].purpose == nil)
    }

    @Test("Parses podcast:podroll")
    func podcastPodroll() throws {
        let feed = try parser.parse(maximalFixture())
        let podroll = try #require(feed.channel?.podroll)
        #expect(podroll.remoteItems.count == 2)
        #expect(podroll.remoteItems[0].feedGuid == "podroll-guid-1")
        #expect(podroll.remoteItems[0].feedUrl?.absoluteString == "https://friend.example.com/feed.xml")
        #expect(podroll.remoteItems[1].itemGuid == "item-42")
        #expect(podroll.remoteItems[1].medium == "music")
    }

    @Test("Parses podcast:updateFrequency")
    func podcastUpdateFrequency() throws {
        let feed = try parser.parse(maximalFixture())
        let uf = try #require(feed.channel?.updateFrequency)
        #expect(uf.label == "Weekly on Mondays")
        #expect(uf.rrule == "FREQ=WEEKLY;BYDAY=MO")
        #expect(uf.dtstart == "2025-01-06")
        #expect(uf.complete == false)
    }

    @Test("Parses podcast:podping")
    func podcastPodping() throws {
        let feed = try parser.parse(maximalFixture())
        #expect(feed.channel?.podpingEnabled == true)
    }

    @Test("Parses podcast:publisher")
    func podcastPublisher() throws {
        let feed = try parser.parse(maximalFixture())
        let pub = try #require(feed.channel?.publisher)
        #expect(pub.remoteItem.feedGuid == "pub-guid-1")
        #expect(pub.remoteItem.feedUrl?.absoluteString == "https://publisher.example.com/feed.xml")
        #expect(pub.remoteItem.medium == "publisher")
    }

    @Test("Parses podcast:chat")
    func podcastChat() throws {
        let feed = try parser.parse(maximalFixture())
        let chat = try #require(feed.channel?.chat)
        #expect(chat.server == "irc.example.com")
        #expect(chat.protocol == "irc")
        #expect(chat.accountId == "#podcast")
        #expect(chat.space == "main")
        #expect(chat.embedUrl?.absoluteString == "https://chat.example.com/embed")
    }

    @Test("Parses podcast:trailer")
    func podcastTrailer() throws {
        let feed = try parser.parse(maximalFixture())
        let trailer = try #require(feed.channel?.trailers.first)
        #expect(trailer.title == "Season 1 Trailer")
        #expect(trailer.url.absoluteString == "https://example.com/trailer.mp3")
        #expect(trailer.length == 5_000_000)
        #expect(trailer.type == "audio/mpeg")
        #expect(trailer.season == 1)
        #expect(trailer.pubDate.timeIntervalSince1970 > 0)
    }

    // MARK: - Helpers

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
