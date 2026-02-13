import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - ItemITunesTests

/// Tests for the ``Item`` struct — iTunes namespace properties and defaults.
@Suite("Item — iTunes Extensions")
struct ItemITunesTests {

    // MARK: - Default Properties

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

    @Test("Item other namespace properties default to nil or empty")
    func itemOtherNamespacePropertiesDefaultToNil() {
        let item = Item()

        #expect(item.atomLinks.isEmpty)
        #expect(item.dublinCore == nil)
        #expect(item.contentEncoded == nil)
        #expect(item.podloveChapters == nil)
    }

    // MARK: - Initialization

    @Test("Item can be initialized with iTunes properties")
    func itemInitWithItunesProperties() {
        let imageURL = makeURL("https://example.com/ep1.jpg")
        let item = Item(
            title: "Episode 1",
            itunesAuthor: "John Doe",
            itunesDuration: 3600,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: imageURL,
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
        #expect(item.itunesImage == imageURL)
        #expect(item.itunesSeason == 2)
        #expect(item.itunesSubtitle == "A short subtitle")
        #expect(item.itunesSummary == "A longer summary")
        #expect(item.itunesTitle == "Episode Title Override")
    }

    @Test("ITunesEpisodeType has all expected cases")
    func itunesEpisodeTypeCases() {
        #expect(ITunesEpisodeType.full.rawValue == "full")
        #expect(ITunesEpisodeType.trailer.rawValue == "trailer")
        #expect(ITunesEpisodeType.bonus.rawValue == "bonus")
        #expect(ITunesEpisodeType.allCases.count == 3)
    }

    @Test("Item can be initialized with content encoded")
    func itemInitWithContentEncoded() {
        let item = Item(
            contentEncoded: ContentEncoded(value: "<p>Rich HTML content</p>")
        )

        #expect(item.contentEncoded?.value == "<p>Rich HTML content</p>")
    }

    // MARK: - XML Generation

    @Test("Item XML contains iTunes tags when set")
    func itemXmlContainsItunesTags() {
        let imageURL = makeURL("https://example.com/ep1.jpg")
        let item = Item(
            title: "Episode 1",
            itunesAuthor: "John Doe",
            itunesDuration: 3600,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: true,
            itunesImage: imageURL,
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
    func itemXmlContainsEpisodeTypes() {
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
    func itemXmlContainsContentEncoded() {
        let item = Item(
            contentEncoded: ContentEncoded(value: "<p>Show notes</p>")
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<content:encoded><![CDATA[<p>Show notes</p>]]></content:encoded>"))
    }
}

// MARK: - ItemPodcastNSTests

/// Tests for the ``Item`` struct — Podcast NS 2.0 properties and XML generation.
@Suite("Item — Podcast NS 2.0 Extensions")
struct ItemPodcastNSTests {

    // MARK: - Default Properties

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

    // MARK: - Initialization

    @Test("Item can be initialized with Podcast NS 2.0 properties")
    func itemInitWithPodcastNsProperties() {
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let chaptersURL = makeURL("https://example.com/ep1/chapters.json")
        let transcript = Transcript(
            url: transcriptURL,
            type: "text/vtt",
            language: "en"
        )
        let chapters = ChaptersLink(url: chaptersURL)
        let soundbite = Soundbite(startTime: 30.0, duration: 15.0, title: "Best Part")

        let item = Item(
            title: "Episode 1",
            transcripts: [transcript],
            chaptersLink: chapters,
            soundbites: [soundbite]
        )

        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].url == transcriptURL)
        #expect(item.transcripts[0].type == "text/vtt")
        #expect(item.transcripts[0].language == "en")
        #expect(item.chaptersLink?.url == chaptersURL)
        #expect(item.chaptersLink?.type == "application/json+chapters")
        #expect(item.soundbites.count == 1)
        #expect(item.soundbites[0].startTime == 30.0)
        #expect(item.soundbites[0].duration == 15.0)
        #expect(item.soundbites[0].title == "Best Part")
    }

    @Test("Item can be initialized with multiple transcripts")
    func itemInitWithMultipleTranscripts() {
        let vttURL = makeURL("https://example.com/ep1.vtt")
        let srtURL = makeURL("https://example.com/ep1.srt")
        let vttTranscript = Transcript(url: vttURL, type: "text/vtt", language: "en", rel: "captions")
        let srtTranscript = Transcript(url: srtURL, type: "application/srt", language: "fr")

        let item = Item(transcripts: [vttTranscript, srtTranscript])

        #expect(item.transcripts.count == 2)
        #expect(item.transcripts[0].rel == "captions")
        #expect(item.transcripts[1].language == "fr")
    }

    // MARK: - XML Generation

    @Test("Item XML contains soundbite when set")
    func itemXmlContainsSoundbite() {
        let item = Item(soundbites: [Soundbite(startTime: 0.0, duration: 10.0, title: "Best Part")])
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains(#"<podcast:soundbite startTime="0.0" duration="10.0">Best Part</podcast:soundbite>"#))
    }

    @Test("Item XML contains soundbite without title")
    func itemXmlContainsSoundbiteWithoutTitle() {
        let item = Item(soundbites: [Soundbite(startTime: 73.0, duration: 60.0)])
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains(#"<podcast:soundbite startTime="73.0" duration="60.0" />"#))
    }

    @Test("Item XML contains multiple soundbites")
    func itemXmlContainsMultipleSoundbites() {
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
    func itemXmlContainsTranscript() {
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let item = Item(
            transcripts: [Transcript(url: transcriptURL, type: "text/vtt", language: "en", rel: "captions")]
        )
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:transcript"))
        #expect(xml.contains(#"url="https://example.com/ep1.vtt""#))
        #expect(xml.contains(#"type="text/vtt""#))
        #expect(xml.contains(#"language="en""#))
        #expect(xml.contains(#"rel="captions""#))
    }

    @Test("Item XML contains transcript without optional attributes")
    func itemXmlContainsTranscriptMinimal() {
        let transcriptURL = makeURL("https://example.com/ep1.srt")
        let item = Item(transcripts: [Transcript(url: transcriptURL, type: "application/srt")])
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:transcript"))
        #expect(xml.contains(#"url="https://example.com/ep1.srt""#))
        #expect(xml.contains(#"type="application/srt""#))
        #expect(!xml.contains(#"language="#))
        #expect(!xml.contains(#"rel="#))
    }

    @Test("Item XML contains chapters link when set")
    func itemXmlContainsChaptersLink() {
        let chaptersURL = makeURL("https://example.com/ep1/chapters.json")
        let item = Item(chaptersLink: ChaptersLink(url: chaptersURL))
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:chapters"))
        #expect(xml.contains(#"url="https://example.com/ep1/chapters.json""#))
        #expect(xml.contains(#"type="application/json+chapters""#))
    }

    @Test("Item XML contains person when set")
    func itemXmlContainsPerson() {
        let hrefURL = makeURL("https://jane.example.com")
        let imgURL = makeURL("https://example.com/jane.jpg")
        let item = Item(
            persons: [PodcastPerson(name: "Jane Doe", role: "host", group: "cast", href: hrefURL, img: imgURL)]
        )
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:person"))
        #expect(xml.contains(#"role="host""#))
        #expect(xml.contains(#"group="cast""#))
        #expect(xml.contains(">Jane Doe</podcast:person>"))
    }

    @Test("Item XML contains all Podcast NS 2.0 tags together")
    func itemXmlContainsAllPodcastNsTags() {
        let transcriptURL = makeURL("https://example.com/ep.vtt")
        let chaptersURL = makeURL("https://example.com/chapters.json")
        let item = Item(
            title: "Episode With Everything",
            transcripts: [Transcript(url: transcriptURL, type: "text/vtt")],
            chaptersLink: ChaptersLink(url: chaptersURL),
            soundbites: [Soundbite(startTime: 5.0, duration: 20.0, title: "Clip")],
            persons: [PodcastPerson(name: "Host")]
        )
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<podcast:transcript"))
        #expect(xml.contains("<podcast:chapters"))
        #expect(xml.contains("<podcast:soundbite"))
        #expect(xml.contains("<podcast:person"))
        #expect(xml.contains("<title>Episode With Everything</title>"))
    }

    // MARK: - Equatable

    @Test("Items with different soundbites are not equal")
    func itemsWithDifferentSoundbitesAreNotEqual() {
        let item1 = Item(soundbites: [Soundbite(startTime: 0.0, duration: 10.0)])
        let item2 = Item(soundbites: [Soundbite(startTime: 5.0, duration: 10.0)])
        #expect(item1 != item2)
    }

    @Test("Items with different transcripts are not equal")
    func itemsWithDifferentTranscriptsAreNotEqual() {
        let urlA = makeURL("https://example.com/a.vtt")
        let urlB = makeURL("https://example.com/b.vtt")
        let item1 = Item(transcripts: [Transcript(url: urlA, type: "text/vtt")])
        let item2 = Item(transcripts: [Transcript(url: urlB, type: "text/vtt")])
        #expect(item1 != item2)
    }

    // MARK: - Hashable

    @Test("Items with different Podcast NS properties produce different hashes")
    func itemHashDiffersWithPodcastNs() {
        let item1 = Item(soundbites: [Soundbite(startTime: 0.0, duration: 5.0)])
        let item2 = Item(soundbites: [Soundbite(startTime: 10.0, duration: 5.0)])
        let set: Set = [item1, item2]
        #expect(set.count == 2)
    }
}
