import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - Channel Builder Tests

@Suite("Channel Fluent Builder")
struct ChannelBuilderTests {

    private func baseChannel() -> Channel {
        Channel(
            title: "Test Podcast",
            link: URL(string: "https://example.com")!,
            description: "A test podcast"
        )
    }

    @Test("author sets itunesAuthor")
    func authorSetsItunesAuthor() {
        let channel = baseChannel().author("John Doe")
        #expect(channel.itunesAuthor == "John Doe")
    }

    @Test("language sets language")
    func languageSetsLanguage() {
        let channel = baseChannel().language("en-us")
        #expect(channel.language == "en-us")
    }

    @Test("copyright sets copyright")
    func copyrightSetsCopyright() {
        let channel = baseChannel().copyright("2025 Acme")
        #expect(channel.copyright == "2025 Acme")
    }

    @Test("category appends itunesCategories")
    func categoryAppendsCategory() {
        let channel = baseChannel().category(.technology)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesCategories[0].text == "Technology")
    }

    @Test("categories replaces all itunesCategories")
    func categoriesReplacesAll() {
        let channel = baseChannel()
            .category(.technology)
            .categories([.music(), .news()])
        #expect(channel.itunesCategories.count == 2)
        #expect(channel.itunesCategories[0].text == "Music")
    }

    @Test("explicit sets itunesExplicit")
    func explicitSetsFlag() {
        let channel = baseChannel().explicit(false)
        #expect(channel.itunesExplicit == false)
    }

    @Test("image sets itunesImage")
    func imageSetsImage() {
        let channel = baseChannel().image("https://example.com/art.jpg")
        #expect(channel.itunesImage?.absoluteString == "https://example.com/art.jpg")
    }

    @Test("type sets itunesType")
    func typeSetsType() {
        let channel = baseChannel().type("serial")
        #expect(channel.itunesType == .serial)
    }

    @Test("owner sets itunesOwner")
    func ownerSetsOwner() {
        let channel = baseChannel().owner(name: "John", email: "john@test.com")
        #expect(channel.itunesOwner?.name == "John")
        #expect(channel.itunesOwner?.email == "john@test.com")
    }

    @Test("locked sets locked with owner")
    func lockedSetsLocked() {
        let channel = baseChannel().locked(owner: "owner@test.com")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "owner@test.com")
    }

    @Test("guid sets podcastGuid")
    func guidSetsGuid() {
        let channel = baseChannel().guid("abc-123")
        #expect(channel.podcastGuid?.value == "abc-123")
    }

    @Test("funding appends funding")
    func fundingAppendsFunding() {
        let channel = baseChannel().funding(url: "https://patreon.com/test", text: "Support us")
        #expect(channel.funding.count == 1)
        #expect(channel.funding[0].message == "Support us")
    }

    @Test("atomLink appends atom link")
    func atomLinkAppendsLink() {
        let channel = baseChannel().atomLink(href: "https://example.com/feed", rel: "self")
        #expect(channel.atomLinks.count == 1)
        #expect(channel.atomLinks[0].rel == "self")
    }

    @Test("medium sets medium")
    func mediumSetsMedium() {
        let channel = baseChannel().medium(.podcast)
        #expect(channel.medium == .podcast)
    }

    @Test("publisher sets publisher")
    func publisherSetsPublisher() {
        let channel = baseChannel().publisher(feedGuid: "pub-guid-1", feedUrl: "https://network.com/feed.xml")
        #expect(channel.publisher?.remoteItem.feedGuid == "pub-guid-1")
        #expect(channel.publisher?.remoteItem.feedUrl?.absoluteString == "https://network.com/feed.xml")
        #expect(channel.publisher?.remoteItem.medium == "publisher")
    }

    @Test("chained modifiers produce correct model")
    func chainedModifiers() {
        let channel = baseChannel()
            .author("Host Name")
            .category(.technology)
            .explicit(false)
            .image("https://example.com/artwork.jpg")
            .language("en-us")
            .locked(owner: "owner@example.com")
            .guid("ead4c236-bf58-58c6-a2c6-a6b28d128cb6")
            .funding(url: "https://patreon.com/mypodcast", text: "Support on Patreon")

        #expect(channel.itunesAuthor == "Host Name")
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage != nil)
        #expect(channel.language == "en-us")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.podcastGuid?.value == "ead4c236-bf58-58c6-a2c6-a6b28d128cb6")
        #expect(channel.funding.count == 1)
    }
}

// MARK: - Item Builder Tests

@Suite("Item Fluent Builder")
struct ItemBuilderTests {

    private func baseItem() -> Item {
        Item(title: "Episode 1")
    }

    @Test("description sets description")
    func descriptionSetsDescription() {
        let item = baseItem().description("Episode notes")
        #expect(item.description == "Episode notes")
    }

    @Test("guid sets guid")
    func guidSetsGuid() {
        let item = baseItem().guid("ep-1", isPermaLink: false)
        #expect(item.guid?.value == "ep-1")
        #expect(item.guid?.isPermaLink == false)
    }

