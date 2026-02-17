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
import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("OPMLExportCommand Tests")
struct OPMLExportCommandTests {

    @Test("Parses single source argument")
    func parsesSingleSource() throws {
        let command = try OPMLExportCommand.parse(["feed.xml"])
        #expect(command.sources == ["feed.xml"])
        #expect(command.output == nil)
        #expect(command.title == "Podcast Subscriptions")
        #expect(command.owner == nil)
    }

    @Test("Parses multiple source arguments")
    func parsesMultipleSources() throws {
        let command = try OPMLExportCommand.parse([
            "feed1.xml", "feed2.xml", "feed3.xml"
        ])
        #expect(command.sources.count == 3)
    }

    @Test("Parses output option")
    func parsesOutput() throws {
        let command = try OPMLExportCommand.parse([
            "feed.xml", "-o", "subscriptions.opml"
        ])
        #expect(command.output == "subscriptions.opml")
    }

    @Test("Parses title option")
    func parsesTitle() throws {
        let command = try OPMLExportCommand.parse([
            "feed.xml", "--title", "My Pods"
        ])
        #expect(command.title == "My Pods")
    }

    @Test("Parses owner option")
    func parsesOwner() throws {
        let command = try OPMLExportCommand.parse([
            "feed.xml", "--owner", "John Doe"
        ])
        #expect(command.owner == "John Doe")
    }

    @Test("Export with nonexistent file throws error")
    func exportNonexistentFile() throws {
        #expect(throws: (any Error).self) {
            var command = try OPMLExportCommand.parse(
                ["/tmp/nonexistent_feed_\(UUID()).xml"]
            )
            try command.run()
        }
    }
}
