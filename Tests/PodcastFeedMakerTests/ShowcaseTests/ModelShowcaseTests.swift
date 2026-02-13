// swiftlint:disable file_length type_body_length function_body_length
import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - RSS 2.0 Model Showcase

@Suite("RSS 2.0 Model Showcase")
struct RSS20ModelShowcase {

    // MARK: - Channel

    @Test("Channel initializes with required properties only")
    func channelRequiredOnly() throws {
        let url = try #require(URL(string: "https://example.com"))
        let channel = Channel(title: "Swift Talk", link: url, description: "A podcast about Swift")

        #expect(channel.title == "Swift Talk")
        #expect(channel.link == url)
        #expect(channel.description == "A podcast about Swift")
        #expect(channel.language == nil)
        #expect(channel.copyright == nil)
        #expect(channel.managingEditor == nil)
        #expect(channel.webMaster == nil)
        #expect(channel.pubDate == nil)
        #expect(channel.lastBuildDate == nil)
        #expect(channel.categories.isEmpty)
        #expect(channel.generator == nil)
        #expect(channel.docs == nil)
        #expect(channel.cloud == nil)
        #expect(channel.ttl == nil)
        #expect(channel.rating == nil)
        #expect(channel.image == nil)
        #expect(channel.textInput == nil)
        #expect(channel.skipSchedule == nil)
        #expect(channel.items.isEmpty)
    }

    @Test("Channel initializes with all RSS 2.0 core properties")
    func channelAllRSSProperties() throws {
        let siteURL = try #require(URL(string: "https://swifttalk.dev"))
        let docsURL = try #require(URL(string: "https://www.rssboard.org/rss-specification"))
        let imageURL = try #require(URL(string: "https://swifttalk.dev/logo.png"))
        let searchURL = try #require(URL(string: "https://swifttalk.dev/search"))
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)
        let buildDate = Date(timeIntervalSince1970: 1_700_100_000)

        let channel = Channel(
            title: "Swift Talk",
            link: siteURL,
            description: "Weekly discussions about Swift programming",
            language: "en-US",
            copyright: "Copyright 2025 Atelier Socle",
            managingEditor: "editor@swifttalk.dev (Jane Swift)",
            webMaster: "admin@swifttalk.dev (Ops Team)",
            pubDate: pubDate,
            lastBuildDate: buildDate,
            categories: [
                RSSCategory(value: "Technology"),
                RSSCategory(value: "Programming", domain: "https://example.com/categories")
            ],
            generator: "PodcastFeedMaker 1.0",
            docs: docsURL,
            cloud: RSSCloud(
                domain: "rpc.swifttalk.dev",
                port: 80,
                path: "/RPC2",
                registerProcedure: "pingMe",
                protocolType: "soap"
            ),
            ttl: 60,
            rating: "(PICS-1.1 \"http://www.icra.org/ratingsv02.html\" l gen true)",
            image: RSSImage(
                url: imageURL,
                title: "Swift Talk Logo",
                link: siteURL,
                width: 144,
                height: 144,
                imageDescription: "The official Swift Talk podcast logo"
            ),
            textInput: RSSTextInput(
                title: "Search",
                description: "Search episodes",
                name: "query",
                link: searchURL
            ),
            skipSchedule: SkipSchedule(
                hours: [0, 1, 2, 3, 4, 5],
                days: [.saturday, .sunday]
            )
        )

