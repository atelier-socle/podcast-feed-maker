import Foundation
import Testing

@testable import PodcastFeedMaker

struct NamespaceResolverTests {

    // MARK: - Helpers

    private func minimalChannel() throws -> Channel {
        Channel(
            title: "Test",
            link: try #require(URL(string: "https://example.com")),
            description: "Test feed"
        )
    }

    private func feedWith(channel: Channel) -> PodcastFeed {
        PodcastFeed(channel: channel)
    }

    // MARK: - Tests

    @Test("Minimal channel has no extra namespaces")
    func minimalChannelNoNamespaces() throws {
        let feed = feedWith(channel: try minimalChannel())
        let resolved = NamespaceResolver.resolve(feed)
        #expect(resolved.isEmpty)
    }

    @Test("Feed with no channel returns empty")
    func noChannelReturnsEmpty() {
        let feed = PodcastFeed()
        let resolved = NamespaceResolver.resolve(feed)
        #expect(resolved.isEmpty)
    }

    @Test("Detects iTunes namespace from channel property")
    func detectsITunesFromChannel() throws {
        var ch = try minimalChannel()
        ch.itunesAuthor = "Host"
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.itunes))
        #expect(!resolved.contains(.atom))
        #expect(!resolved.contains(.podcast))
    }

    @Test("Detects iTunes namespace from item property")
    func detectsITunesFromItem() throws {
        var ch = try minimalChannel()
        ch.items = [Item(itunesDuration: 3600)]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.itunes))
    }

    @Test("Detects Atom namespace")
    func detectsAtom() throws {
        var ch = try minimalChannel()
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        ch.atomLinks = [AtomLink.selfLink(href: feedURL)]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.atom))
        #expect(!resolved.contains(.itunes))
    }

    @Test("Detects Podcast namespace from channel property")
    func detectsPodcastFromChannel() throws {
        var ch = try minimalChannel()
        ch.podcastGuid = PodcastGuid(value: "abc-123")
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.podcast))
    }

    @Test("Detects Podcast namespace from item property")
    func detectsPodcastFromItem() throws {
        var ch = try minimalChannel()
        let transcriptURL = try #require(URL(string: "https://example.com/t.vtt"))
        ch.items = [Item(transcripts: [Transcript(url: transcriptURL, type: "text/vtt")])]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.podcast))
    }

    @Test("Detects Dublin Core namespace")
    func detectsDublinCore() throws {
        var ch = try minimalChannel()
        ch.dublinCore = DublinCore(creator: "Jane")
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.dublinCore))
    }

    @Test("Detects Dublin Core from item")
    func detectsDublinCoreFromItem() throws {
        var ch = try minimalChannel()
        ch.items = [Item(dublinCore: DublinCore(creator: "Jane"))]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.dublinCore))
    }

    @Test("Detects Content namespace from item")
    func detectsContent() throws {
        var ch = try minimalChannel()
        ch.items = [Item(contentEncoded: ContentEncoded(value: "<p>Hello</p>"))]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.content))
    }

    @Test("Detects Podlove namespace from item")
    func detectsPodlove() throws {
        var ch = try minimalChannel()
        ch.items = [Item(podloveChapters: PodloveChapters(chapters: [PodloveChapter(start: "00:00:00", title: "Intro")]))]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.contains(.podloveSimpleChapters))
    }

    @Test("Full feed detects all 6 standard namespaces")
    func fullFeedAllNamespaces() throws {
        var ch = try minimalChannel()
        ch.itunesAuthor = "Host"
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        ch.atomLinks = [AtomLink.selfLink(href: feedURL)]
        ch.podcastGuid = PodcastGuid(value: "abc-123")
        ch.dublinCore = DublinCore(creator: "Host")
        ch.items = [
            Item(
                contentEncoded: ContentEncoded(value: "<p>Content</p>"),
                podloveChapters: PodloveChapters(chapters: [PodloveChapter(start: "00:00:00", title: "Intro")])
            )
        ]
        let resolved = NamespaceResolver.resolve(feedWith(channel: ch))
        #expect(resolved.count == 6)
        #expect(resolved.contains(.itunes))
        #expect(resolved.contains(.atom))
        #expect(resolved.contains(.podcast))
        #expect(resolved.contains(.dublinCore))
        #expect(resolved.contains(.content))
        #expect(resolved.contains(.podloveSimpleChapters))
    }

    @Test("Custom namespaces are preserved")
    func customNamespacesPreserved() throws {
        var ch = try minimalChannel()
        ch.itunesAuthor = "Host"
        var feed = feedWith(channel: ch)
        feed.namespaces = [.itunes, .custom(#"xmlns:custom="https://example.com/ns""#)]
        let resolved = NamespaceResolver.resolve(feed)
        #expect(resolved.contains(.itunes))
        #expect(resolved.contains(.custom(#"xmlns:custom="https://example.com/ns""#)))
    }

    @Test("Detects Podcast namespace from various channel properties")
    func detectsPodcastFromVariousChannelProps() throws {
        // locked
        var ch1 = try minimalChannel()
        ch1.locked = Locked(isLocked: true)
        #expect(NamespaceResolver.resolve(feedWith(channel: ch1)).contains(.podcast))

        // funding
        var ch2 = try minimalChannel()
        let fundingURL = try #require(URL(string: "https://example.com"))
        ch2.funding = [Funding(url: fundingURL, message: "Support")]
        #expect(NamespaceResolver.resolve(feedWith(channel: ch2)).contains(.podcast))

        // medium
        var ch3 = try minimalChannel()
        ch3.medium = .podcast
        #expect(NamespaceResolver.resolve(feedWith(channel: ch3)).contains(.podcast))

        // trailers
        var ch4 = try minimalChannel()
        let trailerURL = try #require(URL(string: "https://example.com/t.mp3"))
        ch4.trailers = [Trailer(title: "T", url: trailerURL, pubDate: Date())]
        #expect(NamespaceResolver.resolve(feedWith(channel: ch4)).contains(.podcast))
    }
}
