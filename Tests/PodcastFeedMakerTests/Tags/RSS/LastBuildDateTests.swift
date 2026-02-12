import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - LastBuildDateTests

/// Tests for the `lastBuildDate` property on ``Channel``.
///
/// In the new model, `Channel.lastBuildDate` is an optional `Date?`.
/// The date is formatted to RFC 822 in XML output.
@Suite("RSS LastBuildDate Property Tests")
struct LastBuildDateTests {

    // MARK: - Initialization

    @Test("Channel lastBuildDate defaults to nil")
    func channelLastBuildDateDefaultsToNil() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        #expect(channel.lastBuildDate == nil)
    }

    @Test("Channel lastBuildDate can be set at initialization")
    func channelLastBuildDateCanBeSet() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            lastBuildDate: date
        )

        #expect(channel.lastBuildDate == date)
    }

    @Test("Channel lastBuildDate is mutable")
    func channelLastBuildDateIsMutable() {
        var channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let date = Date(timeIntervalSince1970: 500_000)
        channel.lastBuildDate = date
        #expect(channel.lastBuildDate == date)
    }

    // MARK: - XML Generation

    @Test("Channel XML contains lastBuildDate tag with RFC 822 format")
    func channelXmlContainsLastBuildDateFormatted() throws {
        let components = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2024, month: 3, day: 26,
            hour: 20, minute: 30, second: 0
        )
        let date = components.date!

        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            lastBuildDate: date
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<lastBuildDate>Tue, 26 Mar 2024 20:30:00 +0000</lastBuildDate>"))
    }

    @Test("Channel XML omits lastBuildDate tag when nil")
    func channelXmlOmitsLastBuildDateWhenNil() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
        #expect(!xml.contains("<lastBuildDate>"))
    }

    // MARK: - Equatable

    @Test("Channels with same lastBuildDate are equal")
    func channelsWithSameLastBuildDateAreEqual() {
        let url = URL(string: "https://example.com")!
        let date = Date(timeIntervalSince1970: 100)
        let channel1 = Channel(title: "T", link: url, description: "D", lastBuildDate: date)
        let channel2 = Channel(title: "T", link: url, description: "D", lastBuildDate: date)
        #expect(channel1 == channel2)
    }

    @Test("Channels with different lastBuildDates are not equal")
    func channelsWithDifferentLastBuildDatesAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)
        let channel1 = Channel(title: "T", link: url, description: "D", lastBuildDate: date1)
        let channel2 = Channel(title: "T", link: url, description: "D", lastBuildDate: date2)
        #expect(channel1 != channel2)
    }
}
