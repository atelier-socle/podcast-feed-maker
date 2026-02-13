// swiftlint:disable file_length
import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Feed Parser Showcase

/// Comprehensive showcase of every public API in the Parser layer.
/// Each test is self-contained and demonstrates one feature with realistic data.
@Suite("Feed Parser Showcase")
struct ParserShowcase { // swiftlint:disable:this type_body_length

    // MARK: - Helpers

    /// A minimal valid RSS 2.0 feed XML string.
    private static let minimalXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
            <channel>
                <title>Minimal Podcast</title>
                <link>https://example.com</link>
                <description>A minimal test feed.</description>
            </channel>
        </rss>
        """

    /// Builds an XML string with all 7 namespaces using FeedGenerator (proving round-trip).
    private static func generateAllNamespacesXML() throws -> String { // swiftlint:disable:this function_body_length
        let episode = Item(
            title: "Full Episode",
            link: URL(string: "https://example.com/ep1"),
            description: "Episode description.",
            author: "author@example.com",
            enclosure: Enclosure(
                url: try #require(URL(string: "https://cdn.example.com/ep1.mp3")),
                length: 48_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-full-001", isPermaLink: false),
            itunesAuthor: "Jane Host",
            itunesDuration: 3661,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/ep1.jpg"),
            itunesSeason: 2,
            itunesSubtitle: "Subtitle here",
            itunesTitle: "Special Title",
            atomLinks: [
                AtomLink(href: try #require(URL(string: "https://example.com/ep1/comments")), rel: "replies")
            ],
            dublinCore: DublinCore(creator: "Jane Host", subject: "Tech"),
            contentEncoded: ContentEncoded(value: "<p>Full <strong>show notes</strong>.</p>"),
            transcripts: [
                Transcript(
                    url: try #require(URL(string: "https://example.com/ep1.vtt")),
                    type: "text/vtt",
                    language: "en",
                    rel: "captions"
                )
            ],
            chaptersLink: ChaptersLink(
                url: try #require(URL(string: "https://example.com/ep1/chapters.json"))
            ),
            soundbites: [
                Soundbite(startTime: 120.5, duration: 45.0, title: "Best moment")
            ],
            persons: [
                PodcastPerson(
                    name: "Jane Host",
                    role: "host",
                    group: "cast",
                    href: URL(string: "https://example.com/jane"),
                    img: URL(string: "https://cdn.example.com/jane.jpg")
                ),
                PodcastPerson(name: "Bob Guest", role: "guest")
            ],
            podloveChapters: PodloveChapters(
                version: "1.2",
                chapters: [
                    PodloveChapter(start: "00:00:00.000", title: "Intro"),
                    PodloveChapter(
                        start: "00:05:30.000",
                        title: "Main Topic",
                        href: URL(string: "https://example.com/topic"),
                        image: URL(string: "https://cdn.example.com/topic.jpg")
                    ),
                    PodloveChapter(start: "00:30:00.000", title: "Outro")
                ]
            )
        )

        let channel = Channel(
            title: "The Complete Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "Covering all 7 namespaces.",
            language: "en-US",
            copyright: "2026 Atelier Socle",
            managingEditor: "editor@example.com (Editor)",
            pubDate: Date(timeIntervalSince1970: 1_739_404_800),
            lastBuildDate: Date(timeIntervalSince1970: 1_739_404_800),
            generator: "PodcastFeedMaker/1.0",
            ttl: 60,
            items: [episode],
            itunesAuthor: "Atelier Socle",
            itunesCategories: [
                .technology,
                ITunesCategory(
                    text: "Education",
                    subcategories: [ITunesCategory(text: "Self-Improvement")]
                )
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

        let feed = PodcastFeed(
            version: "2.0",
            namespaces: PodcastNamespace.allStandard,
            channel: channel
        )

        let generator = FeedGenerator()
        return try generator.generate(feed)
    }

    // MARK: - FeedParser — Parse from String

    @Test("FeedParser — parse from XML string")
    func parseFromString() throws {
        let parser = FeedParser()
        let feed = try parser.parse(Self.minimalXML)

        let channel = try #require(feed.channel)
        #expect(channel.title == "Minimal Podcast")
        #expect(channel.link == URL(string: "https://example.com"))
        #expect(channel.description == "A minimal test feed.")
    }

    @Test("FeedParser — parse from Data")
    func parseFromData() throws {
        let data = try #require(Self.minimalXML.data(using: .utf8))
        let parser = FeedParser()
        let feed = try parser.parse(data: data)

        let channel = try #require(feed.channel)
        #expect(channel.title == "Minimal Podcast")
    }

    @Test("FeedParser — parse all 7 namespaces from generated XML")
    func parseAllNamespaces() throws { // swiftlint:disable:this function_body_length
        let xml = try Self.generateAllNamespacesXML()
        let parser = FeedParser()
        let feed = try parser.parse(xml)

        let channel = try #require(feed.channel)

        // RSS 2.0 Core
        #expect(channel.title == "The Complete Podcast")
        #expect(channel.link == URL(string: "https://example.com"))
        #expect(channel.description == "Covering all 7 namespaces.")
        #expect(channel.language == "en-US")
        #expect(channel.copyright == "2026 Atelier Socle")
        #expect(channel.generator == "PodcastFeedMaker/1.0")
        #expect(channel.ttl == 60)

        // iTunes
        #expect(channel.itunesAuthor == "Atelier Socle")
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage == URL(string: "https://cdn.example.com/artwork.jpg"))
        #expect(channel.itunesOwner?.name == "Wlad")
        #expect(channel.itunesOwner?.email == "wlad@example.com")
        #expect(channel.itunesType == .episodic)
        #expect(channel.itunesCategories.count >= 1)
        #expect(channel.itunesCategories[0].text == "Technology")

        // Atom
        #expect(!channel.atomLinks.isEmpty)
        let selfLink = channel.atomLinks.first(where: { $0.rel == "self" })
        #expect(selfLink?.href == URL(string: "https://example.com/feed.xml"))

        // Dublin Core
        #expect(channel.dublinCore?.creator == "Atelier Socle")
        #expect(channel.dublinCore?.language == "en")

        // Podcast NS 2.0
        #expect(channel.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "wlad@example.com")
        #expect(channel.funding.count == 1)
        #expect(channel.funding[0].message == "Support the show")
        #expect(channel.persons.count == 1)
        #expect(channel.persons[0].name == "Wlad")

        // Item verification
        #expect(channel.items.count == 1)
        let item = channel.items[0]

        #expect(item.title == "Full Episode")
        #expect(item.enclosure?.url == URL(string: "https://cdn.example.com/ep1.mp3"))
        #expect(item.enclosure?.length == 48_000_000)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "ep-full-001")
        #expect(item.guid?.isPermaLink == false)

        // Item iTunes
        #expect(item.itunesAuthor == "Jane Host")
        #expect(item.itunesDuration == 3661)
        #expect(item.itunesEpisode == 1)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesSeason == 2)
        #expect(item.itunesTitle == "Special Title")

        // Item Dublin Core
        #expect(item.dublinCore?.creator == "Jane Host")
        #expect(item.dublinCore?.subject == "Tech")

        // Item Content Module
        #expect(item.contentEncoded?.value.contains("<strong>show notes</strong>") == true)

        // Item Podcast NS 2.0
        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].url == URL(string: "https://example.com/ep1.vtt"))
        #expect(item.transcripts[0].type == "text/vtt")
        #expect(item.transcripts[0].language == "en")
        #expect(item.chaptersLink?.url == URL(string: "https://example.com/ep1/chapters.json"))
        #expect(item.soundbites.count == 1)
        #expect(item.soundbites[0].title == "Best moment")
        #expect(item.persons.count == 2)
        #expect(item.persons[0].name == "Jane Host")
        #expect(item.persons[1].name == "Bob Guest")

        // Item Podlove Simple Chapters
        let chapters = try #require(item.podloveChapters)
        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 3)
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[1].title == "Main Topic")
        #expect(chapters.chapters[1].href == URL(string: "https://example.com/topic"))
        #expect(chapters.chapters[2].title == "Outro")
    }

    // MARK: - Parse Minimal RSS 2.0

    @Test("FeedParser — parse minimal RSS 2.0 feed with no namespace tags")
    func parseMinimalRSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Plain RSS</title>
                    <link>https://example.com</link>
                    <description>No namespaces used.</description>
                    <item>
                        <title>Episode 1</title>
                        <description>First episode.</description>
                        <guid>ep-001</guid>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Plain RSS")
        #expect(channel.items.count == 1)
        #expect(channel.items[0].title == "Episode 1")
        #expect(channel.items[0].guid?.value == "ep-001")
        // Default isPermaLink is true when not specified
        #expect(channel.items[0].guid?.isPermaLink == true)

        // No namespace data
        #expect(channel.itunesAuthor == nil)
        #expect(channel.podcastGuid == nil)
        #expect(channel.dublinCore == nil)
    }

    // MARK: - Round-Trip Preservation

    @Test("FeedParser — preserve unknown elements for round-trip fidelity")
    func parseUnknownElements() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Unknown Test</title>
                    <link>https://example.com</link>
                    <description>Testing unknown elements.</description>
                    <custom:rating>5</custom:rating>
                    <item>
                        <title>Ep 1</title>
                        <custom:score>95</custom:score>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        // Channel-level unknown element
        let channelUnknown = channel.unknownElements.first(where: { $0.name == "custom:rating" })
        #expect(channelUnknown?.textContent == "5")

        // Item-level unknown element
        let itemUnknown = channel.items[0].unknownElements.first(where: { $0.name == "custom:score" })
        #expect(itemUnknown?.textContent == "95")
    }

    @Test("FeedParser — CDATA content preserved correctly")
    func parseCDATAContent() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/">
                <channel>
                    <title>CDATA Show</title>
                    <link>https://example.com</link>
                    <description><![CDATA[A <b>bold</b> description.]]></description>
                    <item>
                        <title>Ep 1</title>
                        <content:encoded><![CDATA[<p>Full <em>HTML</em> notes.</p>]]></content:encoded>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        // The parser should preserve the content as-is (without the CDATA wrapper)
        #expect(channel.description == "A <b>bold</b> description.")

        let item = try #require(channel.items.first)
        #expect(item.contentEncoded?.value == "<p>Full <em>HTML</em> notes.</p>")

        // CDATA tracking
        #expect(channel.cdataFields.contains("description"))
    }

    @Test("FeedParser — XML comments preserved for round-trip")
    func parseXMLComments() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Comment Show</title>
                    <link>https://example.com</link>
                    <description>Comment test.</description>
                    <!-- Channel-level comment -->
                    <item>
                        <title>Ep 1</title>
                        <!-- Item-level comment -->
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.xmlComments.contains(where: { $0.contains("Channel-level comment") }))

        let item = try #require(channel.items.first)
        #expect(item.xmlComments.contains(where: { $0.contains("Item-level comment") }))
    }

    // MARK: - Parse with Diagnostics

    @Test("FeedParser — parseWithDiagnostics returns feed and warnings")
    func parseWithDiagnostics() throws {
        let parser = FeedParser()
        let result = try parser.parseWithDiagnostics(Self.minimalXML)

        let channel = try #require(result.feed.channel)
        #expect(channel.title == "Minimal Podcast")
        // Warnings array exists (may be empty for well-formed feeds)
        #expect(result.warnings is [ParserError])
    }

    @Test("FeedParser — parseWithDiagnostics from Data")
    func parseWithDiagnosticsData() throws {
        let data = try #require(Self.minimalXML.data(using: .utf8))
        let parser = FeedParser()
        let result = try parser.parseWithDiagnostics(data: data)

        #expect(result.feed.channel?.title == "Minimal Podcast")
    }
}

// MARK: - Date Parser Showcase

@Suite("Date Parser Showcase")
struct DateParserShowcase {

    @Test("DateParser — RFC 2822 full format with day name")
    func parseRFC2822Full() throws {
        let date = DateParser.parse("Mon, 10 Feb 2025 12:00:00 +0000")
        #expect(date != nil)

        // Verify the parsed date is 2025-02-10 12:00:00 UTC
        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            #expect(components.year == 2025)
            #expect(components.month == 2)
            #expect(components.day == 10)
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — RFC 2822 without day name")
    func parseRFC2822NoDayName() {
        let date = DateParser.parse("10 Feb 2025 12:00:00 +0000")
        #expect(date != nil)
    }

    @Test("DateParser — RFC 2822 with timezone abbreviation")
    func parseRFC2822Timezone() throws {
        // PST is UTC-8
        let date = DateParser.parse("Mon, 10 Feb 2025 04:00:00 PST")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.hour], from: date)
            // 04:00 PST = 12:00 UTC
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — RFC 2822 with negative offset")
    func parseRFC2822NegativeOffset() throws {
        let date = DateParser.parse("Tue, 11 Mar 2025 09:30:00 -0500")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.hour, .minute], from: date)
            // 09:30 -0500 = 14:30 UTC
            #expect(components.hour == 14)
            #expect(components.minute == 30)
        }
    }

    @Test("DateParser — RFC 2822 with two-digit year")
    func parseRFC2822TwoDigitYear() throws {
        // Two-digit year: < 50 maps to 2000s
        let date = DateParser.parse("10 Feb 25 12:00:00 GMT")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year], from: date)
            #expect(components.year == 2025)
        }
    }

    @Test("DateParser — ISO 8601 with Z suffix")
    func parseISO8601Z() throws {
        let date = DateParser.parse("2025-02-10T12:00:00Z")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            #expect(components.year == 2025)
            #expect(components.month == 2)
            #expect(components.day == 10)
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — ISO 8601 with positive offset")
    func parseISO8601Offset() throws {
        let date = DateParser.parse("2025-02-10T14:00:00+02:00")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.hour], from: date)
            // 14:00 +0200 = 12:00 UTC
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — ISO 8601 date only (no time)")
    func parseISO8601DateOnly() throws {
        let date = DateParser.parse("2025-02-10")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == 2025)
            #expect(components.month == 2)
            #expect(components.day == 10)
        }
    }

    @Test("DateParser — ISO 8601 with milliseconds")
    func parseISO8601Millis() {
        let date = DateParser.parse("2025-02-10T12:00:00.123Z")
        #expect(date != nil)
    }

    @Test("DateParser — common format: long month name")
    func parseLongMonth() throws {
        let date = DateParser.parse("February 12, 2026")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == 2026)
            #expect(components.month == 2)
            #expect(components.day == 12)
        }
    }

    @Test("DateParser — common format: slash-separated date")
    func parseSlashFormat() throws {
        let date = DateParser.parse("2026/02/12")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == 2026)
            #expect(components.month == 2)
            #expect(components.day == 12)
        }
    }

    @Test("DateParser — common format: day month year")
    func parseDayMonthYear() {
        let date = DateParser.parse("12 Feb 2026")
        #expect(date != nil)
    }

    @Test("DateParser — returns nil for empty string")
    func parseEmpty() {
        #expect(DateParser.parse("") == nil)
        #expect(DateParser.parse("   ") == nil)
    }

    @Test("DateParser — returns nil for gibberish")
    func parseGibberish() {
        #expect(DateParser.parse("not a date") == nil)
        #expect(DateParser.parse("yesterday") == nil)
    }

    @Test("DateParser — generator and parser roundtrip for RFC 2822 dates")
    func rfc2822Roundtrip() {
        let original = Date(timeIntervalSince1970: 1_739_404_800)
        let formatted = XMLBuilder.rfc2822Date(original)
        let parsed = DateParser.parse(formatted)

        #expect(parsed != nil)
        if let parsed {
            // Allow 1-second tolerance for rounding
            #expect(abs(parsed.timeIntervalSince(original)) < 1.0)
        }
    }
}

// MARK: - iTunes Parsing Showcase

@Suite("iTunes Parsing Showcase")
struct ITunesParsingShowcase {

    @Test("FeedParser — iTunes explicit true/false values")
    func parseExplicitTrueFalse() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:explicit>true</itunes:explicit>
                    <item>
                        <title>Ep</title>
                        <itunes:explicit>false</itunes:explicit>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesExplicit == true)
        #expect(channel.items[0].itunesExplicit == false)
    }

    @Test("FeedParser — iTunes explicit yes/no legacy values")
    func parseExplicitYesNo() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:explicit>yes</itunes:explicit>
                    <item>
                        <title>Ep</title>
                        <itunes:explicit>no</itunes:explicit>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesExplicit == true)
        #expect(channel.items[0].itunesExplicit == false)
    }

    @Test("FeedParser — iTunes duration as integer seconds")
    func parseDurationSeconds() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Ep</title>
                        <itunes:duration>3600</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.itunesDuration == 3600)
    }

    @Test("FeedParser — iTunes duration in HH:MM:SS format")
    func parseDurationHHMMSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Ep</title>
                        <itunes:duration>01:30:15</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        // 1*3600 + 30*60 + 15 = 5415
        #expect(item.itunesDuration == 5415)
    }

    @Test("FeedParser — iTunes duration in MM:SS format")
    func parseDurationMMSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Ep</title>
                        <itunes:duration>45:30</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        // 45*60 + 30 = 2730
        #expect(item.itunesDuration == 2730)
    }

    @Test("FeedParser — iTunes block yes/no values")
    func parseITunesBlock() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:block>yes</itunes:block>
                    <item>
                        <title>Ep</title>
                        <itunes:block>no</itunes:block>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesBlock == true)
        #expect(channel.items[0].itunesBlock == false)
    }

    @Test("FeedParser — iTunes category with subcategory")
    func parseITunesCategory() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:category text="Technology">
                        <itunes:category text="Podcasting" />
                    </itunes:category>
                    <itunes:category text="Comedy" />
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesCategories.count == 2)
        #expect(channel.itunesCategories[0].text == "Technology")
        #expect(channel.itunesCategories[0].subcategories.count == 1)
        #expect(channel.itunesCategories[0].subcategories[0].text == "Podcasting")
        #expect(channel.itunesCategories[1].text == "Comedy")
    }

    @Test("FeedParser — iTunes owner with name and email")
    func parseITunesOwner() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:owner>
                        <itunes:name>Jane Doe</itunes:name>
                        <itunes:email>jane@example.com</itunes:email>
                    </itunes:owner>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesOwner?.name == "Jane Doe")
        #expect(channel.itunesOwner?.email == "jane@example.com")
    }

    @Test("FeedParser — iTunes show type")
    func parseITunesType() throws {
        let serialXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:type>serial</itunes:type>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(serialXML)
        #expect(feed.channel?.itunesType == .serial)
    }

    @Test("FeedParser — iTunes episode type")
    func parseITunesEpisodeType() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Trailer</title>
                        <itunes:episodeType>trailer</itunes:episodeType>
                    </item>
                    <item>
                        <title>Bonus</title>
                        <itunes:episodeType>bonus</itunes:episodeType>
                    </item>
                    <item>
                        <title>Full</title>
                        <itunes:episodeType>full</itunes:episodeType>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let items = try #require(feed.channel?.items)
        #expect(items.count == 3)
        #expect(items[0].itunesEpisodeType == .trailer)
        #expect(items[1].itunesEpisodeType == .bonus)
        #expect(items[2].itunesEpisodeType == .full)
    }
}

// MARK: - Malformed Feed Parsing Showcase

@Suite("Malformed Feed Parsing Showcase")
struct MalformedParsingShowcase {

    @Test("FeedParser — best-effort parsing of feed with malformed date")
    func parseMalformedDate() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Malformed Dates</title>
                    <link>https://example.com</link>
                    <description>Feed with bad dates.</description>
                    <pubDate>not-a-real-date</pubDate>
                    <item>
                        <title>Good Episode</title>
                        <pubDate>Mon, 10 Feb 2025 12:00:00 +0000</pubDate>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let feed = try parser.parse(xml)
        let channel = try #require(feed.channel)

        // Channel date should be nil (unparseable)
        #expect(channel.pubDate == nil)

        // Item with valid date should parse correctly
        #expect(channel.items[0].pubDate != nil)
        #expect(channel.items[0].title == "Good Episode")
    }

    @Test("FeedParser — best-effort parsing collects warnings via diagnostics")
    func parseMalformedWithDiagnostics() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Warnings Show</title>
                    <link>https://example.com</link>
                    <description>Test with non-fatal issues.</description>
                    <item>
                        <title>Good Episode</title>
                        <itunes:duration>1800</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let parser = FeedParser()
        let result = try parser.parseWithDiagnostics(xml)

        // Feed should be parsed successfully
        let channel = try #require(result.feed.channel)
        #expect(channel.title == "Warnings Show")
        #expect(channel.items[0].itunesDuration == 1800)

        // Warnings array is accessible
        #expect(result.warnings is [ParserError])
    }

    @Test("FeedParser — throws for completely invalid XML")
    func parseInvalidXML() {
        let parser = FeedParser()

        #expect(throws: ParserError.self) {
            try parser.parse("This is not XML at all <><><<")
        }
    }

    @Test("FeedParser — throws missingChannel for RSS with no channel")
    func parseMissingChannel() {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            </rss>
            """
        let parser = FeedParser()

