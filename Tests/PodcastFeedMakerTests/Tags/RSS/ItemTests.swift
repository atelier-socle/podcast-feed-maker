// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - ItemTests

/// Tests for the ``Item`` struct — core RSS properties.
///
/// `Item` represents a single episode in a podcast feed with ~35 typed properties.
/// All properties are optional or default to empty arrays.
/// Conforms to `Sendable`, `Hashable`, and `Equatable`.
@Suite("Item — RSS Core")
struct ItemTests {

    // MARK: - Default Initialization

    @Test("Item can be initialized with no parameters")
    func itemInitWithNoParams() {
        let item = Item()

        #expect(item.title == nil)
        #expect(item.link == nil)
        #expect(item.description == nil)
        #expect(item.author == nil)
        #expect(item.categories.isEmpty)
        #expect(item.comments == nil)
        #expect(item.enclosure == nil)
        #expect(item.guid == nil)
        #expect(item.pubDate == nil)
        #expect(item.source == nil)
    }

    // MARK: - Initialization with Values

    @Test("Item can be initialized with RSS core properties")
    func itemInitWithRssCoreProperties() {
        let url = makeURL("https://example.com/ep1")
        let date = Date(timeIntervalSince1970: 1_000_000)
        let guid = GUID(value: "ep-001", isPermaLink: false)
        let enclosureURL = makeURL("https://example.com/ep1.mp3")
        let enclosure = Enclosure(
            url: enclosureURL,
            length: 50000,
            mimeType: .mpeg
        )

        let item = Item(
            title: "Episode 1",
            link: url,
            description: "First episode",
            author: "author@example.com",
            enclosure: enclosure,
            guid: guid,
            pubDate: date
        )

        #expect(item.title == "Episode 1")
        #expect(item.link == url)
        #expect(item.description == "First episode")
        #expect(item.author == "author@example.com")
        #expect(item.enclosure?.url == enclosureURL)
        #expect(item.enclosure?.length == 50000)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "ep-001")
        #expect(item.guid?.isPermaLink == false)
        #expect(item.pubDate == date)
    }

    @Test("Item can be initialized with title and enclosure using string MIME type")
    func itemInitWithStringMimeType() {
        let enclosureURL = makeURL("https://example.com/ep1.m4a")
        let enclosure = Enclosure(
            url: enclosureURL,
            length: 30000,
            type: "audio/m4a"
        )

        let item = Item(title: "Episode", enclosure: enclosure)

        #expect(item.enclosure?.type == "audio/m4a")
    }

    // MARK: - Mutability

    @Test("Item properties are mutable")
    func itemPropertiesAreMutable() {
        var item = Item()

        let linkURL = makeURL("https://example.com/ep1")
        item.title = "New Title"
        item.link = linkURL
        item.description = "Updated description"
        item.itunesDuration = 1800
        item.itunesEpisode = 5
        item.itunesEpisodeType = .bonus
        item.soundbites = [Soundbite(startTime: 0.0, duration: 10.0)]

        #expect(item.title == "New Title")
        #expect(item.link == linkURL)
        #expect(item.description == "Updated description")
        #expect(item.itunesDuration == 1800)
        #expect(item.itunesEpisode == 5)
        #expect(item.itunesEpisodeType == .bonus)
        #expect(item.soundbites.count == 1)
    }

    // MARK: - XML Generation