        #expect(channel.language == "en-US")
        #expect(channel.copyright == "Copyright 2025 Atelier Socle")
        #expect(channel.managingEditor == "editor@swifttalk.dev (Jane Swift)")
        #expect(channel.webMaster == "admin@swifttalk.dev (Ops Team)")
        #expect(channel.pubDate == pubDate)
        #expect(channel.lastBuildDate == buildDate)
        #expect(channel.categories.count == 2)
        #expect(channel.generator == "PodcastFeedMaker 1.0")
        #expect(channel.docs == docsURL)
        #expect(channel.cloud?.domain == "rpc.swifttalk.dev")
        #expect(channel.ttl == 60)
        #expect(channel.rating != nil)
        #expect(channel.image?.width == 144)
        #expect(channel.textInput?.name == "query")
        #expect(channel.skipSchedule?.hours.count == 6)
        #expect(channel.skipSchedule?.days.contains(.saturday) == true)
    }

    @Test("Channel supports all namespace properties")
    func channelAllNamespaceProperties() throws {
        let url = try #require(URL(string: "https://example.com"))
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        let artworkURL = try #require(URL(string: "https://example.com/artwork.jpg"))
        let donateURL = try #require(URL(string: "https://example.com/donate"))
        let publisherURL = try #require(URL(string: "https://publisher.example.com/feed.xml"))

        let channel = Channel(
            title: "Full Namespace Show",
            link: url,
            description: "Demonstrates all namespace properties",
            itunesAuthor: "Wlad",
            itunesBlock: false,
            itunesCategories: [.technology],
            itunesComplete: false,
            itunesExplicit: false,
            itunesImage: artworkURL,
            itunesKeywords: ["swift", "ios", "development"],
            itunesNewFeedUrl: feedURL,
            itunesOwner: ITunesOwner(name: "Wlad", email: "wlad@example.com"),
            itunesSubtitle: "A short subtitle",
            itunesSummary: "A longer summary of the show",
            itunesTitle: "Full NS Show",
            itunesType: .serial,
            itunesVerify: true,
            atomLinks: [.selfLink(href: feedURL)],
            dublinCore: DublinCore(creator: "Wlad"),
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "wlad@example.com"),
            funding: [Funding(url: donateURL, message: "Support the show")],
            persons: [PodcastPerson(name: "Wlad", role: "host", group: "cast")],
            locations: [PodcastLocation(name: "Paris", geo: "geo:48.8566,2.3522", osm: "R7444", rel: "creator", country: "FR")],
            license: PodcastLicense(identifier: "cc-by-4.0"),
            value: PodcastValue(type: "lightning", method: "keysend"),
            medium: .podcast,
            podcastBlocks: [PodcastBlock(isBlocked: true, id: "google")],
            txtRecords: [PodcastTxt(value: "verify-abc123", purpose: "verify")],
            podroll: Podroll(remoteItems: [RemoteItem(feedGuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")]),
            updateFrequency: UpdateFrequency(label: "Weekly on Fridays", rrule: "FREQ=WEEKLY;BYDAY=FR"),
            podpingEnabled: true,
            trailers: [Trailer(title: "Season 2 Preview", url: url, pubDate: Date())],
            liveItems: [],
            publisher: PodcastPublisher(
                remoteItem: RemoteItem(feedGuid: "003af0a0-1234-5678-90ab-cdef01234567", feedUrl: publisherURL, medium: "publisher")
            ),
            podcastImages: [PodcastImage(href: artworkURL, alt: "Show art", purpose: "artwork")],
            podcastImagesSrcset: PodcastImages(srcset: "https://example.com/art-1500.jpg 1500w"),
            chat: PodcastChat(server: "irc.zeronode.net", protocol: "irc", accountId: "host", space: "#podcast"),
            unknownElements: [UnknownElement(name: "custom:tag", attributes: ["attr": "val"], textContent: "content")],
            xmlComments: ["Generated by PodcastFeedMaker"],
            cdataFields: ["description"]
        )

        #expect(channel.itunesAuthor == "Wlad")
        #expect(channel.itunesBlock == false)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesComplete == false)
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage == artworkURL)
        #expect(channel.itunesKeywords.count == 3)
        #expect(channel.itunesNewFeedUrl == feedURL)
        #expect(channel.itunesOwner?.name == "Wlad")
        #expect(channel.itunesSubtitle == "A short subtitle")
        #expect(channel.itunesSummary != nil)
        #expect(channel.itunesTitle == "Full NS Show")
        #expect(channel.itunesType == .serial)
        #expect(channel.itunesVerify == true)
        #expect(channel.atomLinks.count == 1)
        #expect(channel.dublinCore?.creator == "Wlad")
        #expect(channel.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.funding.count == 1)
        #expect(channel.persons.count == 1)
        #expect(channel.locations.count == 1)
        #expect(channel.location?.name == "Paris")
        #expect(channel.license?.identifier == "cc-by-4.0")
        #expect(channel.value?.type == "lightning")
        #expect(channel.medium == .podcast)
        #expect(channel.podcastBlocks.count == 1)
        #expect(channel.txtRecords.count == 1)
        #expect(channel.podroll?.remoteItems.count == 1)
        #expect(channel.updateFrequency?.rrule == "FREQ=WEEKLY;BYDAY=FR")
        #expect(channel.podpingEnabled == true)
        #expect(channel.trailers.count == 1)
        #expect(channel.publisher?.remoteItem.feedGuid == "003af0a0-1234-5678-90ab-cdef01234567")
        #expect(channel.podcastImages.count == 1)
        #expect(channel.podcastImagesSrcset?.srcset.contains("1500w") == true)
        #expect(channel.chat?.server == "irc.zeronode.net")
        #expect(channel.unknownElements.count == 1)
        #expect(channel.xmlComments.count == 1)
        #expect(channel.cdataFields.contains("description"))
    }

    @Test("Channel location convenience accessor works")
    func channelLocationConvenience() throws {
        let url = try #require(URL(string: "https://example.com"))
        var channel = Channel(title: "Test", link: url, description: "Test")

        // Setting via convenience sets a single-element array
        channel.location = PodcastLocation(name: "Berlin", country: "DE")
        #expect(channel.locations.count == 1)
        #expect(channel.location?.name == "Berlin")

        // Setting to nil clears the array
        channel.location = nil
        #expect(channel.locations.isEmpty)
        #expect(channel.location == nil)
    }

    // MARK: - Item

    @Test("Item initializes with all properties set to nil/empty by default")
    func itemDefaults() {
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
        #expect(item.atomLinks.isEmpty)
        #expect(item.dublinCore == nil)
        #expect(item.contentEncoded == nil)
        #expect(item.transcripts.isEmpty)
        #expect(item.chaptersLink == nil)
        #expect(item.soundbites.isEmpty)
        #expect(item.persons.isEmpty)
        #expect(item.locations.isEmpty)
        #expect(item.license == nil)
        #expect(item.alternateEnclosures.isEmpty)
        #expect(item.value == nil)
        #expect(item.socialInteractions.isEmpty)
        #expect(item.txtRecords.isEmpty)
        #expect(item.podcastSeason == nil)
        #expect(item.podcastEpisode == nil)
        #expect(item.podcastImages.isEmpty)
        #expect(item.podcastImagesSrcset == nil)
        #expect(item.podloveChapters == nil)
        #expect(item.unknownElements.isEmpty)
        #expect(item.xmlComments.isEmpty)
        #expect(item.cdataFields.isEmpty)
    }

    @Test("Item initializes with all RSS 2.0 core properties")
    func itemAllRSSProperties() throws {
        let linkURL = try #require(URL(string: "https://swifttalk.dev/episodes/1"))
        let commentsURL = try #require(URL(string: "https://swifttalk.dev/episodes/1/comments"))
        let enclosureURL = try #require(URL(string: "https://cdn.swifttalk.dev/episode1.mp3"))
        let sourceURL = try #require(URL(string: "https://otherpodcast.com/feed.xml"))
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let item = Item(
            title: "Episode 1: Getting Started with Swift 6",
            link: linkURL,
            description: "An introduction to the strict concurrency features in Swift 6",
            author: "jane@swifttalk.dev (Jane Swift)",
            categories: [
                RSSCategory(value: "Programming"),
                RSSCategory(value: "Swift", domain: "https://swifttalk.dev/tags")
            ],
            comments: commentsURL,
            enclosure: Enclosure(url: enclosureURL, length: 48_576_000, type: "audio/mpeg"),
            guid: GUID(value: "swifttalk-ep001", isPermaLink: false),
            pubDate: pubDate,
            source: RSSSource(title: "Other Podcast", url: sourceURL)
        )

        #expect(item.title == "Episode 1: Getting Started with Swift 6")
        #expect(item.link == linkURL)
        #expect(item.description?.contains("Swift 6") == true)
        #expect(item.author == "jane@swifttalk.dev (Jane Swift)")
        #expect(item.categories.count == 2)
        #expect(item.categories[1].domain == "https://swifttalk.dev/tags")
        #expect(item.comments == commentsURL)
        #expect(item.enclosure?.url == enclosureURL)
        #expect(item.enclosure?.length == 48_576_000)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "swifttalk-ep001")
        #expect(item.guid?.isPermaLink == false)
        #expect(item.pubDate == pubDate)
        #expect(item.source?.title == "Other Podcast")
        #expect(item.source?.url == sourceURL)
    }

    @Test("Item location convenience accessor works")
    func itemLocationConvenience() {
        var item = Item(title: "Location Test")

        item.location = PodcastLocation(name: "Tokyo", country: "JP")
        #expect(item.locations.count == 1)
        #expect(item.location?.name == "Tokyo")

        item.location = nil
        #expect(item.locations.isEmpty)
    }

    @Test("ITunesEpisodeType has all three cases")
    func itunesEpisodeTypeCases() {
        let allCases = ITunesEpisodeType.allCases
        #expect(allCases.count == 3)
        #expect(ITunesEpisodeType.full.rawValue == "full")
        #expect(ITunesEpisodeType.trailer.rawValue == "trailer")
        #expect(ITunesEpisodeType.bonus.rawValue == "bonus")
    }

    @Test("ITunesShowType has both cases")
    func itunesShowTypeCases() {
        let allCases = ITunesShowType.allCases
        #expect(allCases.count == 2)
        #expect(ITunesShowType.episodic.rawValue == "episodic")
        #expect(ITunesShowType.serial.rawValue == "serial")
    }

    // MARK: - Enclosure

    @Test("Enclosure initializes with string type")
    func enclosureStringInit() throws {
        let url = try #require(URL(string: "https://cdn.example.com/episode.mp3"))
        let enclosure = Enclosure(url: url, length: 24_576_000, type: "audio/mpeg")

        #expect(enclosure.url == url)
        #expect(enclosure.length == 24_576_000)
        #expect(enclosure.type == "audio/mpeg")
    }

    @Test("Enclosure initializes with MIMEType enum")
    func enclosureMIMETypeInit() throws {
        let url = try #require(URL(string: "https://cdn.example.com/episode.opus"))
        let enclosure = Enclosure(url: url, length: 12_000_000, mimeType: .opus)

        #expect(enclosure.type == "audio/opus")
    }

    @Test("Enclosure.MIMEType covers all 11 audio/video/document formats")
    func enclosureMIMETypeAllCases() {
        let allCases = Enclosure.MIMEType.allCases
        #expect(allCases.count == 11)
        #expect(Enclosure.MIMEType.aac.rawValue == "audio/aac")
        #expect(Enclosure.MIMEType.m4a.rawValue == "audio/m4a")
        #expect(Enclosure.MIMEType.mpeg.rawValue == "audio/mpeg")
        #expect(Enclosure.MIMEType.ogg.rawValue == "audio/ogg")
        #expect(Enclosure.MIMEType.opus.rawValue == "audio/opus")
        #expect(Enclosure.MIMEType.wav.rawValue == "audio/wav")
        #expect(Enclosure.MIMEType.flac.rawValue == "audio/flac")
        #expect(Enclosure.MIMEType.quicktime.rawValue == "video/quicktime")
        #expect(Enclosure.MIMEType.mp4.rawValue == "video/mp4")
        #expect(Enclosure.MIMEType.m4v.rawValue == "video/m4v")
        #expect(Enclosure.MIMEType.pdf.rawValue == "application/pdf")
    }

    @Test("Enclosure convenience factories create typed enclosures")
    func enclosureConvenienceFactories() throws {
        let mp3 = try #require(Enclosure.mp3(url: "https://cdn.example.com/ep1.mp3", length: 48_000_000))
        #expect(mp3.type == "audio/mpeg")
        #expect(mp3.length == 48_000_000)

        let m4a = try #require(Enclosure.m4a(url: "https://cdn.example.com/ep1.m4a", length: 36_000_000))
        #expect(m4a.type == "audio/m4a")

        let mp4 = try #require(Enclosure.mp4(url: "https://cdn.example.com/ep1.mp4", length: 120_000_000))
        #expect(mp4.type == "video/mp4")
    }

    @Test("Enclosure factory returns nil for invalid URL")
    func enclosureFactoryInvalidURL() {
        let result = Enclosure.mp3(url: "", length: 0)
        #expect(result == nil)
    }

    // MARK: - GUID

    @Test("GUID defaults isPermaLink to true")
    func guidDefaultPermaLink() {
        let guid = GUID(value: "https://example.com/episodes/42")
        #expect(guid.value == "https://example.com/episodes/42")
        #expect(guid.isPermaLink == true)
    }

    @Test("GUID with isPermaLink set to false for opaque identifiers")
    func guidNonPermaLink() {
        let guid = GUID(value: "550e8400-e29b-41d4-a716-446655440000", isPermaLink: false)
        #expect(guid.isPermaLink == false)
    }

    // MARK: - RSSImage

    @Test("RSSImage initializes with all properties")
    func rssImageAllProperties() throws {
        let imageURL = try #require(URL(string: "https://example.com/podcast-logo.png"))
        let siteURL = try #require(URL(string: "https://example.com"))

        let image = RSSImage(
            url: imageURL,
            title: "Podcast Logo",
            link: siteURL,
            width: 88,
            height: 31,
            imageDescription: "The official podcast logo"
        )

        #expect(image.url == imageURL)
        #expect(image.title == "Podcast Logo")
        #expect(image.link == siteURL)
        #expect(image.width == 88)
        #expect(image.height == 31)
        #expect(image.imageDescription == "The official podcast logo")
    }

    @Test("RSSImage initializes with required properties only")
    func rssImageRequiredOnly() throws {
        let url = try #require(URL(string: "https://example.com/logo.jpg"))
        let link = try #require(URL(string: "https://example.com"))
        let image = RSSImage(url: url, title: "Logo", link: link)

        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.imageDescription == nil)
    }

    // MARK: - RSSCategory

    @Test("RSSCategory with and without domain")
    func rssCategoryDomain() {
        let simple = RSSCategory(value: "Technology")
        #expect(simple.value == "Technology")
        #expect(simple.domain == nil)

        let withDomain = RSSCategory(value: "Swift", domain: "https://example.com/tags")
        #expect(withDomain.domain == "https://example.com/tags")
    }

    // MARK: - RSSCloud

    @Test("RSSCloud initializes with all five required properties")
    func rssCloudAllProperties() {
        let cloud = RSSCloud(
            domain: "rpc.podcasts.example.com",
            port: 80,
            path: "/RPC2",
            registerProcedure: "pingMe",
            protocolType: "soap"
        )

        #expect(cloud.domain == "rpc.podcasts.example.com")
        #expect(cloud.port == 80)
        #expect(cloud.path == "/RPC2")
        #expect(cloud.registerProcedure == "pingMe")
        #expect(cloud.protocolType == "soap")
    }

    // MARK: - RSSTextInput

    @Test("RSSTextInput initializes with all properties")
    func rssTextInputAllProperties() throws {
        let url = try #require(URL(string: "https://example.com/search"))
        let textInput = RSSTextInput(
            title: "Search",
            description: "Search our episodes",
            name: "query",
            link: url
        )

        #expect(textInput.title == "Search")
        #expect(textInput.description == "Search our episodes")
        #expect(textInput.name == "query")
        #expect(textInput.link == url)
    }

    // MARK: - SkipSchedule

    @Test("SkipSchedule with hours and days")
    func skipScheduleHoursAndDays() {
        let schedule = SkipSchedule(hours: [0, 1, 2, 3], days: [.saturday, .sunday])

        #expect(schedule.hours.count == 4)
        #expect(schedule.hours.contains(0))
        #expect(schedule.hours.contains(3))
        #expect(schedule.days.contains(.saturday))
        #expect(schedule.days.contains(.sunday))
        #expect(!schedule.days.contains(.monday))
    }

    @Test("SkipSchedule.Day has all seven days of the week")
    func skipScheduleAllDays() {
        let allDays = SkipSchedule.Day.allCases
        #expect(allDays.count == 7)
        #expect(SkipSchedule.Day.monday.rawValue == "Monday")
        #expect(SkipSchedule.Day.tuesday.rawValue == "Tuesday")
        #expect(SkipSchedule.Day.wednesday.rawValue == "Wednesday")
        #expect(SkipSchedule.Day.thursday.rawValue == "Thursday")
        #expect(SkipSchedule.Day.friday.rawValue == "Friday")
        #expect(SkipSchedule.Day.saturday.rawValue == "Saturday")
        #expect(SkipSchedule.Day.sunday.rawValue == "Sunday")
    }

    @Test("SkipSchedule defaults to empty sets")
    func skipScheduleDefaults() {
        let schedule = SkipSchedule()
        #expect(schedule.hours.isEmpty)
        #expect(schedule.days.isEmpty)
    }

    // MARK: - RSSSource

    @Test("RSSSource identifies the originating feed")
    func rssSourceAllProperties() throws {
        let url = try #require(URL(string: "https://otherpodcast.com/feed.xml"))
        let source = RSSSource(title: "The Other Podcast", url: url)

        #expect(source.title == "The Other Podcast")
        #expect(source.url == url)
    }
}

// MARK: - iTunes Model Showcase

@Suite("iTunes Model Showcase")
struct ITunesModelShowcase {

    // MARK: - ITunesCategory

    @Test("ITunesCategory initializes from raw strings")
    func categoryFromStrings() {
        let category = ITunesCategory(
            text: "Technology",
            subcategories: [ITunesCategory(text: "Podcasting")]
        )

        #expect(category.text == "Technology")
        #expect(category.subcategories.count == 1)
        #expect(category.subcategories[0].text == "Podcasting")
    }

    @Test("ITunesCategory initializes from Category enum")
    func categoryFromEnum() {
        let category = ITunesCategory(.arts)
        #expect(category.text == "Arts")
        #expect(category.subcategories.isEmpty)
    }

    @Test("ITunesCategory.Category enum has all 19 main categories")
    func allMainCategories() {
        let allCases = ITunesCategory.Category.allCases
        #expect(allCases.count == 19)
        #expect(ITunesCategory.Category.arts.rawValue == "Arts")
        #expect(ITunesCategory.Category.business.rawValue == "Business")
        #expect(ITunesCategory.Category.comedy.rawValue == "Comedy")
        #expect(ITunesCategory.Category.education.rawValue == "Education")
        #expect(ITunesCategory.Category.fiction.rawValue == "Fiction")
        #expect(ITunesCategory.Category.government.rawValue == "Government")
        #expect(ITunesCategory.Category.healthAndFitness.rawValue == "Health & Fitness")
        #expect(ITunesCategory.Category.history.rawValue == "History")
        #expect(ITunesCategory.Category.kidsAndFamily.rawValue == "Kids & Family")
        #expect(ITunesCategory.Category.leisure.rawValue == "Leisure")
        #expect(ITunesCategory.Category.music.rawValue == "Music")
        #expect(ITunesCategory.Category.news.rawValue == "News")
        #expect(ITunesCategory.Category.religionAndSpirituality.rawValue == "Religion & Spirituality")
        #expect(ITunesCategory.Category.science.rawValue == "Science")
        #expect(ITunesCategory.Category.societyAndCulture.rawValue == "Society & Culture")
        #expect(ITunesCategory.Category.sports.rawValue == "Sports")
        #expect(ITunesCategory.Category.technology.rawValue == "Technology")
        #expect(ITunesCategory.Category.trueCrime.rawValue == "True Crime")
        #expect(ITunesCategory.Category.tvAndFilm.rawValue == "TV & Film")
    }

