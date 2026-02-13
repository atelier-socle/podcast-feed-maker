import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Gap 1: PodcastImage

@Suite("Spec Compliance — PodcastImage")
struct PodcastImageComplianceTests {

    @Test("PodcastImage model stores all 7 attributes")
    func modelAttributes() {
        let image = PodcastImage(
            href: makeURL("https://example.com/art.jpg"),
            alt: "Show art",
            aspectRatio: "1/1",
            width: 3000,
            height: 3000,
            type: "image/jpeg",
            purpose: "artwork"
        )
        #expect(image.href.absoluteString == "https://example.com/art.jpg")
        #expect(image.alt == "Show art")
        #expect(image.aspectRatio == "1/1")
        #expect(image.width == 3000)
        #expect(image.height == 3000)
        #expect(image.type == "image/jpeg")
        #expect(image.purpose == "artwork")
    }

    @Test("PodcastImage defaults are nil")
    func modelDefaults() {
        let image = PodcastImage(href: makeURL("https://example.com/a.jpg"))
        #expect(image.alt == nil)
        #expect(image.aspectRatio == nil)
        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.type == nil)
        #expect(image.purpose == nil)
    }

    @Test("Channel holds multiple podcast:image elements")
    func channelMultipleImages() {
        let images = [
            PodcastImage(href: makeURL("https://example.com/art.jpg"), purpose: "artwork"),
            PodcastImage(href: makeURL("https://example.com/social.jpg"), purpose: "social")
        ]
        let channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D",
            podcastImages: images
        )
        #expect(channel.podcastImages.count == 2)
    }

    @Test("Item holds multiple podcast:image elements")
    func itemMultipleImages() {
        var item = Item(title: "Ep")
        item.podcastImages = [
            PodcastImage(href: makeURL("https://example.com/ep-art.jpg"), purpose: "artwork")
        ]
        #expect(item.podcastImages.count == 1)
    }

    @Test("Generator emits podcast:image with aspect-ratio hyphen")
    func generatorEmitsImage() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.podcastImages = [
            PodcastImage(
                href: makeURL("https://example.com/art.jpg"),
                alt: "Art",
                aspectRatio: "1/1",
                width: 3000,
                type: "image/jpeg",
                purpose: "artwork"
            )
        ]
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains(#"<podcast:image href="https://example.com/art.jpg""#))
        #expect(xml.contains(#"aspect-ratio="1/1""#))
        #expect(xml.contains(#"width="3000""#))
        #expect(xml.contains(#"purpose="artwork""#))
    }

    @Test("Parser reads podcast:image at channel level")
    func parserChannelImage() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <podcast:image href="https://example.com/art.jpg" alt="Art" \
            aspect-ratio="1/1" width="3000" height="3000" type="image/jpeg" purpose="artwork" />
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let images = try #require(feed.channel?.podcastImages)
        #expect(images.count == 1)
        #expect(images[0].href.absoluteString == "https://example.com/art.jpg")
        #expect(images[0].alt == "Art")
        #expect(images[0].aspectRatio == "1/1")
        #expect(images[0].width == 3000)
        #expect(images[0].height == 3000)
        #expect(images[0].type == "image/jpeg")
        #expect(images[0].purpose == "artwork")
    }

    @Test("Parser reads podcast:image at item level")
    func parserItemImage() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <item>
                  <title>Ep</title>
                  <podcast:image href="https://example.com/ep-art.jpg" purpose="artwork" />
                </item>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.podcastImages.count == 1)
        #expect(item.podcastImages[0].purpose == "artwork")
    }

    @Test("podcast:image round-trips")
    func imageRoundTrip() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.podcastImages = [
            PodcastImage(
                href: makeURL("https://example.com/art.jpg"),
                alt: "Art",
                aspectRatio: "16/9",
                width: 1920,
                height: 1080,
                type: "image/png",
                purpose: "social"
            )
        ]
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        let reparsed = try FeedParser().parse(xml)
        #expect(reparsed.channel?.podcastImages.count == 1)
        let img = try #require(reparsed.channel?.podcastImages.first)
        #expect(img.alt == "Art")
        #expect(img.aspectRatio == "16/9")
        #expect(img.width == 1920)
        #expect(img.height == 1080)
        #expect(img.purpose == "social")
    }

    @Test("NamespaceResolver detects podcast:image")
    func namespaceResolverDetects() {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.podcastImages = [
            PodcastImage(href: makeURL("https://example.com/art.jpg"))
        ]
        let feed = PodcastFeed(channel: channel)
        let ns = NamespaceResolver.resolve(feed)
        #expect(ns.contains(.podcast))
    }
}

