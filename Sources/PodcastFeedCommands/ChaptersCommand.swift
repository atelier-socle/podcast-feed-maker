import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Extracts or manages chapters from a feed.
struct ChaptersCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "chapters",
        abstract: "Extract chapters from a podcast feed."
    )

    @Argument(help: "Feed file path or URL.")
    var source: String

    @Option(
        name: .shortAndLong,
        help: "Episode identifier: title substring, guid, or numeric index (0-based).")
    var episode: String?

    @Option(name: .shortAndLong, help: "Output format: text, json, psc.")
    var format: String = "text"

    @Option(help: "Export chapters to a file.")
    var export: String?

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let feed = try FeedLoader.load(from: source)
        let items = feed.channel?.items ?? []

        if let episodeID = episode {
            let item = try findEpisode(episodeID, in: items)
            try outputChapters(for: item)
        } else {
            let withChapters = items.enumerated().filter { _, item in
                item.podloveChapters != nil || item.chaptersLink != nil
            }

            if withChapters.isEmpty {
                print("No episodes with chapters found.")
                throw ExitCode(rawValue: ExitCodes.warningsOnly)
            }

            print(ColorOutput.bold("Episodes with chapters:"))
            for (idx, item) in withChapters {
                let title = item.title ?? "(untitled)"
                let chapterCount = item.podloveChapters?.chapters.count ?? 0
                let source = item.chaptersLink != nil ? " + JSON chapters link" : ""
                print("  [\(idx)] \(title) — \(chapterCount) chapter(s)\(source)")
            }
        }
    }

    private func findEpisode(_ identifier: String, in items: [Item]) throws -> Item {
        // Try numeric index
        if let idx = Int(identifier), idx >= 0, idx < items.count {
            return items[idx]
        }

        // Try guid match
        if let match = items.first(where: { $0.guid?.value == identifier }) {
            return match
        }

        // Try title substring match
        let lower = identifier.lowercased()
        if let match = items.first(where: {
            $0.title?.lowercased().contains(lower) == true
        }) {
            return match
        }

        throw ValidationError("Episode not found: '\(identifier)'")
    }

    private func outputChapters(for item: Item) throws {
        guard let chapters = item.podloveChapters else {
            print("No embedded chapters for this episode.")
            if let link = item.chaptersLink {
                print("JSON chapters link: \(link.url.absoluteString)")
            }
            throw ExitCode(rawValue: ExitCodes.warningsOnly)
        }

        let output: String
        switch format {
        case "json":
            let jsonChapters = chapters.chapters.map { ch in
                ExportChapter(
                    start: ch.start,
                    title: ch.title,
                    href: ch.href?.absoluteString,
                    image: ch.image?.absoluteString
                )
            }
            output = try OutputFormatter.jsonString(jsonChapters)
        case "psc":
            output = generatePSCXML(chapters)
        default:
            output = OutputFormatter.formatChapters(chapters.chapters)
        }

        if let exportPath = export {
            try output.write(toFile: exportPath, atomically: true, encoding: .utf8)
            print("Chapters exported to \(exportPath)")
        } else {
            print(output)
        }
    }

    private func generatePSCXML(_ chapters: PodloveChapters) -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<psc:chapters version=\"\(chapters.version)\""
        xml += " xmlns:psc=\"http://podlove.org/simple-chapters\">\n"
        for chapter in chapters.chapters {
            xml += "  <psc:chapter start=\"\(chapter.start)\""
            xml += " title=\"\(escapeXML(chapter.title))\""
            if let href = chapter.href {
                xml += " href=\"\(escapeXML(href.absoluteString))\""
            }
            if let image = chapter.image {
                xml += " image=\"\(escapeXML(image.absoluteString))\""
            }
            xml += " />\n"
        }
        xml += "</psc:chapters>"
        return xml
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

private struct ExportChapter: Encodable {
    let start: String
    let title: String?
    let href: String?
    let image: String?
}
