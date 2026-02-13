import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Helpers

private func minimalChannel() -> Channel {
    Channel(
        title: "Test Podcast",
        link: makeURL("https://example.com"),
        description: "A test podcast"
    )
}

private func minimalFeed(channel: Channel? = nil) -> PodcastFeed {
    PodcastFeed(channel: channel ?? minimalChannel())
}

// MARK: - Content Module Tests

struct FeedGeneratorContentTests {

    @Test("content:encoded always uses CDATA")
    func contentEncodedCDATA() throws {
        var ch = minimalChannel()
        ch.items = [Item(contentEncoded: ContentEncoded(value: "<p>Hello <strong>World</strong></p>"))]
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<content:encoded><![CDATA[<p>Hello <strong>World</strong></p>]]></content:encoded>"))
    }
}

// MARK: - CDATA Strategy Tests

struct FeedGeneratorCDATATests {

    @Test("Description with HTML uses CDATA")
    func descriptionHTMLCDATA() throws {
        let linkURL = makeURL("https://example.com")
        var ch = Channel(
            title: "Test",
            link: linkURL,
            description: "<p>HTML description</p>"
        )
        ch.items = []
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<description><![CDATA[<p>HTML description</p>]]></description>"))
    }

    @Test("Description without HTML uses escaping")
    func descriptionPlainEscapes() throws {
        let linkURL = makeURL("https://example.com")
        var ch = Channel(
            title: "Test",
            link: linkURL,
            description: "Tom & Jerry podcast"
        )
        ch.items = []
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<description>Tom &amp; Jerry podcast</description>"))
    }
}

// MARK: - Special Character Tests

struct FeedGeneratorSpecialCharTests {

    @Test("Special characters in content are escaped")
    func specialCharsEscaped() throws {
        let linkURL = makeURL("https://example.com")
        var ch = Channel(
            title: "Tom & Jerry \u{00A9} 2025",
            link: linkURL,
            description: "A show about \u{2122} brands"
        )
        ch.items = []
        let xml = try FeedGenerator().generate(minimalFeed(channel: ch))
        #expect(xml.contains("<title>Tom &amp; Jerry &#xA9; 2025</title>"))
        #expect(xml.contains("A show about &#x2122; brands"))
    }
}

// MARK: - Empty/Nil Fields Tests

struct FeedGeneratorOmissionTests {

    @Test("Generate item with deprecated podcastImagesSrcset")
    func generateItemPodcastImagesSrcset() throws {
        var ch = minimalChannel()
        var item = Item(title: "Ep1")
        item.podcastImagesSrcset = PodcastImages(
            srcset: "https://example.com/img1.jpg 200w, https://example.com/img2.jpg 600w"
        )
        ch.items = [item]
        let feed = PodcastFeed(namespaces: [.podcast], channel: ch)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("podcast:images"))
        #expect(xml.contains("srcset"))
        #expect(xml.contains("200w"))
    }

    @Test("Generate channel with deprecated podcastImagesSrcset")
    func generateChannelPodcastImagesSrcset() throws {
        var ch = minimalChannel()
        ch.podcastImagesSrcset = PodcastImages(
            srcset: "https://example.com/art-1500.jpg 1500w, https://example.com/art-600.jpg 600w"
        )
        let feed = PodcastFeed(namespaces: [.podcast], channel: ch)
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("podcast:images"))
        #expect(xml.contains("1500w"))
    }

    @Test("Nil optional fields are omitted")
    func nilFieldsOmitted() throws {
        let xml = try FeedGenerator().generate(minimalFeed())
        #expect(!xml.contains("<language>"))
        #expect(!xml.contains("<copyright>"))
        #expect(!xml.contains("<itunes:author>"))
        #expect(!xml.contains("<podcast:guid>"))
        #expect(!xml.contains("<dc:creator>"))
    }

    @Test("Empty arrays produce no elements")
    func emptyArraysOmitted() throws {
        let xml = try FeedGenerator().generate(minimalFeed())
        #expect(!xml.contains("<item>"))
        #expect(!xml.contains("<itunes:category"))
        #expect(!xml.contains("<podcast:funding"))
    }

    // MARK: - Unknown Self-Closing Element

    @Test("Generate unknown element without text content produces self-closing tag")
    func generateUnknownSelfClosing() throws {
        let linkURL = makeURL("https://example.com")
        var channel = Channel(
            title: "Test",
            link: linkURL,
            description: "Test"
        )
        // Add an unknown element with NO text content (just attributes)
        channel.unknownElements.append(
            UnknownElement(name: "custom:tag", attributes: ["key": "value"], textContent: nil)
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("custom:tag"))
        #expect(xml.contains("key=\"value\""))
    }
}