// MARK: - Gap 2: PodcastPublisher (Breaking Change)

@Suite("Spec Compliance — PodcastPublisher")
struct PodcastPublisherComplianceTests {

    @Test("PodcastPublisher uses remoteItem container")
    func modelStructure() {
        let pub = PodcastPublisher(
            remoteItem: RemoteItem(
                feedGuid: "abc-123",
                feedUrl: URL(string: "https://example.com/feed.xml"),
                medium: "publisher"
            ))
        #expect(pub.remoteItem.feedGuid == "abc-123")
        #expect(pub.remoteItem.medium == "publisher")
    }

    @Test("Generator emits publisher container with remoteItem")
    func generatorEmitsContainer() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.publisher = PodcastPublisher(
            remoteItem: RemoteItem(
                feedGuid: "pub-guid-1",
                feedUrl: URL(string: "https://publisher.example.com/feed.xml"),
                medium: "publisher"
            ))
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("<podcast:publisher>"))
        #expect(xml.contains("</podcast:publisher>"))
        #expect(xml.contains(#"feedGuid="pub-guid-1""#))
        #expect(xml.contains(#"medium="publisher""#))
    }

    @Test("Parser reads publisher container")
    func parserReadsContainer() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <podcast:publisher>
                  <podcast:remoteItem feedGuid="pub-guid-1" \
            feedUrl="https://publisher.example.com/feed.xml" medium="publisher" />
                </podcast:publisher>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let pub = try #require(feed.channel?.publisher)
        #expect(pub.remoteItem.feedGuid == "pub-guid-1")
        #expect(pub.remoteItem.feedUrl?.absoluteString == "https://publisher.example.com/feed.xml")
        #expect(pub.remoteItem.medium == "publisher")
    }

    @Test("Publisher round-trips")
    func publisherRoundTrip() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.publisher = PodcastPublisher(
            remoteItem: RemoteItem(
                feedGuid: "my-pub-guid",
                feedUrl: URL(string: "https://publisher.example.com/feed.xml"),
                medium: "publisher"
            ))
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        let reparsed = try FeedParser().parse(xml)
        #expect(reparsed.channel?.publisher?.remoteItem.feedGuid == "my-pub-guid")
        #expect(reparsed.channel?.publisher?.remoteItem.medium == "publisher")
    }

    @Test("Builder creates publisher with remoteItem")
    func builderPublisher() {
        let channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        ).publisher(feedGuid: "abc", feedUrl: "https://pub.example.com/feed.xml")
        #expect(channel.publisher?.remoteItem.feedGuid == "abc")
        #expect(channel.publisher?.remoteItem.medium == "publisher")
    }
}

// MARK: - Gap 3: PodcastLocation — rel, country, multiple

@Suite("Spec Compliance — PodcastLocation")
struct PodcastLocationComplianceTests {

    @Test("PodcastLocation stores rel and country")
    func modelAttributes() {
        let loc = PodcastLocation(
            name: "Austin, TX",
            geo: "geo:30.2672,-97.7431",
            osm: "R113314",
            rel: "creator",
            country: "US"
        )
        #expect(loc.rel == "creator")
        #expect(loc.country == "US")
    }

