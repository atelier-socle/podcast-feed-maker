import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - FeedTests

/// Tests for the ``PodcastFeed`` struct.
///
/// `PodcastFeed` is the root model with `version: String`,
/// `namespaces: [PodcastNamespace]`, and `channel: Channel?`.
/// Conforms to `Sendable`, `Hashable`, and `Equatable`.
/// `GeneratorError.missingChannel` is thrown when generating XML without a channel.
@Suite("PodcastFeed Struct Tests")
struct FeedTests {

    // MARK: - Helpers

    /// Creates a minimal channel for feed construction.
    private func makeMinimalChannel(
        title: String = "Test Podcast",
        link: URL = URL(string: "https://example.com")!,
        description: String = "A test podcast"
    ) -> Channel {
        Channel(title: title, link: link, description: description)
    }

    // MARK: - Initialization

    @Test("PodcastFeed can be initialized with defaults")
    func feedInitWithDefaults() {
        let feed = PodcastFeed()

        #expect(feed.version == "2.0")
        #expect(feed.namespaces == PodcastNamespace.allStandard)
        #expect(feed.channel == nil)
    }

    @Test("PodcastFeed default version is 2.0")
    func feedDefaultVersion() {
        let feed = PodcastFeed()
        #expect(feed.version == "2.0")
    }

    @Test("PodcastFeed default namespaces include all 6 standard namespaces")
    func feedDefaultNamespaces() {
        let feed = PodcastFeed()
        #expect(feed.namespaces.count == 6)
        #expect(feed.namespaces.contains(.itunes))
        #expect(feed.namespaces.contains(.atom))
        #expect(feed.namespaces.contains(.podcast))
        #expect(feed.namespaces.contains(.dublinCore))
        #expect(feed.namespaces.contains(.content))
        #expect(feed.namespaces.contains(.podloveSimpleChapters))
    }

    @Test("PodcastFeed allStandard returns 6 namespaces")
    func feedAllStandardCount() {
        #expect(PodcastNamespace.allStandard.count == 6)
    }

    @Test("PodcastFeed can be initialized with a channel")
    func feedInitWithChannel() {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(channel: channel)

        #expect(feed.channel?.title == "Test Podcast")
        #expect(feed.channel?.link == URL(string: "https://example.com")!)
        #expect(feed.channel?.description == "A test podcast")
        #expect(feed.version == "2.0")
    }

    @Test("PodcastFeed can be initialized with custom version")
    func feedInitWithCustomVersion() {
        let feed = PodcastFeed(version: "2.1")
        #expect(feed.version == "2.1")
    }

    @Test("PodcastFeed can be initialized with custom namespaces")
    func feedInitWithCustomNamespaces() {
        let feed = PodcastFeed(namespaces: [.itunes, .atom])
        #expect(feed.namespaces.count == 2)
        #expect(feed.namespaces.contains(.itunes))
        #expect(feed.namespaces.contains(.atom))
        #expect(!feed.namespaces.contains(.podcast))
        #expect(!feed.namespaces.contains(.dublinCore))
    }

    @Test("PodcastFeed can be initialized with empty namespaces")
    func feedInitWithEmptyNamespaces() {
        let feed = PodcastFeed(namespaces: [])
        #expect(feed.namespaces.isEmpty)
    }

    @Test("PodcastFeed can be initialized with channel set to nil explicitly")
    func feedInitWithNilChannel() {
        let feed = PodcastFeed(channel: nil)
        #expect(feed.channel == nil)
    }

