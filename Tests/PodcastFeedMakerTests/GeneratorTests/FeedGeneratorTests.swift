import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Helpers

private func minimalChannel() -> Channel {
    Channel(
        title: "Test Podcast",
        link: makeURL("https://example.com"),
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
        ch.webMaster = "webmaster@example.com"
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
        let imageURL = makeURL("https://example.com/logo.png")
        let linkURL = makeURL("https://example.com")
        ch.image = RSSImage(
            url: imageURL,
            title: "Logo",
            link: linkURL,
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
        let searchURL = makeURL("https://example.com/search")
        ch.textInput = RSSTextInput(title: "Search", description: "Search this feed", name: "query", link: searchURL)
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
        let encURL = makeURL("https://example.com/ep.mp3")
        ch.items = [Item(enclosure: Enclosure(url: encURL, length: 12345, type: "audio/mpeg"))]
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
        let sourceURL = makeURL("https://other.com/feed.xml")
        ch.items = [Item(source: RSSSource(title: "Other Feed", url: sourceURL))]
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
        ch.itunesImage = makeURL("https://example.com/art.jpg")
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
        ch.itunesNewFeedUrl = makeURL("https://example.com/new-feed.xml")
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<itunes:new-feed-url>https://example.com/new-feed.xml</itunes:new-feed-url>"))
    }

    @Test("Item iTunes properties")
    func itemITunesProperties() throws {
        var ch = minimalChannel()
        ch.items = [
            Item(
                itunesAuthor: "Author",
                itunesDuration: 3600,
                itunesEpisode: 5,
                itunesEpisodeType: .full,
                itunesExplicit: false,
                itunesSeason: 2,
                itunesSubtitle: "Sub",
                itunesTitle: "Ep Title"
            )
        ]
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
        let selfURL = makeURL("https://example.com/feed.xml")
        ch.atomLinks = [AtomLink.selfLink(href: selfURL)]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains(#"<atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml" />"#))
    }

    @Test("Atom link with all attributes")
    func atomLinkFull() throws {
        var ch = minimalChannel()
        let linkURL = makeURL("https://example.com")
        ch.atomLinks = [
            AtomLink(
                href: linkURL,
                rel: "alternate",
                type: "text/html",
                hreflang: "en",
                title: "Website",
                length: 1024
            )
        ]
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
