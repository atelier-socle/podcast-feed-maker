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

/// Validates a feed against platform-specific requirements.
struct ValidateCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "validate",
        abstract: "Validate a podcast feed against platform requirements."
    )

    @Argument(help: "Feed file path or URL.")
    var source: String

    @Option(
        name: .shortAndLong, parsing: .upToNextOption,
        help: "Platform(s): apple, spotify, amazon, podcastindex, psp1, all.")
    var platform: [String] = []

    @Option(name: .shortAndLong, help: "Output format: text, json.")
    var format: String = "text"

    @Option(name: .long, help: "Template level: basic, standard, advanced, expert.")
    var template: TemplateName?

    @Flag(name: .shortAndLong, help: "Show info-level messages too.")
    var verbose: Bool = false

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    // swiftlint:disable:next function_body_length
    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let validator = FeedValidator()
        let platforms = try resolvePlatforms()
        let reports = platforms.map { validator.validate(feed, for: $0) }

        // Template validation (if requested)
        var templateReport: TemplateValidationReport?
        if let templateName = template {
            let resolved = templateName.resolve()
            templateReport = TemplateValidator().validate(feed, against: resolved)
        }

        if format == "json" {
            let jsonReports = reports.map { report in
                JSONValidationReport(
                    platform: report.platform.rawValue,
                    errors: report.errors.map {
                        JSONValidationEntry(field: $0.field, message: $0.message)
                    },
                    warnings: report.warnings.map {
                        JSONValidationEntry(field: $0.field, message: $0.message)
                    },
                    infos: report.results.filter { $0.severity == .info }
                        .map { JSONValidationEntry(field: $0.field, message: $0.message) }
                )
            }
            var output: JSONValidateOutput
            if let tReport = templateReport {
                output = JSONValidateOutput(
                    platforms: jsonReports,
                    template: JSONTemplateReport(
                        level: tReport.level.description,
                        isCompliant: tReport.isCompliant,
                        errors: tReport.errors.map {
                            JSONTemplateEntry(tag: $0.tag.rawValue, message: $0.message)
                        },
                        warnings: tReport.warnings.map {
                            JSONTemplateEntry(tag: $0.tag.rawValue, message: $0.message)
                        },
                        infos: tReport.infos.map {
                            JSONTemplateEntry(tag: $0.tag.rawValue, message: $0.message)
                        }
                    )
                )
            } else {
                output = JSONValidateOutput(platforms: jsonReports, template: nil)
            }
            let json = try OutputFormatter.jsonString(output)
            print(json)
        } else {
            for report in reports {
                print("Validating against \(ColorOutput.bold(report.platform.rawValue))...")
                print(OutputFormatter.formatValidationReport(report, verbose: verbose))
                print("")
            }

            let totalErrors = reports.flatMap(\.errors).count
            let totalWarnings = reports.flatMap(\.warnings).count
            print(
                "Summary: \(totalErrors) error(s), \(totalWarnings) warning(s) "
                    + "across \(reports.count) platform(s)")

            if let tReport = templateReport {
                print("")
                print("Template validation (\(tReport.level)):")
                print(OutputFormatter.formatTemplateReport(tReport, verbose: verbose))
            }
        }

        let hasErrors =
            reports.contains { !$0.isValid }
            || (templateReport?.isCompliant == false)
        let hasWarnings =
            reports.flatMap(\.warnings).isEmpty == false
            || (templateReport?.warnings.isEmpty == false)

        if hasErrors {
            throw ExitCode(rawValue: ExitCodes.error)
        }
        if hasWarnings {
            throw ExitCode(rawValue: ExitCodes.warningsOnly)
        }
    }

    private func resolvePlatforms() throws -> [ValidationPlatform] {
        if platform.isEmpty || platform.contains("all") {
            return ValidationPlatform.allCases
        }

        return try platform.map { name in
            guard let resolved = ValidationPlatform(rawValue: name) else {
                throw ValidationError(
                    "Unknown platform: '\(name)'. "
                        + "Valid: apple, spotify, amazon, podcastIndex, psp1, all")
            }
            return resolved
        }
    }
}

// MARK: - JSON Output Types

private struct JSONValidateOutput: Encodable {
    let platforms: [JSONValidationReport]
    let template: JSONTemplateReport?
}

private struct JSONValidationReport: Encodable {
    let platform: String
    let errors: [JSONValidationEntry]
    let warnings: [JSONValidationEntry]
    let infos: [JSONValidationEntry]
}

private struct JSONValidationEntry: Encodable {
    let field: String?
    let message: String
}

private struct JSONTemplateReport: Encodable {
    let level: String
    let isCompliant: Bool
    let errors: [JSONTemplateEntry]
    let warnings: [JSONTemplateEntry]
    let infos: [JSONTemplateEntry]
}

private struct JSONTemplateEntry: Encodable {
    let tag: String
    let message: String
}
