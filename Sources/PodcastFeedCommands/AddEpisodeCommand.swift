import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Adds a new episode to an existing feed.
struct AddEpisodeCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "add-episode",
        abstract: "Add a new episode to an existing podcast feed."
    )

    @Argument(help: "Existing feed file path.")
    var feed: String

    @Option(help: "Episode title (required).")
    var title: String

    @Option(help: "Audio file URL (required).")
    var audio: String

    @Option(help: "File size in bytes (for enclosure).")
    var length: Int?

    @Option(help: "MIME type (default: audio/mpeg).")
    var type: String = "audio/mpeg"

    @Option(help: "Duration in seconds.")
    var duration: Int?

    @Option(help: "Episode description.")
    var description: String?

    @Option(help: "Episode GUID (auto-generated if omitted).")
    var guid: String?

    @Option(name: .long, help: "Publication date in RFC 2822 (default: now).")
    var pubDate: String?

    @Flag(help: "Mark episode as explicit.")
    var explicit: Bool = false

    @Option(name: .shortAndLong, help: "Output file path (required).")
    var output: String

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        var podcast = try FeedLoader.load(from: feed)

        guard let audioURL = URL(string: audio) else {
            throw ValidationError("Invalid audio URL: \(audio)")
        }

        let enclosureLength = try resolveLength(audioURL: audioURL)
        let episodeGuid = guid ?? UUID().uuidString
        let episodePubDate = try resolvePubDate()

        let episode = Item(
            title: title,
            description: description,
            enclosure: Enclosure(
                url: audioURL,
                length: enclosureLength,
                type: type
            ),
            guid: GUID(value: episodeGuid, isPermaLink: false),
            pubDate: episodePubDate,
            itunesDuration: duration,
            itunesExplicit: explicit ? true : nil
        )

        // Insert at position 0 (newest first)
        podcast.channel?.items.insert(episode, at: 0)
        podcast.channel?.lastBuildDate = Date()

        let generator = FeedGenerator()
        let xml = try generator.generate(podcast)

        try xml.write(toFile: output, atomically: true, encoding: .utf8)
        print(ColorOutput.success("Episode \"\(title)\" added to \(output)"))
    }

    private func resolveLength(audioURL: URL) throws -> Int {
        if let length {
            return length
        }
        // Try to detect file size for local paths
        if audioURL.isFileURL {
            let attrs = try FileManager.default.attributesOfItem(atPath: audioURL.path)
            if let size = attrs[.size] as? Int {
                return size
            }
        }
        return 0
    }

    private func resolvePubDate() throws -> Date {
        guard let pubDateString = pubDate else {
            return Date()
        }
        // Try RFC 2822 date parsing
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        if let date = formatter.date(from: pubDateString) {
            return date
        }
        // Try ISO 8601
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: pubDateString) {
            return date
        }
        throw ValidationError(
            "Cannot parse date: '\(pubDateString)'. "
                + "Use RFC 2822 (e.g., 'Thu, 13 Feb 2026 12:00:00 +0000') or ISO 8601."
        )
    }
}
