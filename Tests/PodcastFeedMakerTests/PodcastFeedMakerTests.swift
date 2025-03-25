import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFeedMakerTests {
//    @Test
//    func textExample() async throws {
//        let isoLanguageCodes = Locale.LanguageCode.isoLanguageCodes
//        print("isoLanguageCodes", isoLanguageCodes)
//        let ids = Locale.availableIdentifiers
//        print("ids", ids)
//        for id in ids {
//            let value = Locale.autoupdatingCurrent.localizedString(forIdentifier: id)
//            print("id: \(id), lang/region: \(String(describing: value))")
//        }
//    }

    @Test func testCategories() async throws {
        let categories: [Namespace.iTunes.iTunesMainCategory] = [.arts([.books]), .business([.nonProfit])]
        let xml = try categories.map {
            try $0.xmlRepresentation()
        }
        let result = xml.indentedTagsRepresentation
        let expected = "\t\t<itunes:category text=\"Arts\"><itunes:category text=\"Books\" /></itunes:category>\n\t\t<itunes:category text=\"Business\"><itunes:category text=\"Non-Profit\" /></itunes:category>"
        #expect(result.count == expected.count)
        #expect(result == expected)
    }

    @Test func testAllCategories() async throws {
        let categories = Namespace.iTunes.iTunesMainCategory.allCases
        let xml = try categories.map {
            try $0.xmlRepresentation()
        }

        let result = xml.indentedTagsRepresentation
        let expected = 4508

        #expect(result.count == expected)

        for category in categories {
            try #expect(result.contains(category.xmlRepresentation()))
        }
    }

//    @Test func testCompleteFeed() async throws {
//        let xml = try MockFeed.complete.xmlRepresentation()
//        print(xml)
//
//        try xml.write(
//            toFile: "/tmp/feed-full-\(Date.now.timeIntervalSince1970).xml",
//            atomically: true,
//            encoding: .utf8
//        )
//    }

    @Test func testFeed() async throws {
//        let xml = try PodcastFeedMaker(MockFeed.default).xmlRepresentation()
        let xml = try PodcastFeedMaker(MockFeed.applePodcasts).xmlRepresentation()
        print(xml)

//        try xml.write(
//            toFile: "/tmp/feed-\(Date.now.timeIntervalSince1970).xml",
//            atomically: true,
//            encoding: .utf8
//        )
    }
}

enum MockFeed {

