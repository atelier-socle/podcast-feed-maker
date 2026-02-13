import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("Template Round-Trip")
struct TemplateRoundTripTests {

    private let testURL = URL(string: "https://example.com")!
    private let feedURL = URL(string: "https://example.com/feed.xml")!
    private let imageURL = URL(string: "https://example.com/art.jpg")!

    @Test("basic template → generate → parse → channel.title matches")
    func basicRoundTrip() throws {
        let feed = PodcastFeed.basic(
            title: "Round Trip Show", link: testURL, description: "Testing round-trip"
        ) { ch in
            ch.category(.technology).explicit(false).image(self.imageURL.absoluteString)
        }

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        #expect(parsed.channel?.title == "Round Trip Show")
        #expect(parsed.channel?.description == "Testing round-trip")
        #expect(parsed.channel?.itunesExplicit == false)
        #expect(parsed.channel?.itunesImage == imageURL)
    }

    @Test("standard template → generate → parse → validate against template")
    func standardRoundTrip() throws {
        let feed = PodcastFeed.standard(
            title: "Standard Show", link: testURL, description: "A standard podcast"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: self.feedURL.absoluteString, rel: "self")
                .image(self.imageURL.absoluteString)
                .language("en")
        }

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        let report = TemplateValidator().validate(parsed, against: StandardTemplate())
        #expect(report.isCompliant)
    }

    @Test("standard template passes PSP-1 platform validation after round-trip")
    func standardPSP1RoundTrip() throws {
        let feed = PodcastFeed.standard(
            title: "PSP-1 Show", link: testURL, description: "Compliant"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: self.feedURL.absoluteString, rel: "self")
                .image(self.imageURL.absoluteString)
                .language("en")
        }

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        let report = FeedValidator().validate(parsed, for: .psp1)
        #expect(report.isValid)
    }

    @Test("advanced template round-trips with items")
    func advancedWithItemsRoundTrip() throws {
        var feed = PodcastFeed.advanced(
            title: "Advanced Show", link: testURL, description: "Rich metadata"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: self.feedURL.absoluteString, rel: "self")
                .image(self.imageURL.absoluteString)
                .language("en")
                .medium(.podcast)
        }

        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure.mp3(url: "https://example.com/ep1.mp3", length: 50_000),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(timeIntervalSince1970: 1_700_000_000),
            itunesDuration: 1800,
            itunesExplicit: false
        )
        feed.channel?.items = [item]

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        #expect(parsed.channel?.items.count == 1)
        #expect(parsed.channel?.items[0].title == "Episode 1")
        #expect(parsed.channel?.items[0].itunesDuration == 1800)
    }

    @Test("detectLevel after round-trip matches original template level")
    func detectLevelAfterRoundTrip() throws {
        let feed = PodcastFeed.standard(
            title: "Level Test", link: testURL, description: "Testing"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: self.feedURL.absoluteString, rel: "self")
                .image(self.imageURL.absoluteString)
                .language("en")
        }

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        let level = TemplateValidator().detectLevel(parsed)
        #expect(level >= .standard)
    }

    @Test("expert template → generate → parse → validate against template")
    func expertRoundTrip() throws {
        var feed = PodcastFeed.expert(
            title: "Expert Show", link: testURL, description: "Full coverage"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: self.feedURL.absoluteString, rel: "self")
                .image(self.imageURL.absoluteString)
                .language("en")
                .medium(.podcast)
                .funding(url: "https://example.com/donate", text: "Support")
        }
        feed.channel?.persons = [PodcastPerson(name: "Host")]

        var item = Item(
            title: "Episode 1",
            enclosure: Enclosure.mp3(url: "https://example.com/ep1.mp3", length: 50_000),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(timeIntervalSince1970: 1_700_000_000),
            itunesDuration: 1800,
            itunesExplicit: false
        )
        item.transcripts = [
            Transcript(url: URL(string: "https://example.com/ep1.srt")!, type: "application/srt")
        ]
        feed.channel?.items = [item]

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        let report = TemplateValidator().validate(parsed, against: ExpertTemplate())
        #expect(report.isCompliant)
        #expect(parsed.channel?.persons.count == 1)
        #expect(parsed.channel?.funding.count == 1)
    }

    @Test("Apple platform validation passes after basic template round-trip")
    func applePlatformRoundTrip() throws {
        var feed = PodcastFeed.basic(
            title: "Apple Show", link: testURL, description: "Apple-compatible podcast"
        ) { ch in
            ch.category(.technology)
                .explicit(false)
                .image(self.imageURL.absoluteString)
                .author("Host")
                .language("en")
        }

        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure.mp3(url: "https://example.com/ep1.mp3", length: 50_000),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(timeIntervalSince1970: 1_700_000_000),
            itunesDuration: 1800
        )
        feed.channel?.items = [item]

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        let report = FeedValidator().validate(parsed, for: .apple)
        #expect(report.errors.isEmpty)
    }

    @Test("all-platform validation passes after standard template with PSP-1 fields")
    func allPlatformRoundTrip() throws {
        var feed = PodcastFeed.standard(
            title: "Universal Show", link: testURL, description: "Cross-platform podcast"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: self.feedURL.absoluteString, rel: "self")
                .image(self.imageURL.absoluteString)
                .language("en")
        }

        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure.mp3(url: "https://example.com/ep1.mp3", length: 50_000),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(timeIntervalSince1970: 1_700_000_000),
            itunesDuration: 1800
        )
        feed.channel?.items = [item]

        let xml = try FeedGenerator().generate(feed)
        let parsed = try FeedParser().parse(xml)

        // Validate against all platforms
        for platform in ValidationPlatform.allCases {
            let report = FeedValidator().validate(parsed, for: platform)
            #expect(report.errors.isEmpty, "Platform \(platform) should have no errors")
        }
    }
}