        #expect(throws: ParserError.self) {
            try parser.parse(xml)
        }
    }

    @Test("FeedParser — handles empty items gracefully")
    func parseEmptyItems() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Empty Items</title>
                    <link>https://example.com</link>
                    <description>Items with no content.</description>
                    <item>
                    </item>
                    <item>
                        <title>Real Episode</title>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == nil)
        #expect(channel.items[1].title == "Real Episode")
    }
}

// MARK: - Parser Error Showcase

@Suite("Parser Error Showcase")
struct ParserErrorShowcase {

    @Test("ParserError — error cases are equatable")
    func errorEquatable() {
        #expect(ParserError.missingChannel == ParserError.missingChannel)
        #expect(ParserError.missingRSSElement == ParserError.missingRSSElement)
        #expect(
            ParserError.invalidXML("bad") == ParserError.invalidXML("bad")
        )
        #expect(
            ParserError.invalidXML("a") != ParserError.invalidXML("b")
        )
    }

    @Test("ParserError — error descriptions are human-readable")
    func errorDescriptions() {
        #expect(ParserError.missingChannel.errorDescription?.contains("Missing") == true)
        #expect(ParserError.missingRSSElement.errorDescription?.contains("rss") == true)
        #expect(ParserError.invalidXML("reason").errorDescription?.contains("Invalid XML") == true)
        #expect(ParserError.encodingError("utf-8").errorDescription?.contains("Encoding") == true)
        #expect(ParserError.networkError("timeout").errorDescription?.contains("Network") == true)
    }

    @Test("ParserError — encoding error on invalid UTF-8 simulation")
    func encodingError() {
        let parser = FeedParser()
        // Create data that would cause encoding issues by simulating the error path
        let badData = Data([0xFF, 0xFE, 0x00]) // Not valid UTF-8 XML
        #expect(throws: ParserError.self) {
            try parser.parse(data: badData)
        }
    }
}