    @Test("Item XML wraps content in item tags")
    func itemXmlWrapsInItemTags() {
        let item = Item(title: "Episode 1")
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains("<item>"))
        #expect(xml.contains("</item>"))
    }

    @Test("Item XML contains RSS core tags when set")
    func itemXmlContainsRssCoreTags() {
        let linkURL = makeURL("https://example.com/ep1")
        let item = Item(
            title: "Episode 1",
            link: linkURL,
            description: "The first episode",
            author: "author@example.com"
        )

        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<title>Episode 1</title>"))
        #expect(xml.contains("<link>https://example.com/ep1</link>"))
        #expect(xml.contains("<description>The first episode</description>"))
        #expect(xml.contains("<author>author@example.com</author>"))
    }

    @Test("Item XML contains enclosure when set")
    func itemXmlContainsEnclosure() {
        let enclosureURL = makeURL("https://example.com/ep1.mp3")
        let enclosure = Enclosure(
            url: enclosureURL,
            length: 50000,
            mimeType: .mpeg
        )

        let item = Item(enclosure: enclosure)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains("<enclosure url="))
        #expect(xml.contains(#"url="https://example.com/ep1.mp3""#))
        #expect(xml.contains(#"length="50000""#))
        #expect(xml.contains(#"type="audio/mpeg""#))
    }

    @Test("Item XML contains guid when set")
    func itemXmlContainsGuid() {
        let guid = GUID(value: "ep-001", isPermaLink: false)
        let item = Item(guid: guid)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains(#"<guid isPermaLink="false">ep-001</guid>"#))
    }

    @Test("Item XML contains guid with isPermaLink true")
    func itemXmlContainsGuidPermaLink() {
        let guid = GUID(value: "https://example.com/ep1")
        let item = Item(guid: guid)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains(#"<guid isPermaLink="true">https://example.com/ep1</guid>"#))
    }

    @Test("Item XML omits all tags when no properties are set")
    func itemXmlOmitsAllTagsWhenEmpty() {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")

        #expect(xml.contains("<item>"))
        #expect(xml.contains("</item>"))
        #expect(!xml.contains("<title>"))
        #expect(!xml.contains("<link>"))
        #expect(!xml.contains("<description>"))
        #expect(!xml.contains("<enclosure"))
        #expect(!xml.contains("<guid"))
        #expect(!xml.contains("<itunes:"))
        #expect(!xml.contains("<podcast:transcript"))
        #expect(!xml.contains("<podcast:chapters"))
        #expect(!xml.contains("<podcast:soundbite"))
        #expect(!xml.contains("<content:encoded"))
    }

    // MARK: - Sendable

    @Test("Item is Sendable")
    func itemIsSendable() async {
        let item = Item(title: "Episode 1")
        let result = await Task { item.title }.value
        #expect(result == "Episode 1")
    }

    @Test("Item with complex properties is Sendable")
    func itemWithComplexPropertiesIsSendable() async {
        let enclosureURL = makeURL("https://example.com/ep.mp3")
        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure(url: enclosureURL, length: 100, mimeType: .mpeg),
            soundbites: [Soundbite(startTime: 0.0, duration: 10.0)]
        )
        let result = await Task { item.soundbites.count }.value
        #expect(result == 1)
    }

    // MARK: - Equatable

    @Test("Items with identical properties are equal")
    func itemsWithIdenticalPropertiesAreEqual() {
        let item1 = Item(title: "Ep1", description: "Desc")
        let item2 = Item(title: "Ep1", description: "Desc")
        #expect(item1 == item2)
    }

    @Test("Items with different properties are not equal")
    func itemsWithDifferentPropertiesAreNotEqual() {
        let item1 = Item(title: "Ep1")
        let item2 = Item(title: "Ep2")
        #expect(item1 != item2)
    }

    @Test("Empty items are equal")
    func emptyItemsAreEqual() {
        let item1 = Item()
        let item2 = Item()
        #expect(item1 == item2)
    }

    @Test("Items with different episode types are not equal")
    func itemsWithDifferentEpisodeTypesAreNotEqual() {
        let item1 = Item(itunesEpisodeType: .full)
        let item2 = Item(itunesEpisodeType: .trailer)
        #expect(item1 != item2)
    }

    // MARK: - Hashable

    @Test("Item is Hashable and can be stored in a Set")
    func itemHashable() {
        let item1 = Item(title: "A")
        let item2 = Item(title: "B")
        let set: Set = [item1, item2]
        #expect(set.count == 2)
    }

    @Test("Duplicate items collapse in a Set")
    func duplicateItemsCollapseInSet() {
        let item1 = Item(title: "Same")
        let item2 = Item(title: "Same")
        let set: Set = [item1, item2]
        #expect(set.count == 1)
    }

    // MARK: - Location Computed Setter

    @Test("Setting location to a value replaces locations array with single element")
    func locationSetterSetsValue() {
        var item = Item(title: "Geo Episode")
        let loc = PodcastLocation(name: "Paris", geo: "geo:48.8566,2.3522")
        item.location = loc
        #expect(item.locations.count == 1)
        #expect(item.locations[0].name == "Paris")
        #expect(item.locations[0].geo == "geo:48.8566,2.3522")
        #expect(item.location?.name == "Paris")
    }

    @Test("Setting location to nil clears locations array")
    func locationSetterClearsArray() {
        var item = Item(
            title: "Geo Episode",
            locations: [
                PodcastLocation(name: "Austin", rel: "creator"),
                PodcastLocation(name: "London", rel: "subject")
            ]
        )
        #expect(item.locations.count == 2)
        item.location = nil
        #expect(item.locations.isEmpty)
        #expect(item.location == nil)
    }

    @Test("Setting location replaces existing multi-location array")
    func locationSetterReplacesMultiple() {
        var item = Item(
            title: "Multi-Location",
            locations: [
                PodcastLocation(name: "Place A"),
                PodcastLocation(name: "Place B")
            ]
        )
        let newLoc = PodcastLocation(name: "Place C", country: "US")
        item.location = newLoc
        #expect(item.locations.count == 1)
        #expect(item.locations[0].name == "Place C")
        #expect(item.locations[0].country == "US")
    }

    @Test("Location getter returns first element of locations array")
    func locationGetterReturnsFirst() {
        let item = Item(
            locations: [
                PodcastLocation(name: "First"),
                PodcastLocation(name: "Second")
            ]
        )
        #expect(item.location?.name == "First")
    }

    @Test("Location getter returns nil for empty locations")
    func locationGetterReturnsNilForEmpty() {
        let item = Item()
        #expect(item.location == nil)
    }
}
