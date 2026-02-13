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

    private static func makeFullRSSChannel() throws -> Channel {
        let siteURL = try #require(URL(string: "https://swifttalk.dev"))
        let docsURL = try #require(URL(string: "https://www.rssboard.org/rss-specification"))
        let imageURL = try #require(URL(string: "https://swifttalk.dev/logo.png"))
        let searchURL = try #require(URL(string: "https://swifttalk.dev/search"))
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)
        let buildDate = Date(timeIntervalSince1970: 1_700_100_000)

        return Channel(
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
    }

    @Test("Channel initializes with all RSS 2.0 core properties")
    func channelAllRSSProperties() throws {
        let channel = try Self.makeFullRSSChannel()

        #expect(channel.language == "en-US")
        #expect(channel.copyright == "Copyright 2025 Atelier Socle")
        #expect(channel.managingEditor == "editor@swifttalk.dev (Jane Swift)")
        #expect(channel.webMaster == "admin@swifttalk.dev (Ops Team)")
        #expect(channel.pubDate == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(channel.lastBuildDate == Date(timeIntervalSince1970: 1_700_100_000))
        #expect(channel.categories.count == 2)
        #expect(channel.generator == "PodcastFeedMaker 1.0")
        #expect(channel.docs == URL(string: "https://www.rssboard.org/rss-specification"))
        #expect(channel.cloud?.domain == "rpc.swifttalk.dev")
        #expect(channel.ttl == 60)
        #expect(channel.rating != nil)
        #expect(channel.image?.width == 144)
        #expect(channel.textInput?.name == "query")
        #expect(channel.skipSchedule?.hours.count == 6)
        #expect(channel.skipSchedule?.days.contains(.saturday) == true)
    }

    private static func makeAllNamespaceChannel() throws -> Channel {
        let url = try #require(URL(string: "https://example.com"))
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        let artworkURL = try #require(URL(string: "https://example.com/artwork.jpg"))
        let donateURL = try #require(URL(string: "https://example.com/donate"))
        let publisherURL = try #require(URL(string: "https://publisher.example.com/feed.xml"))

        return Channel(
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
    }

    @Test("Channel supports all namespace properties")
    func channelAllNamespaceProperties() throws {
        let artworkURL = try #require(URL(string: "https://example.com/artwork.jpg"))
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        let channel = try Self.makeAllNamespaceChannel()

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
}
