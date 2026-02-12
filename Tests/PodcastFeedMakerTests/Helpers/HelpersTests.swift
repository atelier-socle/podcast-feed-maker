import Foundation
@testable import PodcastFeedMaker
import Testing

struct HelpersTests {
    @Test
    func testBooleanYesNo() {
        #expect(XMLBuilder.boolYesNo(true) == "yes")
        #expect(XMLBuilder.boolYesNo(false) == "no")
    }

    @Test
    func testBooleanTrueFalse() {
        #expect(XMLBuilder.boolTrueFalse(true) == "true")
        #expect(XMLBuilder.boolTrueFalse(false) == "false")
    }

    @Test
    func testEscapeSpecialChars() {
        let original = #"My "quote" & <html> > test ™ is ©"#
        let expected = #"My &quot;quote&quot; &amp; &lt;html&gt; &gt; test &#x2122; is &#xA9;"#
        #expect(XMLBuilder.escape(original) == expected)
    }

    @Test
    func testRfc2822DateFormat() throws {
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
        #expect(XMLBuilder.rfc2822Date(date) == "Tue, 18 Mar 2025 19:20:15 +0000")
    }

    @Test
    func testValidateURL() throws {
        try XMLBuilder.validateURL(URL(string: "https://swift.org")!, context: "test")

        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(URL(string: "ftp://invalid-url")!, context: "test")
        }

        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(URL(string: "file://file_path")!, context: "test")
        }
    }

    @Test
    func testEncodeURL() {
        let input = URL(string: "https://swift.org/search?query=école+swift&lang=fr")!
        let encoded = XMLBuilder.encodeURL(input)
        #expect(encoded.contains("query=%C3%A9cole+swift"))
        #expect(encoded.contains("lang=fr"))
    }

    @Test
    func test_encodeURL_returnsEscapedStringOrFallback() {
        let url = URL(string: "https://example.com/query?param=ç©🎉")!
        let encoded = XMLBuilder.encodeURL(url)
        #expect(encoded.starts(with: "https://example.com"))
    }
}
