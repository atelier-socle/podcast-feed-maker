import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Feed Generator Showcase

/// Comprehensive showcase of every public API in the Generator layer.
/// Each test is self-contained and demonstrates one feature with realistic data.
@Suite("Feed Generator Showcase")
struct GeneratorShowcase {

    // MARK: - Helpers

    /// Builds a minimal valid feed for tests that only need a feed skeleton.
    private static func minimalFeed(
        namespaces: [PodcastNamespace] = [],
        items: [Item] = []
    ) throws -> PodcastFeed {
        let channel = Channel(
            title: "Minimal Podcast",
            link: makeURL("https://example.com"),
            description: "A minimal test feed.",
            items: items
        )
        return PodcastFeed(version: "2.0", namespaces: namespaces, channel: channel)
    }

    /// Builds a rich feed with iTunes, Atom, Podcast NS 2.0, DC, Content, and Podlove data.
    private static func richItem() -> Item {
        Item(
            title: "Episode 1: Getting Started",
            link: URL(string: "https://example.com/ep1"),
            description: "The very first episode.",
            enclosure: Enclosure(
                url: makeURL("https://cdn.example.com/ep1.mp3"),
                length: 48_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-001", isPermaLink: false),
            itunesAuthor: "Jane Host",
            itunesDuration: 1800,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/ep1.jpg"),
            itunesSeason: 1,
            itunesSubtitle: "Pilot episode",
            dublinCore: DublinCore(creator: "Jane Host"),
            contentEncoded: ContentEncoded(value: "<p>Full <strong>show notes</strong> here.</p>"),
            transcripts: [
                Transcript(
                    url: makeURL("https://example.com/ep1.vtt"),
                    type: "text/vtt",
                    language: "en"
                )
            ],
            chaptersLink: ChaptersLink(
                url: makeURL("https://example.com/ep1/chapters.json")
            ),
            soundbites: [
                Soundbite(startTime: 120.0, duration: 45.0, title: "Best moment")
            ],
            persons: [
                PodcastPerson(
                    name: "Jane Host",
                    role: "host",
                    group: "cast",
                    href: URL(string: "https://example.com/jane"),
                    img: URL(string: "https://cdn.example.com/jane.jpg")
                )
            ],
            podloveChapters: PodloveChapters(
                version: "1.2",
                chapters: [
                    PodloveChapter(start: "00:00:00.000", title: "Intro"),
                    PodloveChapter(
                        start: "00:05:30.000",
                        title: "Main Topic",
                        href: URL(string: "https://example.com/topic")
                    )
                ]
            )
        )

    }

    private static func richFeed() -> PodcastFeed {
        let channel = Channel(
            title: "The Showcase Podcast",
            link: makeURL("https://example.com"),
            description: "A podcast demonstrating PodcastFeedMaker.",
            language: "en-US",
            copyright: "2026 Atelier Socle",
            managingEditor: "editor@example.com (Editor)",
            pubDate: Date(timeIntervalSince1970: 1_739_404_800),  // 2025-02-13
            lastBuildDate: Date(timeIntervalSince1970: 1_739_404_800),
            generator: "PodcastFeedMaker/1.0",
            ttl: 60,
            items: [richItem()],
            itunesAuthor: "Atelier Socle",
            itunesCategories: [
                .technology,
                .education(.selfImprovement)
            ],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/artwork.jpg"),
            itunesOwner: ITunesOwner(name: "Wlad", email: "wlad@example.com"),
            itunesType: .episodic,
            atomLinks: [
                AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))
            ],
            dublinCore: DublinCore(creator: "Atelier Socle", language: "en"),
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "wlad@example.com"),
            funding: [
                Funding(
                    url: makeURL("https://example.com/donate"),
                    message: "Support the show"
                )
            ],
            persons: [
                PodcastPerson(name: "Wlad", role: "host", group: "cast")
            ]
        )

        return PodcastFeed(
            version: "2.0",
            namespaces: PodcastNamespace.allStandard,
            channel: channel
        )
    }

    // MARK: - FeedGenerator — Synchronous Generation

    @Test("FeedGenerator — synchronous full XML generation")
    func feedGeneratorSynchronous() throws {
        let feed = Self.richFeed()
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<?xml"))
        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>The Showcase Podcast</title>"))
        #expect(xml.contains("<item>"))
        #expect(xml.contains("<title>Episode 1: Getting Started</title>"))
        #expect(xml.contains("</channel>"))
        #expect(xml.contains("</rss>"))
    }

    @Test("FeedGenerator — pretty-print output with indentation")
    func feedGeneratorPrettyPrint() throws {
        let feed = try Self.minimalFeed()
        let generator = FeedGenerator(prettyPrint: true)
        let xml = try generator.generate(feed)

        // Pretty-print uses tab indentation and newlines
        #expect(xml.contains("\n"))
        #expect(xml.contains("\t<channel>"))
        #expect(xml.contains("\t\t<title>Minimal Podcast</title>"))
    }

    @Test("FeedGenerator — minified output without unnecessary whitespace")
    func feedGeneratorMinified() throws {
        let feed = try Self.minimalFeed()
        let generator = FeedGenerator(prettyPrint: false)
        let xml = try generator.generate(feed)

        // Minified: no newlines between elements, no tabs
        #expect(!xml.contains("\n"))
        #expect(!xml.contains("\t"))
        #expect(xml.contains("<channel><title>Minimal Podcast</title>"))
    }

    // MARK: - Namespace Modes

    @Test("FeedGenerator — automatic namespace detection includes only used namespaces")
    func feedGeneratorAutoNamespace() throws {
        // Feed uses only iTunes features, no podcast NS, no DC, etc.
        let channel = Channel(
            title: "iTunes Only Show",
            link: makeURL("https://example.com"),
            description: "Only iTunes tags.",
            itunesAuthor: "Host",
            itunesExplicit: false
        )
        let feed = PodcastFeed(
            version: "2.0",
            namespaces: PodcastNamespace.allStandard,
            channel: channel
        )

        let generator = FeedGenerator(namespaceMode: .auto)
        let xml = try generator.generate(feed)

        // Should declare itunes namespace since itunesAuthor is set
        #expect(xml.contains("xmlns:itunes="))
        // Should NOT declare podcast, content, dc, psc, atom
        #expect(!xml.contains("xmlns:podcast="))
        #expect(!xml.contains("xmlns:content="))
        #expect(!xml.contains("xmlns:dc="))
        #expect(!xml.contains("xmlns:psc="))
        #expect(!xml.contains("xmlns:atom="))
    }

    @Test("FeedGenerator — feedDefined namespace mode uses feed.namespaces as-is")
    func feedGeneratorFeedDefinedNamespace() throws {
        let feed = try Self.minimalFeed(namespaces: [.itunes, .atom])
        let generator = FeedGenerator(namespaceMode: .feedDefined)
        let xml = try generator.generate(feed)

        #expect(xml.contains("xmlns:itunes="))
        #expect(xml.contains("xmlns:atom="))
        #expect(!xml.contains("xmlns:podcast="))
        #expect(!xml.contains("xmlns:dc="))
    }

    @Test("FeedGenerator — explicit namespace mode uses specified namespaces")
    func feedGeneratorExplicitNamespace() throws {
        let feed = try Self.minimalFeed(namespaces: PodcastNamespace.allStandard)
        let generator = FeedGenerator(namespaceMode: .explicit([.podcast, .dublinCore]))
        let xml = try generator.generate(feed)

        #expect(xml.contains("xmlns:podcast="))
        #expect(xml.contains("xmlns:dc="))
        #expect(!xml.contains("xmlns:itunes="))
        #expect(!xml.contains("xmlns:atom="))
    }

    @Test("FeedGenerator — parsed namespace mode preserves original prefixes")
    func feedGeneratorParsedNamespace() throws {
        var feed = try Self.minimalFeed(namespaces: [.itunes])
        feed.namespacePrefixes = [
            "apple": "http://www.itunes.com/dtds/podcast-1.0.dtd",
            "ns2": "https://podcastindex.org/namespace/1.0"
        ]

        let generator = FeedGenerator(namespaceMode: .parsed)
        let xml = try generator.generate(feed)

        // The parsed mode should use the custom prefix names
        #expect(xml.contains("xmlns:apple=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""))
        #expect(xml.contains("xmlns:ns2=\"https://podcastindex.org/namespace/1.0\""))
    }

    // MARK: - CDATA and Escaping

    @Test("FeedGenerator — CDATA wrapping for HTML content in content:encoded")
    func feedGeneratorCDATA() throws {
        let item = Item(
            title: "HTML Episode",
            contentEncoded: ContentEncoded(value: "<p>Rich <em>notes</em>.</p>")
        )
        let feed = try Self.minimalFeed(namespaces: [.content], items: [item])
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<content:encoded><![CDATA[<p>Rich <em>notes</em>.</p>]]></content:encoded>"))
    }

    @Test("FeedGenerator — CDATA wrapping for description when cdataFields is set")
    func feedGeneratorCDATAForDescription() throws {
        let item = Item(
            title: "CDATA Description",
            description: "<b>Bold</b> text",
            cdataFields: ["description"]
        )
        let feed = try Self.minimalFeed(items: [item])
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<description><![CDATA[<b>Bold</b> text]]></description>"))
    }

    @Test("FeedGenerator — proper XML escaping of special characters")
    func feedGeneratorXMLEscaping() throws {
        let channel = Channel(
            title: "Rock & Roll <Live> \"Special\" Edition",
            link: makeURL("https://example.com"),
            description: "A show about R&B music."
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("Rock &amp; Roll &lt;Live&gt; &quot;Special&quot; Edition"))
        #expect(xml.contains("R&amp;B music"))
    }

    // MARK: - XML Declaration

    @Test("FeedGenerator — XML declaration with encoding")
    func feedGeneratorXMLDeclaration() throws {
        let feed = try Self.minimalFeed()
        let generator = FeedGenerator(includeXMLDeclaration: true, encoding: "UTF-8")
        let xml = try generator.generate(feed)

        #expect(xml.hasPrefix("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
    }

    @Test("FeedGenerator — XML declaration omission")
    func feedGeneratorNoXMLDeclaration() throws {
        let feed = try Self.minimalFeed()
        let generator = FeedGenerator(includeXMLDeclaration: false)
        let xml = try generator.generate(feed)

        #expect(!xml.contains("<?xml"))
        #expect(xml.hasPrefix("<rss"))
    }

    @Test("FeedGenerator — custom encoding in declaration")
    func feedGeneratorCustomEncoding() throws {
        let feed = try Self.minimalFeed()
        let generator = FeedGenerator(encoding: "ISO-8859-1")
        let xml = try generator.generate(feed)

        #expect(xml.contains("encoding=\"ISO-8859-1\""))
    }

    // MARK: - All 7 Namespaces

    @Test("FeedGenerator — generate feed with all 7 namespaces declared")
    func feedGeneratorAllNamespaces() throws {
        let feed = Self.richFeed()
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        // All 6 standard namespace declarations (RSS 2.0 core has no prefix)
        #expect(xml.contains("xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""))
        #expect(xml.contains("xmlns:atom=\"http://www.w3.org/2005/Atom\""))
        #expect(xml.contains("xmlns:podcast=\"https://podcastindex.org/namespace/1.0\""))
        #expect(xml.contains("xmlns:dc=\"http://purl.org/dc/elements/1.1/\""))
        #expect(xml.contains("xmlns:content=\"http://purl.org/rss/1.0/modules/content/\""))
        #expect(xml.contains("xmlns:psc=\"http://podlove.org/simple-chapters\""))
    }

    // MARK: - Minimal RSS 2.0

    @Test("FeedGenerator — generate minimal RSS 2.0 only feed with no namespaces")
    func feedGeneratorMinimalRSS() throws {
        let feed = try Self.minimalFeed(namespaces: [])
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<rss version=\"2.0\">"))
        #expect(!xml.contains("xmlns:"))
        #expect(xml.contains("<title>Minimal Podcast</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<description>A minimal test feed.</description>"))
    }

    // MARK: - All 7 Namespaces (continued in GeneratorITunesShowcase)
}

