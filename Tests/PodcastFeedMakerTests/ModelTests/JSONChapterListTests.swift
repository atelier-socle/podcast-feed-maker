import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - JSONChapterListTests

@Suite("JSONChapterList Tests")
struct JSONChapterListTests {

    // MARK: - Encode

    @Test("Encode JSONChapterList to JSON contains version and chapters")
    func encodeToJSON() throws {
        let list = JSONChapterList(version: "1.2.0", chapters: [
            JSONChapter(startTime: 0, title: "Intro"),
            JSONChapter(startTime: 300, title: "Main Topic"),
        ])
        let data = try JSONEncoder().encode(list)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["version"] as? String == "1.2.0")
        let chapters = try #require(json["chapters"] as? [[String: Any]])
        #expect(chapters.count == 2)
        #expect(chapters[0]["startTime"] as? Double == 0)
        #expect(chapters[0]["title"] as? String == "Intro")
        #expect(chapters[1]["startTime"] as? Double == 300)
        #expect(chapters[1]["title"] as? String == "Main Topic")
    }

    // MARK: - Decode

    @Test("Decode JSONChapterList from JSON string")
    func decodeFromJSON() throws {
        let jsonString = """
            {
              "version": "1.2.0",
              "chapters": [
                { "startTime": 0, "title": "Intro" },
                { "startTime": 120.5, "title": "Topic One" }
              ]
            }
            """
        let data = try #require(jsonString.data(using: .utf8))
        let list = try JSONDecoder().decode(JSONChapterList.self, from: data)
        #expect(list.version == "1.2.0")
        #expect(list.chapters.count == 2)
        #expect(list.chapters[0].startTime == 0)
        #expect(list.chapters[0].title == "Intro")
        #expect(list.chapters[1].startTime == 120.5)
        #expect(list.chapters[1].title == "Topic One")
    }

    // MARK: - Round-Trip

    @Test("Round-trip encode then decode preserves equality")
    func roundTrip() throws {
        let original = JSONChapterList(version: "1.2.0", chapters: [
            JSONChapter(startTime: 0, title: "Intro"),
            JSONChapter(
                startTime: 60,
                title: "Chapter 1",
                endTime: 120,
                url: URL(string: "https://example.com/ch1"),
                img: URL(string: "https://example.com/ch1.jpg"),
                toc: true,
                location: PodcastLocation(
                    name: "Austin, TX",
                    geo: "geo:30.2672,-97.7431",
                    osm: "R113314"
                )
            ),
        ])
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(
            JSONChapterList.self, from: data
        )
        #expect(decoded == original)
    }

    // MARK: - All Optional Fields

    @Test("JSONChapter with all optional fields encodes correctly")
    func allOptionalFields() throws {
        let chapter = JSONChapter(
            startTime: 180,
            title: "Deep Dive",
            endTime: 360,
            url: URL(string: "https://example.com/deep"),
            img: URL(string: "https://example.com/deep.png"),
            toc: false,
            location: PodcastLocation(
                name: "New York",
                geo: "geo:40.7128,-74.0060",
                osm: "R175905"
            )
        )
        let data = try JSONEncoder().encode(chapter)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["startTime"] as? Double == 180)
        #expect(json["title"] as? String == "Deep Dive")
        #expect(json["endTime"] as? Double == 360)
        #expect(json["url"] as? String == "https://example.com/deep")
        #expect(json["img"] as? String == "https://example.com/deep.png")
        #expect(json["toc"] as? Bool == false)
        let location = try #require(json["location"] as? [String: Any])
        #expect(location["name"] as? String == "New York")
        #expect(location["geo"] as? String == "geo:40.7128,-74.0060")
        #expect(location["osm"] as? String == "R175905")
    }

    // MARK: - Required Fields Only

    @Test("JSONChapter with only required fields")
    func requiredFieldsOnly() throws {
        let chapter = JSONChapter(startTime: 42.5)
        let data = try JSONEncoder().encode(chapter)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["startTime"] as? Double == 42.5)
        #expect(json["title"] == nil)
        #expect(json["endTime"] == nil)
        #expect(json["url"] == nil)
        #expect(json["img"] == nil)
        #expect(json["toc"] == nil)
        #expect(json["location"] == nil)
    }

    @Test("JSONChapter with startTime and title only")
    func startTimeAndTitleOnly() throws {
        let chapter = JSONChapter(startTime: 0, title: "Welcome")
        let data = try JSONEncoder().encode(chapter)
        let decoded = try JSONDecoder().decode(
            JSONChapter.self, from: data
        )
        #expect(decoded.startTime == 0)
        #expect(decoded.title == "Welcome")
        #expect(decoded.endTime == nil)
        #expect(decoded.url == nil)
        #expect(decoded.img == nil)
        #expect(decoded.toc == nil)
        #expect(decoded.location == nil)
    }

    // MARK: - Empty Chapters

    @Test("Empty chapters array")
    func emptyChapters() throws {
        let list = JSONChapterList(chapters: [])
        #expect(list.version == "1.2.0")
        #expect(list.chapters.isEmpty)
        let data = try JSONEncoder().encode(list)
        let decoded = try JSONDecoder().decode(
            JSONChapterList.self, from: data
        )
        #expect(decoded == list)
    }

    // MARK: - Location Sub-Object

    @Test("Location with name only round-trips")
    func locationNameOnly() throws {
        let chapter = JSONChapter(
            startTime: 10,
            title: "On Location",
            location: PodcastLocation(name: "Paris")
        )
        let data = try JSONEncoder().encode(chapter)
        let decoded = try JSONDecoder().decode(
            JSONChapter.self, from: data
        )
        #expect(decoded.location?.name == "Paris")
        #expect(decoded.location?.geo == nil)
        #expect(decoded.location?.osm == nil)
    }

    @Test("Location with geo and osm round-trips")
    func locationFull() throws {
        let location = PodcastLocation(
            name: "Berlin",
            geo: "geo:52.5200,13.4050",
            osm: "R62422"
        )
        let chapter = JSONChapter(
            startTime: 600,
            title: "Berlin Episode",
            location: location
        )
        let data = try JSONEncoder().encode(chapter)
        let decoded = try JSONDecoder().decode(
            JSONChapter.self, from: data
        )
        #expect(decoded.location == location)
    }

    // MARK: - Equatable / Hashable

    @Test("JSONChapterList conforms to Equatable")
    func equatable() {
        let a = JSONChapterList(chapters: [
            JSONChapter(startTime: 0, title: "A"),
        ])
        let b = JSONChapterList(chapters: [
            JSONChapter(startTime: 0, title: "A"),
        ])
        let c = JSONChapterList(chapters: [
            JSONChapter(startTime: 0, title: "B"),
        ])
        #expect(a == b)
        #expect(a != c)
    }

    @Test("JSONChapter conforms to Hashable")
    func hashable() {
        let ch1 = JSONChapter(startTime: 0, title: "Intro")
        let ch2 = JSONChapter(startTime: 0, title: "Intro")
        let ch3 = JSONChapter(startTime: 10, title: "Different")
        var set: Set<JSONChapter> = []
        set.insert(ch1)
        set.insert(ch2)
        set.insert(ch3)
        #expect(set.count == 2)
    }

    // MARK: - Default Version

    @Test("Default version is 1.2.0")
    func defaultVersion() {
        let list = JSONChapterList()
        #expect(list.version == "1.2.0")
        #expect(list.chapters.isEmpty)
    }

    // MARK: - Decode with Unknown Keys

    @Test("Decode ignores unknown JSON keys")
    func decodeUnknownKeys() throws {
        let jsonString = """
            {
              "version": "1.2.0",
              "chapters": [
                { "startTime": 0, "title": "Intro", "customField": "ignored" }
              ],
              "extraKey": true
            }
            """
        let data = try #require(jsonString.data(using: .utf8))
        let list = try JSONDecoder().decode(JSONChapterList.self, from: data)
        #expect(list.chapters.count == 1)
        #expect(list.chapters[0].title == "Intro")
    }
}
