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

// MARK: - EnclosureTests

/// Tests for the ``Enclosure`` struct.
///
/// `Enclosure` has `url: URL`, `length: Int`, `type: String`, plus
/// a convenience initializer accepting ``Enclosure.MIMEType``.
/// Conforms to `Sendable`, `Hashable`, `Equatable`, and `Codable`.
@Suite("Enclosure Struct Tests")
struct EnclosureTests {

    // MARK: - Initialization (String type)

    @Test("Enclosure can be initialized with string type")
    func enclosureInitWithStringType() {
        let url = makeURL("https://example.com/audio.mp3")
        let enclosure = Enclosure(url: url, length: 12345, type: "audio/mpeg")

        #expect(enclosure.url == url)
        #expect(enclosure.length == 12345)
        #expect(enclosure.type == "audio/mpeg")
    }

    // MARK: - Initialization (MIMEType)

    @Test("Enclosure can be initialized with MIMEType enum")
    func enclosureInitWithMimeType() {
        let url = makeURL("https://example.com/audio.mp3")
        let enclosure = Enclosure(url: url, length: 12345, mimeType: .mpeg)

        #expect(enclosure.url == url)
        #expect(enclosure.length == 12345)
        #expect(enclosure.type == "audio/mpeg")
    }

    @Test("Enclosure MIMEType convenience init sets correct type string")
    func enclosureMimeTypeConvenience() {
        let url = makeURL("https://example.com/audio.m4a")
        let enclosure = Enclosure(url: url, length: 9999, mimeType: .m4a)
        #expect(enclosure.type == "audio/m4a")
    }

    // MARK: - MIMEType Raw Values

    @Test("MIMEType raw values are correct")
    func mimeTypeRawValues() {
        #expect(Enclosure.MIMEType.aac.rawValue == "audio/aac")
        #expect(Enclosure.MIMEType.m4a.rawValue == "audio/m4a")
        #expect(Enclosure.MIMEType.mpeg.rawValue == "audio/mpeg")
        #expect(Enclosure.MIMEType.ogg.rawValue == "audio/ogg")
        #expect(Enclosure.MIMEType.opus.rawValue == "audio/opus")
        #expect(Enclosure.MIMEType.wav.rawValue == "audio/wav")
        #expect(Enclosure.MIMEType.flac.rawValue == "audio/flac")
        #expect(Enclosure.MIMEType.quicktime.rawValue == "video/quicktime")
        #expect(Enclosure.MIMEType.mp4.rawValue == "video/mp4")
        #expect(Enclosure.MIMEType.m4v.rawValue == "video/m4v")
        #expect(Enclosure.MIMEType.pdf.rawValue == "application/pdf")
    }

    @Test("MIMEType has all expected cases")
    func mimeTypeAllCases() {
        #expect(Enclosure.MIMEType.allCases.count == 24)
    }

    // MARK: - Properties

    @Test("Enclosure properties are mutable")
    func enclosurePropertiesAreMutable() {
        let oldURL = makeURL("https://example.com/old.mp3")
        var enclosure = Enclosure(
            url: oldURL,
            length: 100,
            type: "audio/mpeg"
        )

        let newURL = makeURL("https://example.com/new.mp3")
        enclosure.url = newURL
        enclosure.length = 200
        enclosure.type = "audio/m4a"

        #expect(enclosure.url == newURL)
        #expect(enclosure.length == 200)
        #expect(enclosure.type == "audio/m4a")
    }

    // MARK: - XML Generation

    @Test("Enclosure generates expected XML via XMLBuilder")
    func enclosureXmlRepresentation() {
        let url = makeURL("https://example.com/audio.m4a")
        let enclosure = Enclosure(url: url, length: 9999, mimeType: .m4a)
        let xml = XMLBuilder().selfClosingElement(
            "enclosure",
            attributes: [
                ("url", XMLBuilder.encodeURL(enclosure.url)),
                ("length", "\(enclosure.length)"),
                ("type", "\(enclosure.type)")
            ]
        )

        #expect(xml.contains(#"<enclosure url="https://example.com/audio.m4a""#))
        #expect(xml.contains(#"length="9999""#))
        #expect(xml.contains(#"type="audio/m4a""#))
        #expect(xml.contains("/>"))
    }

