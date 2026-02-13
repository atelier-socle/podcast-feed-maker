import Foundation
import PodcastFeedMaker
import Testing

/// Comprehensive round-trip tests demonstrating parse-generate-parse fidelity.
///
/// Every test follows the same pattern: build or parse a feed, generate XML,
/// parse the XML back, and verify the result matches the original. This is
/// the gold standard for proving zero data loss across the full pipeline.
@Suite("Round-Trip Showcase")
struct RoundTripShowcaseTests {

    // MARK: - Helpers

    /// A minimal RSS feed with only the three required channel elements.
    private static let minimalXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" \
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
        xmlns:atom="http://www.w3.org/2005/Atom" \
        xmlns:podcast="https://podcastindex.org/namespace/1.0" \
        xmlns:dc="http://purl.org/dc/elements/1.1/" \
        xmlns:content="http://purl.org/rss/1.0/modules/content/" \
        xmlns:psc="http://podlove.org/simple-chapters">
        <channel>
        \t<title>Minimal Show</title>
        \t<link>https://example.com</link>
        \t<description>A minimal podcast feed.</description>
        </channel>
        </rss>
        """

    /// A rich feed covering all 7 namespaces: RSS 2.0, iTunes, Podcast NS 2.0,
    /// Atom, Dublin Core, Content Module, and Podlove Simple Chapters.
    private static let allNamespacesXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" \
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
        xmlns:atom="http://www.w3.org/2005/Atom" \
        xmlns:podcast="https://podcastindex.org/namespace/1.0" \
        xmlns:dc="http://purl.org/dc/elements/1.1/" \
        xmlns:content="http://purl.org/rss/1.0/modules/content/" \
        xmlns:psc="http://podlove.org/simple-chapters">
        <channel>
        \t<title>Full Namespace Show</title>
        \t<link>https://example.com</link>
        \t<description>Covers every supported namespace.</description>
        \t<atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        \t<language>en</language>
        \t<copyright>2026 Example Inc.</copyright>
        \t<itunes:author>Jane Host</itunes:author>
        \t<itunes:category text="Technology"/>
        \t<itunes:explicit>false</itunes:explicit>
        \t<itunes:image href="https://example.com/artwork.jpg"/>
        \t<itunes:owner>
        \t\t<itunes:name>Jane Host</itunes:name>
        \t\t<itunes:email>jane@example.com</itunes:email>
        \t</itunes:owner>
        \t<itunes:type>episodic</itunes:type>
        \t<dc:creator>Dublin Core Creator</dc:creator>
        \t<podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>
        \t<podcast:locked owner="jane@example.com">yes</podcast:locked>
        \t<podcast:medium>podcast</podcast:medium>
        \t<podcast:funding url="https://example.com/donate">Support the show</podcast:funding>
        \t<podcast:person>Jane Host</podcast:person>
        \t<item>
        \t\t<title>Episode 1 — All Namespaces</title>
        \t\t<link>https://example.com/ep1</link>
        \t\t<description>Episode covering all namespaces.</description>
        \t\t<enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
        \t\t<guid isPermaLink="false">ep-001</guid>
        \t\t<itunes:author>Jane Host</itunes:author>
        \t\t<itunes:duration>1800</itunes:duration>
        \t\t<itunes:episode>1</itunes:episode>
        \t\t<itunes:episodeType>full</itunes:episodeType>
        \t\t<itunes:explicit>false</itunes:explicit>
        \t\t<itunes:season>1</itunes:season>
        \t\t<dc:creator>Episode DC Creator</dc:creator>
        \t\t<podcast:transcript url="https://example.com/ep1.srt" type="application/srt"/>
        \t\t<podcast:person>Guest Speaker</podcast:person>
        \t\t<psc:chapters version="1.2">
        \t\t\t<psc:chapter start="00:00:00.000" title="Intro"/>
        \t\t\t<psc:chapter start="00:05:30.000" title="Main Topic"/>
        \t\t\t<psc:chapter start="00:25:00.000" title="Outro"/>
        \t\t</psc:chapters>
        \t\t<content:encoded><![CDATA[<p>Rich <strong>HTML</strong> content.</p>]]></content:encoded>
        \t</item>
        </channel>
        </rss>
        """

    // MARK: - Minimal Feed Round-Trip

    @Test("Parse then generate then parse — zero data loss on minimal feed")
    func minimalFeedRoundTrip() throws {
        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Step 1: Parse original XML
        let feed1 = try parser.parse(Self.minimalXML)
        let channel1 = try #require(feed1.channel)
        #expect(channel1.title == "Minimal Show")
        #expect(channel1.link.absoluteString == "https://example.com")
        #expect(channel1.description == "A minimal podcast feed.")

        // Step 2: Generate XML from the parsed model
        let generatedXML = try generator.generate(feed1)
        #expect(generatedXML.contains("<title>Minimal Show</title>"))

        // Step 3: Parse the generated XML
        let feed2 = try parser.parse(generatedXML)
        let channel2 = try #require(feed2.channel)

        // Step 4: Compare — zero data loss
        #expect(channel1.title == channel2.title)
        #expect(channel1.link == channel2.link)
        #expect(channel1.description == channel2.description)
        #expect(channel1.items.count == channel2.items.count)
    }