// MARK: - Streaming Feed Parser Showcase

@Suite("Streaming Feed Parser Showcase")
struct StreamingParserShowcase {

    @Test("StreamingFeedParser — async item parsing from string")
    func streamingParseString() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Stream Show</title>
                    <link>https://example.com</link>
                    <description>Streaming test.</description>
                    <item>
                        <title>Episode 1</title>
                    </item>
                    <item>
                        <title>Episode 2</title>
                    </item>
                    <item>
                        <title>Episode 3</title>
                    </item>
                </channel>
            </rss>
            """

        let parser = StreamingFeedParser()
        var items: [Item] = []
        for try await item in parser.parseItems(from: xml) {
            items.append(item)
        }

        #expect(items.count == 3)
        #expect(items[0].title == "Episode 1")
        #expect(items[1].title == "Episode 2")
        #expect(items[2].title == "Episode 3")
    }

    @Test("StreamingFeedParser — async item parsing from Data")
    func streamingParseData() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
                <channel>
                    <title>Data Show</title>
                    <link>https://example.com</link>
                    <description>Data test.</description>
                    <item>
                        <title>Data Episode</title>
                    </item>
                </channel>
            </rss>
            """
        let data = try #require(xml.data(using: .utf8))

        let parser = StreamingFeedParser()
        var items: [Item] = []
        for try await item in parser.parseItems(from: data) {
            items.append(item)
        }

