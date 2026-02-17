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

@Suite("EpisodesCommand Tests")
struct EpisodesCommandTests {

    @Test("Parses source with defaults")
    func parsesDefaults() throws {
        let command = try EpisodesCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "text")
        #expect(command.limit == nil)
        #expect(command.sort == "newest")
    }

    @Test("Parses limit option")
    func parsesLimit() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--limit", "10"])
        #expect(command.limit == 10)
    }

    @Test("Parses sort option")
    func parsesSort() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "--sort", "oldest"])
        #expect(command.sort == "oldest")
    }

    @Test("Parses JSON format with short flag")
    func parsesShortFormat() throws {
        let command = try EpisodesCommand.parse(["feed.xml", "-f", "json", "-n", "5"])
        #expect(command.format == "json")
        #expect(command.limit == 5)
    }
}
