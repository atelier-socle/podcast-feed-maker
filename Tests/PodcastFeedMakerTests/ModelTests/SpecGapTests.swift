import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Channel Rating Tests

@Suite("Channel Rating Tests")
struct ChannelRatingTests {

    // MARK: - Model

    @Test("Channel rating defaults to nil")
    func ratingDefaultsNil() {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "desc"
        )
        #expect(channel.rating == nil)
    }

    @Test("Channel rating can be set via init")
    func ratingViaInit() {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "desc",
            rating: "(PICS-1.1 \"http://www.classify.org/safesurf/\" 1 r (SS~~000 1))"
        )
        #expect(channel.rating == "(PICS-1.1 \"http://www.classify.org/safesurf/\" 1 r (SS~~000 1))")
    }

    @Test("Channel rating is mutable")
    func ratingMutable() {
        var channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "desc"
        )
        channel.rating = "some rating"
        #expect(channel.rating == "some rating")
    }

    // MARK: - Generator

    @Test("Generator emits rating element when set")
    func generatorEmitsRating() throws {
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "desc",
                rating: "(PICS-1.1 \"http://www.classify.org/safesurf/\" 1 r (SS~~000 1))"
            ))
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("<rating>"))
        #expect(xml.contains("</rating>"))
        #expect(xml.contains("PICS-1.1"))
    }

    @Test("Generator omits rating element when nil")
    func generatorOmitsRating() throws {
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "desc"
            ))
        let xml = try FeedGenerator().generate(feed)
        #expect(!xml.contains("<rating>"))
    }

    @Test("Generator places rating between ttl and image")
    func generatorRatingOrdering() throws {
        let feed = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "desc",
                ttl: 60,
                rating: "test-rating",
                image: RSSImage(
                    url: URL(string: "https://example.com/img.jpg")!,
                    title: "Art",
                    link: URL(string: "https://example.com")!
                )
            ))
        let xml = try FeedGenerator().generate(feed)
        let ttlRange = try #require(xml.range(of: "<ttl>"))
        let ratingRange = try #require(xml.range(of: "<rating>"))
        let imageRange = try #require(xml.range(of: "<image>"))
        #expect(ttlRange.lowerBound < ratingRange.lowerBound)
        #expect(ratingRange.lowerBound < imageRange.lowerBound)
    }

    // MARK: - Parser

    @Test("Parser reads rating from XML")
    func parserReadsRating() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>desc</description>
                <rating>(PICS-1.1 "http://www.classify.org/safesurf/" 1 r (SS~~000 1))</rating>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)
        #expect(channel.rating == "(PICS-1.1 \"http://www.classify.org/safesurf/\" 1 r (SS~~000 1))")
    }

    @Test("Parser sets rating to nil when absent")
    func parserNilWhenAbsent() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>desc</description>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        #expect(feed.channel?.rating == nil)
    }

    // MARK: - Round-Trip

    @Test("Rating survives round-trip: generate → parse")
    func ratingRoundTrip() throws {
        let original = PodcastFeed(
            channel: Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "desc",
                rating: "(PICS-1.1 \"http://www.classify.org/safesurf/\" 1 r (SS~~000 1))"
            ))
        let xml = try FeedGenerator().generate(original)
        let reparsed = try FeedParser().parse(xml)
        #expect(reparsed.channel?.rating == original.channel?.rating)
    }
}

// MARK: - JSONChapterList Metadata Tests

@Suite("JSONChapterList Metadata Tests")
struct JSONChapterListMetadataTests {

    // MARK: - Model

    @Test("Default init has nil metadata fields")
    func defaultNilMetadata() {
        let list = JSONChapterList()
        #expect(list.title == nil)
        #expect(list.author == nil)
        #expect(list.podcastName == nil)
    }

    @Test("Init with all metadata fields")
    func initWithMetadata() {
        let list = JSONChapterList(
            title: "Episode 7 - Making Progress",
            author: "John Doe",
            podcastName: "John's Awesome Podcast",
            chapters: [JSONChapter(startTime: 0, title: "Intro")]
        )
        #expect(list.title == "Episode 7 - Making Progress")
        #expect(list.author == "John Doe")
        #expect(list.podcastName == "John's Awesome Podcast")
        #expect(list.chapters.count == 1)
    }

