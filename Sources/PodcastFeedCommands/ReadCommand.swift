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
import PodcastFeedMaker

/// Parses and displays a feed from a file or URL.
struct ReadCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Parse and display a podcast feed."
    )

    @Argument(help: "Feed file path or URL.")
    var source: String

    @Option(name: .shortAndLong, help: "Output format: summary, json, xml.")
    var format: String = "summary"

    @Flag(name: .shortAndLong, help: "Show all fields including empty/nil.")
    var verbose: Bool = false

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        switch format {
        case "json":
            let feed = try FeedLoader.load(from: source)
            let json = try OutputFormatter.jsonString(feed)
            print(json)

        case "xml":
            let feed = try FeedLoader.load(from: source)
            let generator = FeedGenerator()
            let xml = try generator.generate(feed)
            print(xml)

        case "summary":
            let feed = try FeedLoader.load(from: source)
            print(OutputFormatter.formatFeedSummary(feed, verbose: verbose))

        default:
            throw ValidationError("Unknown format: '\(format)'. Valid: summary, json, xml")
        }
    }
}
