import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Gap 5: itunes:new-feed-url

@Suite("Spec Compliance — itunes:new-feed-url")
struct ItunesNewFeedUrlComplianceTests {

    @Test("Builder sets new feed URL")
    func builderNewFeedUrl() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D"
        ).newFeedUrl("https://example.com/new-feed.xml")
        #expect(channel.itunesNewFeedUrl?.absoluteString == "https://example.com/new-feed.xml")
    }

    @Test("CrossCutting warns when new-feed-url is not HTTPS")
    func crossCuttingHttpWarning() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            itunesNewFeedUrl: URL(string: "http://example.com/feed.xml")
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        let hasWarning = results.contains {
            $0.field == "channel.itunesNewFeedUrl" && $0.severity == .warning
        }
        #expect(hasWarning)
    }

    @Test("CrossCutting no warning for HTTPS new-feed-url")
    func crossCuttingHttpsOk() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            itunesNewFeedUrl: URL(string: "https://example.com/feed.xml")
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        let hasWarning = results.contains {
            $0.field == "channel.itunesNewFeedUrl" && $0.severity == .warning
        }
        #expect(!hasWarning)
    }

    @Test("Apple validation shows INFO when new-feed-url present")
    func appleInfoWhenPresent() throws {
        let linkURL = try #require(URL(string: "https://example.com"))
        let enclosureURL = try #require(URL(string: "https://example.com/ep.mp3"))
        let channel = Channel(
            title: "T", link: linkURL, description: "D",
            items: [
                Item(
                    title: "Ep",
                    enclosure: Enclosure(
                        url: enclosureURL, length: 1000, type: "audio/mpeg"
                    ))
            ],
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            itunesNewFeedUrl: URL(string: "https://example.com/new.xml")
        )
        let feed = PodcastFeed(channel: channel)
        let results = AppleValidation.validate(feed)
        let hasInfo = results.contains { (result: ValidationResult) in
            result.field == "channel.itunesNewFeedUrl" && result.severity == .info
        }
        #expect(hasInfo)
    }

    @Test("itunes:new-feed-url round-trips")
    func newFeedUrlRoundTrip() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            itunesNewFeedUrl: URL(string: "https://example.com/new-feed.xml")
        )
        let feed = PodcastFeed(namespaces: [.itunes], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("<itunes:new-feed-url>https://example.com/new-feed.xml</itunes:new-feed-url>"))
        let reparsed = try FeedParser().parse(xml)
        #expect(reparsed.channel?.itunesNewFeedUrl?.absoluteString == "https://example.com/new-feed.xml")
    }
}

// MARK: - Gap 6: itunes:complete

@Suite("Spec Compliance — itunes:complete")
struct ItunesCompleteComplianceTests {

    @Test("Builder sets complete flag")
    func builderComplete() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D"
        ).complete(true)
        #expect(channel.itunesComplete == true)
    }

    @Test("CrossCutting emits INFO when complete is true")
    func crossCuttingInfo() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            itunesComplete: true
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        let hasInfo = results.contains {
            $0.field == "channel.itunesComplete" && $0.severity == .info
        }
        #expect(hasInfo)
    }

    @Test("CrossCutting no INFO when complete is nil")
    func crossCuttingNoInfoWhenNil() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D"
        )
        let feed = PodcastFeed(channel: channel)
        let results = CrossCuttingValidation.validate(feed)
        let hasInfo = results.contains {
            $0.field == "channel.itunesComplete"
        }
        #expect(!hasInfo)
    }

    @Test("itunes:complete round-trips")
    func completeRoundTrip() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            itunesComplete: true
        )
        let feed = PodcastFeed(namespaces: [.itunes], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("<itunes:complete>yes</itunes:complete>"))
        let reparsed = try FeedParser().parse(xml)
        #expect(reparsed.channel?.itunesComplete == true)
    }
}

// MARK: - Gap 7: RSS Category domain

@Suite("Spec Compliance — RSS Category domain")
struct RSSCategoryDomainComplianceTests {

    @Test("RSSCategory stores domain attribute")
    func modelDomain() {
        let cat = RSSCategory(value: "Technology", domain: "tech")
        #expect(cat.value == "Technology")
        #expect(cat.domain == "tech")
    }

    @Test("Generator emits domain attribute")
    func generatorDomain() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            categories: [RSSCategory(value: "Technology", domain: "tech")]
        )
        let feed = PodcastFeed(channel: channel)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains(#"<category domain="tech">Technology</category>"#))
    }

    @Test("Parser reads domain from channel category")
    func parserChannelDomain() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <category domain="tech">Technology</category>
                <category>Education</category>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let cats = try #require(feed.channel?.categories)
        #expect(cats.count == 2)
        #expect(cats[0].domain == "tech")
        #expect(cats[0].value == "Technology")
        #expect(cats[1].domain == nil)
        #expect(cats[1].value == "Education")
    }

    @Test("Parser reads domain from item category")
    func parserItemDomain() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <item>
                  <title>Ep</title>
                  <category domain="episodes">Season 1</category>
                </item>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let cat = try #require(feed.channel?.items.first?.categories.first)
        #expect(cat.domain == "episodes")
        #expect(cat.value == "Season 1")
    }

    @Test("RSS category domain round-trips")
    func domainRoundTrip() throws {
        let channel = Channel(
            title: "T", link: try #require(URL(string: "https://example.com")), description: "D",
            categories: [
                RSSCategory(value: "Technology", domain: "tech"),
                RSSCategory(value: "Education")
            ]
        )
        let feed = PodcastFeed(channel: channel)
        let xml = try FeedGenerator().generate(feed)
        let reparsed = try FeedParser().parse(xml)
        let cats = try #require(reparsed.channel?.categories)
        #expect(cats.count == 2)
        #expect(cats[0].domain == "tech")
        #expect(cats[1].domain == nil)
    }
}