    @Test("ITunesCategory factory methods with subcategories")
    func categoryFactoryMethods() {
        let arts = ITunesCategory.arts(.books)
        #expect(arts.text == "Arts")
        #expect(arts.subcategories[0].text == "Books")

        let business = ITunesCategory.business(.entrepreneurship)
        #expect(business.subcategories[0].text == "Entrepreneurship")

        let comedy = ITunesCategory.comedy(.standUp)
        #expect(comedy.subcategories[0].text == "Stand-Up")

        let education = ITunesCategory.education(.courses)
        #expect(education.subcategories[0].text == "Courses")

        let fiction = ITunesCategory.fiction(.scienceFiction)
        #expect(fiction.subcategories[0].text == "Science Fiction")

        let health = ITunesCategory.healthAndFitness(.mentalHealth)
        #expect(health.subcategories[0].text == "Mental Health")

        let kids = ITunesCategory.kidsAndFamily(.parenting)
        #expect(kids.subcategories[0].text == "Parenting")

        let leisure = ITunesCategory.leisure(.videoGames)
        #expect(leisure.subcategories[0].text == "Video Games")

        let music = ITunesCategory.music(.musicHistory)
        #expect(music.subcategories[0].text == "Music History")

        let news = ITunesCategory.news(.techNews)
        #expect(news.subcategories[0].text == "Tech News")

        let religion = ITunesCategory.religionAndSpirituality(.buddhism)
        #expect(religion.subcategories[0].text == "Buddhism")

        let science = ITunesCategory.science(.astronomy)
        #expect(science.subcategories[0].text == "Astronomy")

        let society = ITunesCategory.societyAndCulture(.philosophy)
        #expect(society.subcategories[0].text == "Philosophy")

        let sports = ITunesCategory.sports(.soccer)
        #expect(sports.subcategories[0].text == "Soccer")

        let tv = ITunesCategory.tvAndFilm(.filmReviews)
        #expect(tv.subcategories[0].text == "Film Reviews")
    }

    @Test("ITunesCategory factory methods without subcategories")
    func categoryFactoryNoSubcategory() {
        let government: ITunesCategory = .government
        #expect(government.text == "Government")
        #expect(government.subcategories.isEmpty)

        let history: ITunesCategory = .history
        #expect(history.text == "History")
        #expect(history.subcategories.isEmpty)

        let technology: ITunesCategory = .technology
        #expect(technology.text == "Technology")
        #expect(technology.subcategories.isEmpty)

        let trueCrime: ITunesCategory = .trueCrime
        #expect(trueCrime.text == "True Crime")
        #expect(trueCrime.subcategories.isEmpty)
    }

    @Test("ITunesCategory.validSubcategories returns correct subcategories per main category")
    func validSubcategories() {
        let artsSubs = ITunesCategory.validSubcategories(for: .arts)
        #expect(artsSubs.count == 6)
        #expect(artsSubs.contains("Books"))
        #expect(artsSubs.contains("Visual Arts"))

        let businessSubs = ITunesCategory.validSubcategories(for: .business)
        #expect(businessSubs.count == 6)
        #expect(businessSubs.contains("Careers"))

        let comedySubs = ITunesCategory.validSubcategories(for: .comedy)
        #expect(comedySubs.count == 3)

        let educationSubs = ITunesCategory.validSubcategories(for: .education)
        #expect(educationSubs.count == 4)

        let fictionSubs = ITunesCategory.validSubcategories(for: .fiction)
        #expect(fictionSubs.count == 3)

        let healthSubs = ITunesCategory.validSubcategories(for: .healthAndFitness)
        #expect(healthSubs.count == 6)

        let kidsSubs = ITunesCategory.validSubcategories(for: .kidsAndFamily)
        #expect(kidsSubs.count == 4)

        let leisureSubs = ITunesCategory.validSubcategories(for: .leisure)
        #expect(leisureSubs.count == 8)

        let musicSubs = ITunesCategory.validSubcategories(for: .music)
        #expect(musicSubs.count == 3)

        let newsSubs = ITunesCategory.validSubcategories(for: .news)
        #expect(newsSubs.count == 7)

        let religionSubs = ITunesCategory.validSubcategories(for: .religionAndSpirituality)
        #expect(religionSubs.count == 7)

        let scienceSubs = ITunesCategory.validSubcategories(for: .science)
        #expect(scienceSubs.count == 9)

        let societySubs = ITunesCategory.validSubcategories(for: .societyAndCulture)
        #expect(societySubs.count == 5)

        let sportsSubs = ITunesCategory.validSubcategories(for: .sports)
        #expect(sportsSubs.count == 15)

        let tvSubs = ITunesCategory.validSubcategories(for: .tvAndFilm)
        #expect(tvSubs.count == 5)

        // Categories with no subcategories
        #expect(ITunesCategory.validSubcategories(for: .government).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .history).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .technology).isEmpty)
        #expect(ITunesCategory.validSubcategories(for: .trueCrime).isEmpty)
    }

    @Test("All subcategory enums have correct raw values")
    func subcategoryEnumRawValues() {
        // Arts
        #expect(ITunesCategory.ArtsSubcategory.books.rawValue == "Books")
        #expect(ITunesCategory.ArtsSubcategory.design.rawValue == "Design")
        #expect(ITunesCategory.ArtsSubcategory.fashionAndBeauty.rawValue == "Fashion & Beauty")
        #expect(ITunesCategory.ArtsSubcategory.food.rawValue == "Food")
        #expect(ITunesCategory.ArtsSubcategory.performingArts.rawValue == "Performing Arts")
        #expect(ITunesCategory.ArtsSubcategory.visualArts.rawValue == "Visual Arts")

        // Business
        #expect(ITunesCategory.BusinessSubcategory.careers.rawValue == "Careers")
        #expect(ITunesCategory.BusinessSubcategory.entrepreneurship.rawValue == "Entrepreneurship")
        #expect(ITunesCategory.BusinessSubcategory.investing.rawValue == "Investing")
        #expect(ITunesCategory.BusinessSubcategory.management.rawValue == "Management")
        #expect(ITunesCategory.BusinessSubcategory.marketing.rawValue == "Marketing")
        #expect(ITunesCategory.BusinessSubcategory.nonProfit.rawValue == "Non-Profit")

        // Comedy
        #expect(ITunesCategory.ComedySubcategory.comedyInterviews.rawValue == "Comedy Interviews")
        #expect(ITunesCategory.ComedySubcategory.improv.rawValue == "Improv")
        #expect(ITunesCategory.ComedySubcategory.standUp.rawValue == "Stand-Up")

        // Education
        #expect(ITunesCategory.EducationSubcategory.courses.rawValue == "Courses")
        #expect(ITunesCategory.EducationSubcategory.howTo.rawValue == "How To")
        #expect(ITunesCategory.EducationSubcategory.languageLearning.rawValue == "Language Learning")
        #expect(ITunesCategory.EducationSubcategory.selfImprovement.rawValue == "Self-Improvement")

        // Fiction
        #expect(ITunesCategory.FictionSubcategory.comedyFiction.rawValue == "Comedy Fiction")
        #expect(ITunesCategory.FictionSubcategory.drama.rawValue == "Drama")
        #expect(ITunesCategory.FictionSubcategory.scienceFiction.rawValue == "Science Fiction")

        // Health & Fitness
        #expect(ITunesCategory.HealthAndFitnessSubcategory.alternativeHealth.rawValue == "Alternative Health")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.fitness.rawValue == "Fitness")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.medicine.rawValue == "Medicine")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.mentalHealth.rawValue == "Mental Health")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.nutrition.rawValue == "Nutrition")
        #expect(ITunesCategory.HealthAndFitnessSubcategory.sexuality.rawValue == "Sexuality")

        // Kids & Family
        #expect(ITunesCategory.KidsAndFamilySubcategory.educationForKids.rawValue == "Education for Kids")
        #expect(ITunesCategory.KidsAndFamilySubcategory.parenting.rawValue == "Parenting")
        #expect(ITunesCategory.KidsAndFamilySubcategory.petsAndAnimals.rawValue == "Pets & Animals")
        #expect(ITunesCategory.KidsAndFamilySubcategory.storiesForKids.rawValue == "Stories for Kids")

        // Leisure
        #expect(ITunesCategory.LeisureSubcategory.animationAndManga.rawValue == "Animation & Manga")
        #expect(ITunesCategory.LeisureSubcategory.automotive.rawValue == "Automotive")
        #expect(ITunesCategory.LeisureSubcategory.aviation.rawValue == "Aviation")
        #expect(ITunesCategory.LeisureSubcategory.crafts.rawValue == "Crafts")
        #expect(ITunesCategory.LeisureSubcategory.games.rawValue == "Games")
        #expect(ITunesCategory.LeisureSubcategory.hobbies.rawValue == "Hobbies")
        #expect(ITunesCategory.LeisureSubcategory.homeAndGarden.rawValue == "Home & Garden")
        #expect(ITunesCategory.LeisureSubcategory.videoGames.rawValue == "Video Games")

        // Music
        #expect(ITunesCategory.MusicSubcategory.musicCommentary.rawValue == "Music Commentary")
        #expect(ITunesCategory.MusicSubcategory.musicHistory.rawValue == "Music History")
        #expect(ITunesCategory.MusicSubcategory.musicInterviews.rawValue == "Music Interviews")

        // News
        #expect(ITunesCategory.NewsSubcategory.businessNews.rawValue == "Business News")
        #expect(ITunesCategory.NewsSubcategory.dailyNews.rawValue == "Daily News")
        #expect(ITunesCategory.NewsSubcategory.entertainmentNews.rawValue == "Entertainment News")
        #expect(ITunesCategory.NewsSubcategory.newsCommentary.rawValue == "News Commentary")
        #expect(ITunesCategory.NewsSubcategory.politics.rawValue == "Politics")
        #expect(ITunesCategory.NewsSubcategory.sportsNews.rawValue == "Sports News")
        #expect(ITunesCategory.NewsSubcategory.techNews.rawValue == "Tech News")

        // Religion & Spirituality
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.buddhism.rawValue == "Buddhism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.christianity.rawValue == "Christianity")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.hinduism.rawValue == "Hinduism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.islam.rawValue == "Islam")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.judaism.rawValue == "Judaism")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.religion.rawValue == "Religion")
        #expect(ITunesCategory.ReligionAndSpiritualitySubcategory.spirituality.rawValue == "Spirituality")

        // Science
        #expect(ITunesCategory.ScienceSubcategory.astronomy.rawValue == "Astronomy")
        #expect(ITunesCategory.ScienceSubcategory.chemistry.rawValue == "Chemistry")
        #expect(ITunesCategory.ScienceSubcategory.earthSciences.rawValue == "Earth Sciences")
        #expect(ITunesCategory.ScienceSubcategory.lifeSciences.rawValue == "Life Sciences")
        #expect(ITunesCategory.ScienceSubcategory.mathematics.rawValue == "Mathematics")
        #expect(ITunesCategory.ScienceSubcategory.naturalSciences.rawValue == "Natural Sciences")
        #expect(ITunesCategory.ScienceSubcategory.nature.rawValue == "Nature")
        #expect(ITunesCategory.ScienceSubcategory.physics.rawValue == "Physics")
        #expect(ITunesCategory.ScienceSubcategory.socialSciences.rawValue == "Social Sciences")

        // Society & Culture
        #expect(ITunesCategory.SocietyAndCultureSubcategory.documentary.rawValue == "Documentary")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.personalJournals.rawValue == "Personal Journals")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.philosophy.rawValue == "Philosophy")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.placesAndTravel.rawValue == "Places & Travel")
        #expect(ITunesCategory.SocietyAndCultureSubcategory.relationships.rawValue == "Relationships")

        // Sports
        #expect(ITunesCategory.SportsSubcategory.baseball.rawValue == "Baseball")
        #expect(ITunesCategory.SportsSubcategory.basketball.rawValue == "Basketball")
        #expect(ITunesCategory.SportsSubcategory.cricket.rawValue == "Cricket")
        #expect(ITunesCategory.SportsSubcategory.fantasySports.rawValue == "Fantasy Sports")
        #expect(ITunesCategory.SportsSubcategory.football.rawValue == "Football")
        #expect(ITunesCategory.SportsSubcategory.golf.rawValue == "Golf")
        #expect(ITunesCategory.SportsSubcategory.hockey.rawValue == "Hockey")
        #expect(ITunesCategory.SportsSubcategory.rugby.rawValue == "Rugby")
        #expect(ITunesCategory.SportsSubcategory.running.rawValue == "Running")
        #expect(ITunesCategory.SportsSubcategory.soccer.rawValue == "Soccer")
        #expect(ITunesCategory.SportsSubcategory.swimming.rawValue == "Swimming")
        #expect(ITunesCategory.SportsSubcategory.tennis.rawValue == "Tennis")
        #expect(ITunesCategory.SportsSubcategory.volleyball.rawValue == "Volleyball")
        #expect(ITunesCategory.SportsSubcategory.wilderness.rawValue == "Wilderness")
        #expect(ITunesCategory.SportsSubcategory.wrestling.rawValue == "Wrestling")

        // TV & Film
        #expect(ITunesCategory.TvAndFilmSubcategory.afterShows.rawValue == "After Shows")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmHistory.rawValue == "Film History")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmInterviews.rawValue == "Film Interviews")
        #expect(ITunesCategory.TvAndFilmSubcategory.filmReviews.rawValue == "Film Reviews")
        #expect(ITunesCategory.TvAndFilmSubcategory.tvReviews.rawValue == "TV Reviews")
    }

    // MARK: - ITunesOwner

    @Test("ITunesOwner holds name and email")
    func itunesOwnerProperties() {
        let owner = ITunesOwner(name: "Wlad Dicario", email: "wlad@ateliersocle.com")
        #expect(owner.name == "Wlad Dicario")
        #expect(owner.email == "wlad@ateliersocle.com")
    }

    // MARK: - Item iTunes Properties

    @Test("Item initializes with all iTunes namespace properties")
    func itemAllITunesProperties() throws {
        let imageURL = try #require(URL(string: "https://example.com/ep1-art.jpg"))

        let item = Item(
            title: "Episode with Full iTunes Metadata",
            itunesAuthor: "Jane Swift",
            itunesBlock: false,
            itunesDuration: 3600,
            itunesEpisode: 42,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: imageURL,
            itunesKeywords: ["swift", "concurrency", "actors"],
            itunesSeason: 3,
            itunesSubtitle: "A deep dive into actors",
            itunesSummary: "In this episode we explore the actor model in Swift concurrency...",
            itunesTitle: "Actors Deep Dive"
        )

        #expect(item.itunesAuthor == "Jane Swift")
        #expect(item.itunesBlock == false)
        #expect(item.itunesDuration == 3600)
        #expect(item.itunesEpisode == 42)
        #expect(item.itunesEpisodeType == .full)
        #expect(item.itunesExplicit == false)
        #expect(item.itunesImage == imageURL)
        #expect(item.itunesKeywords.count == 3)
        #expect(item.itunesSeason == 3)
        #expect(item.itunesSubtitle == "A deep dive into actors")
        #expect(item.itunesSummary?.contains("actor model") == true)
        #expect(item.itunesTitle == "Actors Deep Dive")
    }
}

