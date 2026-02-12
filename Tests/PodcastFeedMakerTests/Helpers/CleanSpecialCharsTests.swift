import Foundation
@testable import PodcastFeedMaker
import Testing

struct CleanSpecialCharsTests {

    @Test
    func test_escape_shouldReplaceStandardXMLChars() {
        let input = "\"Test\" & \"Quotes\" <Tags> > Out &copy; © ™ ℗ \u{2019}"
        let expected = """
        &quot;Test&quot; &amp; &quot;Quotes&quot; &lt;Tags&gt; &gt; Out &#xA9; &#xA9; &#x2122; &#x2117; &apos;
        """
        let result = XMLBuilder.escape(input)
        #expect(result == expected)
    }

    @Test
    func test_escape_shouldHandleEdgeCases() {
        let input = "Simple text without special characters"
        let result = XMLBuilder.escape(input)
        #expect(result == input)
    }

    @Test
    func test_escape_shouldEscapeMixedSymbols() {
        let input = "Nested <div>Text &copy;</div>"
        let expected = "Nested &lt;div&gt;Text &#xA9;&lt;/div&gt;"
        let result = XMLBuilder.escape(input)
        #expect(result == expected)
    }
}
