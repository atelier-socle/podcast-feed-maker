import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastFeedMakerTests {

    @Test
    func test_xmlRepresentation_generatesValidFeed() throws {
        let title = RSSTag.Title("My Podcast")
        let link = RSSTag.Link(URL(string: "https://example.com")!)
        let description = RSSTag.Description("Welcome to the show!")
        let author = Namespace.iTunes.Author(name: "Jane Doe")
        let explicit = Namespace.iTunes.Explicit(.no)
        let image = Namespace.iTunes.Image(url: URL(string: "https://example.com/image.jpg")!)
        let categories: Set<Namespace.iTunes.iTunesMainCategory> = [
            .technology
        ]

        let channel = RSSTag.Channel(
            title: title,
            link: link,
            description: description,
            author: author,
            explicit: explicit,
            image: image,
            categories: .init(categories: categories),
            items: []
        )

        let feed = Feed(channel: channel)
        let maker = PodcastFeedMaker(feed)

        let xml = try maker.xmlRepresentation()

        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>My Podcast</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<description>Welcome to the show!</description>"))
        #expect(xml.contains("<itunes:author>Jane Doe</itunes:author>"))
    }

    @Test
    func test_xmlRepresentation_throwsIfFeedIsInvalid() {
        let title = RSSTag.Title("My Podcast")
        let invalidLink = RSSTag.Link(URL(string: "http://")!)
        let description = RSSTag.Description("This is broken")
        let author = Namespace.iTunes.Author(name: "Jane Doe")
        let explicit = Namespace.iTunes.Explicit(.no)
        let image = Namespace.iTunes.Image(url: URL(string: "https://example.com/image.jpg")!)
        let categories: Set<Namespace.iTunes.iTunesMainCategory> = [
            .technology
        ]

        let channel = RSSTag.Channel(
            title: title,
            link: invalidLink,
            description: description,
            author: author,
            explicit: explicit,
            image: image,
            categories: .init(categories: categories),
            items: []
        )

        let feed = Feed(channel: channel)
        let maker = PodcastFeedMaker(feed)

        #expect(throws: URL.URLValidatorError.self) {
            _ = try maker.xmlRepresentation()
        }
    }

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
}
