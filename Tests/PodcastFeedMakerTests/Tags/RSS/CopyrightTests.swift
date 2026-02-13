import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - CopyrightTests

/// Tests for the `copyright` property on ``Channel``.
///
/// In the new model, `Channel.copyright` is an optional `String?`.
@Suite("RSS Copyright Property Tests")
struct CopyrightTests {

    // MARK: - Initialization

    @Test("Channel copyright defaults to nil")
    func channelCopyrightDefaultsToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        #expect(channel.copyright == nil)
    }

    @Test("Channel copyright can be set at initialization")
    func channelCopyrightCanBeSet() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            copyright: "2025 Atelier Socle"
        )

        #expect(channel.copyright == "2025 Atelier Socle")
    }

    @Test("Channel copyright is mutable")
    func channelCopyrightIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        channel.copyright = "2025 Updated"
        #expect(channel.copyright == "2025 Updated")
    }

    // MARK: - XML Generation

    @Test("Channel XML contains copyright tag when set")
    func channelXmlContainsCopyright() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            copyright: "2025 Atelier Socle"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<copyright>2025 Atelier Socle</copyright>"))
    }

    @Test("Channel XML omits copyright tag when nil")
    func channelXmlOmitsCopyrightWhenNil() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(!xml.contains("<copyright>"))
    }

    @Test("Channel XML escapes special characters in copyright")
    func channelXmlEscapesSpecialCharsInCopyright() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            copyright: "\u{00A9} 2025 Atelier Socle"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<copyright>&#xA9; 2025 Atelier Socle</copyright>"))
    }

    @Test("Channel XML escapes ampersand and angle brackets in copyright")
    func channelXmlEscapesAmpersandInCopyright() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            copyright: "My & Co <2025>"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("My &amp; Co &lt;2025&gt;"))
    }

    // MARK: - Equatable

    @Test("Channels with same copyright are equal")
    func channelsWithSameCopyrightAreEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", copyright: "2025")
        let channel2 = Channel(title: "T", link: url, description: "D", copyright: "2025")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different copyrights are not equal")
    func channelsWithDifferentCopyrightsAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", copyright: "2025")
        let channel2 = Channel(title: "T", link: url, description: "D", copyright: "2024")
        #expect(channel1 != channel2)
    }

    @Test("Channels with nil vs non-nil copyright are not equal")
    func channelsWithNilVsNonNilCopyrightAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D")
        let channel2 = Channel(title: "T", link: url, description: "D", copyright: "2025")
        #expect(channel1 != channel2)
    }
}