// MARK: - Podcast NS 2.0 Phase 1

@Suite("Podcast NS 2.0 -- Phase 1")
struct PodcastNS20Phase1Showcase {

    // MARK: - Locked

    @Test("Locked with owner email")
    func lockedWithOwner() {
        let locked = Locked(isLocked: true, owner: "owner@podcast.example")
        #expect(locked.isLocked == true)
        #expect(locked.owner == "owner@podcast.example")
    }

    @Test("Locked without owner")
    func lockedWithoutOwner() {
        let locked = Locked(isLocked: false)
        #expect(locked.isLocked == false)
        #expect(locked.owner == nil)
    }

    // MARK: - Transcript

    @Test("Transcript with all properties")
    func transcriptAllProperties() throws {
        let url = try #require(URL(string: "https://example.com/ep1.vtt"))
        let transcript = Transcript(url: url, type: "text/vtt", language: "en", rel: "captions")

        #expect(transcript.url == url)
        #expect(transcript.type == "text/vtt")
        #expect(transcript.language == "en")
        #expect(transcript.rel == "captions")
    }

    @Test("Transcript with required properties only")
    func transcriptRequiredOnly() throws {
        let url = try #require(URL(string: "https://example.com/ep1.srt"))
        let transcript = Transcript(url: url, type: "application/srt")

        #expect(transcript.language == nil)
        #expect(transcript.rel == nil)
    }

    @Test("Transcript.TranscriptType covers all known MIME types")
    func transcriptTypeAllCases() {
        let allCases = Transcript.TranscriptType.allCases
        #expect(allCases.count == 5)
        #expect(Transcript.TranscriptType.vtt.rawValue == "text/vtt")
        #expect(Transcript.TranscriptType.srt.rawValue == "application/srt")
        #expect(Transcript.TranscriptType.subrip.rawValue == "application/x-subrip")
        #expect(Transcript.TranscriptType.html.rawValue == "text/html")
        #expect(Transcript.TranscriptType.json.rawValue == "application/json")
    }

    // MARK: - Funding

    @Test("Funding links to a donation page")
    func fundingAllProperties() throws {
        let url = try #require(URL(string: "https://www.patreon.com/swifttalk"))
        let funding = Funding(url: url, message: "Support us on Patreon")

        #expect(funding.url == url)
        #expect(funding.message == "Support us on Patreon")
    }

    // MARK: - ChaptersLink

    @Test("ChaptersLink with default type")
    func chaptersLinkDefaultType() throws {
        let url = try #require(URL(string: "https://example.com/ep1/chapters.json"))
        let chapters = ChaptersLink(url: url)

        #expect(chapters.url == url)
        #expect(chapters.type == "application/json+chapters")
    }

    @Test("ChaptersLink with explicit type")
    func chaptersLinkExplicitType() throws {
        let url = try #require(URL(string: "https://example.com/ep1/chapters.json"))
        let chapters = ChaptersLink(url: url, type: "application/json")

        #expect(chapters.type == "application/json")
    }

    // MARK: - Soundbite

    @Test("Soundbite with title")
    func soundbiteWithTitle() {
        let soundbite = Soundbite(startTime: 73.0, duration: 60.0, title: "Best moment of the episode")

        #expect(soundbite.startTime == 73.0)
        #expect(soundbite.duration == 60.0)
        #expect(soundbite.title == "Best moment of the episode")
    }

    @Test("Soundbite without title")
    func soundbiteWithoutTitle() {
        let soundbite = Soundbite(startTime: 120.5, duration: 30.0)

        #expect(soundbite.startTime == 120.5)
        #expect(soundbite.duration == 30.0)
        #expect(soundbite.title == nil)
    }
}

// MARK: - Podcast NS 2.0 Phase 2

@Suite("Podcast NS 2.0 -- Phase 2")
struct PodcastNS20Phase2Showcase {

    // MARK: - PodcastPerson

    @Test("PodcastPerson with all properties")
    func personAllProperties() throws {
        let href = try #require(URL(string: "https://janeswift.dev"))
        let img = try #require(URL(string: "https://janeswift.dev/headshot.jpg"))

        let person = PodcastPerson(
            name: "Jane Swift",
            role: "host",
            group: "cast",
            href: href,
            img: img
        )

        #expect(person.name == "Jane Swift")
        #expect(person.role == "host")
        #expect(person.group == "cast")
        #expect(person.href == href)
        #expect(person.img == img)
    }

    @Test("PodcastPerson with name only defaults role and group to nil")
    func personNameOnly() {
        let person = PodcastPerson(name: "Anonymous Guest")

        #expect(person.name == "Anonymous Guest")
        #expect(person.role == nil)
        #expect(person.group == nil)
        #expect(person.href == nil)
        #expect(person.img == nil)
    }

    @Test("PodcastPerson.Role enum covers common podcast taxonomy roles")
    func personRoleEnum() {
        let allRoles = PodcastPerson.Role.allCases
        #expect(allRoles.count == 8)
        #expect(PodcastPerson.Role.host.rawValue == "host")
        #expect(PodcastPerson.Role.guest.rawValue == "guest")
        #expect(PodcastPerson.Role.editor.rawValue == "editor")
        #expect(PodcastPerson.Role.producer.rawValue == "producer")
        #expect(PodcastPerson.Role.writer.rawValue == "writer")
        #expect(PodcastPerson.Role.designer.rawValue == "designer")
        #expect(PodcastPerson.Role.composer.rawValue == "composer")
        #expect(PodcastPerson.Role.narrator.rawValue == "narrator")
    }

    // MARK: - PodcastLocation

    @Test("PodcastLocation with all attributes")
    func locationAllProperties() {
        let location = PodcastLocation(
            name: "Austin, TX",
            geo: "geo:30.2672,-97.7431",
            osm: "R113314",
            rel: "creator",
            country: "US"
        )

        #expect(location.name == "Austin, TX")
        #expect(location.geo == "geo:30.2672,-97.7431")
        #expect(location.osm == "R113314")
        #expect(location.rel == "creator")
        #expect(location.country == "US")
    }

    @Test("PodcastLocation with name only")
    func locationNameOnly() {
        let location = PodcastLocation(name: "Somewhere beautiful")

        #expect(location.name == "Somewhere beautiful")
        #expect(location.geo == nil)
        #expect(location.osm == nil)
        #expect(location.rel == nil)
        #expect(location.country == nil)
    }

    @Test("PodcastLocation subject relationship")
    func locationSubject() {
        let location = PodcastLocation(
            name: "Paris",
            geo: "geo:48.8566,2.3522",
            osm: "R7444",
            rel: "subject",
            country: "FR"
        )

        #expect(location.rel == "subject")
        #expect(location.country == "FR")
    }

    // MARK: - PodcastSeason

    @Test("PodcastSeason with name")
    func seasonWithName() {
        let season = PodcastSeason(number: 3, name: "Mysteries of the Deep")

        #expect(season.number == 3)
        #expect(season.name == "Mysteries of the Deep")
    }

