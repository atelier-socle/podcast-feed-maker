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

@Suite("DiffCommand Tests")
struct DiffCommandTests {

    @Test("Parses both arguments")
    func parsesBothArgs() throws {
        let command = try DiffCommand.parse(["feed-v1.xml", "feed-v2.xml"])
        #expect(command.old == "feed-v1.xml")
        #expect(command.new == "feed-v2.xml")
        #expect(command.format == "text")
    }

    @Test("Parses JSON format")
    func parsesJSONFormat() throws {
        let command = try DiffCommand.parse(["a.xml", "b.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses no-color flag")
    func parsesNoColor() throws {
        let command = try DiffCommand.parse(["a.xml", "b.xml", "--no-color"])
        #expect(command.noColor == true)
    }
}
