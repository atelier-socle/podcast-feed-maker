import ArgumentParser
import Foundation
import PodcastFeedMaker

/// Scaffolds a new podcast feed configuration from a template.
///
/// Creates a starter feed with placeholder values based on the template level.
/// Output can be JSON (for use with `generate` command) or XML.
///
/// ```
/// podcastfeed init --template standard
/// podcastfeed init --template basic --format xml --output feed.xml
/// ```
struct InitCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Scaffold a new podcast feed from a template."
    )

    @Option(name: .long, help: "Template level: basic, standard, advanced, expert.")
    var template: TemplateName

    @Option(
        name: .long, parsing: .upToNextOption,
        help: "Override platforms: apple, spotify, amazon, podcastIndex, psp1, all.")
    var platforms: [String] = []

    @Option(name: .shortAndLong, help: "Output format: json (default), xml.")
    var format: String = "json"

    @Option(name: .shortAndLong, help: "Output file path (stdout if omitted).")
    var output: String?

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let resolved = template.resolve(platforms: platforms)
        let feed = buildScaffold(for: resolved)
        let content: String

        if format == "xml" {
            let generator = FeedGenerator()
            content = try generator.generate(feed)
        } else {
            content = try OutputFormatter.jsonString(feed)
        }

        if let outputPath = output {
            try content.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print(ColorOutput.success("Scaffold written to \(outputPath)"))
        } else {
            print(content)
        }
    }

    // MARK: - Scaffold Builder

    // swiftlint:disable:next force_unwrapping
    private static let placeholderURL = URL(string: "https://example.com")!
    // swiftlint:disable:next force_unwrapping
    private static let placeholderTranscriptURL = URL(string: "https://example.com/episodes/ep001.srt")!

    // swiftlint:disable:next function_body_length
    private func buildScaffold(for template: ComposedTemplate) -> PodcastFeed {
        let url = Self.placeholderURL
        let imageURL = "https://example.com/artwork.jpg"
        let feedURL = "https://example.com/feed.xml"

        switch template.level {
        case .basic:
            var feed = PodcastFeed.basic(
                title: "My Podcast",
                link: url,
                description: "A podcast about..."
            ) { ch in
                ch.category(.technology)
                    .explicit(false)
                    .image(imageURL)
            }
            feed.channel?.items = [
                Item(
                    title: "Episode 1",
                    enclosure: Enclosure.mp3(
                        url: "https://example.com/episodes/ep001.mp3", length: 50_000_000),
                    guid: GUID(value: "ep-001", isPermaLink: false)
                )
            ]
            return feed

        case .standard:
            var feed = PodcastFeed.standard(
                title: "My Podcast",
                link: url,
                description: "A podcast about..."
            ) { ch in
                ch.author("Your Name")
                    .explicit(false)
                    .category(.technology)
                    .owner(name: "Your Name", email: "you@example.com")
                    .locked(owner: "you@example.com")
                    .guid(UUID().uuidString)
                    .atomLink(href: feedURL, rel: "self")
                    .image(imageURL)
                    .language("en")
            }
            feed.channel?.items = [
                Item(
                    title: "Episode 1",
                    description: "Episode description...",
                    enclosure: Enclosure.mp3(
                        url: "https://example.com/episodes/ep001.mp3", length: 50_000_000),
                    guid: GUID(value: "ep-001", isPermaLink: false),
                    pubDate: Date(),
                    itunesDuration: 1800,
                    itunesExplicit: false
                )
            ]
            return feed

        case .advanced:
            var feed = PodcastFeed.advanced(
                title: "My Podcast",
                link: url,
                description: "A podcast about..."
            ) { ch in
                ch.author("Your Name")
                    .explicit(false)
                    .category(.technology)
                    .owner(name: "Your Name", email: "you@example.com")
                    .locked(owner: "you@example.com")
                    .guid(UUID().uuidString)
                    .atomLink(href: feedURL, rel: "self")
                    .image(imageURL)
                    .language("en")
                    .medium(.podcast)
                    .funding(url: "https://example.com/donate", text: "Support this podcast")
            }
            feed.channel?.items = [
                Item(
                    title: "Episode 1",
                    description: "Episode description...",
                    enclosure: Enclosure.mp3(
                        url: "https://example.com/episodes/ep001.mp3", length: 50_000_000),
                    guid: GUID(value: "ep-001", isPermaLink: false),
                    pubDate: Date(),
                    itunesDuration: 1800,
                    itunesEpisodeType: .full,
                    itunesExplicit: false
                )
            ]
            return feed

        case .expert:
            var feed = PodcastFeed.expert(
                title: "My Podcast",
                link: url,
                description: "A podcast about..."
            ) { ch in
                ch.author("Your Name")
                    .explicit(false)
                    .category(.technology)
                    .owner(name: "Your Name", email: "you@example.com")
                    .locked(owner: "you@example.com")
                    .guid(UUID().uuidString)
                    .atomLink(href: feedURL, rel: "self")
                    .image(imageURL)
                    .language("en")
                    .medium(.podcast)
                    .funding(url: "https://example.com/donate", text: "Support this podcast")
            }
            feed.channel?.persons = [PodcastPerson(name: "Your Name")]
            var item = Item(
                title: "Episode 1",
                description: "Episode description...",
                enclosure: Enclosure.mp3(
                    url: "https://example.com/episodes/ep001.mp3", length: 50_000_000),
                guid: GUID(value: "ep-001", isPermaLink: false),
                pubDate: Date(),
                itunesDuration: 1800,
                itunesEpisodeType: .full,
                itunesExplicit: false
            )
            item.transcripts = [
                Transcript(
                    url: Self.placeholderTranscriptURL,
                    type: "application/srt")
            ]
            feed.channel?.items = [item]
            return feed
        }
    }
}
