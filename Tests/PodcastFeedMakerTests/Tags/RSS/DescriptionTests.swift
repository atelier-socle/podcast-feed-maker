import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - DescriptionTests

/// Tests for the `description` property on ``Channel`` and ``Item``.
///
/// In the new model, `Channel.description` is a required `String` and
/// `Item.description` is an optional `String?`. The old `DescriptionType`
/// enum has been removed.
@Suite("RSS Description Property Tests")
struct DescriptionTests {

    // MARK: - Channel Description

    @Test("Channel requires a description at initialization")
    func channelDescriptionIsRequired() {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "A great podcast about Swift"
        )

        #expect(channel.description == "A great podcast about Swift")
    }

    @Test("Channel description is mutable")
    func channelDescriptionIsMutable() {
        var channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "Original"
        )

        channel.description = "Updated description"
        #expect(channel.description == "Updated description")
    }

    @Test("Channel XML contains description tag")
    func channelXmlContainsDescription() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "This is my show"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("<description>This is my show</description>"))
    }

    @Test("Channel XML escapes special characters in description")
    func channelXmlEscapesSpecialCharsInDescription() throws {
        let channel = Channel(
            title: "Title",
            link: URL(string: "https://example.com")!,
            description: "This is a <b>great</b> & useful podcast"
        )

        let xml = try channel.xmlRepresentation()
        #expect(xml.contains("&lt;b&gt;great&lt;/b&gt;"))
        #expect(xml.contains("&amp; useful"))
    }

    // MARK: - Item Description

    @Test("Item description defaults to nil")
    func itemDescriptionDefaultsToNil() {
        let item = Item()
        #expect(item.description == nil)
    }

    @Test("Item description can be set at initialization")
    func itemDescriptionCanBeSet() {
        let item = Item(description: "Episode summary")
        #expect(item.description == "Episode summary")
    }

    @Test("Item description is mutable")
    func itemDescriptionIsMutable() {
        var item = Item(description: "Old summary")
        item.description = "New summary"
        #expect(item.description == "New summary")
    }

    @Test("Item XML contains description tag when set")
    func itemXmlContainsDescriptionWhenSet() throws {
        let item = Item(description: "Episode summary text")
        let xml = try item.xmlRepresentation()
        #expect(xml.contains("<description>Episode summary text</description>"))
    }

    @Test("Item XML omits description tag when nil")
    func itemXmlOmitsDescriptionWhenNil() throws {
        let item = Item()
        let xml = try item.xmlRepresentation()
        #expect(!xml.contains("<description>"))
    }

    @Test("Item XML escapes special characters in description")
    func itemXmlEscapesSpecialCharsInDescription() throws {
        let item = Item(description: "Swift & Objective-C <comparison>")
        let xml = try item.xmlRepresentation()
        #expect(xml.contains("Swift &amp; Objective-C &lt;comparison&gt;"))
    }

    // MARK: - Equatable

    @Test("Channels with same description are equal")
    func channelsWithSameDescriptionAreEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "Same")
        let channel2 = Channel(title: "T", link: url, description: "Same")
        #expect(channel1 == channel2)
    }

    @Test("Channels with different descriptions are not equal")
    func channelsWithDifferentDescriptionsAreNotEqual() {
        let url = URL(string: "https://example.com")!
        let channel1 = Channel(title: "T", link: url, description: "A")
        let channel2 = Channel(title: "T", link: url, description: "B")
        #expect(channel1 != channel2)
    }

    @Test("Items with same description are equal")
    func itemsWithSameDescriptionAreEqual() {
        let item1 = Item(description: "Summary")
        let item2 = Item(description: "Summary")
        #expect(item1 == item2)
    }

    @Test("Items with different descriptions are not equal")
    func itemsWithDifferentDescriptionsAreNotEqual() {
        let item1 = Item(description: "A")
        let item2 = Item(description: "B")
        #expect(item1 != item2)
    }
}
