import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - ItemTests

/// Tests for the ``Item`` struct.
///
/// `Item` represents a single episode in a podcast feed with ~35 typed properties.
/// All properties are optional or default to empty arrays.
/// Conforms to `Sendable`, `Hashable`, and `Equatable`.
@Suite("Item Struct Tests")
// swiftlint:disable:next type_body_length
struct ItemTests {

    // MARK: - Default Initialization

    @Test("Item can be initialized with no parameters")
    func itemInitWithNoParams() {
        let item = Item()

        #expect(item.title == nil)
        #expect(item.link == nil)
        #expect(item.description == nil)
        #expect(item.author == nil)
        #expect(item.categories.isEmpty)
        #expect(item.comments == nil)
        #expect(item.enclosure == nil)
        #expect(item.guid == nil)
        #expect(item.pubDate == nil)
        #expect(item.source == nil)
    }

    @Test("Item iTunes properties default to nil or empty")
    func itemItunesPropertiesDefaultToNil() {
        let item = Item()

        #expect(item.itunesAuthor == nil)
        #expect(item.itunesBlock == nil)
        #expect(item.itunesDuration == nil)
        #expect(item.itunesEpisode == nil)
        #expect(item.itunesEpisodeType == nil)
        #expect(item.itunesExplicit == nil)
        #expect(item.itunesImage == nil)
        #expect(item.itunesKeywords.isEmpty)
        #expect(item.itunesSeason == nil)
        #expect(item.itunesSubtitle == nil)
        #expect(item.itunesSummary == nil)
        #expect(item.itunesTitle == nil)
    }

    @Test("Item Podcast NS properties default to nil or empty")
    func itemPodcastNsPropertiesDefaultToNil() {
        let item = Item()

        #expect(item.transcripts.isEmpty)
        #expect(item.chaptersLink == nil)
        #expect(item.soundbites.isEmpty)
        #expect(item.persons.isEmpty)
        #expect(item.location == nil)
        #expect(item.license == nil)
        #expect(item.alternateEnclosures.isEmpty)
        #expect(item.value == nil)
        #expect(item.socialInteractions.isEmpty)
        #expect(item.txtRecords.isEmpty)
        #expect(item.podcastSeason == nil)
        #expect(item.podcastEpisode == nil)
    }

    @Test("Item other namespace properties default to nil or empty")
    func itemOtherNamespacePropertiesDefaultToNil() {
        let item = Item()

        #expect(item.atomLinks.isEmpty)
        #expect(item.dublinCore == nil)
        #expect(item.contentEncoded == nil)
        #expect(item.podloveChapters == nil)
    }

    // MARK: - Initialization with Values

    @Test("Item can be initialized with RSS core properties")
    func itemInitWithRssCoreProperties() {
        let url = URL(string: "https://example.com/ep1")!
        let date = Date(timeIntervalSince1970: 1_000_000)
        let guid = GUID(value: "ep-001", isPermaLink: false)
        let enclosure = Enclosure(
            url: URL(string: "https://example.com/ep1.mp3")!,
            length: 50000,
            mimeType: .mpeg
        )

        let item = Item(
            title: "Episode 1",
            link: url,
            description: "First episode",
            author: "author@example.com",
            enclosure: enclosure,
            guid: guid,
            pubDate: date
        )

        #expect(item.title == "Episode 1")
        #expect(item.link == url)
        #expect(item.description == "First episode")
        #expect(item.author == "author@example.com")
        #expect(item.enclosure?.url == URL(string: "https://example.com/ep1.mp3")!)
        #expect(item.enclosure?.length == 50000)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "ep-001")
        #expect(item.guid?.isPermaLink == false)
        #expect(item.pubDate == date)
    }

    @Test("Item can be initialized with title and enclosure using string MIME type")
    func itemInitWithStringMimeType() {
        let enclosure = Enclosure(
            url: URL(string: "https://example.com/ep1.m4a")!,
            length: 30000,
            type: "audio/m4a"
        )

        let item = Item(title: "Episode", enclosure: enclosure)

        #expect(item.enclosure?.type == "audio/m4a")
    }