// MARK: - Feed Generator iTunes & Large Feed Showcase

@Suite("Feed Generator iTunes & Large Feed Showcase")
struct GeneratorITunesShowcase {

    /// Builds a minimal valid feed for tests that only need a feed skeleton.
    private static func minimalFeed(
        namespaces: [PodcastNamespace] = [],
        items: [Item] = []
    ) throws -> PodcastFeed {
        let channel = Channel(
            title: "Minimal Podcast",
            link: makeURL("https://example.com"),
            description: "A minimal test feed.",
            items: items
        )
        return PodcastFeed(version: "2.0", namespaces: namespaces, channel: channel)
    }

    // MARK: - Large Feed

    @Test("FeedGenerator — generate feed with 100+ episodes")
    func feedGeneratorManyEpisodes() throws {
        var items: [Item] = []
        for idx in 1...120 {
            items.append(
                Item(
                    title: "Episode \(idx)",
                    enclosure: Enclosure(
                        url: try #require(URL(string: "https://cdn.example.com/ep\(idx).mp3")),
                        length: 30_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-\(idx)", isPermaLink: false)
                ))
        }

        let feed = try Self.minimalFeed(items: items)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        // Verify all 120 episodes are present
        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<title>Episode 60</title>"))
        #expect(xml.contains("<title>Episode 120</title>"))

        // Count item open tags
        let itemCount = xml.components(separatedBy: "<item>").count - 1
        #expect(itemCount == 120)
    }

    // MARK: - iTunes Elements

    @Test("FeedGenerator — iTunes category with subcategory")
    func feedGeneratorITunesCategory() throws {
        let channel = Channel(
            title: "Cat Show",
            link: makeURL("https://example.com"),
            description: "Categories.",
            itunesCategories: [
                ITunesCategory(
                    text: "Technology",
                    subcategories: [ITunesCategory(text: "Podcasting")]
                )
            ]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<itunes:category text=\"Technology\">"))
        #expect(xml.contains("<itunes:category text=\"Podcasting\""))
    }