    @Test("Metadata fields are mutable")
    func metadataMutable() {
        var list = JSONChapterList()
        list.title = "My Episode"
        list.author = "Author"
        list.podcastName = "My Podcast"
        #expect(list.title == "My Episode")
        #expect(list.author == "Author")
        #expect(list.podcastName == "My Podcast")
    }

    // MARK: - Encode

    @Test("Encode includes metadata fields when set")
    func encodeWithMetadata() throws {
        let list = JSONChapterList(
            title: "Episode Title",
            author: "Jane Doe",
            podcastName: "Great Podcast",
            chapters: [JSONChapter(startTime: 0, title: "Start")]
        )
        let data = try JSONEncoder().encode(list)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["title"] as? String == "Episode Title")
        #expect(json["author"] as? String == "Jane Doe")
        #expect(json["podcastName"] as? String == "Great Podcast")
    }

    @Test("Encode omits metadata fields when nil")
    func encodeOmitsNilMetadata() throws {
        let list = JSONChapterList(chapters: [JSONChapter(startTime: 0)])
        let data = try JSONEncoder().encode(list)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["title"] == nil)
        #expect(json["author"] == nil)
        #expect(json["podcastName"] == nil)
    }

    // MARK: - Decode

    @Test("Decode reads metadata fields from JSON")
    func decodeWithMetadata() throws {
        let jsonString = """
            {
              "version": "1.2.0",
              "title": "Episode 7 - Making Progress",
              "author": "John Doe",
              "podcastName": "John's Awesome Podcast",
              "chapters": [
                { "startTime": 0, "title": "Intro" }
              ]
            }
            """
        let data = try #require(jsonString.data(using: .utf8))
        let list = try JSONDecoder().decode(JSONChapterList.self, from: data)
        #expect(list.title == "Episode 7 - Making Progress")
        #expect(list.author == "John Doe")
        #expect(list.podcastName == "John's Awesome Podcast")
        #expect(list.chapters.count == 1)
    }

    @Test("Decode handles missing metadata fields")
    func decodeMissingMetadata() throws {
        let jsonString = """
            {
              "version": "1.2.0",
              "chapters": []
            }
            """
        let data = try #require(jsonString.data(using: .utf8))
        let list = try JSONDecoder().decode(JSONChapterList.self, from: data)
        #expect(list.title == nil)
        #expect(list.author == nil)
        #expect(list.podcastName == nil)
    }

    // MARK: - Round-Trip

    @Test("Metadata survives encode → decode round-trip")
    func metadataRoundTrip() throws {
        let original = JSONChapterList(
            version: "1.2.0",
            title: "Episode Title",
            author: "Author Name",
            podcastName: "Podcast Name",
            chapters: [
                JSONChapter(startTime: 0, title: "Intro"),
                JSONChapter(startTime: 300, title: "Main")
            ]
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(JSONChapterList.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - Equatable

    @Test("Equality considers metadata fields")
    func equalityWithMetadata() {
        let a = JSONChapterList(title: "A", author: "X")
        let b = JSONChapterList(title: "A", author: "X")
        let c = JSONChapterList(title: "B", author: "X")
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - PodcastMedium Tests

@Suite("PodcastMedium Tests")
struct PodcastMediumTests {

    // MARK: - All 19 Cases

    @Test("All 19 cases exist")
    func allCasesCount() {
        #expect(PodcastMedium.allCases.count == 19)
    }

    @Test("Core types have correct rawValues")
    func coreRawValues() {
        #expect(PodcastMedium.podcast.rawValue == "podcast")
        #expect(PodcastMedium.music.rawValue == "music")
        #expect(PodcastMedium.video.rawValue == "video")
        #expect(PodcastMedium.film.rawValue == "film")
        #expect(PodcastMedium.audiobook.rawValue == "audiobook")
        #expect(PodcastMedium.newsletter.rawValue == "newsletter")
        #expect(PodcastMedium.blog.rawValue == "blog")
        #expect(PodcastMedium.publisher.rawValue == "publisher")
        #expect(PodcastMedium.course.rawValue == "course")
        #expect(PodcastMedium.mixed.rawValue == "mixed")
    }

    @Test("List variants have correct rawValues")
    func listRawValues() {
        #expect(PodcastMedium.podcastL.rawValue == "podcastL")
        #expect(PodcastMedium.musicL.rawValue == "musicL")
        #expect(PodcastMedium.videoL.rawValue == "videoL")
        #expect(PodcastMedium.filmL.rawValue == "filmL")
        #expect(PodcastMedium.audiobookL.rawValue == "audiobookL")
        #expect(PodcastMedium.newsletterL.rawValue == "newsletterL")
        #expect(PodcastMedium.blogL.rawValue == "blogL")
        #expect(PodcastMedium.courseL.rawValue == "courseL")
        #expect(PodcastMedium.publisherL.rawValue == "publisherL")
    }

    @Test("Init from rawValue works for all 19 cases")
    func initFromRawValue() {
        let rawValues = [
            "podcast", "music", "video", "film", "audiobook",
            "newsletter", "blog", "publisher", "course", "mixed",
            "podcastL", "musicL", "videoL", "filmL", "audiobookL",
            "newsletterL", "blogL", "courseL", "publisherL"
        ]
        for raw in rawValues {
            #expect(PodcastMedium(rawValue: raw) != nil, "Failed for: \(raw)")
        }
    }

    @Test("Init from invalid rawValue returns nil")
    func initInvalidRawValue() {
        #expect(PodcastMedium(rawValue: "unknown") == nil)
        #expect(PodcastMedium(rawValue: "") == nil)
    }

    // MARK: - Generator

    @Test("Generator emits new medium types")
    func generatorNewMediumTypes() throws {
        for medium in [PodcastMedium.course, .mixed, .podcastL, .musicL, .courseL] {
            var channel = Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "desc"
            )
            channel.medium = medium
            let feed = PodcastFeed(channel: channel)
            let xml = try FeedGenerator(
                namespaceMode: .explicit([.podcast])
            ).generate(feed)
            #expect(
                xml.contains("<podcast:medium>\(medium.rawValue)</podcast:medium>"),
                "Missing medium element for: \(medium.rawValue)"
            )
        }
    }

    // MARK: - Parser

    @Test("Parser reads new medium types")
    func parserNewMediumTypes() throws {
        let mediums: [PodcastMedium] = [.course, .mixed, .podcastL, .musicL, .courseL]
        for medium in mediums {
            let xml = """
                <?xml version="1.0" encoding="UTF-8"?>
                <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
                  <channel>
                    <title>Test</title>
                    <link>https://example.com</link>
                    <description>desc</description>
                    <podcast:medium>\(medium.rawValue)</podcast:medium>
                  </channel>
                </rss>
                """
            let feed = try FeedParser().parse(xml)
            #expect(
                feed.channel?.medium == medium,
                "Parser failed for: \(medium.rawValue)"
            )
        }
    }

    // MARK: - Round-Trip

    @Test("Medium round-trips for all 18 cases")
    func mediumRoundTrip() throws {
        for medium in PodcastMedium.allCases {
            var channel = Channel(
                title: "Test",
                link: URL(string: "https://example.com")!,
                description: "desc"
            )
            channel.medium = medium
            let feed = PodcastFeed(
                namespaces: [.podcast],
                channel: channel
            )
            let xml = try FeedGenerator().generate(feed)
            let reparsed = try FeedParser().parse(xml)
            #expect(
                reparsed.channel?.medium == medium,
                "Round-trip failed for: \(medium.rawValue)"
            )
        }
    }

    // MARK: - Codable

    @Test("Codable round-trip for new cases")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for medium in PodcastMedium.allCases {
            let data = try encoder.encode(medium)
            let decoded = try decoder.decode(PodcastMedium.self, from: data)
            #expect(decoded == medium, "Codable failed for: \(medium.rawValue)")
        }
    }
}
