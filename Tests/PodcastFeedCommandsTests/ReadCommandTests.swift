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

@Suite("ReadCommand Tests")
struct ReadCommandTests {

    @Test("Parses source argument with default format")
    func parsesSourceDefault() throws {
        let command = try ReadCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "summary")
        #expect(command.verbose == false)
    }

    @Test("Parses JSON format")
    func parsesJSON() throws {
        let command = try ReadCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses XML format")
    func parsesXML() throws {
        let command = try ReadCommand.parse(["feed.xml", "-f", "xml"])
        #expect(command.format == "xml")
    }

    @Test("Parses verbose flag")
    func parsesVerbose() throws {
        let command = try ReadCommand.parse(["feed.xml", "--verbose"])
        #expect(command.verbose == true)
    }
}
