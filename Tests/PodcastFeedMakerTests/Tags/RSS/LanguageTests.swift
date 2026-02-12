import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - LanguageTests

/// Tests for the `language` property on ``Channel``.
///
/// In the new model, `Channel.language` is an optional `String?`.
/// The old `RSSTag.Language` wrapper with `Locale.LanguageCode` has been
/// replaced by a simple string property.
@Suite("RSS Language Property Tests")
struct LanguageTests {

    // MARK: - Initialization

    @Test("Channel language defaults to nil")
    func channelLanguageDefaultsToNil() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        #expect(channel.language == nil)
    }

    @Test("Channel language can be set at initialization")
    func channelLanguageCanBeSet() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "en-us"
        )

        #expect(channel.language == "en-us")
    }

    @Test("Channel language is mutable")
    func channelLanguageIsMutable() {
        var channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "en-us"
        )

        channel.language = "fr"
        #expect(channel.language == "fr")
    }

    @Test("Channel language accepts BCP 47 language tags")
    func channelLanguageAcceptsBcp47() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "pt-BR"
        )

        #expect(channel.language == "pt-BR")
    }

    // MARK: - XML Generation

    @Test("Channel XML contains language tag when set")
    func channelXmlContainsLanguage() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "en-us"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<language>en-us</language>"))
    }

    @Test("Channel XML omits language tag when nil")
    func channelXmlOmitsLanguageWhenNil() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description"
        )

        let xml = try channel.xmlRepresentation()
        #expect(!xml.contains("<language>"))
    }

    @Test("Channel XML preserves language string as-is")
    func channelXmlPreservesLanguageString() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Description",
            language: "fr"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<language>fr</language>"))
    }

    // MARK: - Equatable

    @Test("Channels with same language are equal")
    func channelsWithSameLanguageAreEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D", language: "en")
        let channel2 = Channel(title: "T", link: url, description: "D", language: "en")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different languages are not equal")
    func channelsWithDifferentLanguagesAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "D", language: "en")
        let channel2 = Channel(title: "T", link: url, description: "D", language: "fr")
        #expect(channel1 != channel2)
    }
}
