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

// MARK: - GuidTests

/// Tests for the ``GUID`` struct.
///
/// In the new model, `GUID` is a standalone struct with `value: String`
/// and `isPermaLink: Bool` (default `true`). It conforms to
/// `Sendable`, `Hashable`, `Equatable`, and `Codable`.
@Suite("GUID Struct Tests")
struct GuidTests {

    // MARK: - Initialization

    @Test("GUID can be initialized with value and default isPermaLink")
    func guidInitWithDefaults() {
        let guid = GUID(value: "https://example.com/ep1")
        #expect(guid.value == "https://example.com/ep1")
        #expect(guid.isPermaLink == true)
    }

    @Test("GUID default isPermaLink is true")
    func guidDefaultIsPermaLinkIsTrue() {
        let guid = GUID(value: "some-id")
        #expect(guid.isPermaLink == true)
    }

    @Test("GUID can be initialized with isPermaLink set to false")
    func guidInitWithIsPermaLinkFalse() {
        let guid = GUID(value: "ep001-unique-id", isPermaLink: false)
        #expect(guid.value == "ep001-unique-id")
        #expect(guid.isPermaLink == false)
    }

    @Test("GUID properties are mutable")
    func guidPropertiesAreMutable() {
        var guid = GUID(value: "old-id", isPermaLink: false)
        guid.value = "new-id"
        guid.isPermaLink = true
        #expect(guid.value == "new-id")
        #expect(guid.isPermaLink == true)
    }

    // MARK: - XML Generation

    @Test("GUID generates XML with isPermaLink false")
    func guidXmlWithPermaLinkFalse() {
        let guid = GUID(value: "ep001", isPermaLink: false)
        let xml = XMLBuilder().element("guid", content: guid.value, attributes: [("isPermaLink", "\(guid.isPermaLink)")])
        #expect(xml == #"<guid isPermaLink="false">ep001</guid>"#)
    }

    @Test("GUID generates XML with isPermaLink true")
    func guidXmlWithPermaLinkTrue() {
        let guid = GUID(value: "https://example.com/ep1", isPermaLink: true)
        let xml = XMLBuilder().element("guid", content: guid.value, attributes: [("isPermaLink", "\(guid.isPermaLink)")])
        #expect(xml == #"<guid isPermaLink="true">https://example.com/ep1</guid>"#)
    }

    @Test("GUID generates XML with default isPermaLink")
    func guidXmlWithDefaultPermaLink() {
        let guid = GUID(value: "unique-123")
        let xml = XMLBuilder().element("guid", content: guid.value, attributes: [("isPermaLink", "\(guid.isPermaLink)")])
        #expect(xml.contains(#"isPermaLink="true""#))
        #expect(xml.contains("unique-123"))
    }

    // MARK: - Item Integration

    @Test("Item can hold a GUID")
    func itemCanHoldGuid() {
        let guid = GUID(value: "ep-42", isPermaLink: false)
        let item = Item(guid: guid)
        #expect(item.guid?.value == "ep-42")
        #expect(item.guid?.isPermaLink == false)
    }

    @Test("Item XML contains guid tag when set")
    func itemXmlContainsGuid() {
        let item = Item(guid: GUID(value: "ep-42", isPermaLink: false))
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains(#"<guid isPermaLink="false">ep-42</guid>"#))
    }

    @Test("Item XML omits guid tag when nil")
    func itemXmlOmitsGuidWhenNil() {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(!xml.contains("<guid"))
    }

    // MARK: - Equatable

    @Test("GUIDs with same value and isPermaLink are equal")
    func guidsEqual() {
        let guid1 = GUID(value: "id", isPermaLink: false)
        let guid2 = GUID(value: "id", isPermaLink: false)
        #expect(guid1 == guid2)
    }

    @Test("GUIDs with different values are not equal")
    func guidsDifferentValues() {
        let guid1 = GUID(value: "id1")
        let guid2 = GUID(value: "id2")
        #expect(guid1 != guid2)
    }

    @Test("GUIDs with different isPermaLink are not equal")
    func guidsDifferentPermaLink() {
        let guid1 = GUID(value: "id", isPermaLink: true)
        let guid2 = GUID(value: "id", isPermaLink: false)
        #expect(guid1 != guid2)
    }

    // MARK: - Hashable

    @Test("GUID is Hashable")
    func guidHashable() {
        let guid = GUID(value: "unique", isPermaLink: false)
        let set: Set = [guid]
        #expect(set.contains(GUID(value: "unique", isPermaLink: false)))
        #expect(!set.contains(GUID(value: "unique", isPermaLink: true)))
    }

    // MARK: - Codable

    @Test("GUID can be encoded and decoded via JSON")
    func guidCodable() throws {
        let guid = GUID(value: "ep-99", isPermaLink: false)
        let data = try JSONEncoder().encode(guid)
        let decoded = try JSONDecoder().decode(GUID.self, from: data)
        #expect(decoded == guid)
    }
}
