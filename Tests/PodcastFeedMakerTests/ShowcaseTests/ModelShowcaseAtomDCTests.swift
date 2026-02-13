import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Atom Namespace Showcase

@Suite("Atom Namespace Showcase")
struct AtomNamespaceShowcase {

    @Test("AtomLink with all properties")
    func atomLinkFull() {
        let href = makeURL("https://example.com/alternate-feed.xml")

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
    func atomLinkSelfFactory() {
        let feedURL = makeURL("https://swifttalk.dev/feed.xml")
        let selfLink = AtomLink.selfLink(href: feedURL)

        #expect(selfLink.href == feedURL)
        #expect(selfLink.rel == "self")
        #expect(selfLink.type == "application/rss+xml")
        #expect(selfLink.hreflang == nil)
        #expect(selfLink.title == nil)
        #expect(selfLink.length == nil)
    }

    @Test("AtomLink with href only")
    func atomLinkHrefOnly() {
        let href = makeURL("https://example.com/related")
        let link = AtomLink(href: href)

        #expect(link.href == href)
        #expect(link.rel == nil)
        #expect(link.type == nil)
        #expect(link.hreflang == nil)
        #expect(link.title == nil)
        #expect(link.length == nil)
    }

    @Test("AtomLink enclosure relation for media")
    func atomLinkEnclosure() {
        let href = makeURL("https://cdn.example.com/episode.mp3")

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
    func podloveChaptersContainer() {
        let chapterURL = makeURL("https://example.com/topic")
        let imageURL = makeURL("https://example.com/chapter-img.jpg")

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
    func podloveChapterFull() {
        let href = makeURL("https://swift.org")
        let img = makeURL("https://example.com/swift-logo.png")

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
    func jsonChapterListFull() {
        let chapterURL = makeURL("https://example.com/topic")
        let chapterImg = makeURL("https://example.com/chapter1.jpg")

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
