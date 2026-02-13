import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Escaping Tests

struct XMLBuilderEscapeTests {

    @Test("Escapes ampersand")
    func escapeAmpersand() {
        #expect(XMLBuilder.escape("Tom & Jerry") == "Tom &amp; Jerry")
    }

    @Test("Escapes less-than")
    func escapeLessThan() {
        #expect(XMLBuilder.escape("a < b") == "a &lt; b")
    }

    @Test("Escapes greater-than")
    func escapeGreaterThan() {
        #expect(XMLBuilder.escape("a > b") == "a &gt; b")
    }

    @Test("Escapes double quotes")
    func escapeDoubleQuotes() {
        #expect(XMLBuilder.escape(#"say "hello""#) == "say &quot;hello&quot;")
    }

    @Test("Escapes right single quote to apos")
    func escapeRightSingleQuote() {
        #expect(XMLBuilder.escape("it\u{2019}s") == "it&apos;s")
    }

    @Test("Escapes copyright symbol")
    func escapeCopyright() {
        #expect(XMLBuilder.escape("© 2025") == "&#xA9; 2025")
    }

    @Test("Escapes trademark symbol")
    func escapeTrademark() {
        #expect(XMLBuilder.escape("Brand™") == "Brand&#x2122;")
    }

    @Test("Escapes sound recording copyright symbol")
    func escapeSoundRecording() {
        #expect(XMLBuilder.escape("℗ 2025") == "&#x2117; 2025")
    }

    @Test("Escapes left and right smart quotes")
    func escapeSmartQuotes() {
        #expect(XMLBuilder.escape("\u{201C}hello\u{201D}") == "&quot;hello&quot;")
    }

    @Test("Mixed special characters")
    func escapeMixed() {
        let input = #"My "quote" & <html> > test ™ is ©"#
        let expected = #"My &quot;quote&quot; &amp; &lt;html&gt; &gt; test &#x2122; is &#xA9;"#
        #expect(XMLBuilder.escape(input) == expected)
    }

    @Test("Does not double-escape existing entities")
    func noDoubleEscape() {
        #expect(XMLBuilder.escape("&amp;") == "&amp;")
        #expect(XMLBuilder.escape("&lt;") == "&lt;")
        #expect(XMLBuilder.escape("&gt;") == "&gt;")
        #expect(XMLBuilder.escape("&quot;") == "&quot;")
        #expect(XMLBuilder.escape("&apos;") == "&apos;")
        #expect(XMLBuilder.escape("&#xA9;") == "&#xA9;")
        #expect(XMLBuilder.escape("&#x2122;") == "&#x2122;")
    }

    @Test("Empty string returns empty")
    func escapeEmpty() {
        #expect(XMLBuilder.escape("") == "")
    }

    @Test("Plain text passes through unchanged")
    func escapePlainText() {
        let plain = "Simple text without special characters"
        #expect(XMLBuilder.escape(plain) == plain)
    }

    @Test("Nested HTML-like content escapes correctly")
    func escapeNestedHTML() {
        let input = "Nested <div>Text &copy;</div>"
        let expected = "Nested &lt;div&gt;Text &#xA9;&lt;/div&gt;"
        #expect(XMLBuilder.escape(input) == expected)
    }

    @Test("Standard XML chars with mixed entities")
    func escapeStandardXMLWithEntities() {
        let input = "\"Test\" & \"Quotes\" <Tags> > Out &copy; © ™ ℗ \u{2019}"
        let expected = "&quot;Test&quot; &amp; &quot;Quotes&quot; &lt;Tags&gt; &gt; Out &#xA9; &#xA9; &#x2122; &#x2117; &apos;"
        #expect(XMLBuilder.escape(input) == expected)
    }
}

// MARK: - CDATA Tests

struct XMLBuilderCDATATests {

    @Test("containsHTML detects angle brackets")
    func containsHTMLDetection() {
        #expect(XMLBuilder.containsHTML("<p>Hello</p>") == true)
        #expect(XMLBuilder.containsHTML("a > b") == true)
        #expect(XMLBuilder.containsHTML("plain text") == false)
        #expect(XMLBuilder.containsHTML("") == false)
    }

    @Test("CDATA element wraps content")
    func cdataElement() {
        let builder = XMLBuilder()
        let result = builder.cdataElement("content:encoded", content: "<p>Hello</p>")
        #expect(result == "<content:encoded><![CDATA[<p>Hello</p>]]></content:encoded>")
    }