    static let applePodcasts: Feed = .init(
        channel: .init(
            title: .init("CHANNEL TITLE"),
            link: .init(.init(string: "https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml")!),
            description: .init("CHANNEL DESCRIPTION CONTENT"),
            author: .init(name: "CHANNEL AUTHOR NAME"),
            explicit: .init(.clean),
            image: .init(url: .init(string: "https://atelier-socle.com/podcasts/files/PodFeed-3000x3000.jpg")!),
            categories: .init(categories: .init([.music([]), .news([.techNews])])),
            items: defaultItems,
            language: .init(value: "en_US"),
            summary: nil,
            owner: .init(name: "CHANNEL OWNER NAME", mail: "CHANNEL_OWNER@EMAIL"),
            type: .init(type: .episodic),
            atomSelfLink: .init(
                url: .init(string: "https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml")!
            ),
            additionalTags: [
                Namespace.Podcast.Guid(value: UUID().uuidString),
                Namespace.Podcast.Locked(value: false),
//                Namespace.Podcast.Location(place: "Paris, FR", latitude: 48.856614, longitude: 2.352222),
                RSSTag.TimeToLive(60),
                RSSTag.PubDate(.now),
                RSSTag.LastBuildDate(.now),
                RSSTag.Generator("Atelier Socle Music Studios"),
                RSSTag.Copyright("Copyright 2025 Atelier Socle"),
                RSSTag.Image(
                    url: .init(string: "https://atelier-socle.com/podcasts/files/PodFeed-3000x3000.jpg")!,
                    title: "CHANNEL TITLE",
                    link: .init(string: "https://atelier-socle.com")!
                ),
                Namespace.iTunes.Title(text: "CHANNEL TITLE"),
                Namespace.iTunes.Subtitle(text: "CHANNEL SUBTITLE"),
                Namespace.iTunes.Keywords(keywords: ["music", "sounds", "better", "with", "you"]),
                Namespace.iTunes.Block(value: false),
                Namespace.iTunes.Complete(value: false),
//                Namespace.Podcast.Funding(URL(string: "https://atelier-socle.com")!, form: "Atelier Socle"),
//                Namespace.Podcast.TextField("unique.hash.value.to.verify.ownership", verify: true),
//                Namespace.iTunes.Verify(value: false),
//                Namespace.iTunes.NewFeedUrl(url: ...),
            ]
        )
    )
    // https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml
    // http://localhost:8888/podcasts/feed-1742426334.0261931.xml
    // http://localhost:8888/podcasts/files/TronikShow899-Avicii.m4a
    // http://localhost:8888/podcasts/files/TronikShow885-Avicii.m4a
    /*
    static let `default`: Feed = .init(
        namespaces: Namespace.allCases,
        channel: .init(
            title: .init("CHANNEL TITLE"),
            description: .init("CHANNEL DESCRIPTION CONTENT"),
//            itunesImage: .init(url: .init(string: "https://picsum.photos/3000")!),
            itunesImage: .init(url: .init(string: "https://atelier-socle.com/podcasts/files/PodFeed-3000x3000.jpg")!),
            language: .init(value: "en_US"),
            categories: .init(categories: .init([.music([]), .news([.techNews])])),
            explicit: .init(value: false),
            author: .init(name: "CHANNEL AUTHOR NAME"),
//            link: .init(url: .init(string: "http://localhost:8888/podcasts/")!),
            link: .init(url: .init(string: "https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml")!),
            itunesTitle: .init(text: "CHANNEL ITUNES TITLE"),
            type: .init(type: .episodic),
            copyright: .init(value: "Copyright 2025 Atelier Socle"),
            newFeedUrl: nil,
            block: .init(value: false),
            complete: .init(value: false),
            verify: nil,
            generator: .init(value: "Atelier Socle Music Studios"),
            items: defaultItems,
            summary: nil,
            subtitle: .init(text: "CHANNEL SUBTITLE"),
            keywords: .init(keywords: ["music", "sounds", "better", "with", "you"]),
            owner: .init(name: "CHANNEL OWNER NAME", mail: "CHANNEL_OWNER@EMAIL"),
            pubDate: .init(.now),
            lastBuildDate: .init(value: .now),
            ttl: .init(value: 60),
            locked: .init(value: false),
            guid: .init(value: UUID().uuidString),
            atomLink: .init(url: .init(string: "https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml")!),
            image: .init(
                url: .init(string: "https://atelier-socle.com/podcasts/files/PodFeed-3000x3000.jpg")!,
                title: "CHANNEL TITLE",
                link: .init(string: "https://atelier-socle.com")!
            ),
            location: nil
        )
    )

    static let complete: Feed = .init(
        namespaces: [.itunes, .podcast, .atom, .rdf],
        channel: .init(
            title: .init("CHANNEL TITLE"),
            description: .init("CHANNEL DESCRIPTION CONTENT"),
            itunesImage: .init(url: .init(string: "https://picsum.photos/200")!),
            language: .init(value: "en_US"),
            categories: .init(categories: .init([.music([]), .news([.techNews])])),
            explicit: .init(value: false),
            author: .init(name: "CHANNEL AUTHOR NAME"),
            link: .init(url: .init(string: "http://localhost:8888/podcasts/")!),
            itunesTitle: .init(text: "CHANNEL ITUNES TITLE"),
            type: .init(type: .episodic),
            copyright: .init(value: "Copyright 2025 Atelier Socle"),
            newFeedUrl: .init(url: .init(string: "https://picsum.photos/200")!),
            block: .init(value: false),
            complete: .init(value: false),
            verify: .init(),
            generator: .init(value: "Atelier Socle Music Studios"),
            items: defaultItems,
            summary: .init(content: "CHANNEL SUMMARY"),
            subtitle: .init(text: "CHANNEL SUBTITLE"),
            keywords: .init(keywords: ["music", "sounds", "better", "with", "you"]),
            owner: .init(name: "CHANNEL OWNER NAME", mail: "CHANNEL_OWNER@EMAIL"),
            pubDate: .init(.now),
            lastBuildDate: .init(value: .now),
            ttl: .init(value: 60),
            locked: .init(value: false),
            guid: .init(value: UUID().uuidString),
            atomLink: .init(url: .init(string: "http://localhost:8888/podcasts/")!),
            image: .init(
                url: .init(string: "https://picsum.photos/200")!,
                title: "CHANNEL TITLE",
                link: .init(string: "http://localhost:8888/podcasts/")!
            ),
            location: nil
        )
    )*/

    static let description0 = RSSTag.Description("EP.0 - My description 0, Listen on <a href=\"https://atelier-socle.com\">Apple Podcasts</a>.", type: .html)
    static let summary0 = Namespace.iTunes.Summary(content: "EP.0 - My description 0, Listen on <a href=\"https://atelier-socle.com\">Apple Podcasts</a>.", type: .html)

    static let description1 = RSSTag.Description("EP.1 - My description 1, Listen on <a href=\"https://www.apple.com/itunes/podcasts/\">Apple Podcasts</a>.", type: .html)
    static let summary1 = Namespace.iTunes.Summary(content: "EP.1 - My description 1, Listen on <a href=\"https://www.apple.com/itunes/podcasts/\">Apple Podcasts</a>.", type: .html)

