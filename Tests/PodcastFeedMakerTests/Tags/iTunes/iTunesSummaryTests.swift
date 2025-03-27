import Foundation
@testable import PodcastFeedMaker
import Testing

struct iTunesSummaryTests {

    @Test
    func test_xmlRepresentation_plainText_shouldBeEscaped() throws {
        let tag = Namespace.iTunes.Summary(content: "Swift & SwiftUI ©")
        let expected = "\t<itunes:summary>Swift &amp; SwiftUI &#xA9;</itunes:summary>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_xmlRepresentation_html_shouldBeWrappedInCDATA() throws {
        let htmlContent = "<p><strong>SwiftUI</strong> explained</p>"
        let tag = Namespace.iTunes.Summary(content: htmlContent, type: .html)

        let expected = "\t<itunes:summary><![CDATA[<p><strong>SwiftUI</strong> explained</p>]]></itunes:summary>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_summary_emptyContent_textType() throws {
        let tag = Namespace.iTunes.Summary(content: "")
        let expected = "\t<itunes:summary></itunes:summary>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_summary_emptyContent_htmlType() throws {
        let tag = Namespace.iTunes.Summary(content: "", type: .html)
        let expected = "\t<itunes:summary><![CDATA[]]></itunes:summary>"
        let result = try tag.xmlRepresentation()
        #expect(result == expected)
    }

    @Test
    func test_summary_equatable_and_hashable() {
        let a = Namespace.iTunes.Summary(content: "A")
        let b = Namespace.iTunes.Summary(content: "A")
        let c = Namespace.iTunes.Summary(content: "A", type: .html)

        #expect(a == b)
        #expect(a != c)

        let set: Set = [a, c]
        #expect(set.contains(b))
        #expect(set.contains(c))
    }
}
