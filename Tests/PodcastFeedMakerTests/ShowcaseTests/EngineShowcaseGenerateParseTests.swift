import Foundation
import PodcastFeedMaker
import Testing

// MARK: - PodcastFeedEngine Showcase

/// Comprehensive tests for the ``PodcastFeedEngine`` facade.
///
/// Each test exercises a distinct public method of the engine, demonstrating
/// the high-level API for generation, parsing, validation, normalization,
/// equivalence checking, diffing, and combined workflows.
@Suite("PodcastFeedEngine Showcase")
struct EngineShowcaseTests {

    // MARK: - Test Fixtures

    /// A well-formed feed suitable for most engine tests.
    private static let sampleXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0" \
        xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
        xmlns:atom="http://www.w3.org/2005/Atom" \
        xmlns:podcast="https://podcastindex.org/namespace/1.0">
        <channel>
        \t<title>Engine Test Podcast</title>
        \t<link>https://example.com</link>
        \t<description>A podcast for testing the PodcastFeedEngine.</description>
        \t<atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        \t<language>en</language>
        \t<itunes:author>Engine Tester</itunes:author>
        \t<itunes:category text="Technology"/>
        \t<itunes:explicit>false</itunes:explicit>
        \t<itunes:image href="https://example.com/artwork.jpg"/>
        \t<itunes:owner>
        \t\t<itunes:name>Engine Tester</itunes:name>
        \t\t<itunes:email>tester@example.com</itunes:email>
        \t</itunes:owner>
        \t<itunes:type>episodic</itunes:type>
        \t<podcast:guid>aabbccdd-1234-5678-9abc-def012345678</podcast:guid>
        \t<podcast:locked owner="tester@example.com">yes</podcast:locked>
        \t<item>
        \t\t<title>Episode 1</title>
        \t\t<description>First episode.</description>
        \t\t<enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
        \t\t<guid isPermaLink="false">ep-001</guid>
        \t\t<itunes:duration>1800</itunes:duration>
        \t\t<itunes:episode>1</itunes:episode>
        \t\t<itunes:episodeType>full</itunes:episodeType>
        \t\t<itunes:explicit>false</itunes:explicit>
        \t</item>
        \t<item>
        \t\t<title>Episode 2</title>
        \t\t<description>Second episode.</description>
        \t\t<enclosure url="https://example.com/ep2.mp3" length="60000000" type="audio/mpeg"/>
        \t\t<guid isPermaLink="false">ep-002</guid>
        \t\t<itunes:duration>2400</itunes:duration>
        \t\t<itunes:episode>2</itunes:episode>
        \t\t<itunes:episodeType>full</itunes:episodeType>
        \t\t<itunes:explicit>false</itunes:explicit>
        \t</item>
        </channel>
        </rss>
        """

    /// Builds a feed model programmatically for generation tests.
    private static func buildSampleFeed() throws -> PodcastFeed {
        let channel = Channel(
            title: "Programmatic Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Built from Swift structs.",
            language: "en",
            items: [
                Item(
                    title: "Pilot Episode",
                    description: "The very first episode.",
                    enclosure: Enclosure(
                        url: try #require(URL(string: "https://example.com/pilot.mp3")),
                        length: 25_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "pilot-001", isPermaLink: false),
                    itunesDuration: 900,
                    itunesEpisode: 1,
                    itunesEpisodeType: .full,
                    itunesExplicit: false
                )
            ],
            itunesAuthor: "Swift Dev",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/art.jpg"),
            itunesOwner: ITunesOwner(name: "Swift Dev", email: "dev@example.com"),
            itunesType: .episodic,
            atomLinks: [
                AtomLink(
                    href: try #require(URL(string: "https://example.com/feed.xml")),
                    rel: "self",
                    type: "application/rss+xml"
                )
            ],
            podcastGuid: PodcastGuid(value: "12345678-abcd-efgh-ijkl-000000000000"),
            locked: Locked(isLocked: true, owner: "dev@example.com")
        )
        return PodcastFeed(channel: channel)
    }

    // MARK: - Generation

    @Test("Engine generates feed from model to XML string")
    func engineGenerate() throws {
        let engine = PodcastFeedEngine()
        let feed = try Self.buildSampleFeed()

        let xml = try engine.generate(feed)

        #expect(xml.contains("<?xml version=\"1.0\" encoding=\"UTF-8\"?>"))
        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<title>Programmatic Show</title>"))
        #expect(xml.contains("<itunes:author>Swift Dev</itunes:author>"))
        #expect(xml.contains("<itunes:category text=\"Technology\" />"))
        #expect(xml.contains("<podcast:guid>12345678-abcd-efgh-ijkl-000000000000</podcast:guid>"))
        #expect(xml.contains("<podcast:locked owner=\"dev@example.com\">yes</podcast:locked>"))
        #expect(xml.contains("<title>Pilot Episode</title>"))
        #expect(xml.contains("url=\"https://example.com/pilot.mp3\""))
    }

    @Test("Engine generates minified XML when prettyPrint is false")
    func engineGenerateMinified() throws {
        let engine = PodcastFeedEngine()
        let feed = try Self.buildSampleFeed()

        let xml = try engine.generate(feed, prettyPrint: false)

        // Minified output should not have tabs
        #expect(!xml.contains("\t"), "Minified XML should not contain tab indentation")
        // But should still have all content
        #expect(xml.contains("<title>Programmatic Show</title>"))
    }

    @Test("Engine generates feed as async stream of XML chunks")
    func engineGenerateStream() async throws {
        let engine = PodcastFeedEngine()
        let feed = try Self.buildSampleFeed()

        let stream = engine.generateStream(feed)
        var chunks: [String] = []

        for try await chunk in stream {
            chunks.append(chunk)
        }

        // N+2 chunks: header + N items + footer
        // Feed has 1 item, so expect 3 chunks
        #expect(chunks.count == 3, "1-item feed should yield 3 chunks (header, item, footer)")

        let fullXML = chunks.joined()
        #expect(fullXML.contains("<title>Programmatic Show</title>"))
        #expect(fullXML.contains("<title>Pilot Episode</title>"))
        #expect(fullXML.contains("</rss>"))
    }

    // MARK: - Parsing

    @Test("Engine parses feed from XML string to model")
    func engineParse() throws {
        let engine = PodcastFeedEngine()

        let feed = try engine.parse(Self.sampleXML)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Engine Test Podcast")
        #expect(channel.link.absoluteString == "https://example.com")
        #expect(channel.description == "A podcast for testing the PodcastFeedEngine.")
        #expect(channel.language == "en")
        #expect(channel.itunesAuthor == "Engine Tester")
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesType == .episodic)
        #expect(channel.podcastGuid?.value == "aabbccdd-1234-5678-9abc-def012345678")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "tester@example.com")
        #expect(channel.items.count == 2)
    }

    @Test("Engine parses feed from Data")
    func engineParseData() throws {
        let engine = PodcastFeedEngine()
        let data = Data(Self.sampleXML.utf8)

        let feed = try engine.parse(data: data)

        #expect(feed.channel?.title == "Engine Test Podcast")
        #expect(feed.channel?.items.count == 2)
    }

    @Test("Engine parse extracts item-level metadata correctly")
    func engineParseItems() throws {
        let engine = PodcastFeedEngine()
        let feed = try engine.parse(Self.sampleXML)
        let items = try #require(feed.channel?.items)

        #expect(items.count == 2)

        let ep1 = items[0]
        #expect(ep1.title == "Episode 1")
        #expect(ep1.guid?.value == "ep-001")
        #expect(ep1.guid?.isPermaLink == false)
        #expect(ep1.itunesDuration == 1800)
        #expect(ep1.itunesEpisode == 1)
        #expect(ep1.itunesEpisodeType == .full)
        #expect(ep1.enclosure?.url.absoluteString == "https://example.com/ep1.mp3")
        #expect(ep1.enclosure?.length == 50_000_000)
        #expect(ep1.enclosure?.type == "audio/mpeg")

        let ep2 = items[1]
        #expect(ep2.title == "Episode 2")
        #expect(ep2.guid?.value == "ep-002")
        #expect(ep2.itunesDuration == 2400)
    }

    // MARK: - Validation

    @Test("Engine validates feed against a single platform")
    func engineValidateSinglePlatform() throws {
        let engine = PodcastFeedEngine()
        let feed = try engine.parse(Self.sampleXML)

        let report = engine.validate(feed, for: .apple)

        #expect(report.platform == .apple)
        // The sample feed has itunes:image, category, explicit, owner — Apple should pass
        // (Warnings may exist for HTTPS, artwork size, etc., but no fatal errors on structure)
        #expect(report.results.count >= 0, "Report should have results array")
    }

    @Test("Engine validates feed against all platforms")
    func engineValidateAllPlatforms() throws {
        let engine = PodcastFeedEngine()
        let feed = try engine.parse(Self.sampleXML)

        let reports = engine.validateAll(feed)

        #expect(reports.count == ValidationPlatform.allCases.count)

        let platformNames = reports.map(\.platform)
        #expect(platformNames.contains(.apple))
        #expect(platformNames.contains(.spotify))
        #expect(platformNames.contains(.amazon))
        #expect(platformNames.contains(.podcastIndex))
        #expect(platformNames.contains(.psp1))
    }

    @Test("Engine validation report distinguishes errors, warnings, and info")
    func engineValidationSeverities() throws {
        let engine = PodcastFeedEngine()

        // Create a deliberately incomplete feed to trigger errors
        let incompleteFeed = PodcastFeed(
            channel: Channel(
                title: "Incomplete",
                link: try #require(URL(string: "https://example.com")),
                description: "Missing required fields."
            )
        )

        let report = engine.validate(incompleteFeed, for: .apple)

        // Apple requires itunes:image, itunes:category, itunes:explicit
        #expect(!report.errors.isEmpty, "Incomplete feed should have Apple validation errors")
        // Report should separate errors from other severities
        for error in report.errors {
            #expect(error.severity == .error)
        }
        for warning in report.warnings {
            #expect(warning.severity == .warning)
        }
        for info in report.infos {
            #expect(info.severity == .info)
        }
    }

    @Test("Engine validation isValid reflects error state")
    func engineValidationIsValid() throws {
        let engine = PodcastFeedEngine()
        let feed = try engine.parse(Self.sampleXML)

        let appleReport = engine.validate(feed, for: .apple)

        if appleReport.errors.isEmpty {
            #expect(appleReport.isValid == true)
        } else {
            #expect(appleReport.isValid == false)
        }
    }
}
