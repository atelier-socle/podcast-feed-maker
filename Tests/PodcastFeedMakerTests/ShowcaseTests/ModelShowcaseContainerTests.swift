import Foundation
import Testing

@testable import PodcastFeedMaker

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
    func podcastFeedWithChannel() {
        let url = makeURL("https://swifttalk.dev")

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
    func podcastFeedEquatable() {
        let url = makeURL("https://example.com")
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
        let url = makeURL("https://example.com")
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
    func modelConformances() {
        let url = makeURL("https://example.com")

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
        let url = makeURL("https://example.com")
        let artworkURL = makeURL("https://example.com/art.jpg")
        let enclosureURL = makeURL("https://cdn.example.com/ep1.mp3")
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
