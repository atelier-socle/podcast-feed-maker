import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Builder DSL Showcase

@Suite("Builder DSL Showcase")
struct BuilderDSLShowcase {

    @Test("Result builder creates feed from Channel and Items in closure")
    func resultBuilderBasic() throws {
        let exampleURL = makeURL("https://example.com")
        let feed = PodcastFeed {
            Channel(
                title: "Builder Show",
                link: exampleURL,
                description: "Built with the DSL"
            )
            .author("Host Name")
            .explicit(false)
            .category(.technology)

            Item(title: "Episode 1")
                .duration(1800)

            Item(title: "Episode 2")
                .duration(2400)
        }

        let channel = try #require(feed.channel)
        #expect(channel.title == "Builder Show")
        #expect(channel.itunesAuthor == "Host Name")
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == "Episode 1")
        #expect(channel.items[0].itunesDuration == 1800)
        #expect(channel.items[1].title == "Episode 2")
        #expect(channel.items[1].itunesDuration == 2400)
    }

    @Test("Result builder assembles items alongside existing channel items")
    func resultBuilderMergesItems() throws {
        let exampleURL = makeURL("https://example.com")
        let existingItem = Item(title: "Pre-existing Episode")
        let feed = PodcastFeed {
            Channel(
                title: "Merge Show",
                link: exampleURL,
                description: "Testing item merge",
                items: [existingItem]
            )

            Item(title: "New Episode")
        }

        let channel = try #require(feed.channel)
        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == "Pre-existing Episode")
        #expect(channel.items[1].title == "New Episode")
    }

    @Test("Result builder with no channel returns feed with nil channel")
    func resultBuilderNoChannel() {
        let feed = PodcastFeed {
            Item(title: "Orphan Episode")
        }
        #expect(feed.channel == nil)
    }

    @Test("FeedComponent protocol conformance for Channel and Item")
    func feedComponentConformance() {
        let exampleURL = makeURL("https://example.com")
        let channel: FeedComponent = Channel(
            title: "T",
            link: exampleURL,
            description: "D"
        )
        let item: FeedComponent = Item(title: "E")
        #expect(channel is Channel)
        #expect(item is Item)
    }
}

// MARK: - Channel Fluent Modifiers Showcase

@Suite("Channel Fluent Modifiers Showcase")
struct ChannelFluentModifiersShowcase {

    private func baseChannel() -> Channel {
        let exampleURL = makeURL("https://example.com")
        return Channel(
            title: "Fluent Show",
            link: exampleURL,
            description: "Testing all modifiers"
        )
    }

    @Test("author sets itunes:author")
    func authorModifier() {
        let channel = baseChannel().author("Jane Doe")
        #expect(channel.itunesAuthor == "Jane Doe")
    }

    @Test("language sets feed language")
    func languageModifier() {
        let channel = baseChannel().language("fr-fr")
        #expect(channel.language == "fr-fr")
    }

    @Test("copyright sets copyright notice")
    func copyrightModifier() {
        let channel = baseChannel().copyright("(c) 2025 Atelier Socle")
        #expect(channel.copyright == "(c) 2025 Atelier Socle")
    }

