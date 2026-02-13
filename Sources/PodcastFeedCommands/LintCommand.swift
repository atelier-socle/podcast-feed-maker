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

    @Option(name: .long, help: "Template level: basic, standard, advanced, expert.")
    var template: TemplateName?

    @Option(
        name: .long, parsing: .upToNextOption,
        help: "Override template platforms: apple, spotify, amazon, podcastIndex, psp1, all.")
    var platforms: [String] = []

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let reports = FeedValidator().validateAll(feed)

        let allErrors = reports.flatMap(\.errors)
        let allWarnings = reports.flatMap(\.warnings)

        // Template validation (if requested)
        var templateReport: TemplateValidationReport?
        if let templateName = template {
            let resolved = templateName.resolve(platforms: platforms)
            templateReport = TemplateValidator().validate(feed, against: resolved)
        }

        if format == "json" {
            try printJSONOutput(
                allErrors: allErrors, allWarnings: allWarnings,
                templateReport: templateReport)
        } else {
            printTextOutput(
                feed: feed, allErrors: allErrors, allWarnings: allWarnings,
                templateReport: templateReport)
        }

        try resolveExitCode(
            allErrors: allErrors, allWarnings: allWarnings,
            templateReport: templateReport)
    }
}

// MARK: - Output Helpers

extension LintCommand {

    private func printJSONOutput(
        allErrors: [ValidationResult],
        allWarnings: [ValidationResult],
        templateReport: TemplateValidationReport?
    ) throws {
        let templateJSON = templateReport.map { tReport in
            TemplateLintResult(
                level: tReport.level.description,
                isCompliant: tReport.isCompliant,
                errors: tReport.errors.map {
                    TemplateResultEntry(
                        tag: $0.tag.rawValue, message: $0.message,
                        suggestedLevel: $0.suggestedLevel?.description)
                },
                warnings: tReport.warnings.map {
                    TemplateResultEntry(
                        tag: $0.tag.rawValue, message: $0.message, suggestedLevel: nil)
                },
                infos: tReport.infos.map {
                    TemplateResultEntry(
                        tag: $0.tag.rawValue, message: $0.message,
                        suggestedLevel: $0.suggestedLevel?.description)
                }
            )
        }
        let summary = LintSummary(
            errors: allErrors.map { ResultEntry(field: $0.field, message: $0.message) },
            warnings: allWarnings.map { ResultEntry(field: $0.field, message: $0.message) },
            template: templateJSON
        )
        print(try OutputFormatter.jsonString(summary))
    }

    private func printTextOutput(
        feed: PodcastFeed,
        allErrors: [ValidationResult],
        allWarnings: [ValidationResult],
        templateReport: TemplateValidationReport?
    ) {
        if allErrors.isEmpty && allWarnings.isEmpty {
            let episodeCount = feed.channel?.items.count ?? 0
            print(ColorOutput.success("Feed is valid (\(episodeCount) episodes)"))
        } else {
            let parts = [
                allErrors.isEmpty ? nil : "\(allErrors.count) error(s)",
                allWarnings.isEmpty ? nil : "\(allWarnings.count) warning(s)"
            ].compactMap { $0 }
            print(ColorOutput.error(parts.joined(separator: ", ")))
            for error in allErrors {
                print("  \(ColorOutput.error("ERROR")): \(error.message)")
            }
            for warning in allWarnings {
                print("  \(ColorOutput.warning("WARNING")): \(warning.message)")
            }
        }
        if let tReport = templateReport {
            print("")
            print(OutputFormatter.formatTemplateReport(tReport))
        }
    }

    private func resolveExitCode(
        allErrors: [ValidationResult],
        allWarnings: [ValidationResult],
        templateReport: TemplateValidationReport?
    ) throws {
        let templateErrors = templateReport?.errors ?? []
        let templateWarnings = templateReport?.warnings ?? []

        if !allErrors.isEmpty || !templateErrors.isEmpty {
            throw ExitCode(rawValue: ExitCodes.error)
        }
        let hasWarnings = !allWarnings.isEmpty || !templateWarnings.isEmpty
        if strict && hasWarnings {
            throw ExitCode(rawValue: ExitCodes.error)
        }
        if hasWarnings {
            throw ExitCode(rawValue: ExitCodes.warningsOnly)
        }
    }
}

// MARK: - JSON Output Types

private struct LintSummary: Encodable {
    let errors: [ResultEntry]
    let warnings: [ResultEntry]
    let template: TemplateLintResult?
}

private struct ResultEntry: Encodable {
    let field: String?
    let message: String
}

private struct TemplateLintResult: Encodable {
    let level: String
    let isCompliant: Bool
    let errors: [TemplateResultEntry]
    let warnings: [TemplateResultEntry]
    let infos: [TemplateResultEntry]
}

private struct TemplateResultEntry: Encodable {
    let tag: String
    let message: String
    let suggestedLevel: String?
}
