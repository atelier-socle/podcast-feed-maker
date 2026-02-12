import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - ChannelTests

/// Tests for the ``Channel`` struct.
///
/// `Channel` is the main feed-level container with ~50 typed properties.
/// Required fields: `title: String`, `link: URL`, `description: String`.
/// All other fields default to `nil` or empty arrays.
/// Conforms to `Sendable`, `Hashable`, `Equatable`, and `XmlRepresentable`.
@Suite("Channel Struct Tests")
struct ChannelTests {

    // MARK: - Helpers

    /// Creates a minimal channel with only the required fields.
    private func makeMinimalChannel(
        title: String = "My Podcast",
        link: URL = URL(string: "https://podcast.example.com")!,
        description: String = "A podcast about Swift"
    ) -> Channel {
        Channel(title: title, link: link, description: description)
    }

    // MARK: - Required Fields Initialization

    @Test("Channel can be initialized with only required fields")
    func channelInitWithRequiredFields() {
        let channel = makeMinimalChannel()

        #expect(channel.title == "My Podcast")
        #expect(channel.link == URL(string: "https://podcast.example.com")!)
        #expect(channel.description == "A podcast about Swift")
    }

    @Test("Channel optional RSS fields default to nil")
    func channelOptionalRssFieldsDefaultToNil() {
        let channel = makeMinimalChannel()

        #expect(channel.language == nil)
        #expect(channel.copyright == nil)
        #expect(channel.managingEditor == nil)
        #expect(channel.webMaster == nil)
        #expect(channel.pubDate == nil)
        #expect(channel.lastBuildDate == nil)
        #expect(channel.generator == nil)
        #expect(channel.docs == nil)
        #expect(channel.cloud == nil)
        #expect(channel.ttl == nil)
        #expect(channel.image == nil)
        #expect(channel.textInput == nil)
        #expect(channel.skipSchedule == nil)
    }

    @Test("Channel array properties default to empty")
    func channelArrayPropertiesDefaultToEmpty() {
        let channel = makeMinimalChannel()

        #expect(channel.categories.isEmpty)
        #expect(channel.items.isEmpty)
        #expect(channel.itunesCategories.isEmpty)
        #expect(channel.itunesKeywords.isEmpty)
        #expect(channel.atomLinks.isEmpty)
        #expect(channel.funding.isEmpty)
        #expect(channel.persons.isEmpty)
        #expect(channel.podcastBlocks.isEmpty)
        #expect(channel.txtRecords.isEmpty)
        #expect(channel.trailers.isEmpty)
        #expect(channel.liveItems.isEmpty)
    }

    @Test("Channel iTunes properties default to nil")
    func channelItunesPropertiesDefaultToNil() {
        let channel = makeMinimalChannel()

        #expect(channel.itunesAuthor == nil)
        #expect(channel.itunesBlock == nil)
        #expect(channel.itunesComplete == nil)
        #expect(channel.itunesExplicit == nil)
        #expect(channel.itunesImage == nil)
        #expect(channel.itunesNewFeedUrl == nil)
        #expect(channel.itunesOwner == nil)
        #expect(channel.itunesSubtitle == nil)
        #expect(channel.itunesSummary == nil)
        #expect(channel.itunesTitle == nil)
        #expect(channel.itunesType == nil)
        #expect(channel.itunesVerify == nil)
    }

    @Test("Channel Podcast NS properties default to nil")
    func channelPodcastNsPropertiesDefaultToNil() {
        let channel = makeMinimalChannel()

        #expect(channel.podcastGuid == nil)
        #expect(channel.locked == nil)
        #expect(channel.location == nil)
        #expect(channel.license == nil)
        #expect(channel.value == nil)
        #expect(channel.medium == nil)
        #expect(channel.podroll == nil)
        #expect(channel.updateFrequency == nil)
        #expect(channel.podpingEnabled == nil)
        #expect(channel.publisher == nil)
        #expect(channel.chat == nil)
    }

    @Test("Channel Dublin Core and Atom properties default to nil or empty")
    func channelDublinCoreAndAtomDefaults() {
        let channel = makeMinimalChannel()

        #expect(channel.dublinCore == nil)
        #expect(channel.atomLinks.isEmpty)
    }

    // MARK: - Initialization with Optional Fields