    @Test("FeedGenerator — iTunes owner with name and email")
    func feedGeneratorITunesOwner() throws {
        let channel = Channel(
            title: "Owner Show",
            link: makeURL("https://example.com"),
            description: "Owner test.",
            itunesOwner: ITunesOwner(name: "Jane", email: "jane@example.com")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<itunes:owner>"))
        #expect(xml.contains("<itunes:name>Jane</itunes:name>"))
        #expect(xml.contains("<itunes:email>jane@example.com</itunes:email>"))
        #expect(xml.contains("</itunes:owner>"))
    }

    @Test("FeedGenerator — iTunes explicit uses true/false not yes/no")
    func feedGeneratorITunesExplicit() throws {
        let channel = Channel(
            title: "Explicit Show",
            link: makeURL("https://example.com"),
            description: "Explicit test.",
            itunesExplicit: true
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<itunes:explicit>true</itunes:explicit>"))
    }

    @Test("FeedGenerator — iTunes block uses yes/no not true/false")
    func feedGeneratorITunesBlock() throws {
        let channel = Channel(
            title: "Block Show",
            link: makeURL("https://example.com"),
            description: "Block test.",
            itunesBlock: true
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<itunes:block>yes</itunes:block>"))
    }

    @Test("FeedGenerator — iTunes show type")
    func feedGeneratorITunesType() throws {
        let channel = Channel(
            title: "Serial Show",
            link: makeURL("https://example.com"),
            description: "Serial.",
            itunesType: .serial
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<itunes:type>serial</itunes:type>"))
    }
}
