import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("FeedParser Tests")
struct FeedParserTests {

    let parser = FeedParser()

    // MARK: - Basic Parsing

    @Test("Parses minimal feed")
    func minimalFeed() throws {
        let xml = minimalXML
        let feed = try parser.parse(xml)
        #expect(feed.version == "2.0")
        #expect(feed.channel != nil)
        #expect(feed.channel?.title == "Minimal Podcast")
        #expect(feed.channel?.link.absoluteString == "https://example.com")
        #expect(feed.channel?.description == "A minimal podcast feed")
    }

    @Test("Parses RSS version attribute")
    func rssVersion() throws {
        let feed = try parser.parse(minimalXML)
        #expect(feed.version == "2.0")
    }

    @Test("Throws for missing channel")
    func missingChannel() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        #expect(throws: ParserError.missingChannel) {
            try parser.parse(xml)
        }
    }

    @Test("Parse from Data works with valid UTF-8")
    func parseFromData() throws {
        let data = minimalXML.data(using: .utf8)
        let feed = try parser.parse(data: data ?? Data())
        #expect(feed.channel?.title == "Minimal Podcast")
    }

    // MARK: - Namespace Detection

    @Test("Detects namespaces from xmlns declarations")
    func detectsNamespaces() throws {
        let feed = try parser.parse(maximalFixture())
        let prefixes = Set(feed.namespaces.map(\.prefix))
        #expect(prefixes.contains("itunes"))
        #expect(prefixes.contains("podcast"))
        #expect(prefixes.contains("atom"))
        #expect(prefixes.contains("dc"))
        #expect(prefixes.contains("content"))
        #expect(prefixes.contains("psc"))
    }

    // MARK: - RSS 2.0 Channel Elements

    @Test("Parses channel required elements")
    func channelRequired() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.title == "Maximal Podcast")
        #expect(ch.link.absoluteString == "https://example.com")
        #expect(ch.description == "A feed exercising every single tag")
    }

    @Test("Parses channel optional string elements")
    func channelOptionalStrings() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.language == "en-us")
        #expect(ch.copyright == "Copyright 2025 Example Inc.")
        #expect(ch.managingEditor == "editor@example.com")
        #expect(ch.webMaster == "webmaster@example.com")
        #expect(ch.generator == "PodcastFeedMaker")
    }

    @Test("Parses channel dates")
    func channelDates() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.pubDate != nil)
        #expect(ch.lastBuildDate != nil)
    }

    @Test("Parses channel numeric elements")
    func channelNumeric() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.ttl == 60)
        #expect(ch.docs?.absoluteString ==
            "https://www.rssboard.org/rss-specification")
    }

    @Test("Parses RSS categories")
    func channelCategories() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.categories.count == 2)
        #expect(ch.categories[0].value == "Technology")
        #expect(ch.categories[0].domain == "tech")
        #expect(ch.categories[1].value == "Education")
        #expect(ch.categories[1].domain == nil)
    }

    @Test("Parses RSS cloud element")
    func channelCloud() throws {
        let feed = try parser.parse(maximalFixture())
        let cloud = try #require(feed.channel?.cloud)
        #expect(cloud.domain == "rpc.example.com")
        #expect(cloud.port == 80)
        #expect(cloud.path == "/rpc")
        #expect(cloud.registerProcedure == "notify")
        #expect(cloud.protocolType == "xml-rpc")
    }

    @Test("Parses RSS image")
    func channelImage() throws {
        let feed = try parser.parse(maximalFixture())
        let image = try #require(feed.channel?.image)
        #expect(image.url.absoluteString == "https://example.com/logo.png")
        #expect(image.title == "Maximal Podcast")
        #expect(image.link.absoluteString == "https://example.com")
        #expect(image.width == 144)
        #expect(image.height == 400)
        #expect(image.imageDescription == "Show logo")
    }

    @Test("Parses RSS textInput")
    func channelTextInput() throws {
        let feed = try parser.parse(maximalFixture())
        let ti = try #require(feed.channel?.textInput)
        #expect(ti.title == "Search")
        #expect(ti.description == "Search episodes")
        #expect(ti.name == "q")
        #expect(ti.link.absoluteString == "https://example.com/search")
    }

    @Test("Parses skipHours and skipDays")
    func skipSchedule() throws {
        let feed = try parser.parse(maximalFixture())
        let skip = try #require(feed.channel?.skipSchedule)
        #expect(skip.hours == [0, 6, 12])
        #expect(skip.days == [.saturday, .sunday])
    }

    // MARK: - iTunes Namespace

    @Test("Parses iTunes channel elements")
    func itunesChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.itunesAuthor == "John Doe")
        #expect(ch.itunesBlock == true)
        #expect(ch.itunesComplete == true)
        #expect(ch.itunesExplicit == true)
        #expect(ch.itunesImage?.absoluteString ==
            "https://example.com/itunes-art.jpg")
        #expect(ch.itunesKeywords == ["swift", "development", "podcast"])
        #expect(ch.itunesNewFeedUrl?.absoluteString ==
            "https://example.com/new-feed.xml")
        #expect(ch.itunesSubtitle == "A short subtitle")
        #expect(ch.itunesSummary == "A longer summary of the show")
        #expect(ch.itunesTitle == "Title Override")
        #expect(ch.itunesType == .serial)
        #expect(ch.itunesVerify == true)
    }

    @Test("Parses iTunes owner")
    func itunesOwner() throws {
        let feed = try parser.parse(maximalFixture())
        let owner = try #require(feed.channel?.itunesOwner)
        #expect(owner.name == "Jane Doe")
        #expect(owner.email == "jane@example.com")
    }

    @Test("Parses iTunes categories with subcategories")
    func itunesCategories() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.itunesCategories.count == 2)
        #expect(ch.itunesCategories[0].text == "Technology")
        #expect(ch.itunesCategories[0].subcategories.count == 1)
        #expect(ch.itunesCategories[0].subcategories[0].text ==
            "Tech News")
        #expect(ch.itunesCategories[1].text == "Education")
    }

    // MARK: - Atom Namespace

    @Test("Parses atom links")
    func atomLinks() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.atomLinks.count == 2)
        let selfLink = ch.atomLinks.first {
            $0.rel == "self"
        }
        #expect(selfLink != nil)
        #expect(selfLink?.href.absoluteString ==
            "https://example.com/feed.xml")
        #expect(selfLink?.type == "application/rss+xml")
    }

    // MARK: - Dublin Core

    @Test("Parses Dublin Core channel elements")
    func dublinCoreChannel() throws {
        let feed = try parser.parse(maximalFixture())
        let dc = try #require(feed.channel?.dublinCore)
        #expect(dc.creator == "John Doe")
        #expect(dc.contributor == "Jane Doe")
        #expect(dc.date == "2025-01-01")
        #expect(dc.description == "DC description")
        #expect(dc.format == "audio/mpeg")
        #expect(dc.identifier == "urn:uuid:12345")
        #expect(dc.language == "en")
        #expect(dc.publisher == "Example Publisher")
        #expect(dc.relation == "https://related.example.com")
        #expect(dc.rights == "All rights reserved")
        #expect(dc.source == "https://source.example.com")
        #expect(dc.subject == "Technology")
        #expect(dc.title == "DC Title")
        #expect(dc.type == "Sound")
        #expect(dc.coverage == "Worldwide")
    }

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
        #expect(item.comments?.absoluteString ==
            "https://example.com/ep1/comments")
        #expect(item.pubDate != nil)
    }

    @Test("Parses item enclosure")
    func itemEnclosure() throws {
        let feed = try parser.parse(maximalFixture())
        let enc = try #require(feed.channel?.items.first?.enclosure)
        #expect(enc.url.absoluteString ==
            "https://example.com/ep1.mp3")
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
        #expect(source.url.absoluteString ==
            "https://source.example.com/feed.xml")
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
        #expect(item.itunesImage?.absoluteString ==
            "https://example.com/ep1-art.jpg")
        #expect(item.itunesKeywords == ["intro", "welcome"])
        #expect(item.itunesSeason == 1)
        #expect(item.itunesSubtitle == "Welcome to the show")
        #expect(item.itunesSummary ==
            "A detailed summary of episode 1")
        #expect(item.itunesTitle == "Ep 1 Title Override")
    }

    @Test("Parses HH:MM:SS duration format")
    func durationHMS() throws {
        let feed = try parser.parse(maximalFixture())
        let item2 = try #require(feed.channel?.items.last)
        #expect(item2.itunesDuration == 4500) // 1:15:00 = 4500s
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

    // MARK: - Podcast NS 2.0 Channel

    @Test("Parses podcast:guid")
    func podcastGuid() throws {
        let feed = try parser.parse(maximalFixture())
        #expect(feed.channel?.podcastGuid?.value ==
            "abcdef01-2345-6789-abcd-ef0123456789")
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
        #expect(funding.url.absoluteString ==
            "https://example.com/donate")
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
        #expect(host.img?.absoluteString ==
            "https://example.com/john.jpg")
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
        #expect(lic.url?.absoluteString ==
            "https://creativecommons.org/licenses/by/4.0/")
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
        #expect(podroll.remoteItems[0].feedUrl?.absoluteString ==
            "https://friend.example.com/feed.xml")
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
        #expect(pub.name == "Example Publisher")
        #expect(pub.guid == "pub-guid-1")
        #expect(pub.url?.absoluteString ==
            "https://publisher.example.com")
    }

    @Test("Parses podcast:chat")
    func podcastChat() throws {
        let feed = try parser.parse(maximalFixture())
        let chat = try #require(feed.channel?.chat)
        #expect(chat.server == "irc.example.com")
        #expect(chat.protocol == "irc")
        #expect(chat.accountId == "#podcast")
        #expect(chat.space == "main")
        #expect(chat.embedUrl?.absoluteString ==
            "https://chat.example.com/embed")
    }

    @Test("Parses podcast:trailer")
    func podcastTrailer() throws {
        let feed = try parser.parse(maximalFixture())
        let trailer = try #require(feed.channel?.trailers.first)
        #expect(trailer.title == "Season 1 Trailer")
        #expect(trailer.url.absoluteString ==
            "https://example.com/trailer.mp3")
        #expect(trailer.length == 5_000_000)
        #expect(trailer.type == "audio/mpeg")
        #expect(trailer.season == 1)
        #expect(trailer.pubDate.timeIntervalSince1970 > 0)
    }

    // MARK: - Podcast NS 2.0 Item

    @Test("Parses podcast:transcript")
    func podcastTranscript() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.transcripts.count == 2)
        #expect(item.transcripts[0].url.absoluteString ==
            "https://example.com/ep1.vtt")
        #expect(item.transcripts[0].type == "text/vtt")
        #expect(item.transcripts[0].language == "en")
        #expect(item.transcripts[0].rel == "captions")
    }

    @Test("Parses podcast:chapters link")
    func podcastChaptersLink() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let ch = try #require(item.chaptersLink)
        #expect(ch.url.absoluteString ==
            "https://example.com/ep1-chapters.json")
        #expect(ch.type == "application/json+chapters")
    }

    @Test("Parses podcast:soundbite")
    func podcastSoundbite() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.soundbites.count == 2)
        #expect(item.soundbites[0].startTime == 30.5)
        #expect(item.soundbites[0].duration == 45.0)
        #expect(item.soundbites[0].title == "Best Moment")
        #expect(item.soundbites[1].title == nil)
    }

    @Test("Parses podcast:person at item level")
    func podcastPersonItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.persons.count == 1)
        #expect(item.persons[0].name == "Guest Speaker")
        #expect(item.persons[0].role == "guest")
    }

    @Test("Parses podcast:location at item level")
    func podcastLocationItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let loc = try #require(item.location)
        #expect(loc.name == "Paris")
        #expect(loc.geo == "geo:48.8566,2.3522")
    }

    @Test("Parses podcast:alternateEnclosure")
    func alternateEnclosure() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.alternateEnclosures.count == 1)
        let enc = item.alternateEnclosures[0]
        #expect(enc.type == "audio/opus")
        #expect(enc.length == 30_000_000)
        #expect(enc.bitrate == 96)
        #expect(enc.title == "Opus Version")
        #expect(enc.isDefault == true)
        #expect(enc.sources.count == 2)
        #expect(enc.sources[0].uri ==
            "https://example.com/ep1.opus")
        #expect(enc.sources[0].contentType == "audio/opus")
        #expect(enc.integrity?.type == "sri-hash")
        #expect(enc.integrity?.value == "sha256-xyz789")
    }

    @Test("Parses podcast:value at item level")
    func podcastValueItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let value = try #require(item.value)
        #expect(value.type == "lightning")
        #expect(value.recipients.count == 2)
        #expect(value.recipients[0].fee == true)
    }

    @Test("Parses podcast:socialInteract")
    func podcastSocialInteract() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.socialInteractions.count == 1)
        let si = item.socialInteractions[0]
        #expect(si.uri == "https://social.example.com/ep1")
        #expect(si.protocol == "activitypub")
        #expect(si.accountId == "@podcast")
    }

    @Test("Parses podcast:txt at item level")
    func podcastTxtItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.txtRecords.count == 1)
        #expect(item.txtRecords[0].value == "item-verify-123")
    }

    @Test("Parses podcast:season at item level")
    func podcastSeason() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let season = try #require(item.podcastSeason)
        #expect(season.number == 1)
        #expect(season.name == "Season One")
    }

    @Test("Parses podcast:episode at item level")
    func podcastEpisode() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let ep = try #require(item.podcastEpisode)
        #expect(ep.number == 1.5)
        #expect(ep.display == "1A")
    }

    // MARK: - Podlove Simple Chapters

    @Test("Parses psc:chapters")
    func podloveChapters() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let chapters = try #require(item.podloveChapters)
        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 3)
        #expect(chapters.chapters[0].start == "00:00:00.000")
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[0].href?.absoluteString ==
            "https://example.com/ch1")
        #expect(chapters.chapters[0].image?.absoluteString ==
            "https://example.com/ch1.jpg")
        #expect(chapters.chapters[1].title == "Main Topic")
    }

    // MARK: - Live Item

    @Test("Parses podcast:liveItem")
    func liveItem() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.liveItems.count == 1)
        let live = ch.liveItems[0]
        #expect(live.status == .live)
        #expect(live.title == "Live Episode")
        #expect(live.description == "Broadcasting live!")
        #expect(live.enclosure?.url.absoluteString ==
            "https://example.com/live.mp3")
        #expect(live.guid?.value == "live-guid-1")
        #expect(live.contentLinks.count == 2)
        #expect(live.contentLinks[0].title == "Live Chat")
        #expect(live.persons.count == 1)
        #expect(live.itunesImage?.absoluteString ==
            "https://example.com/live-art.jpg")
    }

    @Test("Parses liveItem alternateEnclosure")
    func liveItemAltEnclosure() throws {
        let feed = try parser.parse(maximalFixture())
        let live = try #require(feed.channel?.liveItems.first)
        #expect(live.alternateEnclosures.count == 1)
        let enc = live.alternateEnclosures[0]
        #expect(enc.type == "audio/opus")
        #expect(enc.isDefault == true)
        #expect(enc.sources.count == 1)
        #expect(enc.integrity?.value == "sha256-abc123")
    }

    @Test("Parses liveItem value")
    func liveItemValue() throws {
        let feed = try parser.parse(maximalFixture())
        let live = try #require(feed.channel?.liveItems.first)
        let value = try #require(live.value)
        #expect(value.type == "lightning")
        #expect(value.recipients.count == 1)
        #expect(value.recipients[0].name == "Live Host")
    }

    @Test("Parses liveItem socialInteract")
    func liveItemSocialInteract() throws {
        let feed = try parser.parse(maximalFixture())
        let live = try #require(feed.channel?.liveItems.first)
        #expect(live.socialInteractions.count == 1)
        #expect(live.socialInteractions[0].protocol == "activitypub")
        #expect(live.socialInteractions[0].priority == 1)
    }

    // MARK: - Diagnostics

    @Test("ParseWithDiagnostics returns warnings")
    func diagnostics() throws {
        let result = try parser.parseWithDiagnostics(minimalXML)
        #expect(result.feed.channel != nil)
    }

    // MARK: - Helpers

    private var minimalXML: String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Minimal Podcast</title>
            <link>https://example.com</link>
            <description>A minimal podcast feed</description>
          </channel>
        </rss>
        """
    }

    private func maximalFixture() throws -> String {
        guard let url = Bundle.module.url(
            forResource: "maximal", withExtension: "xml",
            subdirectory: "Fixtures"
        ) else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
