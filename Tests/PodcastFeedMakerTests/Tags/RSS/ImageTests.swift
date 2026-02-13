import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - ImageTests

/// Tests for the ``RSSImage`` struct.
///
/// `RSSImage` has required `url: URL`, `title: String`, `link: URL`,
/// and optional `width`, `height`, `imageDescription`.
/// Conforms to `Sendable`, `Hashable`, `Equatable`, and `Codable`.
@Suite("RSSImage Struct Tests")
struct ImageTests {

    // MARK: - Initialization

    @Test("RSSImage can be initialized with required properties")
    func rssImageInitWithRequiredProperties() {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
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
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
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
        let oldURL = makeURL("https://example.com/old.png")
        let oldLink = makeURL("https://old.example.com")
        var image = RSSImage(
            url: oldURL,
            title: "Old Title",
            link: oldLink
        )

        let newURL = makeURL("https://example.com/new.png")
        let newLink = makeURL("https://new.example.com")
        image.url = newURL
        image.title = "New Title"
        image.link = newLink
        image.width = 144
        image.height = 400

        #expect(image.url == newURL)
        #expect(image.title == "New Title")
        #expect(image.link == newLink)
        #expect(image.width == 144)
        #expect(image.height == 400)
    }

    // MARK: - XML Generation

    @Test("RSSImage generates XML with expected elements via XMLBuilder")
    func rssImageXmlRepresentation() {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let image = RSSImage(
            url: url,
            title: "Podcast Logo",
            link: link
        )

        let b = XMLBuilder()
        let b1 = b.indented()
        var lines: [String] = []
        lines.append(b.openTag("image"))
        lines.append(b1.element("url", content: XMLBuilder.encodeURL(image.url)))
        lines.append(b1.element("title", content: image.title))
        lines.append(b1.element("link", content: XMLBuilder.encodeURL(image.link)))
        if let width = image.width { lines.append(b1.element("width", content: "\(width)")) }
        if let height = image.height { lines.append(b1.element("height", content: "\(height)")) }
        if let desc = image.imageDescription { lines.append(b1.element("description", content: desc)) }
        lines.append(b.closeTag("image"))
        let xml = lines.joined(separator: "\n")
        #expect(xml.contains("<image>"))
        #expect(xml.contains("<url>https://example.com/logo.png</url>"))
        #expect(xml.contains("<title>Podcast Logo</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("</image>"))
    }

    @Test("RSSImage generates XML escaping special characters in title")
    func rssImageXmlEscapesTitle() {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let image = RSSImage(
            url: url,
            title: "Show & Tell <Podcast>",
            link: link
        )

        let b = XMLBuilder()
        let b1 = b.indented()
        var lines: [String] = []
        lines.append(b.openTag("image"))
        lines.append(b1.element("url", content: XMLBuilder.encodeURL(image.url)))
        lines.append(b1.element("title", content: image.title))
        lines.append(b1.element("link", content: XMLBuilder.encodeURL(image.link)))
        if let width = image.width { lines.append(b1.element("width", content: "\(width)")) }
        if let height = image.height { lines.append(b1.element("height", content: "\(height)")) }
        if let desc = image.imageDescription { lines.append(b1.element("description", content: desc)) }
        lines.append(b.closeTag("image"))
        let xml = lines.joined(separator: "\n")
        #expect(xml.contains("Show &amp; Tell &lt;Podcast&gt;"))
    }

    // MARK: - Channel Integration

    @Test("Channel can hold an RSSImage")
    func channelCanHoldImage() {
        let imgURL = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let image = RSSImage(
            url: imgURL,
            title: "Logo",
            link: link
        )
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            image: image
        )

        #expect(channel.image?.url == imgURL)
        #expect(channel.image?.title == "Logo")
    }

    @Test("Channel XML contains image element when set")
    func channelXmlContainsImage() throws {
        let imgURL = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let image = RSSImage(
            url: imgURL,
            title: "Logo",
            link: link
        )
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            image: image
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<image>"))
        #expect(xml.contains("<url>https://example.com/logo.png</url>"))
    }

    @Test("Channel XML omits image element when nil")
    func channelXmlOmitsImageWhenNil() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(!xml.contains("<image>"))
    }

    // MARK: - Equatable

    @Test("RSSImages with same properties are equal")
    func rssImagesEqual() {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let img1 = RSSImage(url: url, title: "Logo", link: link)
        let img2 = RSSImage(url: url, title: "Logo", link: link)
        #expect(img1 == img2)
    }

    @Test("RSSImages with different titles are not equal")
    func rssImagesDifferentTitles() {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let img1 = RSSImage(url: url, title: "Logo A", link: link)
        let img2 = RSSImage(url: url, title: "Logo B", link: link)
        #expect(img1 != img2)
    }

    // MARK: - Hashable

    @Test("RSSImage is Hashable")
    func rssImageHashable() {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let image = RSSImage(url: url, title: "Logo", link: link)
        let set: Set = [image]
        #expect(set.contains(RSSImage(url: url, title: "Logo", link: link)))
    }

    // MARK: - Codable

    @Test("RSSImage can be encoded and decoded via JSON")
    func rssImageCodable() throws {
        let url = makeURL("https://example.com/logo.png")
        let link = makeURL("https://example.com")
        let image = RSSImage(
            url: url,
            title: "Logo",
            link: link,
            width: 88,
            height: 31
        )
        let data = try JSONEncoder().encode(image)
        let decoded = try JSONDecoder().decode(RSSImage.self, from: data)
        #expect(decoded == image)
    }
}