    @Test("Smart element uses CDATA for HTML")
    func smartElementHTML() {
        let builder = XMLBuilder()
        let result = builder.smartElement("description", content: "<p>Hello</p>")
        #expect(result == "<description><![CDATA[<p>Hello</p>]]></description>")
    }

    @Test("Smart element escapes plain text")
    func smartElementPlain() {
        let builder = XMLBuilder()
        let result = builder.smartElement("description", content: "Tom & Jerry")
        #expect(result == "<description>Tom &amp; Jerry</description>")
    }
}

// MARK: - Date Formatting Tests

struct XMLBuilderDateTests {

    @Test("RFC 2822 date format with known date")
    func rfc2822KnownDate() {
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1
        components.hour = 15
        components.minute = 30
        components.second = 45
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: components) else {
            Issue.record("Failed to create date")
            return
        }

        #expect(XMLBuilder.rfc2822Date(date) == "Mon, 01 Jan 2024 15:30:45 +0000")
    }

    @Test("RFC 2822 uses English locale")
    func rfc2822EnglishLocale() {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: "2025-03-26T18:00:00Z") else {
            Issue.record("Failed to create date")
            return
        }
        let result = XMLBuilder.rfc2822Date(date)
        #expect(result.starts(with: "Wed, 26 Mar 2025"))
    }

    @Test("RFC 2822 converts timezone to UTC")
    func rfc2822UTC() throws {
        let components = DateComponents(
            timeZone: TimeZone(identifier: "Europe/Paris"),
            year: 2025,
            month: 3,
            day: 18,
            hour: 20,
            minute: 20,
            second: 15
        )

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: -2 * 60 * 60) ?? .current
        calendar.locale = Locale(identifier: "en_US")

        let date = try #require(calendar.date(from: components))
        #expect(XMLBuilder.rfc2822Date(date) == "Tue, 18 Mar 2025 19:20:15 +0000")
    }

    @Test("ISO 8601 date format")
    func iso8601KnownDate() {
        var components = DateComponents()
        components.year = 2021
        components.month = 9
        components.day = 26
        components.hour = 7
        components.minute = 30
        components.second = 0
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar(identifier: .gregorian)
        guard let date = calendar.date(from: components) else {
            Issue.record("Failed to create date")
            return
        }

        #expect(XMLBuilder.iso8601Date(date) == "2021-09-26T07:30:00Z")
    }
}

// MARK: - Boolean Formatting Tests

struct XMLBuilderBoolTests {

    @Test("boolYesNo true returns yes")
    func boolYesNoTrue() {
        #expect(XMLBuilder.boolYesNo(true) == "yes")
    }

    @Test("boolYesNo false returns no")
    func boolYesNoFalse() {
        #expect(XMLBuilder.boolYesNo(false) == "no")
    }

    @Test("boolTrueFalse true returns true")
    func boolTrueFalseTrue() {
        #expect(XMLBuilder.boolTrueFalse(true) == "true")
    }

    @Test("boolTrueFalse false returns false")
    func boolTrueFalseFalse() {
        #expect(XMLBuilder.boolTrueFalse(false) == "false")
    }
}

// MARK: - URL Tests

struct XMLBuilderURLTests {

    @Test("encodeURL encodes special characters")
    func encodeURLBasic() {
        let url = makeURL("https://swift.org/search?query=école+swift&lang=fr")
        let encoded = XMLBuilder.encodeURL(url)
        #expect(encoded.contains("query=%C3%A9cole+swift"))
        #expect(encoded.contains("lang=fr"))
    }

    @Test("encodeURL returns string or fallback")
    func encodeURLFallback() {
        let url = makeURL("https://example.com/query?param=ç©🎉")
        let encoded = XMLBuilder.encodeURL(url)
        #expect(encoded.starts(with: "https://example.com"))
    }

    @Test("validateURL accepts valid HTTPS")
    func validateURLValid() throws {
        let url = makeURL("https://swift.org")
        try XMLBuilder.validateURL(url, context: "test")
    }

    @Test("validateURL rejects file URL")
    func validateURLFile() throws {
        let url = makeURL("file://path")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(url, context: "test")
        }
    }

    @Test("validateURL rejects invalid scheme")
    func validateURLScheme() throws {
        let url = makeURL("ftp://example.com")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(url, context: "test")
        }
    }

    @Test("validateURL throws for URL without host")
    func validateURLNoHost() throws {
        let url = makeURL("https:///path")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(url, context: "test")
        }
    }
}

