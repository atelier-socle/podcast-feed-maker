// swiftlint:disable file_length
import Foundation
import PodcastFeedMaker
import Testing

// MARK: - Round-Trip Showcase

/// Comprehensive round-trip tests demonstrating parse-generate-parse fidelity.
///
/// Every test follows the same pattern: build or parse a feed, generate XML,
/// parse the XML back, and verify the result matches the original. This is
/// the gold standard for proving zero data loss across the full pipeline.
@Suite("Round-Trip Showcase")
struct RoundTripShowcaseTests { // swiftlint:disable:this type_body_length

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
                url: URL(string: "https://example.com/new.mp3")!,  // swiftlint:disable:this force_unwrapping
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

    // MARK: - Round-Trip Fidelity Features

    @Test("Unknown elements are preserved through round-trip")
    func unknownElementsRoundTrip() throws {
        // Use non-namespaced custom elements to avoid XMLParser namespace issues.
        // The parser captures any unrecognized elements as UnknownElement.
        let xmlWithCustom = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" \
            xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
            \t<title>Custom Elements Show</title>
            \t<link>https://example.com</link>
            \t<description>Has custom elements.</description>
            \t<myrating>5 stars</myrating>
            \t<item>
            \t\t<title>Episode with Custom</title>
            \t\t<enclosure url="https://example.com/ep.mp3" length="1000" type="audio/mpeg"/>
            \t\t<guid>ep-custom</guid>
            \t\t<mysponsor>ACME Corp</mysponsor>
            \t</item>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Parse — unknown elements should be captured
        let feed1 = try parser.parse(xmlWithCustom)
        let ch1 = try #require(feed1.channel)
        #expect(!ch1.unknownElements.isEmpty, "Channel should capture unknown elements")

        let channelUnknown = ch1.unknownElements.first { $0.name == "myrating" }
        #expect(channelUnknown?.textContent == "5 stars")

        let item1 = try #require(ch1.items.first)
        let itemUnknown = item1.unknownElements.first { $0.name == "mysponsor" }
        #expect(itemUnknown?.textContent == "ACME Corp")

        // Generate and re-parse
        let xml = try generator.generate(feed1)
        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)

        // Verify unknown elements survived
        let roundTrippedChannel = ch2.unknownElements.first { $0.name == "myrating" }
        #expect(roundTrippedChannel?.textContent == "5 stars")