    @Test("Channel can be initialized with optional RSS fields")
    func channelInitWithOptionalFields() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "en-us",
            copyright: "2025",
            managingEditor: "editor@example.com",
            pubDate: date,
            lastBuildDate: date,
            generator: "PodcastFeedMaker",
            ttl: 60
        )

        #expect(channel.language == "en-us")
        #expect(channel.copyright == "2025")
        #expect(channel.managingEditor == "editor@example.com")
        #expect(channel.pubDate == date)
        #expect(channel.lastBuildDate == date)
        #expect(channel.generator == "PodcastFeedMaker")
        #expect(channel.ttl == 60)
    }

    @Test("Channel can be initialized with iTunes fields")
    func channelInitWithItunesFields() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            itunesAuthor: "John Doe",
            itunesBlock: true,
            itunesCategories: [.technology],
            itunesComplete: false,
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/image.png")!,
            itunesKeywords: ["swift", "podcast"],
            itunesOwner: ITunesOwner(name: "John", email: "john@example.com"),
            itunesSubtitle: "A subtitle",
            itunesSummary: "A summary",
            itunesTitle: "Show Title Override",
            itunesType: .episodic
        )

        #expect(channel.itunesAuthor == "John Doe")
        #expect(channel.itunesBlock == true)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesComplete == false)
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesImage == URL(string: "https://example.com/image.png")!)
        #expect(channel.itunesKeywords == ["swift", "podcast"])
        #expect(channel.itunesOwner?.name == "John")
        #expect(channel.itunesOwner?.email == "john@example.com")
        #expect(channel.itunesSubtitle == "A subtitle")
        #expect(channel.itunesSummary == "A summary")
        #expect(channel.itunesTitle == "Show Title Override")
        #expect(channel.itunesType == .episodic)
    }

    @Test("Channel can be initialized with serial iTunes type")
    func channelInitWithSerialType() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            itunesType: .serial
        )

        #expect(channel.itunesType == .serial)
    }

    @Test("ITunesShowType has all expected cases")
    func itunesShowTypeCases() {
        #expect(ITunesShowType.episodic.rawValue == "episodic")
        #expect(ITunesShowType.serial.rawValue == "serial")
        #expect(ITunesShowType.allCases.count == 2)
    }

    @Test("Channel can be initialized with items")
    func channelInitWithItems() {
        let item1 = Item(title: "Episode 1")
        let item2 = Item(title: "Episode 2")
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            items: [item1, item2]
        )

        #expect(channel.items.count == 2)
        #expect(channel.items[0].title == "Episode 1")
        #expect(channel.items[1].title == "Episode 2")
    }

    @Test("Channel can be initialized with Podcast NS 2.0 properties")
    func channelInitWithPodcastNsProperties() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "owner@example.com"),
            funding: [Funding(url: URL(string: "https://example.com/donate")!, message: "Support us")]
        )

        #expect(channel.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1")
        #expect(channel.locked?.isLocked == true)
        #expect(channel.locked?.owner == "owner@example.com")
        #expect(channel.funding.count == 1)
        #expect(channel.funding[0].message == "Support us")
    }

    @Test("Channel can be initialized with Atom links")
    func channelInitWithAtomLinks() {
        let selfLink = AtomLink.selfLink(href: URL(string: "https://example.com/feed.xml")!)
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            atomLinks: [selfLink]
        )

        #expect(channel.atomLinks.count == 1)
        #expect(channel.atomLinks[0].rel == "self")
        #expect(channel.atomLinks[0].type == "application/rss+xml")
    }

    // MARK: - Mutability

    @Test("Channel properties are mutable")
    func channelPropertiesAreMutable() {
        var channel = makeMinimalChannel()

        channel.title = "New Title"
        channel.language = "fr"
        channel.ttl = 120
        channel.itunesExplicit = true
        channel.itunesType = .serial
        channel.items = [Item(title: "Ep1")]
        channel.podcastGuid = PodcastGuid(value: "new-guid")
        channel.locked = Locked(isLocked: false)

        #expect(channel.title == "New Title")
        #expect(channel.language == "fr")
        #expect(channel.ttl == 120)
        #expect(channel.itunesExplicit == true)
        #expect(channel.itunesType == .serial)
        #expect(channel.items.count == 1)
        #expect(channel.podcastGuid?.value == "new-guid")
        #expect(channel.locked?.isLocked == false)
    }

    // MARK: - XML Generation

    @Test("Channel XML contains required RSS tags")
    func channelXmlContainsRequiredTags() throws {
        let channel = makeMinimalChannel()
        let xml = try channel.xmlRepresentation()

        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>My Podcast</title>"))
        #expect(xml.contains("<link>https://podcast.example.com</link>"))
        #expect(xml.contains("<description>A podcast about Swift</description>"))
        #expect(xml.contains("</channel>"))
    }

    @Test("Channel XML contains optional RSS tags when set")
    func channelXmlContainsOptionalTags() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "en-us",
            copyright: "2025 Example",
            generator: "PodcastFeedMaker",
            ttl: 60
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<language>en-us</language>"))
        #expect(xml.contains("<copyright>2025 Example</copyright>"))
        #expect(xml.contains("<generator>PodcastFeedMaker</generator>"))
        #expect(xml.contains("<ttl>60</ttl>"))
    }

    @Test("Channel XML contains iTunes tags when set")
    func channelXmlContainsItunesTags() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            itunesAuthor: "John Doe",
            itunesBlock: true,
            itunesComplete: true,
            itunesExplicit: true,
            itunesImage: URL(string: "https://example.com/art.jpg")!,
            itunesKeywords: ["swift", "development"],
            itunesSubtitle: "A short subtitle",
            itunesSummary: "A longer summary",
            itunesTitle: "Title Override",
            itunesType: .serial
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<itunes:author>John Doe</itunes:author>"))
        #expect(xml.contains("<itunes:block>yes</itunes:block>"))
        #expect(xml.contains("<itunes:complete>yes</itunes:complete>"))
        #expect(xml.contains("<itunes:explicit>yes</itunes:explicit>"))
        #expect(xml.contains(#"<itunes:image href="https://example.com/art.jpg" />"#))
        #expect(xml.contains("<itunes:keywords>swift,development</itunes:keywords>"))
        #expect(xml.contains("<itunes:subtitle>A short subtitle</itunes:subtitle>"))
        #expect(xml.contains("<itunes:summary>A longer summary</itunes:summary>"))
        #expect(xml.contains("<itunes:title>Title Override</itunes:title>"))
        #expect(xml.contains("<itunes:type>serial</itunes:type>"))
    }

    @Test("Channel XML contains itunes:explicit no when explicit is false")
    func channelXmlContainsItunesExplicitNo() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            itunesExplicit: false
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<itunes:explicit>no</itunes:explicit>"))
    }

    @Test("Channel XML contains iTunes owner when set")
    func channelXmlContainsItunesOwner() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            itunesOwner: ITunesOwner(name: "Jane Doe", email: "jane@example.com")
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<itunes:owner>"))
        #expect(xml.contains("<itunes:name>Jane Doe</itunes:name>"))
        #expect(xml.contains("<itunes:email>jane@example.com</itunes:email>"))
        #expect(xml.contains("</itunes:owner>"))
    }

    @Test("Channel XML contains Podcast NS tags when set")
    func channelXmlContainsPodcastNsTags() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            podcastGuid: PodcastGuid(value: "channel-guid-value"),
            locked: Locked(isLocked: false)
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<podcast:guid>channel-guid-value</podcast:guid>"))
        #expect(xml.contains("<podcast:locked>no</podcast:locked>"))
    }

    @Test("Channel XML contains podcast:locked with owner attribute when set")
    func channelXmlContainsLockedWithOwner() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            locked: Locked(isLocked: true, owner: "john@example.com")
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains(#"<podcast:locked owner="john@example.com">yes</podcast:locked>"#))
    }

    @Test("Channel XML contains funding when set")
    func channelXmlContainsFunding() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            funding: [
                Funding(url: URL(string: "https://example.com/donate")!, message: "Support us")
            ]
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains(#"<podcast:funding url="https://example.com/donate">Support us</podcast:funding>"#))
    }

    @Test("Channel XML includes item elements")
    func channelXmlIncludesItems() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            items: [
                Item(title: "Episode 1"),
                Item(title: "Episode 2")
            ]
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<item>"))
        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<title>Episode 2</title>"))
        #expect(xml.contains("</item>"))
    }

    @Test("Channel XML omits optional tags when nil")
    func channelXmlOmitsNilOptionalTags() throws {
        let channel = makeMinimalChannel()
        let xml = try channel.xmlRepresentation()

        #expect(!xml.contains("<language>"))
        #expect(!xml.contains("<copyright>"))
        #expect(!xml.contains("<managingEditor>"))
        #expect(!xml.contains("<generator>"))
        #expect(!xml.contains("<ttl>"))
        #expect(!xml.contains("<itunes:author>"))
        #expect(!xml.contains("<itunes:block>"))
        #expect(!xml.contains("<itunes:complete>"))
        #expect(!xml.contains("<itunes:explicit>"))
        #expect(!xml.contains("<itunes:image"))
        #expect(!xml.contains("<itunes:keywords>"))
        #expect(!xml.contains("<itunes:type>"))
        #expect(!xml.contains("<podcast:guid>"))
        #expect(!xml.contains("<podcast:locked>"))
        #expect(!xml.contains("<podcast:funding"))
        #expect(!xml.contains("<item>"))
    }

    @Test("Channel XML contains Atom link when set")
    func channelXmlContainsAtomLink() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            atomLinks: [
                AtomLink.selfLink(href: URL(string: "https://example.com/feed.xml")!)
            ]
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains(#"<atom:link href="https://example.com/feed.xml""#))
        #expect(xml.contains(#"rel="self""#))
    }

    // MARK: - Sendable

    @Test("Channel is Sendable")
    func channelIsSendable() async {
        let channel = makeMinimalChannel()
        let result = await Task { channel.title }.value
        #expect(result == "My Podcast")
    }

    @Test("Channel with complex properties is Sendable")
    func channelWithComplexPropertiesIsSendable() async {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            itunesType: .serial,
            podcastGuid: PodcastGuid(value: "guid"),
            locked: Locked(isLocked: true)
        )
        let result = await Task { channel.podcastGuid?.value }.value
        #expect(result == "guid")
    }

    // MARK: - Equatable

    @Test("Channels with identical properties are equal")
    func channelsWithIdenticalPropertiesAreEqual() {
        let channel1 = makeMinimalChannel()
        let channel2 = makeMinimalChannel()
        #expect(channel1 == channel2)
    }

    @Test("Channels with different required fields are not equal")
    func channelsWithDifferentRequiredFieldsAreNotEqual() {
        let channel1 = makeMinimalChannel(title: "A")
        let channel2 = makeMinimalChannel(title: "B")
        #expect(channel1 != channel2)
    }

    @Test("Channels with different optional fields are not equal")
    func channelsWithDifferentOptionalFieldsAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D", language: "en")
        let channel2 = Channel(title: "T", link: url, description: "D", language: "fr")
        #expect(channel1 != channel2)
    }

    @Test("Channels with different iTunes types are not equal")
    func channelsWithDifferentItunesTypesAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D", itunesType: .episodic)
        let channel2 = Channel(title: "T", link: url, description: "D", itunesType: .serial)
        #expect(channel1 != channel2)
    }

    @Test("Channels with different Podcast NS properties are not equal")
    func channelsWithDifferentPodcastNsPropertiesAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(
            title: "T", link: url, description: "D",
            podcastGuid: PodcastGuid(value: "guid-1")
        )
        let channel2 = Channel(
            title: "T", link: url, description: "D",
            podcastGuid: PodcastGuid(value: "guid-2")
        )
        #expect(channel1 != channel2)
    }

    // MARK: - Hashable

    @Test("Channel is Hashable and can be stored in a Set")
    func channelHashable() {
        let channel1 = makeMinimalChannel(title: "A")
        let channel2 = makeMinimalChannel(title: "B")
        let set: Set = [channel1, channel2]
        #expect(set.count == 2)
        #expect(set.contains(channel1))
        #expect(set.contains(channel2))
    }

    @Test("Duplicate channels collapse in a Set")
    func duplicateChannelsCollapseInSet() {
        let channel1 = makeMinimalChannel()
        let channel2 = makeMinimalChannel()
        let set: Set = [channel1, channel2]
        #expect(set.count == 1)
    }

    @Test("Channels with different Podcast NS fields produce different hashes")
    func channelHashDiffersWithPodcastNs() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(
            title: "T", link: url, description: "D",
            locked: Locked(isLocked: true)
        )
        let channel2 = Channel(
            title: "T", link: url, description: "D",
            locked: Locked(isLocked: false)
        )
        let set: Set = [channel1, channel2]
        #expect(set.count == 2)
    }
}