    @Test("category appends a single iTunes category")
    func categoryModifier() {
        let channel = baseChannel().category(.technology)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesCategories[0].text == "Technology")
    }

    @Test("categories replaces all iTunes categories")
    func categoriesModifier() {
        let channel = baseChannel()
            .category(.technology)
            .categories([.arts(), .comedy()])
        #expect(channel.itunesCategories.count == 2)
        #expect(channel.itunesCategories[0].text == "Arts")
        #expect(channel.itunesCategories[1].text == "Comedy")
    }

    @Test("explicit sets itunes:explicit")
    func explicitModifier() {
        let channel = baseChannel().explicit(true)
        #expect(channel.itunesExplicit == true)
    }

    @Test("image sets itunes:image URL")
    func imageModifier() {
        let channel = baseChannel().image("https://cdn.example.com/art.jpg")
        #expect(channel.itunesImage?.absoluteString == "https://cdn.example.com/art.jpg")
    }

    @Test("type sets itunes:type")
    func typeModifier() {
        let channel = baseChannel().type("serial")
        #expect(channel.itunesType == .serial)
    }

    @Test("owner sets itunes:owner name and email")
    func ownerModifier() {
        let channel = baseChannel().owner(name: "Jane", email: "jane@example.com")
        #expect(channel.itunesOwner?.name == "Jane")
        #expect(channel.itunesOwner?.email == "jane@example.com")
    }

    @Test("locked sets podcast:locked with owner")
    func lockedModifier() {
        let channel = baseChannel().locked(owner: "jane@example.com")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "jane@example.com")
    }

    @Test("guid sets podcast:guid")
    func guidModifier() {
        let channel = baseChannel().guid("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
        #expect(channel.podcastGuid?.value == "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
    }

    @Test("funding appends a podcast:funding link")
    func fundingModifier() {
        let channel = baseChannel()
            .funding(url: "https://patreon.com/show", text: "Support on Patreon")
        #expect(channel.funding.count == 1)
        #expect(channel.funding[0].message == "Support on Patreon")
        #expect(channel.funding[0].url.absoluteString == "https://patreon.com/show")
    }

    @Test("atomLink appends an atom:link")
    func atomLinkModifier() {
        let channel = baseChannel()
            .atomLink(href: "https://example.com/feed.xml", rel: "self")
        #expect(channel.atomLinks.count == 1)
        #expect(channel.atomLinks[0].rel == "self")
    }

    @Test("medium sets podcast:medium")
    func mediumModifier() {
        let channel = baseChannel().medium(.podcast)
        #expect(channel.medium == .podcast)
    }

    @Test("publisher sets podcast:publisher with remoteItem")
    func publisherModifier() {
        let channel = baseChannel()
            .publisher(
                feedGuid: "pub-guid-123",
                feedUrl: "https://network.example.com/feed.xml"
            )
        #expect(channel.publisher?.remoteItem.feedGuid == "pub-guid-123")
        #expect(
            channel.publisher?.remoteItem.feedUrl?.absoluteString
                == "https://network.example.com/feed.xml"
        )
    }

    @Test("newFeedUrl sets itunes:new-feed-url")
    func newFeedUrlModifier() {
        let channel = baseChannel()
            .newFeedUrl("https://new.example.com/feed.xml")
        #expect(
            channel.itunesNewFeedUrl?.absoluteString == "https://new.example.com/feed.xml"
        )
    }

    @Test("complete sets itunes:complete")
    func completeModifier() {
        let channel = baseChannel().complete(true)
        #expect(channel.itunesComplete == true)
    }

    @Test("location appends a podcast:location")
    func locationModifier() {
        let channel = baseChannel()
            .location(
                name: "Paris",
                geo: "geo:48.8566,2.3522",
                rel: "creator",
                country: "FR"
            )
        #expect(channel.locations.count == 1)
        #expect(channel.locations[0].name == "Paris")
        #expect(channel.locations[0].geo == "geo:48.8566,2.3522")
        #expect(channel.locations[0].rel == "creator")
        #expect(channel.locations[0].country == "FR")
    }

    @Test("All modifiers can be chained fluently")
    func chainingAll() {
        let channel = baseChannel()
            .author("Jane Doe")
            .language("en-us")
            .copyright("(c) 2025")
            .category(.technology)
            .explicit(false)
            .image("https://cdn.example.com/art.jpg")
            .type("episodic")
            .owner(name: "Jane", email: "jane@example.com")
            .locked(owner: "jane@example.com")
            .guid("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
            .funding(url: "https://patreon.com/show", text: "Support us")
            .atomLink(href: "https://example.com/feed.xml", rel: "self")
            .medium(.podcast)
            .publisher(feedGuid: "net-guid")
            .newFeedUrl("https://new.example.com/feed.xml")
            .complete(false)
            .location(name: "San Francisco")

        #expect(channel.itunesAuthor == "Jane Doe")
        #expect(channel.language == "en-us")
        #expect(channel.copyright == "(c) 2025")
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage != nil)
        #expect(channel.itunesType == .episodic)
        #expect(channel.itunesOwner != nil)
        #expect(channel.locked != nil)
        #expect(channel.podcastGuid != nil)
        #expect(channel.funding.count == 1)
        #expect(channel.atomLinks.count == 1)
        #expect(channel.medium == .podcast)
        #expect(channel.publisher != nil)
        #expect(channel.itunesNewFeedUrl != nil)
        #expect(channel.itunesComplete == false)
        #expect(channel.locations.count == 1)
    }
}

// MARK: - Item Fluent Modifiers Showcase

@Suite("Item Fluent Modifiers Showcase")
struct ItemFluentModifiersShowcase {

    private func baseItem() -> Item {
        Item(title: "Test Episode")
    }

    @Test("description sets item description")
    func descriptionModifier() {
        let item = baseItem().description("Episode summary text.")
        #expect(item.description == "Episode summary text.")
    }

