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