    @Test("Channel supports multiple locations")
    func channelMultipleLocations() {
        let channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D",
            locations: [
                PodcastLocation(name: "Austin", rel: "creator", country: "US"),
                PodcastLocation(name: "Paris", rel: "subject", country: "FR")
            ]
        )
        #expect(channel.locations.count == 2)
        #expect(channel.location?.name == "Austin")
    }

    @Test("Location computed property backward compatibility")
    func computedPropertyBackwardCompat() {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.location = PodcastLocation(name: "Berlin")
        #expect(channel.locations.count == 1)
        #expect(channel.location?.name == "Berlin")
        channel.location = nil
        #expect(channel.locations.isEmpty)
    }

    @Test("Generator emits rel and country attributes")
    func generatorEmitsAttributes() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.locations = [
            PodcastLocation(name: "NYC", geo: "geo:40.7,-74.0", rel: "creator", country: "US")
        ]
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains(#"rel="creator""#))
        #expect(xml.contains(#"country="US""#))
    }

    @Test("Parser reads rel and country from XML")
    func parserReadsAttributes() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <podcast:location rel="creator" geo="geo:30,-97" country="US">Austin</podcast:location>
                <podcast:location rel="subject" geo="geo:48,2" country="FR">Paris</podcast:location>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let locs = try #require(feed.channel?.locations)
        #expect(locs.count == 2)
        #expect(locs[0].name == "Austin")
        #expect(locs[0].rel == "creator")
        #expect(locs[0].country == "US")
        #expect(locs[1].name == "Paris")
        #expect(locs[1].rel == "subject")
        #expect(locs[1].country == "FR")
    }

    @Test("Location round-trips with rel and country")
    func locationRoundTrip() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.locations = [
            PodcastLocation(name: "Berlin", rel: "creator", country: "DE")
        ]
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        let reparsed = try FeedParser().parse(xml)
        let loc = try #require(reparsed.channel?.location)
        #expect(loc.name == "Berlin")
        #expect(loc.rel == "creator")
        #expect(loc.country == "DE")
    }

    @Test("Builder creates location with rel and country")
    func builderLocation() {
        let channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        ).location(name: "NYC", geo: "geo:40.7,-74.0", rel: "creator", country: "US")
        #expect(channel.locations.count == 1)
        #expect(channel.locations[0].rel == "creator")
        #expect(channel.locations[0].country == "US")
    }
}

// MARK: - Gap 4: PodcastImages (deprecated srcset)

@Suite("Spec Compliance — PodcastImages (deprecated)")
struct PodcastImagesComplianceTests {

    @Test("PodcastImages model stores srcset")
    func modelSrcset() {
        let images = PodcastImages(srcset: "https://example.com/art-3000.jpg 3000w, https://example.com/art-600.jpg 600w")
        #expect(images.srcset.contains("3000w"))
    }

    @Test("Parser reads podcast:images srcset at channel level")
    func parserChannelSrcset() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <podcast:images srcset="https://example.com/a.jpg 3000w, https://example.com/b.jpg 600w" />
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let srcset = try #require(feed.channel?.podcastImagesSrcset)
        #expect(srcset.srcset.contains("3000w"))
        #expect(srcset.srcset.contains("600w"))
    }

    @Test("Parser reads podcast:images srcset at item level")
    func parserItemSrcset() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:podcast="https://podcastindex.org/namespace/1.0">
              <channel>
                <title>T</title><link>https://example.com</link>
                <description>D</description>
                <item>
                  <title>Ep</title>
                  <podcast:images srcset="https://example.com/ep.jpg 1500w" />
                </item>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let srcset = try #require(feed.channel?.items.first?.podcastImagesSrcset)
        #expect(srcset.srcset.contains("1500w"))
    }

    @Test("podcast:images srcset round-trips")
    func srcsetRoundTrip() throws {
        var channel = Channel(
            title: "T", link: makeURL("https://example.com"), description: "D"
        )
        channel.podcastImagesSrcset = PodcastImages(
            srcset: "https://example.com/art-3000.jpg 3000w, https://example.com/art-600.jpg 600w"
        )
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)
        let reparsed = try FeedParser().parse(xml)
        #expect(reparsed.channel?.podcastImagesSrcset?.srcset.contains("3000w") == true)
    }
}