    @Test("guid sets item GUID with isPermaLink")
    func guidModifier() {
        let item = baseItem().guid("ep-001", isPermaLink: false)
        #expect(item.guid?.value == "ep-001")
        #expect(item.guid?.isPermaLink == false)
    }

    @Test("pubDate sets publication date")
    func pubDateModifier() {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let item = baseItem().pubDate(date)
        #expect(item.pubDate == date)
    }

    @Test("duration sets itunes:duration in seconds")
    func durationModifier() {
        let item = baseItem().duration(3600)
        #expect(item.itunesDuration == 3600)
    }

    @Test("explicit sets itunes:explicit")
    func explicitModifier() {
        let item = baseItem().explicit(true)
        #expect(item.itunesExplicit == true)
    }

    @Test("image sets itunes:image URL")
    func imageModifier() {
        let item = baseItem().image("https://cdn.example.com/ep.jpg")
        #expect(item.itunesImage?.absoluteString == "https://cdn.example.com/ep.jpg")
    }

    @Test("season sets itunes:season number")
    func seasonModifier() {
        let item = baseItem().season(2)
        #expect(item.itunesSeason == 2)
    }

    @Test("episode sets itunes:episode number")
    func episodeModifier() {
        let item = baseItem().episode(5)
        #expect(item.itunesEpisode == 5)
    }

    @Test("episodeType sets itunes:episodeType")
    func episodeTypeModifier() {
        let item = baseItem().episodeType("trailer")
        #expect(item.itunesEpisodeType == .trailer)
    }

    @Test("person appends a podcast:person with role")
    func personModifier() {
        let item = baseItem()
            .person("Jane Host", role: .host)
            .person("John Guest", role: .guest)
        #expect(item.persons.count == 2)
        #expect(item.persons[0].name == "Jane Host")
        #expect(item.persons[0].role == PodcastPerson.Role.host.rawValue)
        #expect(item.persons[1].name == "John Guest")
        #expect(item.persons[1].role == PodcastPerson.Role.guest.rawValue)
    }

    @Test("transcript appends a podcast:transcript")
    func transcriptModifier() {
        let item = baseItem()
            .transcript(url: "https://example.com/ep.vtt", type: .vtt)
        #expect(item.transcripts.count == 1)
        #expect(item.transcripts[0].type == "text/vtt")
    }

    @Test("chapters sets the podcast:chapters link")
    func chaptersModifier() {
        let item = baseItem()
            .chapters(url: "https://example.com/chapters.json")
        #expect(item.chaptersLink?.url.absoluteString == "https://example.com/chapters.json")
        #expect(item.chaptersLink?.type == "application/json+chapters")
    }

    @Test("soundbite appends a podcast:soundbite")
    func soundbiteModifier() {
        let item = baseItem()
            .soundbite(start: 120.0, duration: 30.0, title: "Best moment")
        #expect(item.soundbites.count == 1)
        #expect(item.soundbites[0].startTime == 120.0)
        #expect(item.soundbites[0].duration == 30.0)
        #expect(item.soundbites[0].title == "Best moment")
    }

    @Test("contentEncoded sets content:encoded HTML")
    func contentEncodedModifier() {
        let html = "<p>Rich <strong>HTML</strong> content</p>"
        let item = baseItem().contentEncoded(html)
        #expect(item.contentEncoded?.value == html)
    }

    @Test("All item modifiers can be chained fluently")
    func chainingAll() {
        let item = baseItem()
            .description("Full episode description")
            .guid("ep-001", isPermaLink: false)
            .pubDate(Date(timeIntervalSince1970: 1_700_000_000))
            .duration(2700)
            .explicit(false)
            .image("https://cdn.example.com/ep.jpg")
            .season(1)
            .episode(3)
            .episodeType("full")
            .person("Host", role: .host)
            .transcript(url: "https://example.com/ep.vtt", type: .vtt)
            .chapters(url: "https://example.com/chapters.json")
            .soundbite(start: 60.0, duration: 15.0)
            .contentEncoded("<p>Episode notes</p>")

        #expect(item.description == "Full episode description")
        #expect(item.guid?.value == "ep-001")
        #expect(item.pubDate != nil)
        #expect(item.itunesDuration == 2700)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesImage != nil)
        #expect(item.itunesSeason == 1)
        #expect(item.itunesEpisode == 3)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.persons.count == 1)
        #expect(item.transcripts.count == 1)
        #expect(item.chaptersLink != nil)
        #expect(item.soundbites.count == 1)
        #expect(item.contentEncoded != nil)
    }
}