    @Test("PodcastSeason number only")
    func seasonNumberOnly() {
        let season = PodcastSeason(number: 1)

        #expect(season.number == 1)
        #expect(season.name == nil)
    }

    // MARK: - PodcastEpisode

    @Test("PodcastEpisode with display string")
    func episodeWithDisplay() {
        let episode = PodcastEpisode(number: 3.0, display: "EP3")

        #expect(episode.number == 3.0)
        #expect(episode.display == "EP3")
    }

    @Test("PodcastEpisode supports decimal sub-episodes")
    func episodeDecimalNumber() {
        let episode = PodcastEpisode(number: 3.5, display: "3a")

        #expect(episode.number == 3.5)
        #expect(episode.display == "3a")
    }

    @Test("PodcastEpisode number only")
    func episodeNumberOnly() {
        let episode = PodcastEpisode(number: 42.0)

        #expect(episode.number == 42.0)
        #expect(episode.display == nil)
    }
}

// MARK: - Podcast NS 2.0 Phase 3

@Suite("Podcast NS 2.0 -- Phase 3")
struct PodcastNS20Phase3Showcase {

    // MARK: - Trailer

    @Test("Trailer with all properties")
    func trailerAllProperties() throws {
        let url = try #require(URL(string: "https://cdn.example.com/season2-trailer.mp3"))
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let trailer = Trailer(
            title: "Season 2 Trailer",
            url: url,
            pubDate: pubDate,
            length: 5_242_880,
            type: "audio/mpeg",
            season: 2
        )

        #expect(trailer.title == "Season 2 Trailer")
        #expect(trailer.url == url)
        #expect(trailer.pubDate == pubDate)
        #expect(trailer.length == 5_242_880)
        #expect(trailer.type == "audio/mpeg")
        #expect(trailer.season == 2)
    }

    @Test("Trailer with required properties only")
    func trailerRequiredOnly() throws {
        let url = try #require(URL(string: "https://cdn.example.com/preview.mp3"))
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let trailer = Trailer(title: "Show Preview", url: url, pubDate: pubDate)

        #expect(trailer.length == nil)
        #expect(trailer.type == nil)
        #expect(trailer.season == nil)
    }

    // MARK: - PodcastLicense

    @Test("PodcastLicense with URL")
    func licenseWithURL() throws {
        let url = try #require(URL(string: "https://creativecommons.org/licenses/by/4.0/"))
        let license = PodcastLicense(identifier: "cc-by-4.0", url: url)

        #expect(license.identifier == "cc-by-4.0")
        #expect(license.url == url)
    }

    @Test("PodcastLicense identifier only")
    func licenseIdentifierOnly() {
        let license = PodcastLicense(identifier: "cc-by-sa-4.0")

        #expect(license.identifier == "cc-by-sa-4.0")
        #expect(license.url == nil)
    }

    // MARK: - AlternateEnclosure + PodcastSource + PodcastIntegrity

    @Test("AlternateEnclosure with all properties including sources and integrity")
    func alternateEnclosureComplete() {
        let altEnc = AlternateEnclosure(
            type: "audio/opus",
            length: 18_000_000,
            bitrate: 128_000,
            height: 0,
            language: "en",
            title: "High Quality Opus",
            isDefault: true,
            sources: [
                PodcastSource(uri: "https://cdn.example.com/ep1.opus"),
                PodcastSource(uri: "ipfs://QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn", contentType: "audio/opus")
            ],
            integrity: PodcastIntegrity(type: "sri", value: "sha256-C7yRJuJMwYk3JYONn3V2AUHR3L4rFAF3GJHP+eR3jYg=")
        )

        #expect(altEnc.type == "audio/opus")
        #expect(altEnc.length == 18_000_000)
        #expect(altEnc.bitrate == 128_000)
        #expect(altEnc.height == 0)
        #expect(altEnc.language == "en")
        #expect(altEnc.title == "High Quality Opus")
        #expect(altEnc.isDefault == true)
        #expect(altEnc.sources.count == 2)
        #expect(altEnc.sources[0].uri == "https://cdn.example.com/ep1.opus")
        #expect(altEnc.sources[0].contentType == nil)
        #expect(altEnc.sources[1].uri.hasPrefix("ipfs://"))
        #expect(altEnc.sources[1].contentType == "audio/opus")
        #expect(altEnc.integrity?.type == "sri")
        #expect(altEnc.integrity?.value.hasPrefix("sha256-") == true)
    }

    @Test("AlternateEnclosure with minimal properties")
    func alternateEnclosureMinimal() {
        let altEnc = AlternateEnclosure(type: "audio/mpeg")

        #expect(altEnc.type == "audio/mpeg")
        #expect(altEnc.length == nil)
        #expect(altEnc.bitrate == nil)
        #expect(altEnc.height == nil)
        #expect(altEnc.language == nil)
        #expect(altEnc.title == nil)
        #expect(altEnc.isDefault == nil)
        #expect(altEnc.sources.isEmpty)
        #expect(altEnc.integrity == nil)
    }

    @Test("PodcastSource with optional content type")
    func podcastSourceProperties() {
        let sourceHTTPS = PodcastSource(uri: "https://cdn.example.com/episode.mp3")
        #expect(sourceHTTPS.uri == "https://cdn.example.com/episode.mp3")
        #expect(sourceHTTPS.contentType == nil)

        let sourceIPFS = PodcastSource(uri: "ipfs://QmHash123", contentType: "audio/mpeg")
        #expect(sourceIPFS.contentType == "audio/mpeg")
    }

    @Test("PodcastIntegrity holds type and hash value")
    func podcastIntegrityProperties() {
        let integrity = PodcastIntegrity(
            type: "sri",
            value: "sha256-C7yRJuJMwYk3JYONn3V2AUHR3L4rFAF3GJHP+eR3jYg="
        )

        #expect(integrity.type == "sri")
        #expect(integrity.value.hasPrefix("sha256-"))
    }
}

// MARK: - Podcast NS 2.0 Phase 4+

@Suite("Podcast NS 2.0 -- Phase 4+")
struct PodcastNS20Phase4PlusShowcase {

    // MARK: - PodcastGuid

    @Test("PodcastGuid holds a UUID string")
    func podcastGuidValue() {
        let guid = PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(guid.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
    }

    // MARK: - PodcastValue

    @Test("PodcastValue with recipients and time splits")
    func podcastValueComplete() throws {
        let remoteURL = try #require(URL(string: "https://other.example.com/feed.xml"))
        let value = PodcastValue(
            type: "lightning",
            method: "keysend",
            suggested: "0.00000005000",
            recipients: [
                ValueRecipient(
                    name: "Host",
                    type: "node",
                    address: "02d5c1d52fd3a6a2f4ba0637a6d10b085af94c5b15f2a3f7a7e7b38e4be2f44e8a",
                    customKey: "696969",
                    customValue: "podcaster",
                    split: 90,
                    fee: false
                ),
                ValueRecipient(
                    name: "App Developer",
                    type: "node",
                    address: "03ae9f91a0cb8ff43840e3c322c4c61f019d8c1c3cea15a25cfc425ac605e61f31",
                    split: 10,
                    fee: true
                )
            ],
            timeSplits: [
                ValueTimeSplit(
                    startTime: 60.0,
                    duration: 120.0,
                    recipients: [
                        ValueRecipient(name: "Guest", type: "node", address: "04abc123def456", split: 50)
                    ],
                    remoteItem: RemoteItem(
                        feedGuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
                        feedUrl: remoteURL,
                        itemGuid: "remote-ep-001",
                        medium: "music"
                    ),
                    remotePercentage: 70
                )
            ]
        )

        #expect(value.type == "lightning")
        #expect(value.method == "keysend")
        #expect(value.suggested == "0.00000005000")
        #expect(value.recipients.count == 2)

        let host = value.recipients[0]
        #expect(host.name == "Host")
        #expect(host.type == "node")
        #expect(host.address.hasPrefix("02d5c"))
        #expect(host.customKey == "696969")
        #expect(host.customValue == "podcaster")
        #expect(host.split == 90)
        #expect(host.fee == false)

        let appDev = value.recipients[1]
        #expect(appDev.split == 10)
        #expect(appDev.fee == true)
        #expect(appDev.customKey == nil)
        #expect(appDev.customValue == nil)

        #expect(value.timeSplits.count == 1)
        let split = value.timeSplits[0]
        #expect(split.startTime == 60.0)
        #expect(split.duration == 120.0)
        #expect(split.recipients.count == 1)
        #expect(split.remoteItem?.feedGuid == "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        #expect(split.remoteItem?.feedUrl == remoteURL)
        #expect(split.remoteItem?.itemGuid == "remote-ep-001")
        #expect(split.remoteItem?.medium == "music")
        #expect(split.remotePercentage == 70)
    }

    @Test("PodcastValue with minimal configuration")
    func podcastValueMinimal() {
        let value = PodcastValue(type: "paypal", method: "direct")

        #expect(value.type == "paypal")
        #expect(value.method == "direct")
        #expect(value.suggested == nil)
        #expect(value.recipients.isEmpty)
        #expect(value.timeSplits.isEmpty)
    }

    @Test("ValueRecipient with minimal properties")
    func valueRecipientMinimal() {
        let recipient = ValueRecipient(type: "wallet", address: "wallet-address-123", split: 100)

        #expect(recipient.name == nil)
        #expect(recipient.type == "wallet")
        #expect(recipient.address == "wallet-address-123")
        #expect(recipient.customKey == nil)
        #expect(recipient.customValue == nil)
        #expect(recipient.split == 100)
        #expect(recipient.fee == nil)
    }

    @Test("ValueTimeSplit with minimal properties")
    func valueTimeSplitMinimal() {
        let split = ValueTimeSplit(startTime: 0.0, duration: 30.0)

        #expect(split.startTime == 0.0)
        #expect(split.duration == 30.0)
        #expect(split.recipients.isEmpty)
        #expect(split.remoteItem == nil)
        #expect(split.remotePercentage == nil)
    }

    // MARK: - PodcastMedium

    @Test("PodcastMedium has all 19 cases (10 core + 9 list variants)")
    func podcastMediumAllCases() {
        let allCases = PodcastMedium.allCases
        #expect(allCases.count == 19)

        // Core types
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

        // List variants
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

    // MARK: - PodcastLiveItem

    @Test("PodcastLiveItem with full configuration")
    func liveItemFull() throws {
        let enclosureURL = try #require(URL(string: "https://stream.example.com/live.mp3"))
        let chatURL = try #require(URL(string: "https://example.com/chat"))
        let artworkURL = try #require(URL(string: "https://example.com/live-art.jpg"))
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)
        let endDate = Date(timeIntervalSince1970: 1_700_007_200)

        let liveItem = PodcastLiveItem(
            status: .live,
            start: startDate,
            end: endDate,
            title: "Live Q&A Session",
            description: "Ask us anything about Swift 6",
            enclosure: Enclosure(url: enclosureURL, length: 0, type: "audio/mpeg"),
            guid: GUID(value: "live-2025-001", isPermaLink: false),
            contentLinks: [
                ContentLink(href: chatURL, title: "Join the Chat")
            ],
            persons: [PodcastPerson(name: "Wlad", role: "host")],
            alternateEnclosures: [
                AlternateEnclosure(type: "audio/opus", sources: [PodcastSource(uri: "https://stream.example.com/live.opus")])
            ],
            itunesImage: artworkURL,
            value: PodcastValue(type: "lightning", method: "keysend"),
            socialInteractions: [
                SocialInteract(uri: "https://mastodon.social/@host/live", protocol: "activitypub")
            ]
        )

        #expect(liveItem.status == .live)
        #expect(liveItem.start == startDate)
        #expect(liveItem.end == endDate)
        #expect(liveItem.title == "Live Q&A Session")
        #expect(liveItem.description?.contains("Swift 6") == true)
        #expect(liveItem.enclosure?.url == enclosureURL)
        #expect(liveItem.guid?.value == "live-2025-001")
        #expect(liveItem.contentLinks.count == 1)
        #expect(liveItem.contentLinks[0].title == "Join the Chat")
        #expect(liveItem.persons.count == 1)
        #expect(liveItem.alternateEnclosures.count == 1)
        #expect(liveItem.itunesImage == artworkURL)
        #expect(liveItem.value?.type == "lightning")
        #expect(liveItem.socialInteractions.count == 1)
    }

    @Test("PodcastLiveItem.LiveStatus has all three cases")
    func liveStatusCases() {
        let allCases = PodcastLiveItem.LiveStatus.allCases
        #expect(allCases.count == 3)
        #expect(PodcastLiveItem.LiveStatus.pending.rawValue == "pending")
        #expect(PodcastLiveItem.LiveStatus.live.rawValue == "live")
        #expect(PodcastLiveItem.LiveStatus.ended.rawValue == "ended")
    }

    @Test("ContentLink holds href and title")
    func contentLinkProperties() throws {
        let url = try #require(URL(string: "https://example.com/show-notes"))
        let link = ContentLink(href: url, title: "Show Notes")

        #expect(link.href == url)
        #expect(link.title == "Show Notes")
    }

    // MARK: - SocialInteract

    @Test("SocialInteract with all properties")
    func socialInteractFull() throws {
        let accountURL = try #require(URL(string: "https://mastodon.social/@podcasthost"))

        let social = SocialInteract(
            uri: "https://mastodon.social/@podcasthost/109876543210",
            protocol: "activitypub",
            accountId: "@podcasthost@mastodon.social",
            accountUrl: accountURL,
            priority: 1
        )

        #expect(social.uri == "https://mastodon.social/@podcasthost/109876543210")
        #expect(social.protocol == "activitypub")
        #expect(social.accountId == "@podcasthost@mastodon.social")
        #expect(social.accountUrl == accountURL)
        #expect(social.priority == 1)
    }

    @Test("SocialInteract with required properties only")
    func socialInteractMinimal() {
        let social = SocialInteract(uri: "https://twitter.com/host/status/12345", protocol: "twitter")

        #expect(social.accountId == nil)
        #expect(social.accountUrl == nil)
        #expect(social.priority == nil)
    }

    // MARK: - PodcastBlock

    @Test("PodcastBlock targeting a specific platform")
    func podcastBlockTargeted() {
        let block = PodcastBlock(isBlocked: true, id: "google")

        #expect(block.isBlocked == true)
        #expect(block.id == "google")
    }

    @Test("PodcastBlock targeting all platforms")
    func podcastBlockAll() {
        let block = PodcastBlock(isBlocked: true)

        #expect(block.isBlocked == true)
        #expect(block.id == nil)
    }

    @Test("PodcastBlock inactive (not blocked)")
    func podcastBlockInactive() {
        let block = PodcastBlock(isBlocked: false, id: "amazon")

        #expect(block.isBlocked == false)
    }

    // MARK: - PodcastTxt

    @Test("PodcastTxt verification string")
    func podcastTxtVerify() {
        let txt = PodcastTxt(value: "S6lpp-7ZCn8-VZNOk", purpose: "verify")

        #expect(txt.value == "S6lpp-7ZCn8-VZNOk")
        #expect(txt.purpose == "verify")
    }

    @Test("PodcastTxt without purpose")
    func podcastTxtNoPurpose() {
        let txt = PodcastTxt(value: "Any freeform text content here")

        #expect(txt.value == "Any freeform text content here")
        #expect(txt.purpose == nil)
    }

    // MARK: - RemoteItem

    @Test("RemoteItem with all properties")
    func remoteItemFull() throws {
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))

