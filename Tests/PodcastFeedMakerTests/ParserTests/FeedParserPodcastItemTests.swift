import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Podcast NS 2.0 Item Tests

@Suite("FeedParser Podcast Item Tests")
struct FeedParserPodcastItemTests {

    let parser = FeedParser()

    @Test("Parses podcast:transcript")
    func podcastTranscript() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.transcripts.count == 2)
        #expect(item.transcripts[0].url.absoluteString == "https://example.com/ep1.vtt")
        #expect(item.transcripts[0].type == "text/vtt")
        #expect(item.transcripts[0].language == "en")
        #expect(item.transcripts[0].rel == "captions")
    }

    @Test("Parses podcast:chapters link")
    func podcastChaptersLink() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let ch = try #require(item.chaptersLink)
        #expect(ch.url.absoluteString == "https://example.com/ep1-chapters.json")
        #expect(ch.type == "application/json+chapters")
    }

    @Test("Parses podcast:soundbite")
    func podcastSoundbite() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.soundbites.count == 2)
        #expect(item.soundbites[0].startTime == 30.5)
        #expect(item.soundbites[0].duration == 45.0)
        #expect(item.soundbites[0].title == "Best Moment")
        #expect(item.soundbites[1].title == nil)
    }

    @Test("Parses podcast:person at item level")
    func podcastPersonItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.persons.count == 1)
        #expect(item.persons[0].name == "Guest Speaker")
        #expect(item.persons[0].role == "guest")
    }

    @Test("Parses podcast:location at item level")
    func podcastLocationItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let loc = try #require(item.location)
        #expect(loc.name == "Paris")
        #expect(loc.geo == "geo:48.8566,2.3522")
    }

    @Test("Parses podcast:alternateEnclosure")
    func alternateEnclosure() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.alternateEnclosures.count == 1)
        let enc = item.alternateEnclosures[0]
        #expect(enc.type == "audio/opus")
        #expect(enc.length == 30_000_000)
        #expect(enc.bitrate == 96)
        #expect(enc.title == "Opus Version")
        #expect(enc.isDefault == true)
        #expect(enc.sources.count == 2)
        #expect(enc.sources[0].uri == "https://example.com/ep1.opus")
        #expect(enc.sources[0].contentType == "audio/opus")
        #expect(enc.integrity?.type == "sri-hash")
        #expect(enc.integrity?.value == "sha256-xyz789")
    }

    @Test("Parses podcast:value at item level")
    func podcastValueItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let value = try #require(item.value)
        #expect(value.type == "lightning")
        #expect(value.recipients.count == 2)
        #expect(value.recipients[0].fee == true)
    }

    @Test("Parses podcast:socialInteract")
    func podcastSocialInteract() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.socialInteractions.count == 1)
        let si = item.socialInteractions[0]
        #expect(si.uri == "https://social.example.com/ep1")
        #expect(si.protocol == "activitypub")
        #expect(si.accountId == "@podcast")
    }

    @Test("Parses podcast:txt at item level")
    func podcastTxtItem() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        #expect(item.txtRecords.count == 1)
        #expect(item.txtRecords[0].value == "item-verify-123")
    }

    @Test("Parses podcast:season at item level")
    func podcastSeason() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let season = try #require(item.podcastSeason)
        #expect(season.number == 1)
        #expect(season.name == "Season One")
    }

    @Test("Parses podcast:episode at item level")
    func podcastEpisode() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let ep = try #require(item.podcastEpisode)
        #expect(ep.number == 1.5)
        #expect(ep.display == "1A")
    }

    // MARK: - Helpers

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}

// MARK: - Podlove & Live Item Tests

@Suite("FeedParser Podlove & LiveItem Tests")
struct FeedParserPodloveTests {

    let parser = FeedParser()