    @Test("pubDate sets pubDate")
    func pubDateSetsPubDate() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let item = baseItem().pubDate(date)
        #expect(item.pubDate == date)
    }

    @Test("duration sets itunesDuration")
    func durationSetsDuration() {
        let item = baseItem().duration(3600)
        #expect(item.itunesDuration == 3600)
    }

    @Test("explicit sets itunesExplicit")
    func explicitSetsExplicit() {
        let item = baseItem().explicit(true)
        #expect(item.itunesExplicit == true)
    }

    @Test("image sets itunesImage")
    func imageSetsImage() {
        let item = baseItem().image("https://example.com/ep1.jpg")
        #expect(item.itunesImage?.absoluteString == "https://example.com/ep1.jpg")
    }

    @Test("season sets itunesSeason")
    func seasonSetsSeason() {
        let item = baseItem().season(2)
        #expect(item.itunesSeason == 2)
    }

    @Test("episode sets itunesEpisode")
    func episodeSetsEpisode() {
        let item = baseItem().episode(5)
        #expect(item.itunesEpisode == 5)
    }

    @Test("episodeType sets itunesEpisodeType")
    func episodeTypeSetsType() {
        let item = baseItem().episodeType("trailer")
        #expect(item.itunesEpisodeType == .trailer)
    }

    @Test("person appends person with role")
    func personAppendsPerson() {
        let item = baseItem().person("Jane", role: .host)
        #expect(item.persons.count == 1)
        #expect(item.persons[0].name == "Jane")
        #expect(item.persons[0].role == "host")
    }

    @Test("transcript appends transcript")
    func transcriptAppendsTranscript() {
        let item = baseItem().transcript(url: "https://example.com/ep1.srt", type: .srt)
        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].type == "application/srt")
    }

    @Test("chapters sets chaptersLink")
    func chaptersSetsChaptersLink() {
        let item = baseItem().chapters(url: "https://example.com/chapters.json")
        #expect(item.chaptersLink?.url.absoluteString == "https://example.com/chapters.json")
        #expect(item.chaptersLink?.type == "application/json+chapters")
    }

    @Test("soundbite appends soundbite")
    func soundbiteAppendsSoundbite() {
        let item = baseItem().soundbite(start: 30.0, duration: 60.0, title: "Best moment")
        #expect(item.soundbites.count == 1)
        #expect(item.soundbites[0].startTime == 30.0)
        #expect(item.soundbites[0].duration == 60.0)
        #expect(item.soundbites[0].title == "Best moment")
    }

    @Test("contentEncoded sets contentEncoded")
    func contentEncodedSetsContent() {
        let item = baseItem().contentEncoded("<p>Rich notes</p>")
        #expect(item.contentEncoded?.value == "<p>Rich notes</p>")
    }

    @Test("chained item modifiers produce correct model")
    func chainedItemModifiers() {
        let item = Item(
            title: "Episode 1",
            enclosure: .mp3(url: "https://example.com/ep1.mp3", length: 48_000_000)
        )
        .pubDate(.now)
        .duration(3600)
        .description("First episode description")
        .guid("unique-episode-id-1", isPermaLink: false)
        .person("Host Name", role: .host)
        .transcript(url: "https://example.com/ep1.srt", type: .srt)
        .chapters(url: "https://example.com/ep1-chapters.json")
        .soundbite(start: 30.0, duration: 60.0, title: "Best moment")

        #expect(item.itunesDuration == 3600)
        #expect(item.description == "First episode description")
        #expect(item.guid?.value == "unique-episode-id-1")
        #expect(item.persons.count == 1)
        #expect(item.transcripts.count == 1)
        #expect(item.chaptersLink != nil)
        #expect(item.soundbites.count == 1)
    }
}

// MARK: - Enclosure Convenience Tests

@Suite("Enclosure Convenience Factories")
struct EnclosureConvenienceTests {

    @Test("mp3 creates audio/mpeg enclosure")
    func mp3CreatesEnclosure() {
        let enc = Enclosure.mp3(url: "https://example.com/ep.mp3", length: 12_345_678)
        #expect(enc?.type == "audio/mpeg")
        #expect(enc?.length == 12_345_678)
        #expect(enc?.url.absoluteString == "https://example.com/ep.mp3")
    }

    @Test("m4a creates audio/m4a enclosure")
    func m4aCreatesEnclosure() {
        let enc = Enclosure.m4a(url: "https://example.com/ep.m4a", length: 9_000_000)
        #expect(enc?.type == "audio/m4a")
        #expect(enc?.length == 9_000_000)
    }

    @Test("mp4 creates video/mp4 enclosure")
    func mp4CreatesEnclosure() {
        let enc = Enclosure.mp4(url: "https://example.com/ep.mp4", length: 50_000_000)
        #expect(enc?.type == "video/mp4")
        #expect(enc?.length == 50_000_000)
    }
}

// MARK: - Full Usage Example

@Suite("Full Usage Example")
struct FullUsageExampleTests {

    @Test("Full usage example from spec compiles and produces valid model")
    func fullUsageExample() throws {
        let channel = Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "A great podcast"
        )
        .author("Host Name")
        .category(.technology)
        .explicit(false)
        .image("https://example.com/artwork.jpg")
        .language("en-us")
        .locked(owner: "owner@example.com")
        .guid("ead4c236-bf58-58c6-a2c6-a6b28d128cb6")
        .funding(url: "https://patreon.com/mypodcast", text: "Support on Patreon")

        let item = Item(
            title: "Episode 1",
            enclosure: .mp3(url: "https://example.com/ep1.mp3", length: 48_000_000)
        )
        .pubDate(.now)
        .duration(3600)
        .description("First episode description")
        .guid("unique-episode-id-1", isPermaLink: false)
        .person("Host Name", role: .host)
        .transcript(url: "https://example.com/ep1.srt", type: .srt)
        .chapters(url: "https://example.com/ep1-chapters.json")
        .soundbite(start: 30.0, duration: 60.0, title: "Best moment")

        var feed = PodcastFeed(channel: channel)
        feed.channel?.items = [item]

        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("My Podcast"))
        #expect(xml.contains("Host Name"))
        #expect(xml.contains("episode1.mp3") == false)  // URL is ep1.mp3
        #expect(xml.contains("ep1.mp3"))
    }
}
