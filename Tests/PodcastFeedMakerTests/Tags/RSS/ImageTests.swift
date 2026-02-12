import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - ImageTests

/// Tests for the ``RSSImage`` struct.
///
/// `RSSImage` has required `url: URL`, `title: String`, `link: URL`,
/// and optional `width`, `height`, `imageDescription`.
/// Conforms to `Sendable`, `Hashable`, `Equatable`, `Codable`, and `XmlRepresentable`.
@Suite("RSSImage Struct Tests")
struct ImageTests {

    // MARK: - Initialization

    @Test("RSSImage can be initialized with required properties")
    func rssImageInitWithRequiredProperties() {
        let url = URL(string: "https://example.com/logo.png")!
        let link = URL(string: "https://example.com")!
        let image = RSSImage(url: url, title: "Podcast Logo", link: link)

        #expect(image.url == url)
        #expect(image.title == "Podcast Logo")
        #expect(image.link == link)
        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.imageDescription == nil)
    }

    @Test("RSSImage can be initialized with all properties")
    func rssImageInitWithAllProperties() {
        let url = URL(string: "https://example.com/logo.png")!
        let link = URL(string: "https://example.com")!
        let image = RSSImage(
            url: url,
            title: "Podcast Logo",
            link: link,
            width: 88,
            height: 31,
            imageDescription: "A podcast logo"
        )

        #expect(image.width == 88)
        #expect(image.height == 31)
        #expect(image.imageDescription == "A podcast logo")
    }

    @Test("RSSImage properties are mutable")
    func rssImagePropertiesAreMutable() {
        var image = RSSImage(
            url: URL(string: "https://example.com/old.png")!,
            title: "Old Title",
            link: URL(string: "https://old.example.com")!
        )

        image.url = URL(string: "https://example.com/new.png")!
        image.title = "New Title"
        image.link = URL(string: "https://new.example.com")!
        image.width = 144
        image.height = 400

        #expect(image.url == URL(string: "https://example.com/new.png")!)
        #expect(image.title == "New Title")
        #expect(image.link == URL(string: "https://new.example.com")!)
        #expect(image.width == 144)
        #expect(image.height == 400)
    }

    // MARK: - XML Generation

    @Test("RSSImage xmlRepresentation contains expected elements")
    func rssImageXmlRepresentation() throws {
        let image = RSSImage(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Podcast Logo",
            link: URL(string: "https://example.com")!
        )

        let xml = try image.xmlRepresentation()
        #expect(xml.contains("<image>"))
        #expect(xml.contains("<url>https://example.com/logo.png</url>"))
        #expect(xml.contains("<title>Podcast Logo</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("</image>"))
    }

    @Test("RSSImage xmlRepresentation escapes special characters in title")
    func rssImageXmlEscapesTitle() throws {
        let image = RSSImage(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Show & Tell <Podcast>",
            link: URL(string: "https://example.com")!
        )

        let xml = try image.xmlRepresentation()
        #expect(xml.contains("Show &amp; Tell &lt;Podcast&gt;"))
    }

    // MARK: - Channel Integration

    @Test("Channel can hold an RSSImage")
    func channelCanHoldImage() {
        let image = RSSImage(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Logo",
            link: URL(string: "https://example.com")!
        )
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            image: image
        )

        #expect(channel.image?.url == URL(string: "https://example.com/logo.png")!)
        #expect(channel.image?.title == "Logo")
    }

    @Test("Channel XML contains image element when set")
    func channelXmlContainsImage() throws {
        let image = RSSImage(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Logo",
            link: URL(string: "https://example.com")!
        )
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            image: image
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<image>"))
        #expect(xml.contains("<url>https://example.com/logo.png</url>"))
    }

    @Test("Channel XML omits image element when nil")
    func channelXmlOmitsImageWhenNil() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
        #expect(!xml.contains("<image>"))
    }

    // MARK: - Equatable

    @Test("RSSImages with same properties are equal")
    func rssImagesEqual() {
        let url = URL(string: "https://example.com/logo.png")!
        let link = URL(string: "https://example.com")!
        let img1 = RSSImage(url: url, title: "Logo", link: link)
        let img2 = RSSImage(url: url, title: "Logo", link: link)
        #expect(img1 == img2)
    }

    @Test("RSSImages with different titles are not equal")
    func rssImagesDifferentTitles() {
        let url = URL(string: "https://example.com/logo.png")!
        let link = URL(string: "https://example.com")!
        let img1 = RSSImage(url: url, title: "Logo A", link: link)
        let img2 = RSSImage(url: url, title: "Logo B", link: link)
        #expect(img1 != img2)
    }

    // MARK: - Hashable

    @Test("RSSImage is Hashable")
    func rssImageHashable() {
        let url = URL(string: "https://example.com/logo.png")!
        let link = URL(string: "https://example.com")!
        let image = RSSImage(url: url, title: "Logo", link: link)
        let set: Set = [image]
        #expect(set.contains(RSSImage(url: url, title: "Logo", link: link)))
    }

    // MARK: - Codable

    @Test("RSSImage can be encoded and decoded via JSON")
    func rssImageCodable() throws {
        let image = RSSImage(
            url: URL(string: "https://example.com/logo.png")!,
            title: "Logo",
            link: URL(string: "https://example.com")!,
            width: 88,
            height: 31
        )
        let data = try JSONEncoder().encode(image)
        let decoded = try JSONDecoder().decode(RSSImage.self, from: data)
        #expect(decoded == image)
    }
}
