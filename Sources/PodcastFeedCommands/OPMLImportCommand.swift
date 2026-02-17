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

/// Imports and inspects an OPML subscription list.
struct OPMLImportCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "opml-import",
        abstract: "Parse an OPML file and list podcast subscriptions."
    )

    @Argument(help: "OPML file path.")
    var input: String

    @Option(name: .shortAndLong, help: "Output format: list, json, xml.")
    var format: String = "list"

    @Flag(name: .shortAndLong, help: "Show validation warnings.")
    var validate: Bool = false

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let expandedPath = NSString(string: input).expandingTildeInPath
        let inputURL = URL(fileURLWithPath: expandedPath)
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw InputError.fileNotFound(input)
        }

        let xmlString = try String(contentsOf: inputURL, encoding: .utf8)
        let document = try OPMLParser().parse(xmlString)

        switch format {
        case "json":
            let data = try JSONEncoder.prettyPrinted.encode(document)
            guard let json = String(data: data, encoding: .utf8) else {
                throw OutputError.encodingFailed
            }
            print(json)

        case "xml":
            let xml = OPMLGenerator().generate(document)
            print(xml)

        case "list":
            printSubscriptionList(document)

        default:
            throw ValidationError(
                "Unknown format '\(format)'. Supported: list, json, xml."
            )
        }

        if validate {
            printValidation(document)
        }
    }

    // MARK: - Output Formatting

    private func printSubscriptionList(_ document: OPMLDocument) {
        if let title = document.title {
            print(ColorOutput.bold(title))
        }

        let feeds = document.podcastFeeds
        print("\(feeds.count) subscription(s)")
        print("")

        for (index, feed) in feeds.enumerated() {
            let num = String(format: "%3d.", index + 1)
            print("\(num) \(feed.text)")
            if let url = feed.xmlUrl {
                print("     \(ColorOutput.dim(url.absoluteString))")
            }
        }
    }

    private func printValidation(_ document: OPMLDocument) {
        let report = OPMLValidator().validate(document)

        print("")
        if report.isValid && report.warnings.isEmpty {
            print(ColorOutput.success("Validation: OK"))
        } else {
            for issue in report.issues {
                switch issue.severity {
                case .error:
                    print("  \(ColorOutput.error("ERROR")): \(issue.message)")
                case .warning:
                    print("  \(ColorOutput.warning("WARNING")): \(issue.message)")
                }
            }
            let status =
                report.isValid
                ? ColorOutput.warning(
                    "Validation: \(report.warnings.count) warning(s)"
                )
                : ColorOutput.error(
                    "Validation: \(report.errors.count) error(s), "
                        + "\(report.warnings.count) warning(s)"
                )
            print(status)
        }
    }
}

// MARK: - JSONEncoder Extension

extension JSONEncoder {
    fileprivate static var prettyPrinted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