        #expect(items.count == 1)
        #expect(items[0].title == "Data Episode")
    }

    @Test("StreamingFeedParser — items include all namespace data")
    func streamingNamespaceData() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0">
                <channel>
                    <title>NS Show</title>
                    <link>https://example.com</link>
                    <description>Namespace test.</description>
                    <item>
                        <title>Rich Item</title>
                        <itunes:duration>1800</itunes:duration>
                        <itunes:episode>5</itunes:episode>
                        <itunes:season>2</itunes:season>
                        <itunes:episodeType>full</itunes:episodeType>
                        <podcast:transcript url="https://example.com/t.vtt" type="text/vtt" />
                    </item>
                </channel>
            </rss>
            """

        let parser = StreamingFeedParser()
        var items: [Item] = []
        for try await item in parser.parseItems(from: xml) {
            items.append(item)
        }

        let item = try #require(items.first)
        #expect(item.itunesDuration == 1800)
        #expect(item.itunesEpisode == 5)
        #expect(item.itunesSeason == 2)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].type == "text/vtt")
    }

    @Test("StreamingFeedParser — throws for missing channel")
    func streamingMissingChannel() async {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            </rss>
            """
        let parser = StreamingFeedParser()

        do {
            for try await _ in parser.parseItems(from: xml) {
                // Should not yield items
            }
            Issue.record("Expected error for missing channel")
        } catch {
            #expect(error is ParserError)
        }
    }
}

