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
