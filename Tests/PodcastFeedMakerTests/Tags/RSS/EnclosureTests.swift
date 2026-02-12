import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - EnclosureTests

/// Tests for the ``Enclosure`` struct.
///
/// `Enclosure` has `url: URL`, `length: Int`, `type: String`, plus
/// a convenience initializer accepting ``Enclosure.MIMEType``.
/// Conforms to `Sendable`, `Hashable`, `Equatable`, `Codable`, and `XmlRepresentable`.
@Suite("Enclosure Struct Tests")
struct EnclosureTests {

    // MARK: - Initialization (String type)

    @Test("Enclosure can be initialized with string type")
    func enclosureInitWithStringType() {
        let url = URL(string: "https://example.com/audio.mp3")!
        let enclosure = Enclosure(url: url, length: 12345, type: "audio/mpeg")

        #expect(enclosure.url == url)
        #expect(enclosure.length == 12345)
        #expect(enclosure.type == "audio/mpeg")
    }

    // MARK: - Initialization (MIMEType)

    @Test("Enclosure can be initialized with MIMEType enum")
    func enclosureInitWithMimeType() {
        let url = URL(string: "https://example.com/audio.mp3")!
        let enclosure = Enclosure(url: url, length: 12345, mimeType: .mpeg)

        #expect(enclosure.url == url)
        #expect(enclosure.length == 12345)
        #expect(enclosure.type == "audio/mpeg")
    }

    @Test("Enclosure MIMEType convenience init sets correct type string")
    func enclosureMimeTypeConvenience() {
        let url = URL(string: "https://example.com/audio.m4a")!
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
        #expect(Enclosure.MIMEType.allCases.count == 11)
    }

    // MARK: - Properties

    @Test("Enclosure properties are mutable")
    func enclosurePropertiesAreMutable() {
        var enclosure = Enclosure(
            url: URL(string: "https://example.com/old.mp3")!,
            length: 100,
            type: "audio/mpeg"
        )

        enclosure.url = URL(string: "https://example.com/new.mp3")!
        enclosure.length = 200
        enclosure.type = "audio/m4a"

        #expect(enclosure.url == URL(string: "https://example.com/new.mp3")!)
        #expect(enclosure.length == 200)
        #expect(enclosure.type == "audio/m4a")
    }

    // MARK: - XML Generation

    @Test("Enclosure xmlRepresentation returns expected XML")
    func enclosureXmlRepresentation() throws {
        let url = URL(string: "https://example.com/audio.m4a")!
        let enclosure = Enclosure(url: url, length: 9999, mimeType: .m4a)
        let xml = try enclosure.xmlRepresentation()

        #expect(xml.contains(#"<enclosure url="https://example.com/audio.m4a""#))
        #expect(xml.contains(#"length="9999""#))
        #expect(xml.contains(#"type="audio/m4a""#))
        #expect(xml.contains("/>"))
    }

    @Test("Enclosure xmlRepresentation handles file URL gracefully")
    func enclosureXmlHandlesFileUrl() throws {
        let fileURL = URL(string: "file:///tmp/audio.mp3")!
        let enclosure = Enclosure(url: fileURL, length: 1000, type: "audio/mpeg")
        // Generation encodes the URL as-is; validation is handled by FeedValidator
        let xml = try enclosure.xmlRepresentation()
        #expect(xml.contains("enclosure"))
    }

    // MARK: - Item Integration

    @Test("Item can hold an Enclosure")
    func itemCanHoldEnclosure() {
        let enclosure = Enclosure(
            url: URL(string: "https://example.com/ep1.mp3")!,
            length: 50000,
            mimeType: .mpeg
        )
        let item = Item(enclosure: enclosure)
        #expect(item.enclosure?.url == URL(string: "https://example.com/ep1.mp3")!)
        #expect(item.enclosure?.length == 50000)
        #expect(item.enclosure?.type == "audio/mpeg")
    }

    @Test("Item XML contains enclosure tag when set")
    func itemXmlContainsEnclosure() throws {
        let enclosure = Enclosure(
            url: URL(string: "https://example.com/ep1.mp3")!,
            length: 50000,
            mimeType: .mpeg
        )
        let item = Item(enclosure: enclosure)
        let xml = try item.xmlRepresentation()
        #expect(xml.contains("<enclosure url="))
    }

    @Test("Item XML omits enclosure tag when nil")
    func itemXmlOmitsEnclosureWhenNil() throws {
        let item = Item()
        let xml = try item.xmlRepresentation()
        #expect(!xml.contains("<enclosure"))
    }

    // MARK: - Equatable

    @Test("Enclosures with same properties are equal")
    func enclosuresEqual() {
        let url = URL(string: "https://example.com/a.mp3")!
        let enc1 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        #expect(enc1 == enc2)
    }

    @Test("Enclosures with different URLs are not equal")
    func enclosuresDifferentUrls() {
        let enc1 = Enclosure(url: URL(string: "https://a.com/a.mp3")!, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: URL(string: "https://b.com/b.mp3")!, length: 100, type: "audio/mpeg")
        #expect(enc1 != enc2)
    }

    @Test("Enclosures with different lengths are not equal")
    func enclosuresDifferentLengths() {
        let url = URL(string: "https://example.com/a.mp3")!
        let enc1 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: url, length: 200, type: "audio/mpeg")
        #expect(enc1 != enc2)
    }

    @Test("Enclosures with different types are not equal")
    func enclosuresDifferentTypes() {
        let url = URL(string: "https://example.com/a.mp3")!
        let enc1 = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let enc2 = Enclosure(url: url, length: 100, type: "audio/m4a")
        #expect(enc1 != enc2)
    }

    // MARK: - Hashable

    @Test("Enclosure is Hashable")
    func enclosureHashable() {
        let url = URL(string: "https://example.com/a.mp3")!
        let enclosure = Enclosure(url: url, length: 100, type: "audio/mpeg")
        let set: Set = [enclosure]
        #expect(set.contains(Enclosure(url: url, length: 100, type: "audio/mpeg")))
    }

    // MARK: - Codable

    @Test("Enclosure can be encoded and decoded via JSON")
    func enclosureCodable() throws {
        let enclosure = Enclosure(
            url: URL(string: "https://example.com/ep.mp3")!,
            length: 12345,
            mimeType: .mpeg
        )
        let data = try JSONEncoder().encode(enclosure)
        let decoded = try JSONDecoder().decode(Enclosure.self, from: data)
        #expect(decoded == enclosure)
    }
}
