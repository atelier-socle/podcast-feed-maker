import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Quick validation — validates against all platforms with simplified output.
struct LintCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "lint",
        abstract: "Quick-validate a podcast feed against all platforms."
    )

    @Argument(help: "Feed file path or URL.")
    var source: String

    @Flag(name: .long, help: "Treat warnings as errors.")
    var strict: Bool = false

    @Option(name: .shortAndLong, help: "Output format: text, json.")
    var format: String = "text"

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let validator = FeedValidator()
        let reports = validator.validateAll(feed)

        let allErrors = reports.flatMap(\.errors)
        let allWarnings = reports.flatMap(\.warnings)

        if format == "json" {
            let summary = LintSummary(
                errors: allErrors.map { ResultEntry(field: $0.field, message: $0.message) },
                warnings: allWarnings.map { ResultEntry(field: $0.field, message: $0.message) }
            )
            let json = try OutputFormatter.jsonString(summary)
            print(json)
        } else {
            if allErrors.isEmpty && allWarnings.isEmpty {
                let episodeCount = feed.channel?.items.count ?? 0
                print(ColorOutput.success("Feed is valid (\(episodeCount) episodes)"))
            } else {
                if !allErrors.isEmpty || !allWarnings.isEmpty {
                    let parts = [
                        allErrors.isEmpty ? nil : "\(allErrors.count) error(s)",
                        allWarnings.isEmpty ? nil : "\(allWarnings.count) warning(s)"
                    ].compactMap { $0 }
                    print(ColorOutput.error(parts.joined(separator: ", ")))
                }
                for error in allErrors {
                    print("  \(ColorOutput.error("ERROR")): \(error.message)")
                }
                for warning in allWarnings {
                    print("  \(ColorOutput.warning("WARNING")): \(warning.message)")
                }
            }
        }

        if !allErrors.isEmpty {
            throw ExitCode(rawValue: ExitCodes.error)
        }
        if strict && !allWarnings.isEmpty {
            throw ExitCode(rawValue: ExitCodes.warningsOnly)
        }
        if !allWarnings.isEmpty {
            throw ExitCode(rawValue: ExitCodes.warningsOnly)
        }
    }
}

// MARK: - JSON Output Types

private struct LintSummary: Encodable {
    let errors: [ResultEntry]
    let warnings: [ResultEntry]
}

private struct ResultEntry: Encodable {
    let field: String?
    let message: String
}