        let remote = RemoteItem(
            feedGuid: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1",
            feedUrl: feedURL,
            itemGuid: "episode-001",
            medium: "podcast"
        )

        #expect(remote.feedGuid == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(remote.feedUrl == feedURL)
        #expect(remote.itemGuid == "episode-001")
        #expect(remote.medium == "podcast")
    }

    @Test("RemoteItem with feedGuid only")
    func remoteItemMinimal() {
        let remote = RemoteItem(feedGuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")

        #expect(remote.feedGuid == "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        #expect(remote.feedUrl == nil)
        #expect(remote.itemGuid == nil)
        #expect(remote.medium == nil)
    }

    // MARK: - Podroll

    @Test("Podroll contains multiple recommended podcasts")
    func podrollMultipleRecommendations() throws {
        let url1 = try #require(URL(string: "https://podcast1.example.com/feed.xml"))
        let url2 = try #require(URL(string: "https://podcast2.example.com/feed.xml"))

        let podroll = Podroll(remoteItems: [
            RemoteItem(feedGuid: "guid-1111", feedUrl: url1, medium: "podcast"),
            RemoteItem(feedGuid: "guid-2222", feedUrl: url2, medium: "podcast"),
            RemoteItem(feedGuid: "guid-3333")
        ])

        #expect(podroll.remoteItems.count == 3)
        #expect(podroll.remoteItems[0].feedGuid == "guid-1111")
        #expect(podroll.remoteItems[2].feedUrl == nil)
    }

    @Test("Podroll defaults to empty list")
    func podrollEmpty() {
        let podroll = Podroll()
        #expect(podroll.remoteItems.isEmpty)
    }

    // MARK: - UpdateFrequency

    @Test("UpdateFrequency with all properties")
    func updateFrequencyFull() {
        let freq = UpdateFrequency(
            label: "Weekly on Fridays",
            rrule: "FREQ=WEEKLY;BYDAY=FR",
            dtstart: "2021-01-01T05:00:00.000-05:00",
            complete: false
        )

        #expect(freq.label == "Weekly on Fridays")
        #expect(freq.rrule == "FREQ=WEEKLY;BYDAY=FR")
        #expect(freq.dtstart == "2021-01-01T05:00:00.000-05:00")
        #expect(freq.complete == false)
    }

    @Test("UpdateFrequency all properties are optional")
    func updateFrequencyMinimal() {
        let freq = UpdateFrequency()

        #expect(freq.label == nil)
        #expect(freq.rrule == nil)
        #expect(freq.dtstart == nil)
        #expect(freq.complete == nil)
    }

    @Test("UpdateFrequency with complete flag for finished podcasts")
    func updateFrequencyComplete() {
        let freq = UpdateFrequency(label: "This podcast is complete", complete: true)

        #expect(freq.complete == true)
    }

    // MARK: - PodcastChat

    @Test("PodcastChat with all properties")
    func podcastChatFull() throws {
        let embedURL = try #require(URL(string: "https://example.com/chat-embed"))

        let chat = PodcastChat(
            server: "irc.zeronode.net",
            protocol: "irc",
            accountId: "podcasthost",
            space: "#podcast-room",
            embedUrl: embedURL
        )

        #expect(chat.server == "irc.zeronode.net")
        #expect(chat.protocol == "irc")
        #expect(chat.accountId == "podcasthost")
        #expect(chat.space == "#podcast-room")
        #expect(chat.embedUrl == embedURL)
    }

    @Test("PodcastChat with required properties only")
    func podcastChatMinimal() {
        let chat = PodcastChat(server: "matrix.example.com", protocol: "matrix")

        #expect(chat.server == "matrix.example.com")
        #expect(chat.protocol == "matrix")
        #expect(chat.accountId == nil)
        #expect(chat.space == nil)
        #expect(chat.embedUrl == nil)
    }

    @Test("PodcastChat supports various protocols")
    func podcastChatProtocols() {
        let nostr = PodcastChat(server: "relay.damus.io", protocol: "nostr")
        #expect(nostr.protocol == "nostr")

        let xmpp = PodcastChat(server: "xmpp.example.com", protocol: "xmpp", space: "podcast@conference.example.com")
        #expect(xmpp.protocol == "xmpp")
    }

    // MARK: - PodcastPublisher

    @Test("PodcastPublisher wraps a RemoteItem")
    func podcastPublisherProperties() throws {
        let url = try #require(URL(string: "https://publisher.example.com/feed.xml"))

        let publisher = PodcastPublisher(
            remoteItem: RemoteItem(
                feedGuid: "003af0a0-1234-5678-90ab-cdef01234567",
                feedUrl: url,
                medium: "publisher"
            )
        )

        #expect(publisher.remoteItem.feedGuid == "003af0a0-1234-5678-90ab-cdef01234567")
        #expect(publisher.remoteItem.feedUrl == url)
        #expect(publisher.remoteItem.medium == "publisher")
    }

    // MARK: - PodcastImage

    @Test("PodcastImage with all seven attributes")
    func podcastImageFull() throws {
        let href = try #require(URL(string: "https://example.com/artwork.png"))

        let image = PodcastImage(
            href: href,
            alt: "Show artwork depicting a microphone and code",
            aspectRatio: "1/1",
            width: 3000,
            height: 3000,
            type: "image/png",
            purpose: "artwork"
        )

        #expect(image.href == href)
        #expect(image.alt == "Show artwork depicting a microphone and code")
        #expect(image.aspectRatio == "1/1")
        #expect(image.width == 3000)
        #expect(image.height == 3000)
        #expect(image.type == "image/png")
        #expect(image.purpose == "artwork")
    }

    @Test("PodcastImage with href only")
    func podcastImageMinimal() throws {
        let href = try #require(URL(string: "https://example.com/social-card.jpg"))
        let image = PodcastImage(href: href)

        #expect(image.href == href)
        #expect(image.alt == nil)
        #expect(image.aspectRatio == nil)
        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.type == nil)
        #expect(image.purpose == nil)
    }

    @Test("PodcastImage supports multiple purpose tokens")
    func podcastImageMultiplePurposes() throws {
        let href = try #require(URL(string: "https://example.com/banner.jpg"))
        let image = PodcastImage(href: href, aspectRatio: "16/9", purpose: "social canvas")

        #expect(image.purpose == "social canvas")
    }

    // MARK: - PodcastImages (Deprecated)

    @Test("PodcastImages holds srcset with width descriptors")
    func podcastImagesSrcset() {
        let images = PodcastImages(
            srcset: "https://example.com/art-1500.jpg 1500w, https://example.com/art-600.jpg 600w, https://example.com/art-300.jpg 300w"
        )

        #expect(images.srcset.contains("1500w"))
        #expect(images.srcset.contains("600w"))
        #expect(images.srcset.contains("300w"))
    }
}

// MARK: - Atom Namespace Showcase

@Suite("Atom Namespace Showcase")
struct AtomNamespaceShowcase {

    @Test("AtomLink with all properties")
    func atomLinkFull() throws {
        let href = try #require(URL(string: "https://example.com/alternate-feed.xml"))

        let link = AtomLink(
            href: href,
            rel: "alternate",
            type: "application/atom+xml",
            hreflang: "fr",
            title: "French version of this feed",
            length: 524_288
        )

        #expect(link.href == href)
        #expect(link.rel == "alternate")
        #expect(link.type == "application/atom+xml")
        #expect(link.hreflang == "fr")
        #expect(link.title == "French version of this feed")
        #expect(link.length == 524_288)
    }

