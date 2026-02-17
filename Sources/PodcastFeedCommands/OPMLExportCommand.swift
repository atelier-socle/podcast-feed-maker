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

/// Exports podcast feeds as an OPML subscription list.
struct OPMLExportCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "opml-export",
        abstract: "Export one or more podcast feeds as an OPML file."
    )

    @Argument(help: "Feed file path(s) or URL(s).")
    var sources: [String]

    @Option(name: .shortAndLong, help: "Output file path (stdout if omitted).")
    var output: String?

    @Option(name: .long, help: "Title for the OPML document.")
    var title: String = "Podcast Subscriptions"

    @Option(name: .long, help: "Owner name for the OPML head.")
    var owner: String?

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        var feeds: [PodcastFeed] = []

        for source in sources {
            do {
                let feed = try FeedLoader.load(from: source)
                feeds.append(feed)
            } catch {
                print(ColorOutput.error("Error loading \(source): \(error)"))
            }
        }

        guard !feeds.isEmpty else {
            throw ValidationError("No feeds could be loaded.")
        }

        let document = OPMLFeedConverter.document(
            from: feeds,
            title: title,
            ownerName: owner
        )

        let xml = OPMLGenerator().generate(document)

        if let outputPath = output {
            let expandedPath = NSString(string: outputPath).expandingTildeInPath
            try xml.write(toFile: expandedPath, atomically: true, encoding: .utf8)
            print(
                ColorOutput.success(
                    "Exported \(feeds.count) feed(s) to \(outputPath)"
                ))
        } else {
            print(xml)
        }
    }
}
