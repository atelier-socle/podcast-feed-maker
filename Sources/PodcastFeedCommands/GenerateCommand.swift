import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Generates feed XML from a JSON description file.
struct GenerateCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "generate",
        abstract: "Generate a podcast RSS feed from a JSON file."
    )

    @Argument(help: "Path to JSON file describing the feed.")
    var input: String

    @Option(name: .shortAndLong, help: "Output file path (stdout if omitted).")
    var output: String?

    @Flag(help: "Pretty-print the XML output.")
    var pretty: Bool = false

    @Flag(help: "Minify the XML output.")
    var minified: Bool = false

    @Flag(help: "Run validation after generation.")
    var validate: Bool = false

    @Option(
        parsing: .upToNextOption,
        help: "Platform(s) to validate against when --validate is used.")
    var platform: [String] = []

    @Option(name: .long, help: "Template level: basic, standard, advanced, expert.")
    var template: TemplateName?

    @Option(
        name: .long, parsing: .upToNextOption,
        help: "Override template platforms: apple, spotify, amazon, podcastIndex, psp1, all.")
    var platforms: [String] = []

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let resolved = try InputResolver.resolve(input)
        let jsonData: Data
        switch resolved {
        case .file(let path):
            let expandedPath = NSString(string: path).expandingTildeInPath
            let url = URL(fileURLWithPath: expandedPath)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw InputError.fileNotFound(path)
            }
            jsonData = try Data(contentsOf: url)
        case .url:
            throw ValidationError("Generate command requires a local JSON file, not a URL.")
        }

        let decoder = JSONDecoder()
        let feed = try decoder.decode(PodcastFeed.self, from: jsonData)

        let usePretty = minified ? false : true
        let generator = FeedGenerator(prettyPrint: usePretty)
        let xml = try generator.generate(feed)

        if let outputPath = output {
            try xml.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("Feed written to \(outputPath)")
        } else {
            print(xml)
        }

        if validate {
            let validator = FeedValidator()
            let validationPlatforms = resolvePlatforms()
            let reports = validationPlatforms.map { validator.validate(feed, for: $0) }

            print("")
            for report in reports {
                print("Validating against \(ColorOutput.bold(report.platform.rawValue))...")
                print(OutputFormatter.formatValidationReport(report))
            }

            let hasErrors = reports.contains { !$0.isValid }
            if hasErrors {
                throw ExitCode(rawValue: ExitCodes.error)
            }
        }

        // Template validation (if requested) — informational warnings to stderr
        if let templateName = template {
            let resolvedTemplate = templateName.resolve(platforms: platforms)
            let report = TemplateValidator().validate(feed, against: resolvedTemplate)
            if !report.isCompliant || !report.warnings.isEmpty {
                FileHandle.standardError.write(
                    Data(
                        "\nTemplate validation (\(report.level)):\n".utf8))
                FileHandle.standardError.write(
                    Data(
                        (OutputFormatter.formatTemplateReport(report) + "\n").utf8))
            }
        }
    }

    private func resolvePlatforms() -> [ValidationPlatform] {
        if platform.isEmpty || platform.contains("all") {
            return ValidationPlatform.allCases
        }
        return platform.compactMap { ValidationPlatform(rawValue: $0) }
    }
}
