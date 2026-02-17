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
        let tz = try #require(TimeZone(secondsFromGMT: -2 * 60 * 60))
        calendar.timeZone = tz
        calendar.locale = Locale(identifier: "en_US")

        let date = try #require(calendar.date(from: components))
        #expect(XMLBuilder.rfc2822Date(date) == "Tue, 18 Mar 2025 19:20:15 +0000")
    }

    @Test
    func testValidateURL() throws {
        let validURL = makeURL("https://swift.org")
        try XMLBuilder.validateURL(validURL, context: "test")

        let ftpURL = makeURL("ftp://invalid-url")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(ftpURL, context: "test")
        }

        let fileURL = makeURL("file://file_path")
        #expect(throws: GeneratorError.self) {
            try XMLBuilder.validateURL(fileURL, context: "test")
        }
    }

    @Test
    func testEncodeURL() {
        let input = makeURL("https://swift.org/search?query=école+swift&lang=fr")
        let encoded = XMLBuilder.encodeURL(input)
        #expect(encoded.contains("query=%C3%A9cole+swift"))
        #expect(encoded.contains("lang=fr"))
    }

    @Test
    func test_encodeURL_returnsEscapedStringOrFallback() {
        let url = makeURL("https://example.com/query?param=ç©🎉")
        let encoded = XMLBuilder.encodeURL(url)
        #expect(encoded.starts(with: "https://example.com"))
    }
}
