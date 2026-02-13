import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Lists episodes from a feed.
struct EpisodesCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "episodes",
        abstract: "List episodes from a podcast feed."
    )

    @Argument(help: "Feed file path or URL.")
    var source: String

    @Option(name: .shortAndLong, help: "Output format: text, json.")
    var format: String = "text"

    @Option(name: [.customShort("n"), .long], help: "Max episodes to show.")
    var limit: Int?

    @Option(help: "Sort order: newest, oldest, title.")
    var sort: String = "newest"

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let items = feed.channel?.items ?? []

        guard let sortOrder = EpisodeSort(rawValue: sort) else {
            throw ValidationError("Unknown sort order: '\(sort)'. Valid: newest, oldest, title")
        }

        if format == "json" {
            let episodes = items.map { item in
                EpisodeJSON(
                    title: item.title,
                    guid: item.guid?.value,
                    pubDate: item.pubDate?.description,
                    duration: item.itunesDuration,
                    episodeType: item.itunesEpisodeType?.rawValue,
                    enclosureURL: item.enclosure?.url.absoluteString
                )
            }
            let json = try OutputFormatter.jsonString(episodes)
            print(json)
        } else {
            print(OutputFormatter.formatEpisodeTable(items, limit: limit, sort: sortOrder))
        }
    }
}

private struct EpisodeJSON: Encodable {
    let title: String?
    let guid: String?
    let pubDate: String?
    let duration: Int?
    let episodeType: String?
    let enclosureURL: String?
}