    @Test("PodcastFeed can be initialized with custom namespace string")
    func feedInitWithCustomNamespace() {
        let customNs = PodcastNamespace.custom(#"xmlns:custom="https://custom.example.com""#)
        let feed = PodcastFeed(namespaces: [.itunes, customNs])
        #expect(feed.namespaces.count == 2)
    }

    // MARK: - Mutability

    @Test("PodcastFeed properties are mutable")
    func feedPropertiesAreMutable() {
        var feed = PodcastFeed()

        feed.version = "3.0"
        feed.namespaces = [.itunes]
        feed.channel = makeMinimalChannel()

        #expect(feed.version == "3.0")
        #expect(feed.namespaces.count == 1)
        #expect(feed.channel?.title == "Test Podcast")
    }

    @Test("PodcastFeed channel can be replaced")
    func feedChannelCanBeReplaced() {
        var feed = PodcastFeed(channel: makeMinimalChannel(title: "Original"))

        feed.channel = makeMinimalChannel(title: "Replacement")

        #expect(feed.channel?.title == "Replacement")
    }

    // MARK: - XML Generation

    @Test("PodcastFeed generates valid RSS structure")
    func feedXmlRepresentation() throws {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains(#"<?xml version="1.0" encoding="UTF-8"?>"#))
        #expect(xml.contains("<rss"))
        #expect(xml.contains(#"version="2.0""#))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>Test Podcast</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<description>A test podcast</description>"))
        #expect(xml.contains("</channel>"))
        #expect(xml.contains("</rss>"))
    }

    @Test("PodcastFeed generates XML with all standard namespace declarations")
    func feedXmlIncludesNamespaces() throws {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains(#"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#))
        #expect(xml.contains(#"xmlns:atom="http://www.w3.org/2005/Atom""#))
        #expect(xml.contains(#"xmlns:podcast="https://podcastindex.org/namespace/1.0""#))
        #expect(xml.contains(#"xmlns:dc="http://purl.org/dc/elements/1.1/""#))
        #expect(xml.contains(#"xmlns:content="http://purl.org/rss/1.0/modules/content/""#))
        #expect(xml.contains(#"xmlns:psc="http://podlove.org/simple-chapters""#))
    }

    @Test("PodcastFeed generates XML with custom namespaces only includes those")
    func feedXmlWithCustomNamespaces() throws {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(namespaces: [.itunes], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains(#"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#))
        #expect(!xml.contains("xmlns:atom="))
        #expect(!xml.contains("xmlns:podcast="))
        #expect(!xml.contains("xmlns:dc="))
        #expect(!xml.contains("xmlns:content="))
        #expect(!xml.contains("xmlns:psc="))
    }

    @Test("PodcastFeed generates XML with empty namespaces has no xmlns declarations")
    func feedXmlWithEmptyNamespaces() throws {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(namespaces: [], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(!xml.contains("xmlns:"))
        #expect(xml.contains("<rss"))
        #expect(xml.contains("<channel>"))
    }

    @Test("PodcastFeed generates XML with podcast-only namespace")
    func feedXmlWithPodcastOnlyNamespace() throws {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(namespaces: [.podcast], channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains(#"xmlns:podcast="https://podcastindex.org/namespace/1.0""#))
        #expect(!xml.contains("xmlns:itunes="))
    }

    @Test("PodcastFeed generates XML with channel items")
    func feedXmlIncludesChannelItems() throws {
        let channel = Channel(
            title: "Test",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            items: [
                Item(title: "Episode 1"),
                Item(title: "Episode 2")
            ]
        )
        let feed = PodcastFeed(channel: channel)
        let xml = try FeedGenerator().generate(feed)

        #expect(xml.contains("<item>"))
        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<title>Episode 2</title>"))
        #expect(xml.contains("</item>"))
    }

    // MARK: - Error Handling

    @Test("PodcastFeed generate throws missingChannel when channel is nil")
    func feedXmlThrowsMissingChannelTag() {
        let feed = PodcastFeed()

        #expect(throws: GeneratorError.self) {
            try FeedGenerator().generate(feed)
        }
    }

    @Test("PodcastFeed generate throws when initialized with channel: nil")
    func feedXmlThrowsWhenInitializedWithNilChannel() {
        let feed = PodcastFeed(channel: nil)

        #expect(throws: GeneratorError.self) {
            try FeedGenerator().generate(feed)
        }
    }

    @Test("GeneratorError.missingChannel has correct error description")
    func feedErrorMissingChannelTagDescription() {
        let error = GeneratorError.missingChannel
        #expect(error.errorDescription == "Missing channel — a PodcastFeed must have a channel to generate XML.")
    }

    @Test("PodcastFeed generate throws with matching error details")
    func feedXmlThrowsWithMatchingDetails() {
        let feed = PodcastFeed(channel: nil)

        #expect(performing: {
            try FeedGenerator().generate(feed)
        }, throws: { error in
            error as? GeneratorError == .missingChannel
                && error.localizedDescription.contains("Missing channel")
        })
    }

    @Test("PodcastFeed with channel does not throw")
    func feedWithChannelDoesNotThrow() throws {
        let feed = PodcastFeed(channel: makeMinimalChannel())
        let xml = try FeedGenerator().generate(feed)
        #expect(!xml.isEmpty)
    }

    // MARK: - Sendable

    @Test("PodcastFeed is Sendable")
    func feedIsSendable() async {
        let feed = PodcastFeed(channel: makeMinimalChannel())
        let result = await Task { feed.version }.value
        #expect(result == "2.0")
    }

    @Test("PodcastFeed channel is accessible across concurrency boundaries")
    func feedChannelIsSendable() async {
        let channel = Channel(
            title: "Concurrent Podcast",
            link: URL(string: "https://example.com")!,
            description: "Desc",
            podcastGuid: PodcastGuid(value: "guid-123")
        )
        let feed = PodcastFeed(channel: channel)
        let result = await Task { feed.channel?.podcastGuid?.value }.value
        #expect(result == "guid-123")
    }

    // MARK: - Equatable

    @Test("Feeds with identical properties are equal")
    func feedsWithIdenticalPropertiesAreEqual() {
        let channel = makeMinimalChannel()
        let feed1 = PodcastFeed(channel: channel)
        let feed2 = PodcastFeed(channel: channel)
        #expect(feed1 == feed2)
    }

    @Test("Feeds with different versions are not equal")
    func feedsWithDifferentVersionsAreNotEqual() {
        let channel = makeMinimalChannel()
        let feed1 = PodcastFeed(version: "2.0", channel: channel)
        let feed2 = PodcastFeed(version: "2.1", channel: channel)
        #expect(feed1 != feed2)
    }

    @Test("Feeds with nil vs non-nil channel are not equal")
    func feedsWithNilVsNonNilChannelAreNotEqual() {
        let feed1 = PodcastFeed()
        let feed2 = PodcastFeed(channel: makeMinimalChannel())
        #expect(feed1 != feed2)
    }

    @Test("Feeds with different namespaces are not equal")
    func feedsWithDifferentNamespacesAreNotEqual() {
        let feed1 = PodcastFeed(namespaces: [.itunes])
        let feed2 = PodcastFeed(namespaces: [.atom])
        #expect(feed1 != feed2)
    }

    @Test("Feeds with different channels are not equal")
    func feedsWithDifferentChannelsAreNotEqual() {
        let feed1 = PodcastFeed(channel: makeMinimalChannel(title: "A"))
        let feed2 = PodcastFeed(channel: makeMinimalChannel(title: "B"))
        #expect(feed1 != feed2)
    }

    @Test("Two default-initialized feeds are equal")
    func defaultFeedsAreEqual() {
        let feed1 = PodcastFeed()
        let feed2 = PodcastFeed()
        #expect(feed1 == feed2)
    }

    // MARK: - Hashable

    @Test("PodcastFeed is Hashable and can be stored in a Set")
    func feedHashable() {
        let feed1 = PodcastFeed(version: "2.0")
        let feed2 = PodcastFeed(version: "2.1")
        let set: Set = [feed1, feed2]
        #expect(set.count == 2)
    }

    @Test("Duplicate feeds collapse in a Set")
    func duplicateFeedsCollapseInSet() {
        let feed1 = PodcastFeed()
        let feed2 = PodcastFeed()
        let set: Set = [feed1, feed2]
        #expect(set.count == 1)
    }

    @Test("Feeds with different namespaces produce different hashes")
    func feedHashDiffersWithNamespaces() {
        let feed1 = PodcastFeed(namespaces: [.itunes])
        let feed2 = PodcastFeed(namespaces: [.podcast])
        let set: Set = [feed1, feed2]
        #expect(set.count == 2)
    }

    @Test("Feeds with different channels produce different hashes")
    func feedHashDiffersWithChannels() {
        let feed1 = PodcastFeed(channel: makeMinimalChannel(title: "A"))
        let feed2 = PodcastFeed(channel: makeMinimalChannel(title: "B"))
        let set: Set = [feed1, feed2]
        #expect(set.count == 2)
    }
}
