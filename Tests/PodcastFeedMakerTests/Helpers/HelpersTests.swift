import Foundation
@testable import PodcastFeedMaker
import Testing

struct HelpersTests {
    @Test
    func testBooleanFormatted() async throws {
        #expect(true.stringValue == "yes")
        #expect(false.stringValue == "no")
    }

    @Test
    func testCleanSpecialChars() async throws {
        let original = #"My “quote” & <html> > test ™ is ©"#
        let expected = #"My &quot;quote&quot; &amp; &lt;html&gt; &gt; test &#x2122; is &#xA9;"#
        #expect(original.cleanSpecialChars() == expected)
    }

    @Test
    func testRcfPubDateFormat() async throws {
        let components = DateComponents(
            timeZone: .init(identifier: "Europe/Paris"),
            year: 2025,
            month: 3,
            day: 18,
            hour: 20,
            minute: 20,
            second: 15
        )

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: -2 * 60 * 60)!
        calendar.locale = Locale(identifier: "en_US")
        
        let date = try #require(calendar.date(from: components))
        #expect(date.rcfPubDate == "Tue, 18 Mar 2025 19:20:15 +0000")
    }

    @Test
    func testIndentedTagsRepresentation() async throws {
        let tags: [RSSTag.Title] = [
            .init("Hello"),
            .init("World")
        ]
        let indented = try tags.map { try $0.xmlRepresentation() }.indentedTagsRepresentation
        #expect(indented.contains("\t<title>Hello</title>"))
        #expect(indented.contains("\t<title>World</title>"))
    }

    @Test
    func testDoubleIndentedTagsRepresentation() async throws {
        let tags: [RSSTag.Title] = [
            .init("John"),
            .init("Tech")
        ]
        let doubleIndented = try tags.map { try $0.xmlRepresentation() }.doubleIndentedTagsRepresentation
        #expect(doubleIndented.contains("\t\t<title>John</title>"))
        #expect(doubleIndented.contains("\t\t<title>Tech</title>"))
    }

    @Test
    func testIsValidURL() async throws {
        try #expect(URL(string: "https://swift.org")!.isValid() == true)

        #expect(performing: {
            try URL(string: "ftp://invalid-url")!.isValid()
        }, throws: { error in
            error as? URL.URLValidatorError == .invalidScheme
            && error.localizedDescription.contains("Scheme must be either `http` or `https`.")
        })

        #expect(performing: {
            try URL(string: "not-a-url")!.isValid()
        }, throws: { error in
            error as? URL.URLValidatorError == .schemeNotFound
            && error.localizedDescription.contains("Scheme not found.")
        })
        
        #expect(performing: {
            try URL(string: "file://file_path")!.isValid()
        }, throws: { error in
            error as? URL.URLValidatorError == .isFileURL
            && error.localizedDescription.contains("URL is `file://`.")
        })
        
        #expect(performing: {
            try URL(string: "https://example.com/path/to/resource/with/a/very/long/structure/that/keeps/going/on/and/on/until/it/reaches/a/very/significant/length/that/should/exceed/the/common/url/length/limit/of/255/characters/for/testing?param1=value1&param2=value2&param3=value3&param4=value4")!.isValid()
        }, throws: { error in
            error as? URL.URLValidatorError == .maxLength
            && error.localizedDescription.contains("URL is too long, max length is 255 characters.")
        })
    }

    @Test
    func testEncodeURLQueryAllowed() async throws {
        let input = URL(string: "https://swift.org/search?query=école+swift&lang=fr")!
        let encoded = input.encodeURLQueryAllowed
        #expect(encoded.contains("query=%C3%A9cole+swift"))
        #expect(encoded.contains("lang=fr"))
    }

    @Test
    func test_encodeURLQueryAllowed_returnsEscapedStringOrFallback() {
        let url = URL(string: "https://example.com/query?param=ç©🎉")!

        let encoded = url.encodeURLQueryAllowed

        #expect(encoded.starts(with: "https://example.com"))
    }
}