    @Test("AtomLink self-link factory creates properly typed self reference")
    func atomLinkSelfFactory() throws {
        let feedURL = try #require(URL(string: "https://swifttalk.dev/feed.xml"))
        let selfLink = AtomLink.selfLink(href: feedURL)

        #expect(selfLink.href == feedURL)
        #expect(selfLink.rel == "self")
        #expect(selfLink.type == "application/rss+xml")
        #expect(selfLink.hreflang == nil)
        #expect(selfLink.title == nil)
        #expect(selfLink.length == nil)
    }

    @Test("AtomLink with href only")
    func atomLinkHrefOnly() throws {
        let href = try #require(URL(string: "https://example.com/related"))
        let link = AtomLink(href: href)

        #expect(link.href == href)
        #expect(link.rel == nil)
        #expect(link.type == nil)
        #expect(link.hreflang == nil)
        #expect(link.title == nil)
        #expect(link.length == nil)
    }

    @Test("AtomLink enclosure relation for media")
    func atomLinkEnclosure() throws {
        let href = try #require(URL(string: "https://cdn.example.com/episode.mp3"))

        let link = AtomLink(
            href: href,
            rel: "enclosure",
            type: "audio/mpeg",
            length: 48_576_000
        )

        #expect(link.rel == "enclosure")
        #expect(link.type == "audio/mpeg")
        #expect(link.length == 48_576_000)
    }
}

// MARK: - Dublin Core Showcase

@Suite("Dublin Core Showcase")
struct DublinCoreShowcase {

    @Test("DublinCore with all 15 properties")
    func dublinCoreAllProperties() {
        let dc = DublinCore(
            creator: "Wlad Dicario",
            contributor: "Jane Swift",
            date: "2025-01-15",
            description: "A podcast about Swift programming",
            format: "audio/mpeg",
            identifier: "urn:uuid:917393e3-1b1e-5cef-ace4-edaa54e1f3e1",
            language: "en-US",
            publisher: "Atelier Socle",
            relation: "https://ateliersocle.com/series/swift",
            rights: "Copyright 2025 Atelier Socle. All rights reserved.",
            source: "https://ateliersocle.com",
            subject: "Swift Programming",
            title: "Swift Talk",
            type: "Sound",
            coverage: "Global"
        )

        #expect(dc.creator == "Wlad Dicario")
        #expect(dc.contributor == "Jane Swift")
        #expect(dc.date == "2025-01-15")
        #expect(dc.description == "A podcast about Swift programming")
        #expect(dc.format == "audio/mpeg")
        #expect(dc.identifier == "urn:uuid:917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(dc.language == "en-US")
        #expect(dc.publisher == "Atelier Socle")
        #expect(dc.relation == "https://ateliersocle.com/series/swift")
        #expect(dc.rights == "Copyright 2025 Atelier Socle. All rights reserved.")
        #expect(dc.source == "https://ateliersocle.com")
        #expect(dc.subject == "Swift Programming")
        #expect(dc.title == "Swift Talk")
        #expect(dc.type == "Sound")
        #expect(dc.coverage == "Global")
    }

    @Test("DublinCore with no properties (all nil)")
    func dublinCoreEmpty() {
        let dc = DublinCore()

        #expect(dc.creator == nil)
        #expect(dc.contributor == nil)
        #expect(dc.date == nil)
        #expect(dc.description == nil)
        #expect(dc.format == nil)
        #expect(dc.identifier == nil)
        #expect(dc.language == nil)
        #expect(dc.publisher == nil)
        #expect(dc.relation == nil)
        #expect(dc.rights == nil)
        #expect(dc.source == nil)
        #expect(dc.subject == nil)
        #expect(dc.title == nil)
        #expect(dc.type == nil)
        #expect(dc.coverage == nil)
    }

    @Test("DublinCore with partial properties (typical usage)")
    func dublinCoreTypical() {
        let dc = DublinCore(
            creator: "Wlad",
            language: "en",
            rights: "CC-BY-4.0"
        )

        #expect(dc.creator == "Wlad")
        #expect(dc.language == "en")
        #expect(dc.rights == "CC-BY-4.0")
        #expect(dc.publisher == nil)
    }
}

// MARK: - Content Module Showcase

@Suite("Content Module Showcase")
struct ContentModuleShowcase {

    @Test("ContentEncoded holds HTML string")
    func contentEncodedHTML() {
        let html = "<p>Full show notes with <strong>HTML formatting</strong> and a <a href=\"https://swift.org\">link</a>.</p>"
        let content = ContentEncoded(value: html)

        #expect(content.value == html)
        #expect(content.value.contains("<strong>"))
        #expect(content.value.contains("<a href="))
    }

    @Test("ContentEncoded with complex multi-paragraph HTML")
    func contentEncodedComplex() {
        let html = """
        <h2>Episode Notes</h2>
        <p>In this episode we cover:</p>
        <ul>
            <li>Swift 6 strict concurrency</li>
            <li>The actor model</li>
            <li>Sendable conformance</li>
        </ul>
        <p>Links mentioned:</p>
        <ol>
            <li><a href="https://swift.org">Swift.org</a></li>
        </ol>
        """
        let content = ContentEncoded(value: html)

        #expect(content.value.contains("<h2>"))
        #expect(content.value.contains("<ul>"))
        #expect(content.value.contains("<li>"))
    }
}

// MARK: - Podlove Chapters Showcase

@Suite("Podlove Chapters Showcase")
struct PodloveChaptersShowcase {

    @Test("PodloveChapters container with multiple chapters")
    func podloveChaptersContainer() throws {
        let chapterURL = try #require(URL(string: "https://example.com/topic"))
        let imageURL = try #require(URL(string: "https://example.com/chapter-img.jpg"))

        let chapters = PodloveChapters(
            version: "1.2",
            chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Intro"),
                PodloveChapter(
                    start: "00:05:30.000",
                    title: "Main Topic",
                    href: chapterURL,
                    image: imageURL
                ),
                PodloveChapter(start: "00:45:00.000", title: "Wrap-up and Outro")
            ]
        )

        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 3)
        #expect(chapters.chapters[0].start == "00:00:00.000")
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[0].href == nil)
        #expect(chapters.chapters[0].image == nil)
        #expect(chapters.chapters[1].href == chapterURL)
        #expect(chapters.chapters[1].image == imageURL)
        #expect(chapters.chapters[2].title == "Wrap-up and Outro")
    }

    @Test("PodloveChapters defaults to version 1.2 and empty chapters")
    func podloveChaptersDefaults() {
        let chapters = PodloveChapters()

        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.isEmpty)
    }

    @Test("PodloveChapter with all properties")
    func podloveChapterFull() throws {
        let href = try #require(URL(string: "https://swift.org"))
        let img = try #require(URL(string: "https://example.com/swift-logo.png"))

        let chapter = PodloveChapter(
            start: "01:23:45.678",
            title: "Swift Evolution Deep Dive",
            href: href,
            image: img
        )

        #expect(chapter.start == "01:23:45.678")
        #expect(chapter.title == "Swift Evolution Deep Dive")
        #expect(chapter.href == href)
        #expect(chapter.image == img)
    }

    @Test("PodloveChapter with required properties only")
    func podloveChapterMinimal() {
        let chapter = PodloveChapter(start: "00:00:00.000", title: "Beginning")

        #expect(chapter.start == "00:00:00.000")
        #expect(chapter.title == "Beginning")
        #expect(chapter.href == nil)
        #expect(chapter.image == nil)
    }
}

// MARK: - JSON Chapters Showcase

@Suite("JSON Chapters Showcase")
struct JSONChaptersShowcase {

    @Test("JSONChapterList with all metadata and chapters")
    func jsonChapterListFull() throws {
        let chapterURL = try #require(URL(string: "https://example.com/topic"))
        let chapterImg = try #require(URL(string: "https://example.com/chapter1.jpg"))

        let list = JSONChapterList(
            version: "1.2.0",
            title: "Episode 42: The Answer",
            author: "Wlad",
            podcastName: "Swift Talk",
            chapters: [
                JSONChapter(startTime: 0.0, title: "Intro", endTime: 30.0),
                JSONChapter(
                    startTime: 30.0,
                    title: "Main Topic",
                    endTime: 2700.0,
                    url: chapterURL,
                    img: chapterImg,
                    toc: true,
                    location: PodcastLocation(name: "San Francisco", country: "US")
                ),
                JSONChapter(startTime: 2700.0, title: "Ad Break", toc: false),
                JSONChapter(startTime: 2760.0, title: "Wrap-up")
            ]
        )

        #expect(list.version == "1.2.0")
        #expect(list.title == "Episode 42: The Answer")
        #expect(list.author == "Wlad")
        #expect(list.podcastName == "Swift Talk")
        #expect(list.chapters.count == 4)

        #expect(list.chapters[0].startTime == 0.0)
        #expect(list.chapters[0].endTime == 30.0)

        #expect(list.chapters[1].url == chapterURL)
        #expect(list.chapters[1].img == chapterImg)
        #expect(list.chapters[1].toc == true)
        #expect(list.chapters[1].location?.name == "San Francisco")

        #expect(list.chapters[2].toc == false)
    }

    @Test("JSONChapterList defaults to version 1.2.0 and empty chapters")
    func jsonChapterListDefaults() {
        let list = JSONChapterList()

        #expect(list.version == "1.2.0")
        #expect(list.title == nil)
        #expect(list.author == nil)
        #expect(list.podcastName == nil)
        #expect(list.chapters.isEmpty)
    }

    @Test("JSONChapter with minimal properties")
    func jsonChapterMinimal() {
        let chapter = JSONChapter(startTime: 120.5)

        #expect(chapter.startTime == 120.5)
        #expect(chapter.title == nil)
        #expect(chapter.endTime == nil)
        #expect(chapter.url == nil)
        #expect(chapter.img == nil)
        #expect(chapter.toc == nil)
        #expect(chapter.location == nil)
    }

    @Test("JSONChapterList round-trips through Codable")
    func jsonChapterListCodable() throws {
        let original = JSONChapterList(
            version: "1.2.0",
            title: "Codable Test",
            author: "Tester",
            podcastName: "Test Pod",
            chapters: [
                JSONChapter(startTime: 0.0, title: "Start"),
                JSONChapter(startTime: 300.0, title: "Middle", toc: true),
                JSONChapter(startTime: 600.0, title: "End")
            ]
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(JSONChapterList.self, from: data)

        #expect(decoded == original)
        #expect(decoded.version == "1.2.0")
        #expect(decoded.title == "Codable Test")
        #expect(decoded.chapters.count == 3)
        #expect(decoded.chapters[1].toc == true)
    }
}

// MARK: - PodcastFeed Container Showcase

@Suite("PodcastFeed Container Showcase")
struct PodcastFeedContainerShowcase {

    // MARK: - PodcastFeed

    @Test("PodcastFeed with default parameters")
    func podcastFeedDefaults() {
        let feed = PodcastFeed()

        #expect(feed.version == "2.0")
        #expect(feed.namespaces == PodcastNamespace.allStandard)
        #expect(feed.channel == nil)
        #expect(feed.namespacePrefixes.isEmpty)
    }

    @Test("PodcastFeed with channel and custom namespaces")
    func podcastFeedWithChannel() throws {
        let url = try #require(URL(string: "https://swifttalk.dev"))

        let feed = PodcastFeed(
            version: "2.0",
            namespaces: [.itunes, .atom, .podcast],
            channel: Channel(
                title: "Swift Talk",
                link: url,
                description: "A podcast about Swift"
            ),
            namespacePrefixes: ["apple": "http://www.itunes.com/dtds/podcast-1.0.dtd"]
        )

        #expect(feed.version == "2.0")
        #expect(feed.namespaces.count == 3)
        #expect(feed.channel?.title == "Swift Talk")
        #expect(feed.namespacePrefixes["apple"] == "http://www.itunes.com/dtds/podcast-1.0.dtd")
    }