    static let `defaultItems`: [RSSTag.Item] = [
        /*
        .init(
            title: .init("EP.0 TITLE 0"),
            enclosure: .init(
//                url: URL(string: "http://localhost:8888/podcasts/files/TronikShow899-Avicii.m4a")!,
                url: URL(string: "https://atelier-socle.com/podcasts/files/TronikShow899-Avicii.m4a")!,
                length: 27867798,
                type: .m4a
            ),
            guid: .init(id: UUID().uuidString),
            pubDate: .init(.now),
            description: description0,
            duration: .init(duration: 3349),
            link: .init(url: URL(string: "https://atelier-socle.com")!),
//            image: .init(url: URL(string: "https://picsum.photos/1400")!),
            image: .init(url: URL(string: "https://atelier-socle.com/podcasts/files/EP0-3000x3000.jpg")!),
            explicit: .init(.yes),
            itunesTitle: .init(text: "ITUNES EP.0 TITLE 0"),
            episode: nil,
            season: nil,
            episodeType: .init(type: .trailer),
            transcript: .init(url: URL(string: "https://www.buzzsprout.com/1/10167133/transcript.vtt")!, type: .vtt),
            block: nil,
            summary: summary0,
            chapters: .init(url: URL(string: "https://atelier-socle.com/podcasts/files/chapter-00.json")!, type: .json)
            */
        .init(
            title: RSSTag.Title("EP.0 TITLE 0"),
            enclosure: RSSTag.Enclosure(
                url: URL(string: "https://atelier-socle.com/podcasts/files/TronikShow899-Avicii.m4a")!,
                length: 27867798,
                type: .m4a
            ),
            guid: RSSTag.Guid(UUID().uuidString),
            pubDate: RSSTag.PubDate(.now),
            duration: Namespace.iTunes.Duration(duration: 3349),
            episode: nil,
            episodeType: Namespace.iTunes.EpisodeType(type: .trailer),
            summary: summary0,
            explicit: Namespace.iTunes.Explicit(.yes),
            image: Namespace.iTunes.Image(
                url: URL(string: "https://atelier-socle.com/podcasts/files/EP0-3000x3000.jpg")!
            ),
            additionalTags: [
                RSSTag.Link(URL(string: "https://atelier-socle.com")!),
//                Namespace.iTunes.Season(value: 2),
                Namespace.iTunes.Title(text: "ITUNES EP.0 TITLE 0"),
//                Namespace.iTunes.Block(value: false),
                description0,
                Namespace.Podcast.Chapters(url: URL(string: "https://atelier-socle.com/podcasts/files/chapter-00.json")!, type: .json),
                Namespace.Podcast.Transcript(
                    url: URL(string: "https://www.buzzsprout.com/1/10167133/transcript.vtt")!,
                    type: .vtt
                )
            ]
        ),
        .init(
            /*
            title: .init("EP.1 TITLE 1"),
            enclosure: .init(
//                url: URL(string: "http://localhost:8888/podcasts/files/TronikShow885-Avicii.m4a")!,
                url: URL(string: "https://atelier-socle.com/podcasts/files/TronikShow885-Avicii.m4a")!,
                length: 31009618,
                type: .m4a
            ),
            guid: .init(id: UUID().uuidString),
            pubDate: .init(.now),
            description: description1,
            duration: .init(duration: 3775),
            link: .init(url: URL(string: "https://atelier-socle.com")!),
//            image: .init(url: URL(string: "https://picsum.photos/3000")!),
            image: .init(url: URL(string: "https://atelier-socle.com/podcasts/files/EP1-3000x3000.jpg")!),
            explicit: .init(.no),
            itunesTitle: .init(text: "EP.1 - ITUNES TITLE 1"),
            episode: .init(value: 1),
            season: .init(value: 2),
            episodeType: .init(type: .full),
            transcript: nil/*.init(url: URL(string: "https://picsum.photos/3000")!, type: .vtt)*/,
            block: .init(value: false),
            summary: summary1,
//            chapters: nil
            chapters: .init(url: URL(string: "https://atelier-socle.com/podcasts/files/chapter-01.json")!, type: .json)
             */
            title: RSSTag.Title("EP.1 TITLE 1"),
            enclosure: RSSTag.Enclosure(
                url: URL(string: "https://atelier-socle.com/podcasts/files/TronikShow885-Avicii.m4a")!,
                length: 31009618,
                type: .m4a
            ),
            guid: RSSTag.Guid(UUID().uuidString),
            pubDate: RSSTag.PubDate(.now),
            duration: Namespace.iTunes.Duration(duration: 3775),
            episode: Namespace.iTunes.Episode(value: 1),
            episodeType: Namespace.iTunes.EpisodeType(type: .full),
            summary: summary1,
            explicit: Namespace.iTunes.Explicit(.clean),
            image: Namespace.iTunes.Image(
                url: URL(string: "https://atelier-socle.com/podcasts/files/EP1-3000x3000.jpg")!
            ),
            additionalTags: [
                RSSTag.Link(URL(string: "https://atelier-socle.com")!),
                Namespace.iTunes.Season(value: 2),
                Namespace.iTunes.Title(text: "EP.1 - ITUNES TITLE 1"),
                Namespace.iTunes.Block(value: false),
                description1,
                Namespace.Podcast.Chapters(
                    url: URL(string: "https://atelier-socle.com/podcasts/files/chapter-01.json")!,
                    type: .json
                ),
//                Namespace.Podcast.Transcript(url: URL(string: "transcript.txt")!, type: .vtt)
            ]
        )
    ]
}
