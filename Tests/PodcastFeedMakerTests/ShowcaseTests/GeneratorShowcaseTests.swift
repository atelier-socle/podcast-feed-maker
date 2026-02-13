// swiftlint:disable file_length
import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Feed Generator Showcase

/// Comprehensive showcase of every public API in the Generator layer.
/// Each test is self-contained and demonstrates one feature with realistic data.
@Suite("Feed Generator Showcase")
struct GeneratorShowcase { // swiftlint:disable:this type_body_length

    // MARK: - Helpers

    /// Builds a minimal valid feed for tests that only need a feed skeleton.
    private static func minimalFeed(
        namespaces: [PodcastNamespace] = [],
        items: [Item] = []
    ) throws -> PodcastFeed {
        let channel = Channel(
            title: "Minimal Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A minimal test feed.",
            items: items
        )
        return PodcastFeed(version: "2.0", namespaces: namespaces, channel: channel)
    }

    /// Builds a rich feed with iTunes, Atom, Podcast NS 2.0, DC, Content, and Podlove data.
    private static func richFeed() throws -> PodcastFeed { // swiftlint:disable:this function_body_length
        let episode = Item(
            title: "Episode 1: Getting Started",
            link: URL(string: "https://example.com/ep1"),
            description: "The very first episode.",
            enclosure: Enclosure(
                url: try #require(URL(string: "https://cdn.example.com/ep1.mp3")),
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
                    url: try #require(URL(string: "https://example.com/ep1.vtt")),
                    type: "text/vtt",
                    language: "en"
                )
            ],
            chaptersLink: ChaptersLink(
                url: try #require(URL(string: "https://example.com/ep1/chapters.json"))
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

        let channel = Channel(
            title: "The Showcase Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A podcast demonstrating PodcastFeedMaker.",
            language: "en-US",
            copyright: "2026 Atelier Socle",
            managingEditor: "editor@example.com (Editor)",
            pubDate: Date(timeIntervalSince1970: 1_739_404_800), // 2025-02-13
            lastBuildDate: Date(timeIntervalSince1970: 1_739_404_800),
            generator: "PodcastFeedMaker/1.0",
            ttl: 60,
            items: [episode],
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
                AtomLink.selfLink(href: try #require(URL(string: "https://example.com/feed.xml")))
            ],
            dublinCore: DublinCore(creator: "Atelier Socle", language: "en"),
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "wlad@example.com"),
            funding: [
                Funding(
                    url: try #require(URL(string: "https://example.com/donate")),
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
        let feed = try Self.richFeed()
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
            link: try #require(URL(string: "https://example.com")),
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
            link: try #require(URL(string: "https://example.com")),
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
        let feed = try Self.richFeed()
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

    // MARK: - Large Feed

    @Test("FeedGenerator — generate feed with 100+ episodes")
    func feedGeneratorManyEpisodes() throws {
        var items: [Item] = []
        for idx in 1...120 {
            items.append(Item(
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
            link: try #require(URL(string: "https://example.com")),
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
            link: try #require(URL(string: "https://example.com")),
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
            link: try #require(URL(string: "https://example.com")),
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
            link: try #require(URL(string: "https://example.com")),
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
            link: try #require(URL(string: "https://example.com")),
            description: "Serial.",
            itunesType: .serial
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)

        #expect(xml.contains("<itunes:type>serial</itunes:type>"))
    }

    // MARK: - Podcast Namespace 2.0 Elements

    @Test("FeedGenerator — podcast:guid element")
    func feedGeneratorPodcastGuid() throws {
        let channel = Channel(
            title: "GUID Show",
            link: try #require(URL(string: "https://example.com")),
            description: "GUID test.",
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>"))
    }

    @Test("FeedGenerator — podcast:locked element")
    func feedGeneratorPodcastLocked() throws {
        let channel = Channel(
            title: "Locked Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Locked test.",
            locked: Locked(isLocked: true, owner: "lock@example.com")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains("lock@example.com"))
        #expect(xml.contains("yes"))
    }

    @Test("FeedGenerator — podcast:funding element")
    func feedGeneratorFunding() throws {
        let channel = Channel(
            title: "Funded Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Funding test.",
            funding: [Funding(url: try #require(URL(string: "https://example.com/donate")), message: "Buy us a coffee")]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:funding"))
        #expect(xml.contains("https://example.com/donate"))
        #expect(xml.contains("Buy us a coffee"))
    }

    @Test("FeedGenerator — podcast:person element")
    func feedGeneratorPodcastPerson() throws {
        let channel = Channel(
            title: "Person Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Person test.",
            persons: [
                PodcastPerson(
                    name: "Alice",
                    role: "guest",
                    group: "cast",
                    href: URL(string: "https://example.com/alice"),
                    img: URL(string: "https://cdn.example.com/alice.jpg")
                )
            ]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:person"))
        #expect(xml.contains("Alice"))
        #expect(xml.contains("role=\"guest\""))
    }

    // MARK: - Atom Links

    @Test("FeedGenerator — atom:link self element")
    func feedGeneratorAtomSelfLink() throws {
        let channel = Channel(
            title: "Atom Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Atom test.",
            atomLinks: [AtomLink.selfLink(href: try #require(URL(string: "https://example.com/feed.xml")))]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.atom], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("atom:link"))
        #expect(xml.contains("href=\"https://example.com/feed.xml\""))
        #expect(xml.contains("rel=\"self\""))
        #expect(xml.contains("type=\"application/rss+xml\""))
    }

    // MARK: - Dublin Core

    @Test("FeedGenerator — Dublin Core elements")
    func feedGeneratorDublinCore() throws {
        let channel = Channel(
            title: "DC Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Dublin Core test.",
            dublinCore: DublinCore(
                creator: "Author One",
                language: "en-US",
                rights: "Copyright 2026"
            )
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.dublinCore], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<dc:creator>Author One</dc:creator>"))
        #expect(xml.contains("<dc:language>en-US</dc:language>"))
        #expect(xml.contains("<dc:rights>Copyright 2026</dc:rights>"))
    }

    // MARK: - Podlove Simple Chapters

    @Test("FeedGenerator — Podlove Simple Chapters in item")
    func feedGeneratorPodloveChapters() throws {
        let item = Item(
            title: "Chapters Episode",
            podloveChapters: PodloveChapters(chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Intro"),
                PodloveChapter(
                    start: "00:10:00.000",
                    title: "Interview",
                    href: URL(string: "https://example.com/guest")
                )
            ])
        )
        let feed = try Self.minimalFeed(namespaces: [.podloveSimpleChapters], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("psc:chapters"))
        #expect(xml.contains("psc:chapter"))
        #expect(xml.contains("start=\"00:00:00.000\""))
        #expect(xml.contains("title=\"Intro\""))
        #expect(xml.contains("start=\"00:10:00.000\""))
    }

    // MARK: - Item-Level Elements

    @Test("FeedGenerator — enclosure element with all attributes")
    func feedGeneratorEnclosure() throws {
        let item = Item(
            title: "Enclosure Test",
            enclosure: Enclosure(
                url: try #require(URL(string: "https://cdn.example.com/ep.mp3")),
                length: 24_576_000,
                type: "audio/mpeg"
            )
        )
        let feed = try Self.minimalFeed(items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("url=\"https://cdn.example.com/ep.mp3\""))
        #expect(xml.contains("length=\"24576000\""))
        #expect(xml.contains("type=\"audio/mpeg\""))
    }

    @Test("FeedGenerator — GUID with isPermaLink attribute")
    func feedGeneratorGUID() throws {
        let item = Item(
            title: "GUID Test",
            guid: GUID(value: "unique-id-42", isPermaLink: false)
        )
        let feed = try Self.minimalFeed(items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<guid isPermaLink=\"false\">unique-id-42</guid>"))
    }

    @Test("FeedGenerator — podcast:transcript element")
    func feedGeneratorTranscript() throws {
        let item = Item(
            title: "Transcript Test",
            transcripts: [
                Transcript(
                    url: try #require(URL(string: "https://example.com/captions.vtt")),
                    type: "text/vtt",
                    language: "en",
                    rel: "captions"
                )
            ]
        )
        let feed = try Self.minimalFeed(namespaces: [.podcast], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:transcript"))
        #expect(xml.contains("url=\"https://example.com/captions.vtt\""))
        #expect(xml.contains("type=\"text/vtt\""))
        #expect(xml.contains("language=\"en\""))
        #expect(xml.contains("rel=\"captions\""))
    }

    @Test("FeedGenerator — podcast:soundbite element")
    func feedGeneratorSoundbite() throws {
        let item = Item(
            title: "Soundbite Test",
            soundbites: [
                Soundbite(startTime: 73.0, duration: 60.0, title: "Great moment")
            ]
        )
        let feed = try Self.minimalFeed(namespaces: [.podcast], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:soundbite"))
        #expect(xml.contains("startTime=\"73.0\""))
        #expect(xml.contains("duration=\"60.0\""))
        #expect(xml.contains("Great moment"))
    }

    @Test("FeedGenerator — podcast:chapters link element")
    func feedGeneratorChaptersLink() throws {
        let item = Item(
            title: "Chapters Test",
            chaptersLink: ChaptersLink(
                url: try #require(URL(string: "https://example.com/ch.json")),
                type: "application/json+chapters"
            )
        )
        let feed = try Self.minimalFeed(namespaces: [.podcast], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:chapters"))
        #expect(xml.contains("url=\"https://example.com/ch.json\""))
        #expect(xml.contains("type=\"application/json+chapters\""))
    }

    // MARK: - Round-Trip Preservation

    @Test("FeedGenerator — unknown elements preserved in output")
    func feedGeneratorUnknownElements() throws {
        let channel = Channel(
            title: "Unknown Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Unknown element test.",
            unknownElements: [
                UnknownElement(
                    name: "custom:rating",
                    attributes: ["scale": "10"],
                    textContent: "9"
                )
            ]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<custom:rating scale=\"10\">9</custom:rating>"))
    }

    @Test("FeedGenerator — XML comments preserved in output")
    func feedGeneratorXMLComments() throws {
        let channel = Channel(
            title: "Comment Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Comment test.",
            xmlComments: ["This is a preserved comment"]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<!-- This is a preserved comment -->"))
    }

    // MARK: - Error Handling

    @Test("FeedGenerator — throws missingChannel when no channel")
    func feedGeneratorMissingChannel() throws {
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
        let generator = FeedGenerator()

        #expect(throws: GeneratorError.missingChannel) {
            try generator.generate(feed)
        }
    }

    @Test("GeneratorError — error descriptions are human-readable")
    func generatorErrorDescriptions() {
        let missingChannel = GeneratorError.missingChannel
        #expect(missingChannel.errorDescription?.contains("Missing channel") == true)

        let invalidURL = GeneratorError.invalidURL("enclosure", "not-a-url")
        #expect(invalidURL.errorDescription?.contains("Invalid URL") == true)
        #expect(invalidURL.errorDescription?.contains("enclosure") == true)

        let encoding = GeneratorError.encodingError("UTF-16 not supported")
        #expect(encoding.errorDescription?.contains("Encoding error") == true)
    }

    @Test("GeneratorError — equatable conformance")
    func generatorErrorEquatable() {
        #expect(GeneratorError.missingChannel == GeneratorError.missingChannel)
        #expect(
            GeneratorError.invalidURL("a", "b") == GeneratorError.invalidURL("a", "b")
        )
        #expect(
            GeneratorError.invalidURL("a", "b") != GeneratorError.invalidURL("c", "d")
        )
    }
}

// MARK: - Streaming Feed Generator Showcase

@Suite("Streaming Feed Generator Showcase")
struct StreamingGeneratorShowcase {

    @Test("StreamingFeedGenerator — async chunk generation yields multiple chunks")
    func streamingChunks() async throws {
        let items = (1...5).map { idx in
            Item(
                title: "Stream Episode \(idx)",
                guid: GUID(value: "stream-\(idx)", isPermaLink: false)
            )
        }
        let channel = Channel(
            title: "Streaming Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Streaming test.",
            items: items
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        let streaming = StreamingFeedGenerator()
        var chunks: [String] = []
        for try await chunk in streaming.generate(feed) {
            chunks.append(chunk)
        }

        // N+2 chunks: 1 header + 5 items + 1 footer = 7
        #expect(chunks.count == 7)
    }

    @Test("StreamingFeedGenerator — chunks assemble into valid parseable XML")
    func streamingAssembly() async throws {
        let items = [
            Item(
                title: "Assembled Episode 1",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/a1.mp3")),
                    length: 10_000_000,
                    type: "audio/mpeg"
                )
            ),
            Item(
                title: "Assembled Episode 2",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/a2.mp3")),
                    length: 12_000_000,
                    type: "audio/mpeg"
                )
            )
        ]
        let channel = Channel(
            title: "Assembled Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Assembly test.",
            items: items
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)

        let streaming = StreamingFeedGenerator()
        var assembled = ""
        for try await chunk in streaming.generate(feed) {
            assembled += chunk
        }

        // Verify the assembled string is parseable
        let parser = FeedParser()
        let parsed = try parser.parse(assembled)
        let parsedChannel = try #require(parsed.channel)
        #expect(parsedChannel.title == "Assembled Show")
        #expect(parsedChannel.items.count == 2)
        #expect(parsedChannel.items[0].title == "Assembled Episode 1")
        #expect(parsedChannel.items[1].title == "Assembled Episode 2")
    }

    @Test("StreamingFeedGenerator — pretty-print and minified modes")
    func streamingPrettyPrintModes() async throws {
        let channel = Channel(
            title: "Mode Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Mode test."
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        // Pretty-print
        let prettyGen = StreamingFeedGenerator(prettyPrint: true)
        var prettyChunks = ""
        for try await chunk in prettyGen.generate(feed) { prettyChunks += chunk }
        #expect(prettyChunks.contains("\t"))

        // Minified
        let minGen = StreamingFeedGenerator(prettyPrint: false)
        var minChunks = ""
        for try await chunk in minGen.generate(feed) { minChunks += chunk }
        #expect(!minChunks.contains("\t"))
    }

    @Test("StreamingFeedGenerator — throws missingChannel when no channel")
    func streamingMissingChannel() async {
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
        let streaming = StreamingFeedGenerator()

        do {
            for try await _ in streaming.generate(feed) {
                // Should not yield
            }
            Issue.record("Expected GeneratorError.missingChannel to be thrown")
        } catch {
            #expect(error is GeneratorError)
        }
    }

    @Test("StreamingFeedGenerator — init with all configuration options")
    func streamingInit() {
        let gen = StreamingFeedGenerator(
            prettyPrint: false,
            includeXMLDeclaration: false,
            encoding: "ISO-8859-1",
            namespaceMode: .auto
        )
        #expect(gen.prettyPrint == false)
        #expect(gen.includeXMLDeclaration == false)
        #expect(gen.encoding == "ISO-8859-1")
        #expect(gen.namespaceMode == .auto)
    }
}

// MARK: - XMLBuilder Showcase

@Suite("XMLBuilder Showcase")
struct XMLBuilderShowcase {

    // MARK: - Static Utility Methods

    @Test("XMLBuilder.escape — preserves valid XML entities")
    func escapePreservesEntities() {
        #expect(XMLBuilder.escape("&amp;") == "&amp;")
        #expect(XMLBuilder.escape("&lt;") == "&lt;")
        #expect(XMLBuilder.escape("&gt;") == "&gt;")
        #expect(XMLBuilder.escape("&quot;") == "&quot;")
        #expect(XMLBuilder.escape("&apos;") == "&apos;")
    }

    @Test("XMLBuilder.escape — escapes raw special characters")
    func escapeRawCharacters() {
        #expect(XMLBuilder.escape("A & B") == "A &amp; B")
        #expect(XMLBuilder.escape("1 < 2") == "1 &lt; 2")
        #expect(XMLBuilder.escape("2 > 1") == "2 &gt; 1")
        #expect(XMLBuilder.escape("say \"hi\"") == "say &quot;hi&quot;")
    }

    @Test("XMLBuilder.escape — handles copyright, trademark, and smart quotes")
    func escapeSpecialChars() {
        // Copyright symbol
        #expect(XMLBuilder.escape("\u{00A9}") == "&#xA9;")
        // Trademark
        #expect(XMLBuilder.escape("\u{2122}") == "&#x2122;")
        // Sound recording copyright
        #expect(XMLBuilder.escape("\u{2117}") == "&#x2117;")
        // Right single quote
        #expect(XMLBuilder.escape("\u{2019}") == "&apos;")
        // Smart double quotes
        #expect(XMLBuilder.escape("\u{201C}") == "&quot;")
        #expect(XMLBuilder.escape("\u{201D}") == "&quot;")
    }

    @Test("XMLBuilder.escape — does not double-escape numeric character references")
    func escapeNumericRefs() {
        #expect(XMLBuilder.escape("&#xA9;") == "&#xA9;")
        #expect(XMLBuilder.escape("&#x2122;") == "&#x2122;")
        #expect(XMLBuilder.escape("&#169;") == "&#169;")
    }

    @Test("XMLBuilder.escape — converts HTML named entities to numeric")
    func escapeHTMLEntities() {
        #expect(XMLBuilder.escape("&copy;") == "&#xA9;")
        #expect(XMLBuilder.escape("&trade;") == "&#x2122;")
        #expect(XMLBuilder.escape("&reg;") == "&#xAE;")
    }

    @Test("XMLBuilder.containsHTML — detects angle bracket tags")
    func containsHTMLDetection() {
        #expect(XMLBuilder.containsHTML("<p>Hello</p>") == true)
        #expect(XMLBuilder.containsHTML("Hello > World") == true)
        #expect(XMLBuilder.containsHTML("Plain text only") == false)
        #expect(XMLBuilder.containsHTML("") == false)
    }

    @Test("XMLBuilder.encodeURL — handles standard URLs")
    func encodeURL() throws {
        let url = try #require(URL(string: "https://example.com/path?q=hello&lang=en"))
        let result = XMLBuilder.encodeURL(url)
        #expect(result.contains("https://example.com/path"))
        #expect(result.contains("q=hello"))
    }

    @Test("XMLBuilder.validateURL — accepts valid HTTP/HTTPS URLs")
    func validateURLValid() throws {
        try XMLBuilder.validateURL(try #require(URL(string: "https://example.com/feed.xml")), context: "test")
        try XMLBuilder.validateURL(try #require(URL(string: "http://example.com/feed.xml")), context: "test")
    }

    @Test("XMLBuilder.validateURL — rejects file URLs")
    func validateURLFile() throws {
        let fileURL = try #require(URL(string: "file:///etc/passwd"))
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(fileURL, context: "link")
        }
    }

    @Test("XMLBuilder.validateURL — rejects non-HTTP schemes")
    func validateURLScheme() throws {
        let ftpURL = try #require(URL(string: "ftp://example.com/file"))
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(ftpURL, context: "enclosure")
        }
    }

    @Test("XMLBuilder.formatAttributes — produces well-formed XML attribute strings")
    func formatAttributes() {
        let result = XMLBuilder.formatAttributes([
            ("href", "https://example.com"),
            ("rel", "self"),
            ("type", "application/rss+xml")
        ])
        #expect(result == " href=\"https://example.com\" rel=\"self\" type=\"application/rss+xml\"")
    }

    @Test("XMLBuilder.formatAttributes — returns empty string for empty array")
    func formatAttributesEmpty() {
        #expect(XMLBuilder.formatAttributes([]) == "")
    }

    @Test("XMLBuilder.boolYesNo — converts booleans to yes/no")
    func boolYesNo() {
        #expect(XMLBuilder.boolYesNo(true) == "yes")
        #expect(XMLBuilder.boolYesNo(false) == "no")
    }

    @Test("XMLBuilder.boolTrueFalse — converts booleans to true/false")
    func boolTrueFalse() {
        #expect(XMLBuilder.boolTrueFalse(true) == "true")
        #expect(XMLBuilder.boolTrueFalse(false) == "false")
    }

    @Test("XMLBuilder.rfc2822Date — formats date in RFC 2822 with UTC offset")
    func rfc2822Date() {
        // 2025-02-13 00:00:00 UTC
        let date = Date(timeIntervalSince1970: 1_739_404_800)
        let result = XMLBuilder.rfc2822Date(date)

        #expect(result.contains("+0000"))
        #expect(result.contains("Feb"))
        #expect(result.contains("2025"))
        #expect(result.contains("13"))
    }

    @Test("XMLBuilder.iso8601Date — formats date in ISO 8601 with Z suffix")
    func iso8601Date() {
        let date = Date(timeIntervalSince1970: 1_739_404_800)
        let result = XMLBuilder.iso8601Date(date)

        #expect(result.hasSuffix("Z"))
        #expect(result.contains("2025"))
        #expect(result.contains("-02-"))
        #expect(result.contains("T"))
    }

    // MARK: - Instance Methods

    @Test("XMLBuilder — element building with content")
    func elementBuilding() {
        let builder = XMLBuilder()
        let result = builder.element("title", content: "My Podcast")
        #expect(result == "<title>My Podcast</title>")
    }

    @Test("XMLBuilder — element building with attributes")
    func elementWithAttributes() {
        let builder = XMLBuilder()
        let result = builder.element(
            "guid",
            content: "123",
            attributes: [("isPermaLink", "false")]
        )
        #expect(result == "<guid isPermaLink=\"false\">123</guid>")
    }

    @Test("XMLBuilder — self-closing element")
    func selfClosingElement() {
        let builder = XMLBuilder()
        let result = builder.selfClosingElement(
            "enclosure",
            attributes: [
                ("url", "https://example.com/ep.mp3"),
                ("type", "audio/mpeg")
            ]
        )
        #expect(result == "<enclosure url=\"https://example.com/ep.mp3\" type=\"audio/mpeg\" />")
    }

    @Test("XMLBuilder — open and close tags")
    func openCloseTag() {
        let builder = XMLBuilder()
        #expect(builder.openTag("channel") == "<channel>")
        #expect(builder.closeTag("channel") == "</channel>")
    }

    @Test("XMLBuilder — CDATA element")
    func cdataElement() {
        let builder = XMLBuilder()
        let result = builder.cdataElement("content:encoded", content: "<p>HTML</p>")
        #expect(result == "<content:encoded><![CDATA[<p>HTML</p>]]></content:encoded>")
    }

    @Test("XMLBuilder — smart element auto-detects HTML for CDATA")
    func smartElement() {
        let builder = XMLBuilder()

        // Plain text: no CDATA
        let plain = builder.smartElement("description", content: "Plain text")
        #expect(!plain.contains("CDATA"))
        #expect(plain == "<description>Plain text</description>")

        // HTML content: CDATA wrapping
        let html = builder.smartElement("description", content: "<b>Bold</b>")
        #expect(html.contains("<![CDATA[<b>Bold</b>]]>"))
    }

    @Test("XMLBuilder — indentation with depth")
    func indentation() {
        let builder = XMLBuilder(indentString: "\t", depth: 0)
        #expect(builder.indent == "")

        let nested1 = builder.indented()
        #expect(nested1.indent == "\t")
        #expect(nested1.depth == 1)

        let nested2 = nested1.indented()
        #expect(nested2.indent == "\t\t")
        #expect(nested2.depth == 2)
    }

    @Test("XMLBuilder — custom indent string")
    func customIndent() {
        let builder = XMLBuilder(indentString: "  ", depth: 2)
        #expect(builder.indent == "    ")

        let result = builder.element("title", content: "Test")
        #expect(result == "    <title>Test</title>")
    }
}

// MARK: - Namespace Resolver Showcase

@Suite("Namespace Resolver Showcase")
struct NamespaceResolverShowcase {

    @Test("NamespaceResolver — detects iTunes namespace from channel properties")
    func resolveITunes() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            itunesAuthor: "Host"
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.itunes))
    }

    @Test("NamespaceResolver — detects iTunes namespace from item properties")
    func resolveITunesFromItem() throws {
        let item = Item(title: "Ep", itunesDuration: 600)
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            items: [item]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.itunes))
    }

    @Test("NamespaceResolver — detects Atom namespace from atomLinks")
    func resolveAtom() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            atomLinks: [AtomLink.selfLink(href: try #require(URL(string: "https://example.com/feed")))]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.atom))
    }

    @Test("NamespaceResolver — detects Podcast NS 2.0 from channel fields")
    func resolvePodcast() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            podcastGuid: PodcastGuid(value: "some-guid")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.podcast))
    }

    @Test("NamespaceResolver — detects Dublin Core namespace")
    func resolveDublinCore() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            dublinCore: DublinCore(creator: "Author")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.dublinCore))
    }

    @Test("NamespaceResolver — detects Content namespace from item contentEncoded")
    func resolveContent() throws {
        let item = Item(title: "Ep", contentEncoded: ContentEncoded(value: "<p>Notes</p>"))
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            items: [item]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.content))
    }

    @Test("NamespaceResolver — detects Podlove namespace from item chapters")
    func resolvePodlove() throws {
        let item = Item(
            title: "Ep",
            podloveChapters: PodloveChapters(chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Start")
            ])
        )
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test.",
            items: [item]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(.podloveSimpleChapters))
    }

    @Test("NamespaceResolver — empty channel produces no namespaces")
    func resolveEmpty() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Plain RSS only."
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.isEmpty)
    }

    @Test("NamespaceResolver — nil channel produces no namespaces")
    func resolveNilChannel() {
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.isEmpty)
    }

    @Test("NamespaceResolver — preserves custom namespaces from feed")
    func resolveCustom() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Test."
        )
        let customNS = PodcastNamespace.custom("xmlns:custom=\"https://custom.example.com\"")
        let feed = PodcastFeed(
            version: "2.0",
            namespaces: [customNS],
            channel: channel
        )
        let resolved = NamespaceResolver.resolve(feed)

        #expect(resolved.contains(customNS))
    }
}
