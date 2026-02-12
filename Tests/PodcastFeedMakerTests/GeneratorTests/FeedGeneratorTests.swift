import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - Helpers

private func minimalChannel() -> Channel {
    Channel(
        title: "Test Podcast",
        link: URL(string: "https://example.com")!,
        description: "A test podcast"
    )
}

private func minimalFeed(channel: Channel? = nil) -> PodcastFeed {
    PodcastFeed(channel: channel ?? minimalChannel())
}

// MARK: - Core Generation Tests

struct FeedGeneratorCoreTests {

    @Test("Minimal feed generates valid XML")
    func minimalFeedXML() throws {
        let generator = FeedGenerator()
        let xml = try generator.generate(minimalFeed())
        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<rss"))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>Test Podcast</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<description>A test podcast</description>"))
        #expect(xml.contains("</channel>"))
        #expect(xml.contains("</rss>"))
    }

    @Test("Missing channel throws error")
    func missingChannel() {
        let generator = FeedGenerator()
        let feed = PodcastFeed()
        #expect(throws: GeneratorError.missingChannel) {
            try generator.generate(feed)
        }
    }

    @Test("XML declaration present by default")
    func xmlDeclarationPresent() throws {
        let xml = try FeedGenerator().generate(minimalFeed())
        #expect(xml.starts(with: "<?xml"))
    }

    @Test("XML declaration absent when disabled")
    func xmlDeclarationAbsent() throws {
        let gen = FeedGenerator(includeXMLDeclaration: false)
        let xml = try gen.generate(minimalFeed())
        #expect(!xml.contains("<?xml"))
        #expect(xml.starts(with: "<rss"))
    }

    @Test("Pretty print enabled by default")
    func prettyPrintDefault() throws {
        let xml = try FeedGenerator().generate(minimalFeed())
        #expect(xml.contains("\n"))
        #expect(xml.contains("\t"))
    }

    @Test("Minified output when pretty print disabled")
    func minifiedOutput() throws {
        let gen = FeedGenerator(prettyPrint: false)
        let xml = try gen.generate(minimalFeed())
        #expect(!xml.contains("\n"))
        #expect(!xml.contains("\t"))
    }
}

// MARK: - Namespace Mode Tests

struct FeedGeneratorNamespaceTests {

    @Test("feedDefined mode uses feed namespaces")
    func feedDefinedMode() throws {
        let feed = PodcastFeed(namespaces: [.itunes, .atom], channel: minimalChannel())
        let gen = FeedGenerator(namespaceMode: .feedDefined)
        let xml = try gen.generate(feed)
        #expect(xml.contains("xmlns:itunes="))
        #expect(xml.contains("xmlns:atom="))
        #expect(!xml.contains("xmlns:podcast="))
    }

    @Test("auto mode resolves from content")
    func autoMode() throws {
        var ch = minimalChannel()
        ch.itunesAuthor = "Host"
        let feed = PodcastFeed(namespaces: PodcastNamespace.allStandard, channel: ch)
        let gen = FeedGenerator(namespaceMode: .auto)
        let xml = try gen.generate(feed)
        #expect(xml.contains("xmlns:itunes="))
        #expect(!xml.contains("xmlns:podcast="))
    }

    @Test("explicit mode uses specified namespaces")
    func explicitMode() throws {
        let gen = FeedGenerator(namespaceMode: .explicit([.itunes]))
        let xml = try gen.generate(minimalFeed())
        #expect(xml.contains("xmlns:itunes="))
        #expect(!xml.contains("xmlns:atom="))
    }
}

// MARK: - RSS 2.0 Core Tests

struct FeedGeneratorRSSTests {

    @Test("Channel optional RSS fields")
    func channelOptionalRSSFields() throws {
        var ch = minimalChannel()
        ch.language = "en-us"
        ch.copyright = "Copyright 2025"
        ch.managingEditor = "editor@example.com"
        ch.webMaster = "webmaster@example.com" // swiftlint:disable:this inclusive_language
        ch.generator = "PodcastFeedMaker"
        ch.ttl = 60
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<language>en-us</language>"))
        #expect(xml.contains("<copyright>Copyright 2025</copyright>"))
        #expect(xml.contains("<managingEditor>editor@example.com</managingEditor>"))
        #expect(xml.contains("<webMaster>webmaster@example.com</webMaster>"))
        #expect(xml.contains("<generator>PodcastFeedMaker</generator>"))
        #expect(xml.contains("<ttl>60</ttl>"))
    }

