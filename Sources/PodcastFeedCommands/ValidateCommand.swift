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

    @Flag(name: .shortAndLong, help: "Show info-level messages too.")
    var verbose: Bool = false

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let validator = FeedValidator()
        let platforms = try resolvePlatforms()
        let reports = platforms.map { validator.validate(feed, for: $0) }

        if format == "json" {
            let jsonReports = reports.map { report in
                JSONValidationReport(
                    platform: report.platform.rawValue,
                    errors: report.errors.map { JSONValidationEntry(field: $0.field, message: $0.message) },
                    warnings: report.warnings.map { JSONValidationEntry(field: $0.field, message: $0.message) },
                    infos: report.results.filter { $0.severity == .info }
                        .map { JSONValidationEntry(field: $0.field, message: $0.message) }
                )
            }
            let json = try OutputFormatter.jsonString(jsonReports)
            print(json)
        } else {
            for report in reports {
                print("Validating against \(ColorOutput.bold(report.platform.rawValue))...")
                print(OutputFormatter.formatValidationReport(report, verbose: verbose))
                print("")
            }

            let totalErrors = reports.flatMap(\.errors).count
            let totalWarnings = reports.flatMap(\.warnings).count
            print("Summary: \(totalErrors) error(s), \(totalWarnings) warning(s) across \(reports.count) platform(s)")
        }

        let hasErrors = reports.contains { !$0.isValid }
        let hasWarnings = reports.flatMap(\.warnings).isEmpty == false

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