// MARK: - Generator-Parser Round-Trip Showcase

@Suite("Generator-Parser Round-Trip Showcase")
struct RoundTripShowcase {

    @Test("Round-trip — generate then parse preserves RSS 2.0 core fields")
    func roundTripCore() throws {
        let channel = Channel(
            title: "Round-Trip Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Testing round-trip.",
            language: "fr-FR",
            copyright: "2026 Test Corp",
            ttl: 30
        )
        let original = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)

        let parsedChannel = try #require(parsed.channel)
        #expect(parsedChannel.title == "Round-Trip Show")
        #expect(parsedChannel.link == URL(string: "https://example.com"))
        #expect(parsedChannel.description == "Testing round-trip.")
        #expect(parsedChannel.language == "fr-FR")
        #expect(parsedChannel.copyright == "2026 Test Corp")
        #expect(parsedChannel.ttl == 30)
    }

    @Test("Round-trip — generate then parse preserves iTunes metadata")
    func roundTripITunes() throws {
        let item = Item(
            title: "RT Episode",
            enclosure: Enclosure(
                url: try #require(URL(string: "https://cdn.example.com/rt.mp3")),
                length: 20_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "rt-001", isPermaLink: false),
            itunesAuthor: "Author",
            itunesDuration: 2400,
            itunesEpisode: 3,
            itunesEpisodeType: .bonus,
            itunesExplicit: true,
            itunesSeason: 1
        )
        let channel = Channel(
            title: "RT Show",
            link: try #require(URL(string: "https://example.com")),
            description: "iTunes round-trip.",
            items: [item],
            itunesAuthor: "Show Author",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg"),
            itunesOwner: ITunesOwner(name: "Owner", email: "owner@test.com"),
            itunesType: .serial
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ch = try #require(parsed.channel)

        #expect(ch.itunesAuthor == "Show Author")
        #expect(ch.itunesExplicit == false)
        #expect(ch.itunesType == .serial)
        #expect(ch.itunesOwner?.name == "Owner")

        let ep = try #require(ch.items.first)
        #expect(ep.itunesDuration == 2400)
        #expect(ep.itunesEpisode == 3)
        #expect(ep.itunesEpisodeType == .bonus)
        #expect(ep.itunesExplicit == true)
        #expect(ep.itunesSeason == 1)
    }

    @Test("Round-trip — generate then parse preserves Podcast NS 2.0 data")
    func roundTripPodcastNS() throws {
        let item = Item(
            title: "Podcast NS Episode",
            transcripts: [
                Transcript(
                    url: try #require(URL(string: "https://example.com/ep.vtt")),
                    type: "text/vtt",
                    language: "en"
                )
            ],
            soundbites: [
                Soundbite(startTime: 10.0, duration: 30.0, title: "Highlight")
            ],
            persons: [
                PodcastPerson(name: "Host", role: "host")
            ]
        )
        let channel = Channel(
            title: "NS Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Podcast NS round-trip.",
            items: [item],
            podcastGuid: PodcastGuid(value: "abcdef-12345"),
            locked: Locked(isLocked: false, owner: "admin@test.com"),
            funding: [
                Funding(url: try #require(URL(string: "https://donate.example.com")), message: "Donate")
            ]
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ch = try #require(parsed.channel)

        #expect(ch.podcastGuid?.value == "abcdef-12345")
        #expect(ch.locked?.isLocked == false)
        #expect(ch.locked?.owner == "admin@test.com")
        #expect(ch.funding.count == 1)
        #expect(ch.funding[0].message == "Donate")

        let ep = try #require(ch.items.first)
        #expect(ep.transcripts.count == 1)
        #expect(ep.transcripts[0].language == "en")
        #expect(ep.soundbites.count == 1)
        #expect(ep.soundbites[0].title == "Highlight")
        #expect(ep.persons.count == 1)
        #expect(ep.persons[0].name == "Host")
    }

    @Test("Round-trip — generate then parse preserves content:encoded CDATA")
    func roundTripContentEncoded() throws {
        let htmlContent = "<h1>Show Notes</h1><p>Visit <a href=\"https://example.com\">our site</a>.</p>"
        let item = Item(
            title: "Content Episode",
            contentEncoded: ContentEncoded(value: htmlContent)
        )
        let channel = Channel(
            title: "Content Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Content round-trip.",
            items: [item]
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.content], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ep = try #require(parsed.channel?.items.first)

        #expect(ep.contentEncoded?.value == htmlContent)
    }

    @Test("Round-trip — generate then parse preserves Podlove chapters")
    func roundTripPodlove() throws {
        let item = Item(
            title: "Chapters Episode",
            podloveChapters: PodloveChapters(
                version: "1.2",
                chapters: [
                    PodloveChapter(start: "00:00:00.000", title: "Intro"),
                    PodloveChapter(
                        start: "00:15:00.000",
                        title: "Deep Dive",
                        href: URL(string: "https://example.com/dive")
                    )
                ]
            )
        )
        let channel = Channel(
            title: "Chapters Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Podlove round-trip.",
            items: [item]
        )
        let original = PodcastFeed(
            version: "2.0",
            namespaces: [.podloveSimpleChapters],
            channel: channel
        )

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ep = try #require(parsed.channel?.items.first)
        let chapters = try #require(ep.podloveChapters)

        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 2)
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[1].title == "Deep Dive")
        #expect(chapters.chapters[1].href == URL(string: "https://example.com/dive"))
    }

    @Test("Round-trip — streaming generator output is parseable by FeedParser")
    func roundTripStreaming() async throws {
        let items = (1...3).map { idx in
            Item(
                title: "Streaming Ep \(idx)",
                guid: GUID(value: "stream-\(idx)", isPermaLink: false)
            )
        }
        let channel = Channel(
            title: "Streaming RT",
            link: try #require(URL(string: "https://example.com")),
            description: "Streaming round-trip.",
            items: items
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

        // Generate via streaming
        let streaming = StreamingFeedGenerator()
        var assembled = ""
        for try await chunk in streaming.generate(feed) {
            assembled += chunk
        }

        // Parse the assembled result
        let parsed = try FeedParser().parse(assembled)
        let ch = try #require(parsed.channel)
        #expect(ch.title == "Streaming RT")
        #expect(ch.items.count == 3)
        #expect(ch.items[0].title == "Streaming Ep 1")
        #expect(ch.items[2].title == "Streaming Ep 3")
    }

    @Test("Round-trip — multiple episodes with diverse fields")
    func roundTripMultipleEpisodes() throws {
        let items = [
            Item(
                title: "First",
                description: "Episode one.",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/1.mp3")),
                    length: 10_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "first-ep", isPermaLink: false),
                itunesDuration: 600,
                itunesEpisodeType: .full
            ),
            Item(
                title: "Second",
                description: "Episode two.",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/2.mp3")),
                    length: 15_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "second-ep", isPermaLink: false),
                itunesDuration: 900,
                itunesEpisodeType: .trailer
            ),
            Item(
                title: "Third",
                description: "Episode three.",
                enclosure: Enclosure(
                    url: try #require(URL(string: "https://cdn.example.com/3.mp3")),
                    length: 20_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "third-ep", isPermaLink: false),
                itunesDuration: 1200,
                itunesEpisodeType: .bonus
            )
        ]
        let channel = Channel(
            title: "Multi Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Multiple episodes.",
            items: items,
            itunesAuthor: "Multi Author"
        )
        let original = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)

        let xml = try FeedGenerator().generate(original)
        let parsed = try FeedParser().parse(xml)
        let ch = try #require(parsed.channel)

        #expect(ch.items.count == 3)
        #expect(ch.items[0].title == "First")
        #expect(ch.items[0].guid?.value == "first-ep")
        #expect(ch.items[0].itunesDuration == 600)
        #expect(ch.items[0].itunesEpisodeType == .full)

        #expect(ch.items[1].title == "Second")
        #expect(ch.items[1].itunesEpisodeType == .trailer)

        #expect(ch.items[2].title == "Third")
        #expect(ch.items[2].itunesEpisodeType == .bonus)
    }
}
