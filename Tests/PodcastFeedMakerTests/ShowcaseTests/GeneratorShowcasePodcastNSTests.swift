import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Feed Generator Podcast NS 2.0 Showcase

@Suite("Feed Generator Podcast NS 2.0 Showcase")
struct GeneratorPodcastNSShowcase {

    /// Builds a minimal valid feed for tests that only need a feed skeleton.
    private static func minimalFeed(
        namespaces: [PodcastNamespace] = [],
        items: [Item] = []
    ) throws -> PodcastFeed {
        let channel = Channel(
            title: "Minimal Podcast",
            link: makeURL("https://example.com"),
            description: "A minimal test feed.",
            items: items
        )
        return PodcastFeed(version: "2.0", namespaces: namespaces, channel: channel)
    }

    // MARK: - Podcast Namespace 2.0 Elements

    @Test("FeedGenerator — podcast:guid element")
    func feedGeneratorPodcastGuid() throws {
        let channel = Channel(
            title: "GUID Show",
            link: makeURL("https://example.com"),
            description: "GUID test.",
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>"))
    }

    @Test("FeedGenerator — podcast:locked element")
    func feedGeneratorPodcastLocked() throws {
        let channel = Channel(
            title: "Locked Show",
            link: makeURL("https://example.com"),
            description: "Locked test.",
            locked: Locked(isLocked: true, owner: "lock@example.com")
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains("lock@example.com"))
        #expect(xml.contains("yes"))
    }

    @Test("FeedGenerator — podcast:funding element")
    func feedGeneratorFunding() throws {
        let channel = Channel(
            title: "Funded Show",
            link: makeURL("https://example.com"),
            description: "Funding test.",
            funding: [Funding(url: makeURL("https://example.com/donate"), message: "Buy us a coffee")]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:funding"))
        #expect(xml.contains("https://example.com/donate"))
        #expect(xml.contains("Buy us a coffee"))
    }

    @Test("FeedGenerator — podcast:person element")
    func feedGeneratorPodcastPerson() throws {
        let channel = Channel(
            title: "Person Show",
            link: makeURL("https://example.com"),
            description: "Person test.",
            persons: [
                PodcastPerson(
                    name: "Alice",
                    role: "guest",
                    group: "cast",
                    href: URL(string: "https://example.com/alice"),
                    img: URL(string: "https://cdn.example.com/alice.jpg")
                )
            ]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:person"))
        #expect(xml.contains("Alice"))
        #expect(xml.contains("role=\"guest\""))
    }

    // MARK: - Atom Links

    @Test("FeedGenerator — atom:link self element")
    func feedGeneratorAtomSelfLink() throws {
        let channel = Channel(
            title: "Atom Show",
            link: makeURL("https://example.com"),
            description: "Atom test.",
            atomLinks: [AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.atom], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("atom:link"))
        #expect(xml.contains("href=\"https://example.com/feed.xml\""))
        #expect(xml.contains("rel=\"self\""))
        #expect(xml.contains("type=\"application/rss+xml\""))
    }

    // MARK: - Dublin Core

    @Test("FeedGenerator — Dublin Core elements")
    func feedGeneratorDublinCore() throws {
        let channel = Channel(
            title: "DC Show",
            link: makeURL("https://example.com"),
            description: "Dublin Core test.",
            dublinCore: DublinCore(
                creator: "Author One",
                language: "en-US",
                rights: "Copyright 2026"
            )
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [.dublinCore], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<dc:creator>Author One</dc:creator>"))
        #expect(xml.contains("<dc:language>en-US</dc:language>"))
        #expect(xml.contains("<dc:rights>Copyright 2026</dc:rights>"))
    }

    // MARK: - Podlove Simple Chapters

    @Test("FeedGenerator — Podlove Simple Chapters in item")
    func feedGeneratorPodloveChapters() throws {
        let item = Item(
            title: "Chapters Episode",
            podloveChapters: PodloveChapters(chapters: [
                PodloveChapter(start: "00:00:00.000", title: "Intro"),
                PodloveChapter(
                    start: "00:10:00.000",
                    title: "Interview",
                    href: URL(string: "https://example.com/guest")
                )
            ])
        )
        let feed = try Self.minimalFeed(namespaces: [.podloveSimpleChapters], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("psc:chapters"))
        #expect(xml.contains("psc:chapter"))
        #expect(xml.contains("start=\"00:00:00.000\""))
        #expect(xml.contains("title=\"Intro\""))
        #expect(xml.contains("start=\"00:10:00.000\""))
    }

    // MARK: - Item-Level Elements

    @Test("FeedGenerator — enclosure element with all attributes")
    func feedGeneratorEnclosure() throws {
        let item = Item(
            title: "Enclosure Test",
            enclosure: Enclosure(
                url: makeURL("https://cdn.example.com/ep.mp3"),
                length: 24_576_000,
                type: "audio/mpeg"
            )
        )
        let feed = try Self.minimalFeed(items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("url=\"https://cdn.example.com/ep.mp3\""))
        #expect(xml.contains("length=\"24576000\""))
        #expect(xml.contains("type=\"audio/mpeg\""))
    }

    @Test("FeedGenerator — GUID with isPermaLink attribute")
    func feedGeneratorGUID() throws {
        let item = Item(
            title: "GUID Test",
            guid: GUID(value: "unique-id-42", isPermaLink: false)
        )
        let feed = try Self.minimalFeed(items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<guid isPermaLink=\"false\">unique-id-42</guid>"))
    }

    @Test("FeedGenerator — podcast:transcript element")
    func feedGeneratorTranscript() throws {
        let item = Item(
            title: "Transcript Test",
            transcripts: [
                Transcript(
                    url: makeURL("https://example.com/captions.vtt"),
                    type: "text/vtt",
                    language: "en",
                    rel: "captions"
                )
            ]
        )
        let feed = try Self.minimalFeed(namespaces: [.podcast], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:transcript"))
        #expect(xml.contains("url=\"https://example.com/captions.vtt\""))
        #expect(xml.contains("type=\"text/vtt\""))
        #expect(xml.contains("language=\"en\""))
        #expect(xml.contains("rel=\"captions\""))
    }

    @Test("FeedGenerator — podcast:soundbite element")
    func feedGeneratorSoundbite() throws {
        let item = Item(
            title: "Soundbite Test",
            soundbites: [
                Soundbite(startTime: 73.0, duration: 60.0, title: "Great moment")
            ]
        )
        let feed = try Self.minimalFeed(namespaces: [.podcast], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:soundbite"))
        #expect(xml.contains("startTime=\"73.0\""))
        #expect(xml.contains("duration=\"60.0\""))
        #expect(xml.contains("Great moment"))
    }

    @Test("FeedGenerator — podcast:chapters link element")
    func feedGeneratorChaptersLink() throws {
        let item = Item(
            title: "Chapters Test",
            chaptersLink: ChaptersLink(
                url: makeURL("https://example.com/ch.json"),
                type: "application/json+chapters"
            )
        )
        let feed = try Self.minimalFeed(namespaces: [.podcast], items: [item])
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("podcast:chapters"))
        #expect(xml.contains("url=\"https://example.com/ch.json\""))
        #expect(xml.contains("type=\"application/json+chapters\""))
    }

    // MARK: - Round-Trip Preservation

    @Test("FeedGenerator — unknown elements preserved in output")
    func feedGeneratorUnknownElements() throws {
        let channel = Channel(
            title: "Unknown Show",
            link: makeURL("https://example.com"),
            description: "Unknown element test.",
            unknownElements: [
                UnknownElement(
                    name: "custom:rating",
                    attributes: ["scale": "10"],
                    textContent: "9"
                )
            ]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<custom:rating scale=\"10\">9</custom:rating>"))
    }

    @Test("FeedGenerator — XML comments preserved in output")
    func feedGeneratorXMLComments() throws {
        let channel = Channel(
            title: "Comment Show",
            link: makeURL("https://example.com"),
            description: "Comment test.",
            xmlComments: ["This is a preserved comment"]
        )
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<!-- This is a preserved comment -->"))
    }

    // MARK: - Error Handling

    @Test("FeedGenerator — throws missingChannel when no channel")
    func feedGeneratorMissingChannel() throws {
        let feed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
        let generator = FeedGenerator()

        #expect(throws: GeneratorError.missingChannel) {
            try generator.generate(feed)
        }
    }

    @Test("GeneratorError — error descriptions are human-readable")
    func generatorErrorDescriptions() {
        let missingChannel = GeneratorError.missingChannel
        #expect(missingChannel.errorDescription?.contains("Missing channel") == true)

        let invalidURL = GeneratorError.invalidURL("enclosure", "not-a-url")
        #expect(invalidURL.errorDescription?.contains("Invalid URL") == true)
        #expect(invalidURL.errorDescription?.contains("enclosure") == true)

        let encoding = GeneratorError.encodingError("UTF-16 not supported")
        #expect(encoding.errorDescription?.contains("Encoding error") == true)
    }

    @Test("GeneratorError — equatable conformance")
    func generatorErrorEquatable() {
        #expect(GeneratorError.missingChannel == GeneratorError.missingChannel)
        #expect(
            GeneratorError.invalidURL("a", "b") == GeneratorError.invalidURL("a", "b")
        )
        #expect(
            GeneratorError.invalidURL("a", "b") != GeneratorError.invalidURL("c", "d")
        )
    }

}
