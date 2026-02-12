import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - PubDateTests

/// Tests for the `pubDate` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.pubDate` and `Item.pubDate` are both
/// optional `Date?` properties. Dates are formatted to RFC 822 in XML.
@Suite("RSS PubDate Property Tests")
struct PubDateTests {

    // MARK: - Channel PubDate

    @Test("Channel pubDate defaults to nil")
    func channelPubDateDefaultsToNil() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        #expect(channel.pubDate == nil)
    }

    @Test("Channel pubDate can be set at initialization")
    func channelPubDateCanBeSet() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            pubDate: date
        )

        #expect(channel.pubDate == date)
    }

    @Test("Channel pubDate is mutable")
    func channelPubDateIsMutable() {
        var channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let date = Date(timeIntervalSince1970: 500_000)
        channel.pubDate = date
        #expect(channel.pubDate == date)
    }

    @Test("Channel XML contains pubDate tag with RFC 822 format")
    func channelXmlContainsPubDateFormatted() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.date(from: "2025-03-24 18:30:00")!

        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            pubDate: date
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<pubDate>"))
        #expect(xml.contains("Mon, 24 Mar 2025 18:30:00"))
        #expect(xml.contains("</pubDate>"))
    }

    @Test("Channel XML omits pubDate tag when nil")
    func channelXmlOmitsPubDateWhenNil() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
        #expect(!xml.contains("<pubDate>"))
    }

    // MARK: - Item PubDate

    @Test("Item pubDate defaults to nil")
    func itemPubDateDefaultsToNil() {
        let item = Item()
        #expect(item.pubDate == nil)
    }

    @Test("Item pubDate can be set at initialization")
    func itemPubDateCanBeSet() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let item = Item(pubDate: date)
        #expect(item.pubDate == date)
    }

    @Test("Item XML contains pubDate tag when set")
    func itemXmlContainsPubDateWhenSet() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.date(from: "2025-03-24 18:30:00")!

        let item = Item(pubDate: date)
        let xml = try item.xmlRepresentation()
        #expect(xml.contains("<pubDate>"))
        #expect(xml.contains("Mon, 24 Mar 2025 18:30:00"))
    }

    @Test("Item XML omits pubDate tag when nil")
    func itemXmlOmitsPubDateWhenNil() throws {
        let item = Item()
        let xml = try item.xmlRepresentation()
        #expect(!xml.contains("<pubDate>"))
    }

    // MARK: - Equatable

    @Test("Channels with same pubDate are equal")
    func channelsWithSamePubDateAreEqual() {
        let url = URL(string: "https://example.com")!
        let date = Date(timeIntervalSince1970: 100)
        let channel1 = Channel(title: "T", link: url, description: "D", pubDate: date)
        let channel2 = Channel(title: "T", link: url, description: "D", pubDate: date)
        #expect(channel1 == channel2)
    }

    @Test("Channels with different pubDates are not equal")
    func channelsWithDifferentPubDatesAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)
        let channel1 = Channel(title: "T", link: url, description: "D", pubDate: date1)
        let channel2 = Channel(title: "T", link: url, description: "D", pubDate: date2)
        #expect(channel1 != channel2)
    }

    // MARK: - Hashable

    @Test("Channel pubDate contributes to hash value")
    func channelPubDateHashable() {
        let url = URL(string: "https://example.com")!
        let date = Date(timeIntervalSince1970: 100)
        let channel = Channel(title: "T", link: url, description: "D", pubDate: date)
        let set: Set = [channel]
        #expect(set.contains(channel))
    }
}