    @Test("Channel dates formatted as RFC 2822")
    func channelDates() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 10
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)

        var ch = minimalChannel()
        ch.pubDate = date
        ch.lastBuildDate = date
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<pubDate>Wed, 15 Jan 2025 10:00:00 +0000</pubDate>"))
        #expect(xml.contains("<lastBuildDate>Wed, 15 Jan 2025 10:00:00 +0000</lastBuildDate>"))
    }

    @Test("RSS categories with and without domain")
    func rssCategories() throws {
        var ch = minimalChannel()
        ch.categories = [
            RSSCategory(value: "Technology"),
            RSSCategory(value: "News", domain: "https://example.com")
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<category>Technology</category>"))
        #expect(xml.contains(#"<category domain="https://example.com">News</category>"#))
    }

    @Test("RSS cloud element")
    func rssCloud() throws {
        var ch = minimalChannel()
        ch.cloud = RSSCloud(domain: "rpc.example.com", port: 80, path: "/RPC2", registerProcedure: "pingMe", protocolType: "soap")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<cloud domain="rpc.example.com" port="80" path="/RPC2" registerProcedure="pingMe" protocol="soap" />"#))
    }

    @Test("RSS image with all fields")
    func rssImage() throws {
        var ch = minimalChannel()
        ch.image = RSSImage(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Logo",
            link: URL(string: "https://example.com")!,
            width: 88,
            height: 31,
            imageDescription: "Podcast logo"
        )
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<image>"))
        #expect(xml.contains("<url>https://example.com/logo.png</url>"))
        #expect(xml.contains("<title>Logo</title>"))
        #expect(xml.contains("<width>88</width>"))
        #expect(xml.contains("<height>31</height>"))
        #expect(xml.contains("<description>Podcast logo</description>"))
        #expect(xml.contains("</image>"))
    }

    @Test("RSS text input element")
    func rssTextInput() throws {
        var ch = minimalChannel()
        ch.textInput = RSSTextInput(title: "Search", description: "Search this feed", name: "query", link: URL(string: "https://example.com/search")!)
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<textInput>"))
        #expect(xml.contains("<title>Search</title>"))
        #expect(xml.contains("<name>query</name>"))
        #expect(xml.contains("</textInput>"))
    }

    @Test("Skip schedule elements")
    func skipSchedule() throws {
        var ch = minimalChannel()
        ch.skipSchedule = SkipSchedule(hours: [0, 1, 2], days: [.saturday, .sunday])
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<skipHours>"))
        #expect(xml.contains("<hour>0</hour>"))
        #expect(xml.contains("<hour>1</hour>"))
        #expect(xml.contains("<hour>2</hour>"))
        #expect(xml.contains("</skipHours>"))
        #expect(xml.contains("<skipDays>"))
        #expect(xml.contains("<day>Saturday</day>"))
        #expect(xml.contains("<day>Sunday</day>"))
        #expect(xml.contains("</skipDays>"))
    }

    @Test("Item enclosure")
    func itemEnclosure() throws {
        var ch = minimalChannel()
        ch.items = [Item(enclosure: Enclosure(url: URL(string: "https://example.com/ep.mp3")!, length: 12345, type: "audio/mpeg"))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<enclosure url="https://example.com/ep.mp3" length="12345" type="audio/mpeg" />"#))
    }

    @Test("Item GUID")
    func itemGUID() throws {
        var ch = minimalChannel()
        ch.items = [Item(guid: GUID(value: "https://example.com/ep1", isPermaLink: true))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<guid isPermaLink="true">https://example.com/ep1</guid>"#))
    }

    @Test("Item source")
    func itemSource() throws {
        var ch = minimalChannel()
        ch.items = [Item(source: RSSSource(title: "Other Feed", url: URL(string: "https://other.com/feed.xml")!))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<source url="https://other.com/feed.xml">Other Feed</source>"#))
    }
}

// MARK: - iTunes Tests

struct FeedGeneratorITunesTests {

    @Test("Channel iTunes properties")
    func channelITunesProperties() throws {
        var ch = minimalChannel()
        ch.itunesAuthor = "John Doe"
        ch.itunesBlock = true
        ch.itunesComplete = true
        ch.itunesExplicit = true
        ch.itunesImage = URL(string: "https://example.com/art.jpg")!
        ch.itunesKeywords = ["swift", "development"]
        ch.itunesSubtitle = "A short subtitle"
        ch.itunesSummary = "A longer summary"
        ch.itunesTitle = "Title Override"
        ch.itunesType = .serial
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<itunes:author>John Doe</itunes:author>"))
        #expect(xml.contains("<itunes:block>yes</itunes:block>"))
        #expect(xml.contains("<itunes:complete>yes</itunes:complete>"))
        #expect(xml.contains("<itunes:explicit>true</itunes:explicit>"))
        #expect(xml.contains(#"<itunes:image href="https://example.com/art.jpg" />"#))
        #expect(xml.contains("<itunes:keywords>swift,development</itunes:keywords>"))
        #expect(xml.contains("<itunes:subtitle>A short subtitle</itunes:subtitle>"))
        #expect(xml.contains("<itunes:summary>A longer summary</itunes:summary>"))
        #expect(xml.contains("<itunes:title>Title Override</itunes:title>"))
        #expect(xml.contains("<itunes:type>serial</itunes:type>"))
    }

    @Test("itunes:explicit uses true/false format")
    func itunesExplicitFormat() throws {
        var chTrue = minimalChannel()
        chTrue.itunesExplicit = true
        let xmlTrue = try FeedGenerator().generate(minimalFeed(channel: chTrue))
        #expect(xmlTrue.contains("<itunes:explicit>true</itunes:explicit>"))

        var chFalse = minimalChannel()
        chFalse.itunesExplicit = false
        let xmlFalse = try FeedGenerator().generate(minimalFeed(channel: chFalse))
        #expect(xmlFalse.contains("<itunes:explicit>false</itunes:explicit>"))
    }

    @Test("iTunes owner element")
    func itunesOwner() throws {
        var ch = minimalChannel()
        ch.itunesOwner = ITunesOwner(name: "Jane Doe", email: "jane@example.com")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<itunes:owner>"))
        #expect(xml.contains("<itunes:name>Jane Doe</itunes:name>"))
        #expect(xml.contains("<itunes:email>jane@example.com</itunes:email>"))
        #expect(xml.contains("</itunes:owner>"))
    }

    @Test("iTunes categories with subcategories")
    func itunesCategories() throws {
        var ch = minimalChannel()
        ch.itunesCategories = [
            ITunesCategory(text: "Technology"),
            ITunesCategory(text: "News", subcategories: [ITunesCategory(text: "Tech News")])
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<itunes:category text="Technology" />"#))
        #expect(xml.contains(#"<itunes:category text="News">"#))
        #expect(xml.contains(#"<itunes:category text="Tech News" />"#))
    }

    @Test("iTunes new-feed-url")
    func itunesNewFeedUrl() throws {
        var ch = minimalChannel()
        ch.itunesNewFeedUrl = URL(string: "https://example.com/new-feed.xml")!
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<itunes:new-feed-url>https://example.com/new-feed.xml</itunes:new-feed-url>"))
    }

    @Test("Item iTunes properties")
    func itemITunesProperties() throws {
        var ch = minimalChannel()
        ch.items = [Item(
            itunesAuthor: "Author",
            itunesDuration: 3600,
            itunesEpisode: 5,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesSeason: 2,
            itunesSubtitle: "Sub",
            itunesTitle: "Ep Title"
        )]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<itunes:author>Author</itunes:author>"))
        #expect(xml.contains("<itunes:duration>3600</itunes:duration>"))
        #expect(xml.contains("<itunes:episode>5</itunes:episode>"))
        #expect(xml.contains("<itunes:episodeType>full</itunes:episodeType>"))
        #expect(xml.contains("<itunes:explicit>false</itunes:explicit>"))
        #expect(xml.contains("<itunes:season>2</itunes:season>"))
        #expect(xml.contains("<itunes:subtitle>Sub</itunes:subtitle>"))
        #expect(xml.contains("<itunes:title>Ep Title</itunes:title>"))
    }
}

// MARK: - Atom Tests

struct FeedGeneratorAtomTests {

    @Test("Atom self link")
    func atomSelfLink() throws {
        var ch = minimalChannel()
        ch.atomLinks = [AtomLink.selfLink(href: URL(string: "https://example.com/feed.xml")!)]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml" />"#))
    }

    @Test("Atom link with all attributes")
    func atomLinkFull() throws {
        var ch = minimalChannel()
        ch.atomLinks = [AtomLink(
            href: URL(string: "https://example.com")!,
            rel: "alternate",
            type: "text/html",
            hreflang: "en",
            title: "Website",
            length: 1024
        )]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"href="https://example.com""#))
        #expect(xml.contains(#"rel="alternate""#))
        #expect(xml.contains(#"type="text/html""#))
        #expect(xml.contains(#"hreflang="en""#))
        #expect(xml.contains(#"title="Website""#))
        #expect(xml.contains(#"length="1024""#))
    }
}

// MARK: - Dublin Core Tests

struct FeedGeneratorDublinCoreTests {

    @Test("Dublin Core all 15 properties")
    func dublinCoreAllProperties() throws {
        var ch = minimalChannel()
        ch.dublinCore = DublinCore(
            creator: "Creator",
            contributor: "Contributor",
            date: "2025-01-01",
            description: "DC Description",
            format: "audio/mpeg",
            identifier: "id-001",
            language: "en",
            publisher: "Publisher",
            relation: "related-resource",
            rights: "CC BY 4.0",
            source: "source-feed",
            subject: "Technology",
            title: "DC Title",
            type: "Sound",
            coverage: "Global"
        )
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<dc:creator>Creator</dc:creator>"))
        #expect(xml.contains("<dc:contributor>Contributor</dc:contributor>"))
        #expect(xml.contains("<dc:date>2025-01-01</dc:date>"))
        #expect(xml.contains("<dc:description>DC Description</dc:description>"))
        #expect(xml.contains("<dc:format>audio/mpeg</dc:format>"))
        #expect(xml.contains("<dc:identifier>id-001</dc:identifier>"))
        #expect(xml.contains("<dc:language>en</dc:language>"))
        #expect(xml.contains("<dc:publisher>Publisher</dc:publisher>"))
        #expect(xml.contains("<dc:relation>related-resource</dc:relation>"))
        #expect(xml.contains("<dc:rights>CC BY 4.0</dc:rights>"))
        #expect(xml.contains("<dc:source>source-feed</dc:source>"))
        #expect(xml.contains("<dc:subject>Technology</dc:subject>"))
        #expect(xml.contains("<dc:title>DC Title</dc:title>"))
        #expect(xml.contains("<dc:type>Sound</dc:type>"))
        #expect(xml.contains("<dc:coverage>Global</dc:coverage>"))
    }

    @Test("Dublin Core at item level")
    func dublinCoreItem() throws {
        var ch = minimalChannel()
        ch.items = [Item(dublinCore: DublinCore(creator: "Jane", subject: "AI"))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<dc:creator>Jane</dc:creator>"))
        #expect(xml.contains("<dc:subject>AI</dc:subject>"))
    }
}

// MARK: - Podcast NS 2.0 Tests

struct FeedGeneratorPodcastTests {

    @Test("Podcast GUID")
    func podcastGuid() throws {
        var ch = minimalChannel()
        ch.podcastGuid = PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>"))
    }

    @Test("Podcast locked")
    func podcastLocked() throws {
        var ch = minimalChannel()
        ch.locked = Locked(isLocked: true, owner: "owner@example.com")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:locked owner="owner@example.com">yes</podcast:locked>"#))
    }

    @Test("Podcast medium")
    func podcastMedium() throws {
        var ch = minimalChannel()
        ch.medium = .podcast
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:medium>podcast</podcast:medium>"))
    }

    @Test("Podcast funding")
    func podcastFunding() throws {
        var ch = minimalChannel()
        ch.funding = [Funding(url: URL(string: "https://example.com/donate")!, message: "Support Us")]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:funding url="https://example.com/donate">Support Us</podcast:funding>"#))
    }

    @Test("Podcast person")
    func podcastPerson() throws {
        var ch = minimalChannel()
        ch.persons = [PodcastPerson(
            name: "Jane Host",
            role: "host",
            group: "cast",
            href: URL(string: "https://example.com/jane")!,
            img: URL(string: "https://example.com/jane.jpg")!
        )]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:person role="host" group="cast""#))
        #expect(xml.contains(#"img="https://example.com/jane.jpg""#))
        #expect(xml.contains(">Jane Host</podcast:person>"))
    }

    @Test("Podcast location")
    func podcastLocation() throws {
        var ch = minimalChannel()
        ch.location = PodcastLocation(name: "Austin, TX", geo: "geo:30.2672,-97.7431", osm: "R113314")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:location geo="geo:30.2672,-97.7431" osm="R113314">Austin, TX</podcast:location>"#))
    }

    @Test("Podcast license with and without URL")
    func podcastLicense() throws {
        var ch = minimalChannel()
        ch.license = PodcastLicense(identifier: "cc-by-4.0", url: URL(string: "https://creativecommons.org/licenses/by/4.0/")!)
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:license url="https://creativecommons.org/licenses/by/4.0/">cc-by-4.0</podcast:license>"#))
    }

    @Test("Podcast value with recipients")
    func podcastValue() throws {
        var ch = minimalChannel()
        ch.value = PodcastValue(
            type: "lightning",
            method: "keysend",
            suggested: "0.00000005",
            recipients: [
                ValueRecipient(name: "Host", type: "node", address: "02d5c...", split: 90),
                ValueRecipient(type: "node", address: "03ae9...", split: 10, fee: true)
            ]
        )
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:value type="lightning" method="keysend" suggested="0.00000005">"#))
        #expect(xml.contains(#"<podcast:valueRecipient name="Host" type="node" address="02d5c..." split="90" />"#))
        #expect(xml.contains(#"type="node" address="03ae9..." split="10" fee="true" />"#))
        #expect(xml.contains("</podcast:value>"))
    }

    @Test("Podcast block with platform id")
    func podcastBlock() throws {
        var ch = minimalChannel()
        ch.podcastBlocks = [
            PodcastBlock(isBlocked: true, id: "google"),
            PodcastBlock(isBlocked: true)
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:block id="google">yes</podcast:block>"#))
        #expect(xml.contains("<podcast:block>yes</podcast:block>"))
    }

    @Test("Podcast txt records")
    func podcastTxt() throws {
        var ch = minimalChannel()
        ch.txtRecords = [
            PodcastTxt(value: "verify=abc123", purpose: "verify"),
            PodcastTxt(value: "some text")
        ]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:txt purpose="verify">verify=abc123</podcast:txt>"#))
        #expect(xml.contains("<podcast:txt>some text</podcast:txt>"))
    }

    @Test("Podcast podroll with remote items")
    func podcastPodroll() throws {
        var ch = minimalChannel()
        ch.podroll = Podroll(remoteItems: [
            RemoteItem(feedGuid: "abc-123", feedUrl: URL(string: "https://example.com/feed.xml")!),
            RemoteItem(feedGuid: "def-456")
        ])
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:podroll>"))
        #expect(xml.contains(#"<podcast:remoteItem feedGuid="abc-123" feedUrl="https://example.com/feed.xml" />"#))
        #expect(xml.contains(#"<podcast:remoteItem feedGuid="def-456" />"#))
        #expect(xml.contains("</podcast:podroll>"))
    }

    @Test("Podcast update frequency")
    func updateFrequency() throws {
        var ch = minimalChannel()
        ch.updateFrequency = UpdateFrequency(label: "Weekly on Fridays", rrule: "FREQ=WEEKLY;BYDAY=FR")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:updateFrequency rrule="FREQ=WEEKLY;BYDAY=FR">Weekly on Fridays</podcast:updateFrequency>"#))
    }

    @Test("Podcast podping")
    func podping() throws {
        var ch = minimalChannel()
        ch.podpingEnabled = true
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:podping>true</podcast:podping>"))
    }

    @Test("Podcast publisher")
    func publisher() throws {
        var ch = minimalChannel()
        ch.publisher = PodcastPublisher(name: "Network Name", guid: "pub-guid-123", url: URL(string: "https://network.com")!)
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:publisher guid="pub-guid-123" url="https://network.com">Network Name</podcast:publisher>"#))
    }

    @Test("Podcast chat")
    func chat() throws {
        var ch = minimalChannel()
        ch.chat = PodcastChat(server: "irc.zeronode.net", protocol: "irc", accountId: "host", space: "#podcast")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(##"<podcast:chat server="irc.zeronode.net" protocol="irc" accountId="host" space="#podcast" />"##))
    }

    @Test("Podcast trailer")
    func trailer() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 8
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        var ch = minimalChannel()
        ch.trailers = [Trailer(
            title: "Season 2 Trailer",
            url: URL(string: "https://example.com/trailer.mp3")!,
            pubDate: date,
            length: 12345678,
            type: "audio/mpeg",
            season: 2
        )]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:trailer url="https://example.com/trailer.mp3""#))
        #expect(xml.contains(#"pubdate="Wed, 01 Jan 2025 08:00:00 +0000""#))
        #expect(xml.contains(#"length="12345678""#))
        #expect(xml.contains(#"type="audio/mpeg""#))
        #expect(xml.contains(#"season="2""#))
        #expect(xml.contains(">Season 2 Trailer</podcast:trailer>"))
    }

    @Test("Podcast live item")
    func liveItem() throws {
        var components = DateComponents()
        components.year = 2025
        components.month = 6
        components.day = 15
        components.hour = 14
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.date(from: components)!

        var ch = minimalChannel()
        ch.liveItems = [PodcastLiveItem(
            status: .live,
            start: startDate,
            title: "Live Show",
            enclosure: Enclosure(url: URL(string: "https://example.com/live.mp3")!, length: 0, type: "audio/mpeg"),
            contentLinks: [ContentLink(href: URL(string: "https://example.com/chat")!, title: "Chat Room")]
        )]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:liveItem status="live" start="2025-06-15T14:00:00Z">"#))
        #expect(xml.contains("<title>Live Show</title>"))
        #expect(xml.contains(#"<podcast:contentLink href="https://example.com/chat">Chat Room</podcast:contentLink>"#))
        #expect(xml.contains("</podcast:liveItem>"))
    }

    @Test("Item transcripts")
    func transcripts() throws {
        var ch = minimalChannel()
        ch.items = [Item(transcripts: [
            Transcript(url: URL(string: "https://example.com/t.vtt")!, type: "text/vtt", language: "en")
        ])]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:transcript url="https://example.com/t.vtt" type="text/vtt" language="en" />"#))
    }

    @Test("Item chapters link")
    func chaptersLink() throws {
        var ch = minimalChannel()
        ch.items = [Item(chaptersLink: ChaptersLink(url: URL(string: "https://example.com/chapters.json")!))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:chapters url="https://example.com/chapters.json" type="application/json+chapters" />"#))
    }

    @Test("Item soundbites")
    func soundbites() throws {
        var ch = minimalChannel()
        ch.items = [Item(soundbites: [
            Soundbite(startTime: 30.5, duration: 60.0, title: "Best Moment"),
            Soundbite(startTime: 120.0, duration: 45.0)
        ])]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:soundbite startTime="30.5" duration="60.0">Best Moment</podcast:soundbite>"#))
        #expect(xml.contains(#"<podcast:soundbite startTime="120.0" duration="45.0" />"#))
    }

    @Test("Item alternate enclosure with source and integrity")
    func alternateEnclosure() throws {
        var ch = minimalChannel()
        ch.items = [Item(alternateEnclosures: [AlternateEnclosure(
            type: "audio/opus",
            length: 54321,
            bitrate: 128000,
            title: "High Quality",
            isDefault: true,
            sources: [PodcastSource(uri: "https://example.com/ep.opus")],
            integrity: PodcastIntegrity(type: "sri", value: "sha256-abc123")
        )])]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:alternateEnclosure type="audio/opus" length="54321" bitrate="128000" title="High Quality" default="true">"#))
        #expect(xml.contains(#"<podcast:source uri="https://example.com/ep.opus" />"#))
        #expect(xml.contains(#"<podcast:integrity type="sri" value="sha256-abc123" />"#))
        #expect(xml.contains("</podcast:alternateEnclosure>"))
    }

    @Test("Item social interact")
    func socialInteract() throws {
        var ch = minimalChannel()
        ch.items = [Item(socialInteractions: [SocialInteract(
            uri: "https://mastodon.social/@host/12345",
            protocol: "activitypub",
            accountId: "@host@mastodon.social",
            accountUrl: URL(string: "https://mastodon.social/@host")!,
            priority: 1
        )])]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:socialInteract uri="https://mastodon.social/@host/12345" protocol="activitypub""#))
        #expect(xml.contains(#"accountId="@host@mastodon.social""#))
        #expect(xml.contains(#"priority="1""#))
    }

    @Test("Item podcast season and episode")
    func podcastSeasonEpisode() throws {
        var ch = minimalChannel()
        ch.items = [Item(
            podcastSeason: PodcastSeason(number: 3, name: "Mysteries"),
            podcastEpisode: PodcastEpisode(number: 5, display: "EP5")
        )]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:season name="Mysteries">3</podcast:season>"#))
        #expect(xml.contains(#"<podcast:episode display="EP5">5</podcast:episode>"#))
    }

    @Test("Podcast episode with decimal number")
    func podcastEpisodeDecimal() throws {
        var ch = minimalChannel()
        ch.items = [Item(podcastEpisode: PodcastEpisode(number: 3.5))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<podcast:episode>3.5</podcast:episode>"))
    }

    @Test("Value time split with remote item")
    func valueTimeSplit() throws {
        var ch = minimalChannel()
        ch.items = [Item(value: PodcastValue(
            type: "lightning",
            method: "keysend",
            recipients: [ValueRecipient(type: "node", address: "addr1", split: 100)],
            timeSplits: [ValueTimeSplit(
                startTime: 60.0,
                duration: 120.0,
                recipients: [ValueRecipient(type: "node", address: "addr2", split: 50)],
                remoteItem: RemoteItem(feedGuid: "remote-guid"),
                remotePercentage: 75
            )]
        ))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<podcast:valueTimeSplit startTime="60.0" duration="120.0" remotePercentage="75">"#))
        #expect(xml.contains(#"<podcast:remoteItem feedGuid="remote-guid" />"#))
        #expect(xml.contains("</podcast:valueTimeSplit>"))
    }
}

// MARK: - Podlove Tests

struct FeedGeneratorPodloveTests {

    @Test("Podlove Simple Chapters")
    func podloveChapters() throws {
        var ch = minimalChannel()
        ch.items = [Item(podloveChapters: PodloveChapters(
            version: "1.2",
            chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Intro"),
                PodloveChapter(start: "00:05:30.000", title: "Main Topic",
                               href: URL(string: "https://example.com/topic")!,
                               image: URL(string: "https://example.com/img.jpg")!)
            ]
        ))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<psc:chapters version="1.2">"#))
        #expect(xml.contains(#"<psc:chapter start="00:00:00.000" title="Intro" />"#))
        #expect(xml.contains(#"<psc:chapter start="00:05:30.000" title="Main Topic" href="https://example.com/topic" image="https://example.com/img.jpg" />"#))
        #expect(xml.contains("</psc:chapters>"))
    }
}

// MARK: - Content Module Tests

struct FeedGeneratorContentTests {

    @Test("content:encoded always uses CDATA")
    func contentEncodedCDATA() throws {
        var ch = minimalChannel()
        ch.items = [Item(contentEncoded: ContentEncoded(value: "<p>Hello <strong>World</strong></p>"))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<content:encoded><![CDATA[<p>Hello <strong>World</strong></p>]]></content:encoded>"))
    }
}

// MARK: - CDATA Strategy Tests

struct FeedGeneratorCDATATests {

    @Test("Description with HTML uses CDATA")
    func descriptionHTMLCDATA() throws {
        var ch = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "<p>HTML description</p>"
        )
        ch.items = []
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<description><![CDATA[<p>HTML description</p>]]></description>"))
    }

    @Test("Description without HTML uses escaping")
    func descriptionPlainEscapes() throws {
        var ch = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "Tom & Jerry podcast"
        )
        ch.items = []
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<description>Tom &amp; Jerry podcast</description>"))
    }
}

// MARK: - Special Character Tests

struct FeedGeneratorSpecialCharTests {

    @Test("Special characters in content are escaped")
    func specialCharsEscaped() throws {
        var ch = Channel(
            title: "Tom & Jerry © 2025",
            link: URL(string: "https://example.com")!,
            description: "A show about ™ brands"
        )
        ch.items = []
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<title>Tom &amp; Jerry &#xA9; 2025</title>"))
        #expect(xml.contains("A show about &#x2122; brands"))
    }
}

// MARK: - Empty/Nil Fields Tests

struct FeedGeneratorOmissionTests {

    @Test("Nil optional fields are omitted")
    func nilFieldsOmitted() throws {
        let xml = try FeedGenerator().generate(minimalFeed())
        #expect(!xml.contains("<language>"))
        #expect(!xml.contains("<copyright>"))
        #expect(!xml.contains("<itunes:author>"))
        #expect(!xml.contains("<podcast:guid>"))
        #expect(!xml.contains("<dc:creator>"))
    }

    @Test("Empty arrays produce no elements")
    func emptyArraysOmitted() throws {
        let xml = try FeedGenerator().generate(minimalFeed())
        #expect(!xml.contains("<item>"))
        #expect(!xml.contains("<itunes:category"))
        #expect(!xml.contains("<podcast:funding"))
    }
}
