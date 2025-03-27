import Foundation
@testable import PodcastFeedMaker
import Testing

struct CleanSpecialCharsTests {

    @Test
    func test_cleanSpecialChars_shouldReplaceStandardXMLChars() {
        let input = "\"Test\" & \"Quotes\" <Tags> > Out &copy; © ™ ℗ ’"
        let expected = """
        &quot;Test&quot; &amp; &quot;Quotes&quot; &lt;Tags&gt; &gt; Out &#xA9; &#xA9; &#x2122; &#x2117; &apos;
        """
        let result = input.cleanSpecialChars()
        #expect(result == expected)
    }

    @Test
    func test_cleanSpecialChars_shouldHandleEdgeCases() {
        let input = "Simple text without special characters"
        let result = input.cleanSpecialChars()
        #expect(result == input)
    }

    @Test
    func test_cleanSpecialChars_shouldEscapeMixedSymbols() {
        let input = "Nested <div>Text &copy;</div>"
        let expected = "Nested &lt;div&gt;Text &#xA9;&lt;/div&gt;"
        let result = input.cleanSpecialChars()
        #expect(result == expected)
    }
}