    @Test("Item can be initialized with iTunes properties")
    func itemInitWithItunesProperties() {
        let item = Item(
            title: "Episode 1",
            itunesAuthor: "John Doe",
            itunesDuration: 3600,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/ep1.jpg")!,
            itunesSeason: 2,
            itunesSubtitle: "A short subtitle",
            itunesSummary: "A longer summary",
            itunesTitle: "Episode Title Override"
        )

        #expect(item.itunesAuthor == "John Doe")
        #expect(item.itunesDuration == 3600)
        #expect(item.itunesEpisode == 1)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesImage == URL(string: "https://example.com/ep1.jpg")!)
        #expect(item.itunesSeason == 2)
        #expect(item.itunesSubtitle == "A short subtitle")
        #expect(item.itunesSummary == "A longer summary")
        #expect(item.itunesTitle == "Episode Title Override")
    }

    @Test("Item can be initialized with Podcast NS 2.0 properties")
    func itemInitWithPodcastNsProperties() {
        let transcript = Transcript(
            url: URL(string: "https://example.com/ep1.vtt")!,
            type: "text/vtt",
            language: "en"
        )
        let chapters = ChaptersLink(
            url: URL(string: "https://example.com/ep1/chapters.json")!
        )
        let soundbite = Soundbite(startTime: 30.0, duration: 15.0, title: "Best Part")

        let item = Item(
            title: "Episode 1",
            transcripts: [transcript],
            chaptersLink: chapters,
            soundbites: [soundbite]
        )

        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].url == URL(string: "https://example.com/ep1.vtt")!)
        #expect(item.transcripts[0].type == "text/vtt")
        #expect(item.transcripts[0].language == "en")
        #expect(item.chaptersLink?.url == URL(string: "https://example.com/ep1/chapters.json")!)
        #expect(item.chaptersLink?.type == "application/json+chapters")
        #expect(item.soundbites.count == 1)
        #expect(item.soundbites[0].startTime == 30.0)
        #expect(item.soundbites[0].duration == 15.0)
        #expect(item.soundbites[0].title == "Best Part")
    }

    @Test("Item can be initialized with multiple transcripts")
    func itemInitWithMultipleTranscripts() {
        let vttTranscript = Transcript(
            url: URL(string: "https://example.com/ep1.vtt")!,
            type: "text/vtt",
            language: "en",
            rel: "captions"
        )
        let srtTranscript = Transcript(
            url: URL(string: "https://example.com/ep1.srt")!,
            type: "application/srt",
            language: "fr"
        )

        let item = Item(transcripts: [vttTranscript, srtTranscript])

        #expect(item.transcripts.count == 2)
        #expect(item.transcripts[0].rel == "captions")
        #expect(item.transcripts[1].language == "fr")
    }

    @Test("Item can be initialized with content encoded")
    func itemInitWithContentEncoded() {
        let item = Item(
            contentEncoded: ContentEncoded(value: "<p>Rich HTML content</p>")
        )

        #expect(item.contentEncoded?.value == "<p>Rich HTML content</p>")
    }

    // MARK: - Mutability

    @Test("Item properties are mutable")
    func itemPropertiesAreMutable() {
        var item = Item()

        item.title = "New Title"
        item.link = URL(string: "https://example.com/ep1")!
        item.description = "Updated description"
        item.itunesDuration = 1800
        item.itunesEpisode = 5
        item.itunesEpisodeType = .bonus
        item.soundbites = [Soundbite(startTime: 0.0, duration: 10.0)]

        #expect(item.title == "New Title")
        #expect(item.link == URL(string: "https://example.com/ep1")!)
        #expect(item.description == "Updated description")
        #expect(item.itunesDuration == 1800)
        #expect(item.itunesEpisode == 5)
        #expect(item.itunesEpisodeType == .bonus)
        #expect(item.soundbites.count == 1)
    }

    // MARK: - ITunesEpisodeType

    @Test("ITunesEpisodeType has all expected cases")
    func itunesEpisodeTypeCases() {
        #expect(ITunesEpisodeType.full.rawValue == "full")
        #expect(ITunesEpisodeType.trailer.rawValue == "trailer")
        #expect(ITunesEpisodeType.bonus.rawValue == "bonus")
        #expect(ITunesEpisodeType.allCases.count == 3)
    }

    // MARK: - XML Generation

    @Test("Item XML wraps content in item tags")
    func itemXmlWrapsInItemTags() throws {
        let item = Item(title: "Episode 1")
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains("<item>"))
        #expect(xml.contains("</item>"))
    }

    @Test("Item XML contains RSS core tags when set")
    func itemXmlContainsRssCoreTags() throws {
        let item = Item(
            title: "Episode 1",
            link: URL(string: "https://example.com/ep1")!,
            description: "The first episode",
            author: "author@example.com"
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<link>https://example.com/ep1</link>"))
        #expect(xml.contains("<description>The first episode</description>"))
        #expect(xml.contains("<author>author@example.com</author>"))
    }

    @Test("Item XML contains enclosure when set")
    func itemXmlContainsEnclosure() throws {
        let enclosure = Enclosure(
            url: URL(string: "https://example.com/ep1.mp3")!,
            length: 50000,
            mimeType: .mpeg
        )

        let item = Item(enclosure: enclosure)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains("<enclosure url="))
        #expect(xml.contains(#"url="https://example.com/ep1.mp3""#))
        #expect(xml.contains(#"length="50000""#))
        #expect(xml.contains(#"type="audio/mpeg""#))
    }

    @Test("Item XML contains guid when set")
    func itemXmlContainsGuid() throws {
        let guid = GUID(value: "ep-001", isPermaLink: false)
        let item = Item(guid: guid)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains(#"<guid isPermaLink="false">ep-001</guid>"#))
    }

    @Test("Item XML contains guid with isPermaLink true")
    func itemXmlContainsGuidPermaLink() throws {
        let guid = GUID(value: "https://example.com/ep1")
        let item = Item(guid: guid)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains(#"<guid isPermaLink="true">https://example.com/ep1</guid>"#))
    }

    @Test("Item XML contains iTunes tags when set")
    func itemXmlContainsItunesTags() throws {
        let item = Item(
            title: "Episode 1",
            itunesAuthor: "John Doe",
            itunesDuration: 3600,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: true,
            itunesImage: URL(string: "https://example.com/ep1.jpg")!,
            itunesKeywords: ["swift", "coding"],
            itunesSeason: 2,
            itunesSubtitle: "A subtitle",
            itunesSummary: "A summary",
            itunesTitle: "Title Override"
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<itunes:author>John Doe</itunes:author>"))
        #expect(xml.contains("<itunes:duration>3600</itunes:duration>"))
        #expect(xml.contains("<itunes:episode>1</itunes:episode>"))
        #expect(xml.contains("<itunes:episodeType>full</itunes:episodeType>"))
        #expect(xml.contains("<itunes:explicit>true</itunes:explicit>"))
        #expect(xml.contains(#"<itunes:image href="https://example.com/ep1.jpg" />"#))
        #expect(xml.contains("<itunes:keywords>swift,coding</itunes:keywords>"))
        #expect(xml.contains("<itunes:season>2</itunes:season>"))
        #expect(xml.contains("<itunes:subtitle>A subtitle</itunes:subtitle>"))
        #expect(xml.contains("<itunes:summary>A summary</itunes:summary>"))
        #expect(xml.contains("<itunes:title>Title Override</itunes:title>"))
    }

    @Test("Item XML contains iTunes episode types correctly")
    func itemXmlContainsEpisodeTypes() throws {
        let fullItem = Item(itunesEpisodeType: .full)
        let trailerItem = Item(itunesEpisodeType: .trailer)
        let bonusItem = Item(itunesEpisodeType: .bonus)

        let fullXml = FeedGenerator().generateItem(fullItem, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        let trailerXml = FeedGenerator().generateItem(trailerItem, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        let bonusXml = FeedGenerator().generateItem(bonusItem, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(fullXml.contains("<itunes:episodeType>full</itunes:episodeType>"))
        #expect(trailerXml.contains("<itunes:episodeType>trailer</itunes:episodeType>"))
        #expect(bonusXml.contains("<itunes:episodeType>bonus</itunes:episodeType>"))
    }

    @Test("Item XML contains content:encoded when set")
    func itemXmlContainsContentEncoded() throws {
        let item = Item(
            contentEncoded: ContentEncoded(value: "<p>Show notes</p>")
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<content:encoded><![CDATA[<p>Show notes</p>]]></content:encoded>"))
    }

    @Test("Item XML contains soundbite when set")
    func itemXmlContainsSoundbite() throws {
        let item = Item(
            soundbites: [
                Soundbite(startTime: 0.0, duration: 10.0, title: "Best Part")
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains(#"<podcast:soundbite startTime="0.0" duration="10.0">Best Part</podcast:soundbite>"#))
    }

    @Test("Item XML contains soundbite without title")
    func itemXmlContainsSoundbiteWithoutTitle() throws {
        let item = Item(
            soundbites: [
                Soundbite(startTime: 73.0, duration: 60.0)
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains(#"<podcast:soundbite startTime="73.0" duration="60.0" />"#))
    }

    @Test("Item XML contains multiple soundbites")
    func itemXmlContainsMultipleSoundbites() throws {
        let item = Item(
            soundbites: [
                Soundbite(startTime: 0.0, duration: 10.0, title: "Intro"),
                Soundbite(startTime: 120.0, duration: 30.0, title: "Highlight")
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains(#"startTime="0.0" duration="10.0">Intro"#))
        #expect(xml.contains(#"startTime="120.0" duration="30.0">Highlight"#))
    }

    @Test("Item XML contains transcript when set")
    func itemXmlContainsTranscript() throws {
        let item = Item(
            transcripts: [
                Transcript(
                    url: URL(string: "https://example.com/ep1.vtt")!,
                    type: "text/vtt",
                    language: "en",
                    rel: "captions"
                )
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:transcript"))
        #expect(xml.contains(#"url="https://example.com/ep1.vtt""#))
        #expect(xml.contains(#"type="text/vtt""#))
        #expect(xml.contains(#"language="en""#))
        #expect(xml.contains(#"rel="captions""#))
    }

    @Test("Item XML contains transcript without optional attributes")
    func itemXmlContainsTranscriptMinimal() throws {
        let item = Item(
            transcripts: [
                Transcript(
                    url: URL(string: "https://example.com/ep1.srt")!,
                    type: "application/srt"
                )
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:transcript"))
        #expect(xml.contains(#"url="https://example.com/ep1.srt""#))
        #expect(xml.contains(#"type="application/srt""#))
        #expect(!xml.contains(#"language="#))
        #expect(!xml.contains(#"rel="#))
    }

    @Test("Item XML contains chapters link when set")
    func itemXmlContainsChaptersLink() throws {
        let item = Item(
            chaptersLink: ChaptersLink(
                url: URL(string: "https://example.com/ep1/chapters.json")!
            )
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:chapters"))
        #expect(xml.contains(#"url="https://example.com/ep1/chapters.json""#))
        #expect(xml.contains(#"type="application/json+chapters""#))
    }

    @Test("Item XML contains person when set")
    func itemXmlContainsPerson() throws {
        let item = Item(
            persons: [
                PodcastPerson(
                    name: "Jane Doe",
                    role: "host",
                    group: "cast",
                    href: URL(string: "https://jane.example.com")!,
                    img: URL(string: "https://example.com/jane.jpg")!
                )
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:person"))
        #expect(xml.contains(#"role="host""#))
        #expect(xml.contains(#"group="cast""#))
        #expect(xml.contains(">Jane Doe</podcast:person>"))
    }

    @Test("Item XML contains all Podcast NS 2.0 tags together")
    func itemXmlContainsAllPodcastNsTags() throws {
        let item = Item(
            title: "Episode With Everything",
            transcripts: [
                Transcript(url: URL(string: "https://example.com/ep.vtt")!, type: "text/vtt")
            ],
            chaptersLink: ChaptersLink(url: URL(string: "https://example.com/chapters.json")!),
            soundbites: [
                Soundbite(startTime: 5.0, duration: 20.0, title: "Clip")
            ],
            persons: [
                PodcastPerson(name: "Host")
            ]
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:transcript"))
        #expect(xml.contains("<podcast:chapters"))
        #expect(xml.contains("<podcast:soundbite"))
        #expect(xml.contains("<podcast:person"))
        #expect(xml.contains("<title>Episode With Everything</title>"))
    }

    @Test("Item XML omits all tags when no properties are set")
    func itemXmlOmitsAllTagsWhenEmpty() throws {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains("<item>"))
        #expect(xml.contains("</item>"))
        #expect(!xml.contains("<title>"))
        #expect(!xml.contains("<link>"))
        #expect(!xml.contains("<description>"))
        #expect(!xml.contains("<enclosure"))
        #expect(!xml.contains("<guid"))
        #expect(!xml.contains("<itunes:"))
        #expect(!xml.contains("<podcast:transcript"))
        #expect(!xml.contains("<podcast:chapters"))
        #expect(!xml.contains("<podcast:soundbite"))
        #expect(!xml.contains("<content:encoded"))
    }

    // MARK: - Sendable

    @Test("Item is Sendable")
    func itemIsSendable() async {
        let item = Item(title: "Episode 1")
        let result = await Task { item.title }.value
        #expect(result == "Episode 1")
    }

    @Test("Item with complex properties is Sendable")
    func itemWithComplexPropertiesIsSendable() async {
        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure(url: URL(string: "https://example.com/ep.mp3")!, length: 100, mimeType: .mpeg),
            soundbites: [Soundbite(startTime: 0.0, duration: 10.0)]
        )
        let result = await Task { item.soundbites.count }.value
        #expect(result == 1)
    }

    // MARK: - Equatable

    @Test("Items with identical properties are equal")
    func itemsWithIdenticalPropertiesAreEqual() {
        let item1 = Item(title: "Ep1", description: "Desc")
        let item2 = Item(title: "Ep1", description: "Desc")
        #expect(item1 == item2)
    }

    @Test("Items with different properties are not equal")
    func itemsWithDifferentPropertiesAreNotEqual() {
        let item1 = Item(title: "Ep1")
        let item2 = Item(title: "Ep2")
        #expect(item1 != item2)
    }

    @Test("Empty items are equal")
    func emptyItemsAreEqual() {
        let item1 = Item()
        let item2 = Item()
        #expect(item1 == item2)
    }

    @Test("Items with different soundbites are not equal")
    func itemsWithDifferentSoundbitesAreNotEqual() {
        let item1 = Item(soundbites: [Soundbite(startTime: 0.0, duration: 10.0)])
        let item2 = Item(soundbites: [Soundbite(startTime: 5.0, duration: 10.0)])
        #expect(item1 != item2)
    }

    @Test("Items with different episode types are not equal")
    func itemsWithDifferentEpisodeTypesAreNotEqual() {
        let item1 = Item(itunesEpisodeType: .full)
        let item2 = Item(itunesEpisodeType: .trailer)
        #expect(item1 != item2)
    }

    @Test("Items with different transcripts are not equal")
    func itemsWithDifferentTranscriptsAreNotEqual() {
        let item1 = Item(transcripts: [
            Transcript(url: URL(string: "https://example.com/a.vtt")!, type: "text/vtt")
        ])
        let item2 = Item(transcripts: [
            Transcript(url: URL(string: "https://example.com/b.vtt")!, type: "text/vtt")
        ])
        #expect(item1 != item2)
    }

    // MARK: - Hashable

    @Test("Item is Hashable and can be stored in a Set")
    func itemHashable() {
        let item1 = Item(title: "A")
        let item2 = Item(title: "B")
        let set: Set = [item1, item2]
        #expect(set.count == 2)
    }

    @Test("Duplicate items collapse in a Set")
    func duplicateItemsCollapseInSet() {
        let item1 = Item(title: "Same")
        let item2 = Item(title: "Same")
        let set: Set = [item1, item2]
        #expect(set.count == 1)
    }

    @Test("Items with different Podcast NS properties produce different hashes")
    func itemHashDiffersWithPodcastNs() {
        let item1 = Item(soundbites: [Soundbite(startTime: 0.0, duration: 5.0)])
        let item2 = Item(soundbites: [Soundbite(startTime: 10.0, duration: 5.0)])
        let set: Set = [item1, item2]
        #expect(set.count == 2)
    }
}
