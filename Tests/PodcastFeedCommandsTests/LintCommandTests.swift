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

import ArgumentParser
import Testing

@testable import PodcastFeedCommands

@Suite("LintCommand Tests")
struct LintCommandTests {

    @Test("Parses source argument")
    func parsesSource() throws {
        let command = try LintCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.strict == false)
        #expect(command.format == "text")
    }

    @Test("Parses strict flag")
    func parsesStrict() throws {
        let command = try LintCommand.parse(["feed.xml", "--strict"])
        #expect(command.strict == true)
    }

    @Test("Parses JSON format option")
    func parsesJSONFormat() throws {
        let command = try LintCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses no-color flag")
    func parsesNoColor() throws {
        let command = try LintCommand.parse(["feed.xml", "--no-color"])
        #expect(command.noColor == true)
    }
}
