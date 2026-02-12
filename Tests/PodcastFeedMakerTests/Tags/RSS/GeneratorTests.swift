import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - GeneratorTests

/// Tests for the `generator` property on ``Channel``.
///
/// In the new model, `Channel.generator` is an optional `String?`.
@Suite("RSS Generator Property Tests")
struct GeneratorTests {

    // MARK: - Initialization

    @Test("Channel generator defaults to nil")
    func channelGeneratorDefaultsToNil() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        #expect(channel.generator == nil)
    }

    @Test("Channel generator can be set at initialization")
    func channelGeneratorCanBeSet() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            generator: "PodcastFeedMaker 1.0"
        )

        #expect(channel.generator == "PodcastFeedMaker 1.0")
    }

    @Test("Channel generator is mutable")
    func channelGeneratorIsMutable() {
        var channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        channel.generator = "CustomGenerator 2.0"
        #expect(channel.generator == "CustomGenerator 2.0")
    }

    // MARK: - XML Generation

    @Test("Channel XML contains generator tag when set")
    func channelXmlContainsGenerator() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            generator: "PodcastFeedMaker 1.0"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<generator>PodcastFeedMaker 1.0</generator>"))
    }

    @Test("Channel XML omits generator tag when nil")
    func channelXmlOmitsGeneratorWhenNil() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
        #expect(!xml.contains("<generator>"))
    }

    @Test("Channel XML escapes special characters in generator")
    func channelXmlEscapesSpecialCharsInGenerator() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            generator: "My & Co <2025>"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("My &amp; Co &lt;2025&gt;"))
    }

    // MARK: - Equatable

    @Test("Channels with same generator are equal")
    func channelsWithSameGeneratorAreEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D", generator: "Gen")
        let channel2 = Channel(title: "T", link: url, description: "D", generator: "Gen")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different generators are not equal")
    func channelsWithDifferentGeneratorsAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D", generator: "Gen1")
        let channel2 = Channel(title: "T", link: url, description: "D", generator: "Gen2")
        #expect(channel1 != channel2)
    }
}
