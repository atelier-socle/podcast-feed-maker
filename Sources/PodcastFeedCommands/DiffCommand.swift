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

/// Compares two feeds and shows differences.
struct DiffCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "Compare two podcast feeds and show differences."
    )

    @Argument(help: "First feed (file path or URL).")
    var old: String

    @Argument(help: "Second feed (file path or URL).")
    var new: String

    @Option(name: .shortAndLong, help: "Output format: text, json.")
    var format: String = "text"

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let oldXML = try FeedLoader.loadXML(from: old)
        let newXML = try FeedLoader.loadXML(from: new)

        let engine = PodcastFeedEngine()
        let differences = try engine.diff(xml: oldXML, xml: newXML)

        if format == "json" {
            let jsonDiffs = differences.map { diff in
                JSONDiff(
                    changeType: String(describing: diff.changeType),
                    field: diff.field,
                    oldValue: diff.oldValue,
                    newValue: diff.newValue
                )
            }
            let json = try OutputFormatter.jsonString(jsonDiffs)
            print(json)
        } else {
            print(OutputFormatter.formatDiff(differences, oldLabel: old, newLabel: new))
        }

        if !differences.isEmpty {
            throw ExitCode(rawValue: ExitCodes.error)
        }
    }
}

private struct JSONDiff: Encodable {
    let changeType: String
    let field: String
    let oldValue: String?
    let newValue: String?
}