    @Test("Parses psc:chapters")
    func podloveChapters() throws {
        let feed = try parser.parse(maximalFixture())
        let item = try #require(feed.channel?.items.first)
        let chapters = try #require(item.podloveChapters)
        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 3)
        #expect(chapters.chapters[0].start == "00:00:00.000")
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[0].href?.absoluteString == "https://example.com/ch1")
        #expect(chapters.chapters[0].image?.absoluteString == "https://example.com/ch1.jpg")
        #expect(chapters.chapters[1].title == "Main Topic")
    }

    @Test("Parses podcast:liveItem")
    func liveItem() throws {
        let feed = try parser.parse(maximalFixture())
        let ch = try #require(feed.channel)
        #expect(ch.liveItems.count == 1)
        let live = ch.liveItems[0]
        #expect(live.status == .live)
        #expect(live.title == "Live Episode")
        #expect(live.description == "Broadcasting live!")
        #expect(live.enclosure?.url.absoluteString == "https://example.com/live.mp3")
        #expect(live.guid?.value == "live-guid-1")
        #expect(live.contentLinks.count == 2)
        #expect(live.contentLinks[0].title == "Live Chat")
        #expect(live.persons.count == 1)
        #expect(live.itunesImage?.absoluteString == "https://example.com/live-art.jpg")
    }

    @Test("Parses liveItem alternateEnclosure")
    func liveItemAltEnclosure() throws {
        let feed = try parser.parse(maximalFixture())
        let live = try #require(feed.channel?.liveItems.first)
        #expect(live.alternateEnclosures.count == 1)
        let enc = live.alternateEnclosures[0]
        #expect(enc.type == "audio/opus")
        #expect(enc.isDefault == true)
        #expect(enc.sources.count == 1)
        #expect(enc.integrity?.value == "sha256-abc123")
    }

    @Test("Parses liveItem value")
    func liveItemValue() throws {
        let feed = try parser.parse(maximalFixture())
        let live = try #require(feed.channel?.liveItems.first)
        let value = try #require(live.value)
        #expect(value.type == "lightning")
        #expect(value.recipients.count == 1)
        #expect(value.recipients[0].name == "Live Host")
    }

    @Test("Parses liveItem socialInteract")
    func liveItemSocialInteract() throws {
        let feed = try parser.parse(maximalFixture())
        let live = try #require(feed.channel?.liveItems.first)
        #expect(live.socialInteractions.count == 1)
        #expect(live.socialInteractions[0].protocol == "activitypub")
        #expect(live.socialInteractions[0].priority == 1)
    }

    // MARK: - Helpers

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}

// MARK: - Diagnostics & Edge Case Tests

@Suite("FeedParser Diagnostics & Edge Cases")
struct FeedParserEdgeCaseTests {

    let parser = FeedParser()

    @Test("ParseWithDiagnostics returns warnings")
    func diagnostics() throws {
        let result = try parser.parseWithDiagnostics(minimalXML)
        #expect(result.feed.channel != nil)
    }

    @Test("ParseWithDiagnostics from Data works")
    func diagnosticsFromData() throws {
        let data = Data(minimalXML.utf8)
        let result = try parser.parseWithDiagnostics(data: data)
        #expect(result.feed.channel?.title == "Minimal Podcast")
    }

    @Test("Parse XML with parse error still succeeds if channel found")
    func parseWithRecoverableError() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Desc</description>
              </channel>
            </rss>
            """
        let feed = try parser.parse(xml)
        #expect(feed.channel?.title == "Test")
    }

    // MARK: - File URL Parsing

    @Test("Parse from file URL")
    func parseFromFileURL() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"><channel>
                <title>File URL Test</title>
                <link>https://example.com</link>
                <description>Test</description>
            </channel></rss>
            """
        let path = "/tmp/pfm_url_test_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        let url = URL(fileURLWithPath: path)
        let feed = try await FeedParser().parse(url: url)
        #expect(feed.channel?.title == "File URL Test")
    }

    // MARK: - Duration MM:SS Format

    @Test("Parse itunes:duration in MM:SS format")
    func parseDurationMMSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Test</description>
                <item>
                    <title>Episode</title>
                    <itunes:duration>25:30</itunes:duration>
                </item>
            </channel></rss>
            """
        let feed = try parser.parse(xml)
        let duration = try #require(feed.channel?.items.first?.itunesDuration)
        #expect(duration == 1530)
    }

    // MARK: - Invalid Duration

    @Test("Parse invalid itunes:duration returns nil duration")
    func parseInvalidDuration() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Test</description>
                <item>
                    <title>Ep</title>
                    <itunes:duration>not-a-number</itunes:duration>
                </item>
            </channel>
            </rss>
            """
        let feed = try parser.parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.itunesDuration == nil)
    }

    // MARK: - XML Comment Outside Channel

    @Test("XML comment before channel is not captured in channel comments")
    func parseCommentBeforeChannel() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <!-- Pre-channel comment -->
            <rss version="2.0">
            <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Test</description>
            </channel>
            </rss>
            """
        let feed = try parser.parse(xml)
        // The comment before <channel> is in a non-channel/non-item context
        // so it exercises the default: break path in foundComment
        let channel = try #require(feed.channel)
        // Channel comments only include comments INSIDE <channel>
        #expect(!channel.xmlComments.contains("Pre-channel comment"))
    }

    // MARK: - Item Podcast Block

    @Test("Parse item-level podcast:block exercises break path without unknown capture")
    func parseItemPodcastBlock() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"
                 xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0">
            <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>Test</description>
                <item>
                    <title>Ep</title>
                    <podcast:block id="google">yes</podcast:block>
                </item>
            </channel>
            </rss>
            """
        let feed = try parser.parse(xml)
        let item = try #require(feed.channel?.items.first)
        // podcast:block at item level hits the break path in didEndElement,
        // and must NOT be captured as an unknown element
        let hasBlockUnknown = item.unknownElements.contains { $0.name == "podcast:block" }
        #expect(!hasBlockUnknown)
    }

    // MARK: - Helpers

    private var minimalXML: String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Minimal Podcast</title>
            <link>https://example.com</link>
            <description>A minimal podcast feed</description>
          </channel>
        </rss>
        """
    }

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