        let item2 = try #require(ch2.items.first)
        let roundTrippedItem = item2.unknownElements.first { $0.name == "mysponsor" }
        #expect(roundTrippedItem?.textContent == "ACME Corp")
    }

    @Test("CDATA sections are preserved through round-trip")
    func cdataSectionsRoundTrip() throws {
        let xmlWithCDATA = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" \
            xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
            xmlns:content="http://purl.org/rss/1.0/modules/content/">
            <channel>
            \t<title>CDATA Show</title>
            \t<link>https://example.com</link>
            \t<description><![CDATA[A show with <em>HTML</em> in CDATA.]]></description>
            \t<item>
            \t\t<title>CDATA Episode</title>
            \t\t<description><![CDATA[Episode with <strong>bold</strong> text.]]></description>
            \t\t<enclosure url="https://example.com/ep.mp3" length="5000" type="audio/mpeg"/>
            \t\t<guid>ep-cdata</guid>
            \t\t<content:encoded><![CDATA[<h1>Full HTML</h1><p>Paragraph.</p>]]></content:encoded>
            \t</item>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        let feed1 = try parser.parse(xmlWithCDATA)
        let ch1 = try #require(feed1.channel)

        // Verify CDATA fields are tracked
        #expect(ch1.cdataFields.contains("description"))

        let item1 = try #require(ch1.items.first)
        #expect(item1.cdataFields.contains("description"))
        #expect(item1.contentEncoded?.value == "<h1>Full HTML</h1><p>Paragraph.</p>")

        // Generate and re-parse
        let xml = try generator.generate(feed1)
        #expect(xml.contains("CDATA"), "Generated XML should contain CDATA sections")

        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)
        let item2 = try #require(ch2.items.first)

        // Content survives — CDATA is transparent to the parser
        #expect(ch2.description.contains("HTML"))
        #expect(item2.description?.contains("bold") == true)
        #expect(item2.contentEncoded?.value == "<h1>Full HTML</h1><p>Paragraph.</p>")
    }

    @Test("XML comments are preserved through round-trip")
    func xmlCommentsRoundTrip() throws {
        let xmlWithComments = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
            \t<title>Comments Show</title>
            \t<link>https://example.com</link>
            \t<description>Has XML comments.</description>
            \t<!-- Channel-level comment -->
            \t<item>
            \t\t<title>Commented Episode</title>
            \t\t<enclosure url="https://example.com/ep.mp3" length="1000" type="audio/mpeg"/>
            \t\t<guid>ep-comment</guid>
            \t\t<!-- Item-level comment -->
            \t</item>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        let feed1 = try parser.parse(xmlWithComments)
        let ch1 = try #require(feed1.channel)
        #expect(!ch1.xmlComments.isEmpty, "Channel should capture XML comments")

        let item1 = try #require(ch1.items.first)
        #expect(!item1.xmlComments.isEmpty, "Item should capture XML comments")

        // Generate and re-parse
        let xml = try generator.generate(feed1)
        #expect(xml.contains("<!--"), "Generated XML should preserve comments")

        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)
        #expect(ch1.xmlComments == ch2.xmlComments)

        let item2 = try #require(ch2.items.first)
        #expect(item1.xmlComments == item2.xmlComments)
    }

    @Test("Namespace prefixes are preserved through round-trip in parsed mode")
    func namespacePrefixesRoundTrip() throws {
        let xmlWithPrefixes = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" \
            xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
            xmlns:podcast="https://podcastindex.org/namespace/1.0">
            <channel>
            \t<title>Prefix Show</title>
            \t<link>https://example.com</link>
            \t<description>Tests namespace prefix preservation.</description>
            \t<itunes:explicit>false</itunes:explicit>
            \t<podcast:locked>yes</podcast:locked>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .parsed)

        let feed = try parser.parse(xmlWithPrefixes)

        // Verify prefix mappings were captured
        #expect(!feed.namespacePrefixes.isEmpty, "Parser should capture namespace prefixes")

        // Generate with .parsed mode to use original prefixes
        let xml = try generator.generate(feed)

        // Verify the generated XML uses the expected prefixes
        #expect(xml.contains("xmlns:itunes="))
        #expect(xml.contains("xmlns:podcast="))

        // Re-parse and verify content
        let reparsed = try parser.parse(xml)
        #expect(reparsed.channel?.itunesExplicit == false)
        #expect(reparsed.channel?.locked?.isLocked == true)
    }

    // MARK: - JSON Codable Round-Trip

    @Test("XML to JSON to XML round-trip via Codable")
    func jsonCodableRoundTrip() throws {
        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Parse XML to model
        let feed1 = try parser.parse(Self.allNamespacesXML)

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(feed1)
        #expect(jsonData.count > 0, "JSON encoding should produce data")

        // Decode from JSON
        let decoder = JSONDecoder()
        let feed2 = try decoder.decode(PodcastFeed.self, from: jsonData)

        // Verify model equality
        #expect(feed1.version == feed2.version)
        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.itunesAuthor == feed2.channel?.itunesAuthor)
        #expect(feed1.channel?.podcastGuid == feed2.channel?.podcastGuid)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)

        // Generate XML from the JSON-decoded model
        let xml2 = try generator.generate(feed2)
        let feed3 = try parser.parse(xml2)

        // Full round-trip: XML -> JSON -> XML -> Parse
        #expect(feed3.channel?.title == feed1.channel?.title)
        #expect(feed3.channel?.items.first?.podloveChapters == feed1.channel?.items.first?.podloveChapters)
    }

    // MARK: - FeedDiff Tests

    @Test("FeedDiff — detect channel metadata changes")
    func diffDetectsChannelChanges() throws {
        let parser = FeedParser()

        let feed1 = try parser.parse(Self.allNamespacesXML)
        var feed2 = feed1
        feed2.channel?.title = "Changed Title"
        feed2.channel?.language = "de"

        let diff = FeedDiff()
        let differences = diff.diff(feed1, feed2)

        #expect(!differences.isEmpty, "Should detect changes")

        let titleChange = differences.first { $0.field == "channel.title" }
        #expect(titleChange != nil, "Should detect title change")
        #expect(titleChange?.changeType == .modified)
        #expect(titleChange?.oldValue == "Full Namespace Show")
        #expect(titleChange?.newValue == "Changed Title")

        let langChange = differences.first { $0.field == "channel.language" }
        #expect(langChange != nil, "Should detect language change")
        #expect(langChange?.changeType == .modified)
        #expect(langChange?.oldValue == "en")
        #expect(langChange?.newValue == "de")
    }

    @Test("FeedDiff — detect added, removed, and modified episodes")
    func diffDetectsEpisodeChanges() throws {
        let parser = FeedParser()

        // Feed with 1 episode
        let feed1 = try parser.parse(Self.allNamespacesXML)

        // Add a second episode and modify the first
        var feed2 = feed1
        feed2.channel?.items[0].title = "Episode 1 — Updated"

        let newItem = Item(
            title: "Episode 2 — Brand New",
            enclosure: Enclosure(
                url: URL(string: "https://example.com/ep2.mp3")!,  // swiftlint:disable:this force_unwrapping
                length: 30_000_000,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-002", isPermaLink: false)
        )
        feed2.channel?.items.append(newItem)

        let diff = FeedDiff()
        let differences = diff.diff(feed1, feed2)

        // Should detect the title modification on the existing episode
        let titleMod = differences.first {
            $0.field.contains("ep-001") && $0.field.contains("title")
        }
        #expect(titleMod?.changeType == .modified)

        // Should detect the new episode
        let addedEp = differences.first {
            $0.changeType == .added && $0.field.contains("Episode 2")
        }
        #expect(addedEp != nil, "Should detect added episode")
    }

    @Test("FeedDiff — detect namespace differences in channel")
    func diffDetectsNamespaceDifferences() throws {
        let parser = FeedParser()

        let feed1 = try parser.parse(Self.allNamespacesXML)
        var feed2 = feed1

        // Remove podcast:guid and change locked status
        feed2.channel?.podcastGuid = PodcastGuid(value: "changed-guid")
        feed2.channel?.locked = Locked(isLocked: false, owner: "new@example.com")

        let diff = FeedDiff()
        let differences = diff.diff(feed1, feed2)

        let guidChange = differences.first { $0.field == "channel.podcastGuid" }
        #expect(guidChange?.changeType == .modified)

        let lockedChange = differences.first { $0.field == "channel.locked" }
        #expect(lockedChange?.changeType == .modified)
    }

    @Test("FeedDiff — identical feeds show no differences")
    func diffIdenticalFeeds() throws {
        let parser = FeedParser()
        let feed = try parser.parse(Self.allNamespacesXML)

        let diff = FeedDiff()
        let differences = diff.diff(feed, feed)

        #expect(differences.isEmpty, "Identical feeds should produce zero differences")
    }

    @Test("FeedDiff — diff from XML strings")
    func diffFromXMLStrings() throws {
        let xml1 = Self.minimalXML
        let xml2 = Self.minimalXML.replacingOccurrences(
            of: "Minimal Show", with: "Updated Show"
        )

        let diff = FeedDiff()
        let differences = try diff.diff(xml: xml1, xml: xml2)

        #expect(!differences.isEmpty)
        let titleChange = differences.first { $0.field == "channel.title" }
        #expect(titleChange?.changeType == .modified)
        #expect(titleChange?.oldValue == "Minimal Show")
        #expect(titleChange?.newValue == "Updated Show")
    }

    // MARK: - Multi-Episode Round-Trip

    @Test("Round-trip preserves episode ordering and all per-item metadata")
    func multiEpisodeRoundTrip() throws { // swiftlint:disable:this function_body_length
        // Build a feed programmatically with multiple episodes
        let feedURL = URL(string: "https://example.com")!  // swiftlint:disable:this force_unwrapping
        let channel = Channel(
            title: "Multi-Episode Show",
            link: feedURL,
            description: "A show with multiple episodes for round-trip testing.",
            language: "en",
            items: [
                Item(
                    title: "Episode 3 — Latest",
                    enclosure: Enclosure(
                        url: URL(string: "https://example.com/ep3.mp3")!,  // swiftlint:disable:this force_unwrapping
                        length: 50_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-003", isPermaLink: false),
                    itunesDuration: 2700,
                    itunesEpisode: 3,
                    itunesEpisodeType: .full,
                    itunesSeason: 2
                ),
                Item(
                    title: "Episode 2 — Middle",
                    enclosure: Enclosure(
                        url: URL(string: "https://example.com/ep2.mp3")!,  // swiftlint:disable:this force_unwrapping
                        length: 40_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-002", isPermaLink: false),
                    itunesDuration: 1800,
                    itunesEpisode: 2,
                    itunesEpisodeType: .full,
                    itunesSeason: 1
                ),
                Item(
                    title: "Trailer",
                    enclosure: Enclosure(
                        url: URL(string: "https://example.com/trailer.mp3")!,  // swiftlint:disable:this force_unwrapping
                        length: 5_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "trailer-001", isPermaLink: false),
                    itunesDuration: 120,
                    itunesEpisodeType: .trailer
                )
            ],
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)

        let generator = FeedGenerator(namespaceMode: .auto)
        let parser = FeedParser()

        // Round-trip
        let xml = try generator.generate(feed)
        let reparsed = try parser.parse(xml)
        let ch = try #require(reparsed.channel)

        // Episode count and ordering
        #expect(ch.items.count == 3)
        #expect(ch.items[0].title == "Episode 3 — Latest")
        #expect(ch.items[1].title == "Episode 2 — Middle")
        #expect(ch.items[2].title == "Trailer")

        // Per-item metadata
        #expect(ch.items[0].itunesEpisode == 3)
        #expect(ch.items[0].itunesSeason == 2)
        #expect(ch.items[0].itunesEpisodeType == .full)
        #expect(ch.items[2].itunesEpisodeType == .trailer)
        #expect(ch.items[2].itunesDuration == 120)
    }

    // MARK: - Streaming Generator Round-Trip

    @Test("Streaming generator produces valid XML that parses back correctly")
    func streamingGeneratorRoundTrip() async throws {
        let parser = FeedParser()
        let feed = try parser.parse(Self.allNamespacesXML)

        // Generate via streaming
        let engine = PodcastFeedEngine()
        let stream = engine.generateStream(feed)

        var chunks: [String] = []
        for try await chunk in stream {
            chunks.append(chunk)
        }

        #expect(chunks.count >= 3, "Stream should yield at least header, item, and footer")

        // Concatenate and parse
        let streamedXML = chunks.joined()
        let reparsed = try parser.parse(streamedXML)

        #expect(reparsed.channel?.title == feed.channel?.title)
        #expect(reparsed.channel?.items.count == feed.channel?.items.count)
    }
}
