import Foundation
@testable import PodcastFeedMaker
import Testing

struct DescriptionTests {

    @Test
    func test_textDescription_escapesSpecialCharacters() throws {
        let raw = #"This is a <b>great</b> & useful "podcast""#
        let tag = RSSTag.Description(raw, type: .text)

        let expected = "\t<description>This is a &lt;b&gt;great&lt;/b&gt; &amp; useful &quot;podcast&quot;</description>"
        let result = try tag.xmlRepresentation()

        #expect(result == expected)
    }

    @Test
    func test_htmlDescription_isWrappedInCDATA() throws {
        let html = #"<p>This is <em>formatted</em> text.</p>"#
        let tag = RSSTag.Description(html, type: .html)

        let expected = "\t<description><![CDATA[<p>This is <em>formatted</em> text.</p>]]></description>"
        let result = try tag.xmlRepresentation()

        #expect(result == expected)
    }

    @Test
    func test_equatableAndHashable() {
        let a = RSSTag.Description("Text", type: .text)
        let b = RSSTag.Description("Text", type: .text)
        let c = RSSTag.Description("Different", type: .text)
        let d = RSSTag.Description("Text", type: .html)

        #expect(a == b)
        #expect(a != c)
        #expect(a != d)

        let set: Set<RSSTag.Description> = [a, b, c, d]
        #expect(set.count == 3)
    }
}
