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

@Suite("GeneratorError Tests")
struct GeneratorErrorTests {

    @Test("missingChannel errorDescription")
    func missingChannelDescription() {
        let error = GeneratorError.missingChannel
        #expect(error.errorDescription?.contains("Missing channel") == true)
    }

    @Test("invalidURL errorDescription includes context and URL")
    func invalidURLDescription() {
        let error = GeneratorError.invalidURL("enclosure", "not-a-url")
        #expect(error.errorDescription?.contains("enclosure") == true)
        #expect(error.errorDescription?.contains("not-a-url") == true)
    }

    @Test("encodingError errorDescription includes message")
    func encodingErrorDescription() {
        let error = GeneratorError.encodingError("UTF-8 failure")
        #expect(error.errorDescription?.contains("UTF-8 failure") == true)
    }

    @Test("GeneratorError conforms to Equatable")
    func equatable() {
        #expect(GeneratorError.missingChannel == GeneratorError.missingChannel)
        #expect(
            GeneratorError.invalidURL("a", "b") == GeneratorError.invalidURL("a", "b")
        )
        #expect(
            GeneratorError.invalidURL("a", "b") != GeneratorError.invalidURL("c", "d")
        )
    }
}