    // MARK: - All 7 Namespaces Round-Trip

    @Test("Parse then generate then parse — zero data loss on all 7 namespaces")
    func allNamespacesRoundTrip() throws {
        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Parse
        let feed1 = try parser.parse(Self.allNamespacesXML)
        let ch1 = try #require(feed1.channel)

        // Generate
        let xml = try generator.generate(feed1)

        // Re-parse
        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)

        // RSS 2.0 Core
        #expect(ch1.title == ch2.title)
        #expect(ch1.link == ch2.link)
        #expect(ch1.description == ch2.description)
        #expect(ch1.language == ch2.language)
        #expect(ch1.copyright == ch2.copyright)

        // iTunes Namespace
        #expect(ch1.itunesAuthor == ch2.itunesAuthor)
        #expect(ch1.itunesCategories == ch2.itunesCategories)
        #expect(ch1.itunesExplicit == ch2.itunesExplicit)
        #expect(ch1.itunesImage == ch2.itunesImage)
        #expect(ch1.itunesOwner == ch2.itunesOwner)
        #expect(ch1.itunesType == ch2.itunesType)

        // Atom
        #expect(ch1.atomLinks.count == ch2.atomLinks.count)
        if let a1 = ch1.atomLinks.first, let a2 = ch2.atomLinks.first {
            #expect(a1.href == a2.href)
            #expect(a1.rel == a2.rel)
        }

        // Dublin Core
        #expect(ch1.dublinCore?.creator == ch2.dublinCore?.creator)

        // Podcast NS 2.0
        #expect(ch1.podcastGuid == ch2.podcastGuid)
        #expect(ch1.locked == ch2.locked)
        #expect(ch1.medium == ch2.medium)
        #expect(ch1.funding == ch2.funding)
        #expect(ch1.persons == ch2.persons)

        // Items
        #expect(ch1.items.count == ch2.items.count)
        let item1 = try #require(ch1.items.first)
        let item2 = try #require(ch2.items.first)

        #expect(item1.title == item2.title)
        #expect(item1.enclosure == item2.enclosure)
        #expect(item1.guid == item2.guid)
        #expect(item1.itunesDuration == item2.itunesDuration)
        #expect(item1.itunesEpisode == item2.itunesEpisode)
        #expect(item1.itunesEpisodeType == item2.itunesEpisodeType)
        #expect(item1.itunesSeason == item2.itunesSeason)
        #expect(item1.dublinCore == item2.dublinCore)
        #expect(item1.transcripts == item2.transcripts)
        #expect(item1.persons == item2.persons)

        // Podlove Simple Chapters
        #expect(item1.podloveChapters == item2.podloveChapters)
        let chapters1 = try #require(item1.podloveChapters)
        let chapters2 = try #require(item2.podloveChapters)
        #expect(chapters1.chapters.count == 3)
        #expect(chapters1.chapters.count == chapters2.chapters.count)

        // Content Module
        #expect(item1.contentEncoded == item2.contentEncoded)
    }

    // MARK: - Modify and Preserve

    @Test("Parse then modify by adding an episode then generate then parse — changes preserved")
    func addEpisodeRoundTrip() throws {
        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Parse original
        var feed = try parser.parse(Self.minimalXML)
        #expect(feed.channel?.items.count == 0)

        // Add an episode
        let newEpisode = Item(
            title: "New Episode",
            description: "A freshly added episode.",
            enclosure: Enclosure(
                url: makeURL("https://example.com/new.mp3"),
                length: 10_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "new-ep-001", isPermaLink: false),
            itunesDuration: 900,
            itunesExplicit: false
        )
        feed.channel?.items.append(newEpisode)

        // Generate and re-parse
        let xml = try generator.generate(feed)
        let reparsed = try parser.parse(xml)

        #expect(reparsed.channel?.items.count == 1)
        let item = try #require(reparsed.channel?.items.first)
        #expect(item.title == "New Episode")
        #expect(item.description == "A freshly added episode.")
        #expect(item.guid?.value == "new-ep-001")
        #expect(item.guid?.isPermaLink == false)
        #expect(item.itunesDuration == 900)
        #expect(item.itunesExplicit == false)
        #expect(item.enclosure?.url.absoluteString == "https://example.com/new.mp3")
        #expect(item.enclosure?.length == 10_000_000)
        #expect(item.enclosure?.type == "audio/mpeg")
    }

    @Test("Parse then modify channel metadata then generate — changes reflected")
    func modifyMetadataRoundTrip() throws {
        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        var feed = try parser.parse(Self.allNamespacesXML)

        // Modify metadata
        feed.channel?.title = "Renamed Show"
        feed.channel?.language = "fr"
        feed.channel?.itunesAuthor = "Jean Animateur"
        feed.channel?.itunesExplicit = true

        // Round-trip
        let xml = try generator.generate(feed)
        let reparsed = try parser.parse(xml)
        let ch = try #require(reparsed.channel)

        #expect(ch.title == "Renamed Show")
        #expect(ch.language == "fr")
        #expect(ch.itunesAuthor == "Jean Animateur")
        #expect(ch.itunesExplicit == true)

        // Verify unchanged fields survived
        #expect(ch.copyright == "2026 Example Inc.")
        #expect(ch.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(ch.locked?.isLocked == true)
    }
}