// MARK: - Element Building Tests

struct XMLBuilderElementTests {

    @Test("Simple element with content")
    func simpleElement() {
        let builder = XMLBuilder()
        let xml = builder.element("title", content: "My Podcast")
        #expect(xml == "<title>My Podcast</title>")
    }

    @Test("Element with attributes")
    func elementWithAttributes() {
        let builder = XMLBuilder()
        let xml = builder.element("link", content: "text", attributes: [("rel", "self"), ("type", "rss")])
        #expect(xml == #"<link rel="self" type="rss">text</link>"#)
    }

    @Test("Self-closing element")
    func selfClosingElement() {
        let builder = XMLBuilder()
        let xml = builder.selfClosingElement("enclosure", attributes: [("url", "https://example.com"), ("type", "audio/mpeg")])
        #expect(xml == #"<enclosure url="https://example.com" type="audio/mpeg" />"#)
    }

    @Test("Element with body")
    func elementWithBody() {
        let builder = XMLBuilder()
        let inner = builder.indented()
        let child1 = inner.element("name", content: "Jane")
        let child2 = inner.element("email", content: "jane@example.com")
        let xml = builder.element("owner", body: "\(child1)\n\(child2)")
        #expect(xml.contains("<owner>"))
        #expect(xml.contains("\t<name>Jane</name>"))
        #expect(xml.contains("\t<email>jane@example.com</email>"))
        #expect(xml.contains("</owner>"))
    }

    @Test("Open and close tags")
    func openCloseTag() {
        let builder = XMLBuilder()
        #expect(builder.openTag("channel") == "<channel>")
        #expect(builder.closeTag("channel") == "</channel>")
    }

    @Test("Open tag with attributes")
    func openTagWithAttributes() {
        let builder = XMLBuilder()
        let xml = builder.openTag("rss", attributes: [("version", "2.0")])
        #expect(xml == #"<rss version="2.0">"#)
    }

    @Test("Element escapes content")
    func elementEscapesContent() {
        let builder = XMLBuilder()
        let xml = builder.element("title", content: "Tom & Jerry")
        #expect(xml == "<title>Tom &amp; Jerry</title>")
    }
}

// MARK: - Indentation Tests

struct XMLBuilderIndentTests {

    @Test("Depth 0 has no indentation")
    func depth0() {
        let builder = XMLBuilder()
        #expect(builder.indent == "")
        #expect(builder.depth == 0)
    }

    @Test("Depth 1 has single tab")
    func depth1() {
        let builder = XMLBuilder().indented()
        #expect(builder.indent == "\t")
        #expect(builder.depth == 1)
    }

    @Test("Depth 2 has double tab")
    func depth2() {
        let builder = XMLBuilder().indented().indented()
        #expect(builder.indent == "\t\t")
        #expect(builder.depth == 2)
    }

    @Test("Custom indent string")
    func customIndent() {
        let builder = XMLBuilder(indentString: "  ", depth: 2)
        #expect(builder.indent == "    ")
    }

    @Test("Minified output with empty indent string")
    func minified() {
        let builder = XMLBuilder(indentString: "", depth: 3)
        #expect(builder.indent == "")
        let xml = builder.element("title", content: "test")
        #expect(xml == "<title>test</title>")
    }

    @Test("Indented element includes prefix")
    func indentedElement() {
        let builder = XMLBuilder().indented()
        let xml = builder.element("title", content: "test")
        #expect(xml == "\t<title>test</title>")
    }
}

// MARK: - Attribute Formatting Tests

struct XMLBuilderAttributeTests {

    @Test("Empty attributes returns empty string")
    func emptyAttributes() {
        #expect(XMLBuilder.formatAttributes([]) == "")
    }

    @Test("Single attribute")
    func singleAttribute() {
        #expect(XMLBuilder.formatAttributes([("href", "https://example.com")]) == #" href="https://example.com""#)
    }

    @Test("Multiple attributes")
    func multipleAttributes() {
        let attrs: [(String, String)] = [("type", "audio/mpeg"), ("length", "12345")]
        let result = XMLBuilder.formatAttributes(attrs)
        #expect(result == #" type="audio/mpeg" length="12345""#)
    }
}
