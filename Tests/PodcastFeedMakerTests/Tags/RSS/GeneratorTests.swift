import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - GeneratorTests

/// Tests for the `generator` property on ``Channel``.
///
/// In the new model, `Channel.generator` is an optional `String?`.
@Suite("RSS Generator Property Tests")
struct GeneratorTests {

    // MARK: - Initialization

    @Test("Channel generator defaults to nil")
    func channelGeneratorDefaultsToNil() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        #expect(channel.generator == nil)
    }

    @Test("Channel generator can be set at initialization")
    func channelGeneratorCanBeSet() {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            generator: "PodcastFeedMaker 1.0"
        )

        #expect(channel.generator == "PodcastFeedMaker 1.0")
    }

    @Test("Channel generator is mutable")
    func channelGeneratorIsMutable() {
        let link = makeURL("https://example.com")
        var channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        channel.generator = "CustomGenerator 2.0"
        #expect(channel.generator == "CustomGenerator 2.0")
    }

    // MARK: - XML Generation

    @Test("Channel XML contains generator tag when set")
    func channelXmlContainsGenerator() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            generator: "PodcastFeedMaker 1.0"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("<generator>PodcastFeedMaker 1.0</generator>"))
    }

    @Test("Channel XML omits generator tag when nil")
    func channelXmlOmitsGeneratorWhenNil() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(!xml.contains("<generator>"))
    }

    @Test("Channel XML escapes special characters in generator")
    func channelXmlEscapesSpecialCharsInGenerator() throws {
        let link = makeURL("https://example.com")
        let channel = Channel(
            title: "Title",
            link: link,
            description: "Description",
            generator: "My & Co <2025>"
        )

        let xml = try FeedGenerator().generate(PodcastFeed(channel: channel))
        #expect(xml.contains("My &amp; Co &lt;2025&gt;"))
    }

    // MARK: - Equatable

    @Test("Channels with same generator are equal")
    func channelsWithSameGeneratorAreEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", generator: "Gen")
        let channel2 = Channel(title: "T", link: url, description: "D", generator: "Gen")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different generators are not equal")
    func channelsWithDifferentGeneratorsAreNotEqual() {
        let url = makeURL("https://example.com")
        let channel1 = Channel(title: "T", link: url, description: "D", generator: "Gen1")
        let channel2 = Channel(title: "T", link: url, description: "D", generator: "Gen2")
        #expect(channel1 != channel2)
    }
}
