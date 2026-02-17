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
