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

@testable import PodcastFeedCommands

@Suite("ColorOutput Tests")
struct ColorOutputTests {

    @Test("Error wraps in red when enabled")
    func errorRed() {
        // ColorOutput.isEnabled depends on env/args, test the function directly
        let text = "test error"
        let result = ColorOutput.error(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[31m"))
            #expect(result.contains(text))
            #expect(result.contains("\u{001B}[0m"))
        } else {
            #expect(result == text)
        }
    }

    @Test("Warning wraps in yellow when enabled")
    func warningYellow() {
        let text = "test warning"
        let result = ColorOutput.warning(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[33m"))
            #expect(result.contains(text))
        } else {
            #expect(result == text)
        }
    }

    @Test("Success wraps in green when enabled")
    func successGreen() {
        let text = "all good"
        let result = ColorOutput.success(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[32m"))
            #expect(result.contains(text))
        } else {
            #expect(result == text)
        }
    }

    @Test("Bold wraps in bold when enabled")
    func boldWraps() {
        let text = "important"
        let result = ColorOutput.bold(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[1m"))
        } else {
            #expect(result == text)
        }
    }
}
