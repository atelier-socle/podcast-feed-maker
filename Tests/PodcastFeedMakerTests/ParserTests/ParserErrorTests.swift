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

@Suite("ParserError Tests")
struct ParserErrorTests {

    @Test("invalidXML errorDescription includes detail")
    func invalidXMLDescription() {
        let error = ParserError.invalidXML("unexpected token")
        #expect(error.errorDescription == "Invalid XML: unexpected token")
    }

    @Test("missingRSSElement errorDescription")
    func missingRSSElementDescription() {
        let error = ParserError.missingRSSElement
        #expect(error.errorDescription == "Missing <rss> root element")
    }

    @Test("missingChannel errorDescription")
    func missingChannelDescription() {
        let error = ParserError.missingChannel
        #expect(error.errorDescription == "Missing <channel> element")
    }

    @Test("encodingError errorDescription includes detail")
    func encodingErrorDescription() {
        let error = ParserError.encodingError("Invalid UTF-8")
        #expect(error.errorDescription == "Encoding error: Invalid UTF-8")
    }

    @Test("networkError errorDescription includes detail")
    func networkErrorDescription() {
        let error = ParserError.networkError("Connection refused")
        #expect(error.errorDescription == "Network error: Connection refused")
    }

    @Test("ParserError conforms to Equatable")
    func equatable() {
        #expect(ParserError.missingChannel == ParserError.missingChannel)
        #expect(ParserError.invalidXML("a") != ParserError.invalidXML("b"))
        #expect(ParserError.missingChannel != ParserError.missingRSSElement)
    }
}