    @Test("PodcastFeed is Equatable")
    func podcastFeedEquatable() throws {
        let url = try #require(URL(string: "https://example.com"))
        let feed1 = PodcastFeed(
            namespaces: [.itunes],
            channel: Channel(title: "Test", link: url, description: "Desc")
        )
        let feed2 = PodcastFeed(
            namespaces: [.itunes],
            channel: Channel(title: "Test", link: url, description: "Desc")
        )
        let feed3 = PodcastFeed(
            namespaces: [.atom],
            channel: Channel(title: "Test", link: url, description: "Desc")
        )

        #expect(feed1 == feed2)
        #expect(feed1 != feed3)
    }

    @Test("PodcastFeed round-trips through Codable")
    func podcastFeedCodable() throws {
        let url = try #require(URL(string: "https://example.com"))
        let original = PodcastFeed(
            version: "2.0",
            namespaces: [.itunes, .podcast],
            channel: Channel(title: "Codable Test", link: url, description: "Testing Codable"),
            namespacePrefixes: ["itunes": "http://www.itunes.com/dtds/podcast-1.0.dtd"]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(PodcastFeed.self, from: data)

        #expect(decoded == original)
    }

    // MARK: - PodcastNamespace

    @Test("PodcastNamespace known cases have correct prefix and URI")
    func podcastNamespacePrefixAndURI() {
        #expect(PodcastNamespace.itunes.prefix == "itunes")
        #expect(PodcastNamespace.itunes.uri == "http://www.itunes.com/dtds/podcast-1.0.dtd")

        #expect(PodcastNamespace.atom.prefix == "atom")
        #expect(PodcastNamespace.atom.uri == "http://www.w3.org/2005/Atom")

        #expect(PodcastNamespace.podcast.prefix == "podcast")
        #expect(PodcastNamespace.podcast.uri == "https://podcastindex.org/namespace/1.0")

        #expect(PodcastNamespace.dublinCore.prefix == "dc")
        #expect(PodcastNamespace.dublinCore.uri == "http://purl.org/dc/elements/1.1/")

        #expect(PodcastNamespace.content.prefix == "content")
        #expect(PodcastNamespace.content.uri == "http://purl.org/rss/1.0/modules/content/")

        #expect(PodcastNamespace.podloveSimpleChapters.prefix == "psc")
        #expect(PodcastNamespace.podloveSimpleChapters.uri == "http://podlove.org/simple-chapters")
    }

    @Test("PodcastNamespace custom case")
    func podcastNamespaceCustom() {
        let custom = PodcastNamespace.custom("http://example.com/custom-namespace")
        #expect(custom.prefix == "")
        #expect(custom.uri == "http://example.com/custom-namespace")
    }

    @Test("PodcastNamespace xmlnsDeclaration produces valid xmlns attributes")
    func podcastNamespaceDeclarations() {
        #expect(PodcastNamespace.itunes.xmlnsDeclaration == #"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#)
        #expect(PodcastNamespace.atom.xmlnsDeclaration == #"xmlns:atom="http://www.w3.org/2005/Atom""#)
        #expect(PodcastNamespace.podcast.xmlnsDeclaration == #"xmlns:podcast="https://podcastindex.org/namespace/1.0""#)
        #expect(PodcastNamespace.dublinCore.xmlnsDeclaration == #"xmlns:dc="http://purl.org/dc/elements/1.1/""#)
        #expect(PodcastNamespace.content.xmlnsDeclaration == #"xmlns:content="http://purl.org/rss/1.0/modules/content/""#)
        #expect(PodcastNamespace.podloveSimpleChapters.xmlnsDeclaration == #"xmlns:psc="http://podlove.org/simple-chapters""#)
    }

    @Test("PodcastNamespace.allStandard contains all 6 known namespaces")
    func podcastNamespaceAllStandard() {
        let standard = PodcastNamespace.allStandard
        #expect(standard.count == 6)
        #expect(standard.contains(.itunes))
        #expect(standard.contains(.atom))
        #expect(standard.contains(.podcast))
        #expect(standard.contains(.dublinCore))
        #expect(standard.contains(.content))
        #expect(standard.contains(.podloveSimpleChapters))
    }

    @Test("PodcastNamespace is Comparable sorted by URI")
    func podcastNamespaceComparable() {
        // URIs: atom < itunes < podlove < podcast < content < dublinCore
        // Actual alphabetical sort by URI:
        // http://podlove.org/simple-chapters
        // http://purl.org/dc/elements/1.1/
        // http://purl.org/rss/1.0/modules/content/
        // http://www.itunes.com/dtds/podcast-1.0.dtd
        // http://www.w3.org/2005/Atom
        // https://podcastindex.org/namespace/1.0 (https > http)
        let sorted = PodcastNamespace.allStandard.sorted()
        #expect(sorted.first?.prefix == "psc")
        #expect(sorted.last?.prefix == "podcast")
    }

    @Test("PodcastNamespace round-trips through Codable using URI")
    func podcastNamespaceCodable() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for ns in PodcastNamespace.allStandard {
            let data = try encoder.encode(ns)
            let decoded = try decoder.decode(PodcastNamespace.self, from: data)
            #expect(decoded == ns)
        }

        // Custom namespace
        let custom = PodcastNamespace.custom("http://example.com/ns")
        let data = try encoder.encode(custom)
        let decoded = try decoder.decode(PodcastNamespace.self, from: data)
        #expect(decoded == custom)
    }

    // MARK: - UnknownElement

    @Test("UnknownElement with all properties")
    func unknownElementFull() {
        let element = UnknownElement(
            name: "custom:tag",
            attributes: ["id": "123", "version": "1.0"],
            textContent: "Some custom content"
        )

        #expect(element.name == "custom:tag")
        #expect(element.attributes["id"] == "123")
        #expect(element.attributes["version"] == "1.0")
        #expect(element.textContent == "Some custom content")
    }

    @Test("UnknownElement self-closing (no text content)")
    func unknownElementSelfClosing() {
        let element = UnknownElement(name: "custom:marker", attributes: ["type": "section"])

        #expect(element.name == "custom:marker")
        #expect(element.attributes.count == 1)
        #expect(element.textContent == nil)
    }

    @Test("UnknownElement with name only")
    func unknownElementNameOnly() {
        let element = UnknownElement(name: "rawTag")

        #expect(element.name == "rawTag")
        #expect(element.attributes.isEmpty)
        #expect(element.textContent == nil)
    }

    // MARK: - ValidationPlatform

    @Test("ValidationPlatform has all 5 supported platforms")
    func validationPlatformAllCases() {
        let allCases = ValidationPlatform.allCases
        #expect(allCases.count == 5)
        #expect(ValidationPlatform.apple.rawValue == "apple")
        #expect(ValidationPlatform.spotify.rawValue == "spotify")
        #expect(ValidationPlatform.amazon.rawValue == "amazon")
        #expect(ValidationPlatform.podcastIndex.rawValue == "podcastIndex")
        #expect(ValidationPlatform.psp1.rawValue == "psp1")
    }

    @Test("ValidationSeverity has correct ordering")
    func validationSeverityOrdering() {
        #expect(ValidationSeverity.info.rawValue == 0)
        #expect(ValidationSeverity.warning.rawValue == 1)
        #expect(ValidationSeverity.error.rawValue == 2)

        #expect(ValidationSeverity.info < ValidationSeverity.warning)
        #expect(ValidationSeverity.warning < ValidationSeverity.error)
        #expect(!(ValidationSeverity.error < ValidationSeverity.info))
    }

    // MARK: - Sendable, Hashable, Equatable Conformance

    @Test("All model types conform to Sendable and Hashable")
    func modelConformances() throws {
        let url = try #require(URL(string: "https://example.com"))

        // These compile-time checks verify conformance.
        // We instantiate and insert into a Set to confirm Hashable.
        var set = Set<GUID>()
        set.insert(GUID(value: "test"))
        #expect(set.count == 1)

        var enclosureSet = Set<Enclosure>()
        enclosureSet.insert(Enclosure(url: url, length: 1000, type: "audio/mpeg"))
        #expect(enclosureSet.count == 1)

        var categorySet = Set<RSSCategory>()
        categorySet.insert(RSSCategory(value: "Tech"))
        #expect(categorySet.count == 1)

        var lockedSet = Set<Locked>()
        lockedSet.insert(Locked(isLocked: true))
        #expect(lockedSet.count == 1)

        var personSet = Set<PodcastPerson>()
        personSet.insert(PodcastPerson(name: "Host"))
        #expect(personSet.count == 1)

        var locationSet = Set<PodcastLocation>()
        locationSet.insert(PodcastLocation(name: "Paris"))
        #expect(locationSet.count == 1)

        var mediumSet = Set<PodcastMedium>()
        mediumSet.insert(.podcast)
        mediumSet.insert(.video)
        #expect(mediumSet.count == 2)

        // Sendable conformance is verified at compile time.
        // The fact that these types can be stored in sets and arrays
        // across concurrency boundaries confirms the conformance.
        let sendableGuid: PodcastGuid = PodcastGuid(value: "test-guid")
        let _: any Sendable = sendableGuid
        #expect(sendableGuid.value == "test-guid")
    }

    @Test("Complex model types round-trip through Codable")
    func complexCodableRoundTrip() throws {
        let url = try #require(URL(string: "https://example.com"))
        let artworkURL = try #require(URL(string: "https://example.com/art.jpg"))
        let enclosureURL = try #require(URL(string: "https://cdn.example.com/ep1.mp3"))
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let feed = PodcastFeed(
            version: "2.0",
            namespaces: PodcastNamespace.allStandard,
            channel: Channel(
                title: "Codable Showcase",
                link: url,
                description: "Testing full Codable round-trip",
                language: "en-US",
                pubDate: pubDate,
                categories: [RSSCategory(value: "Technology")],
                items: [
                    Item(
                        title: "Episode 1",
                        enclosure: Enclosure(url: enclosureURL, length: 24_000_000, type: "audio/mpeg"),
                        guid: GUID(value: "ep-001", isPermaLink: false),
                        pubDate: pubDate,
                        itunesDuration: 1800,
                        itunesEpisodeType: .full,
                        podcastSeason: PodcastSeason(number: 1, name: "Season One"),
                        podcastEpisode: PodcastEpisode(number: 1.0, display: "EP1")
                    )
                ],
                itunesCategories: [.technology],
                itunesExplicit: false,
                itunesImage: artworkURL,
                itunesOwner: ITunesOwner(name: "Test", email: "test@example.com"),
                itunesType: .episodic,
                atomLinks: [.selfLink(href: url)],
                podcastGuid: PodcastGuid(value: "codable-guid-1234"),
                locked: Locked(isLocked: false),
                medium: .podcast
            )
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(feed)
        let decoded = try JSONDecoder().decode(PodcastFeed.self, from: data)

        #expect(decoded == feed)
        #expect(decoded.channel?.title == "Codable Showcase")
        #expect(decoded.channel?.items.count == 1)
        #expect(decoded.channel?.items[0].podcastSeason?.name == "Season One")
        #expect(decoded.channel?.items[0].podcastEpisode?.display == "EP1")
    }
}
// swiftlint:enable file_length type_body_length function_body_length