    @Test("Enclosure XMLBuilder handles file URL gracefully")
    func enclosureXmlHandlesFileUrl() {
        let fileURL = makeURL("file:///tmp/audio.mp3")
        let enclosure = Enclosure(url: fileURL, length: 1000, type: "audio/mpeg")
        // Generation encodes the URL as-is; validation is handled by FeedValidator
        let xml = XMLBuilder().selfClosingElement(
            "enclosure",
            attributes: [
                ("url", XMLBuilder.encodeURL(enclosure.url)),
                ("length", "\(enclosure.length)"),
                ("type", "\(enclosure.type)")
            ]
        )
        #expect(xml.contains("enclosure"))
    }

    // MARK: - Item Integration

    @Test("Item can hold an Enclosure")
    func itemCanHoldEnclosure() {
        let url = makeURL("https://example.com/ep1.mp3")
        let enclosure = Enclosure(
            url: url,
            length: 50000,
            mimeType: .mpeg
        )
        let item = Item(enclosure: enclosure)
        #expect(item.enclosure?.url == url)
        #expect(item.enclosure?.length == 50000)
        #expect(item.enclosure?.type == "audio/mpeg")
    }

    @Test("Item XML contains enclosure tag when set")
    func itemXmlContainsEnclosure() {
        let url = makeURL("https://example.com/ep1.mp3")
        let enclosure = Enclosure(
            url: url,
            length: 50000,
            mimeType: .mpeg
        )
        let item = Item(enclosure: enclosure)
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(xml.contains("<enclosure url="))
    }

    @Test("Item XML omits enclosure tag when nil")
    func itemXmlOmitsEnclosureWhenNil() {
        let item = Item()
        let xml = FeedGenerator().generateItem(item, builder: XMLBuilder(depth: 1)).joined(separator: "\n")
        #expect(!xml.contains("<enclosure"))
    }

    // MARK: - Equatable

    @Test("Enclosures with same properties are equal")
    func enclosuresEqual() {
        let url = makeURL("https://example.com/a.mp3")
        let enc1 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        #expect(enc1 == enc2)
    }

    @Test("Enclosures with different URLs are not equal")
    func enclosuresDifferentUrls() {
        let urlA = makeURL("https://a.com/a.mp3")
        let urlB = makeURL("https://b.com/b.mp3")
        let enc1 = Enclosure(url: urlA, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: urlB, length: 100, type: "audio/mpeg")
        #expect(enc1 != enc2)
    }

    @Test("Enclosures with different lengths are not equal")
    func enclosuresDifferentLengths() {
        let url = makeURL("https://example.com/a.mp3")
        let enc1 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: url, length: 200, type: "audio/mpeg")
        #expect(enc1 != enc2)
    }

    @Test("Enclosures with different types are not equal")
    func enclosuresDifferentTypes() {
        let url = makeURL("https://example.com/a.mp3")
        let enc1 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: url, length: 100, type: "audio/m4a")
        #expect(enc1 != enc2)
    }

    // MARK: - Hashable

    @Test("Enclosure is Hashable")
    func enclosureHashable() {
        let url = makeURL("https://example.com/a.mp3")
        let enclosure = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let set: Set = [enclosure]
        #expect(set.contains(Enclosure(url: url, length: 100, type: "audio/mpeg")))
    }

    // MARK: - Codable

    @Test("Enclosure can be encoded and decoded via JSON")
    func enclosureCodable() throws {
        let url = makeURL("https://example.com/ep.mp3")
        let enclosure = Enclosure(
            url: url,
            length: 12345,
            mimeType: .mpeg
        )
        let data = try JSONEncoder().encode(enclosure)
        let decoded = try JSONDecoder().decode(Enclosure.self, from: data)
        #expect(decoded == enclosure)
    }
}
