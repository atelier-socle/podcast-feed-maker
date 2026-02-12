import Foundation
@testable import PodcastFeedMaker
import Testing

// MARK: - CustomValidationRuleTests

@Suite("Custom Validation Rule Tests")
struct CustomValidationRuleTests {

    private let validator = FeedValidator()

    // MARK: - Test Rule

    struct RequireTranscriptsRule: ValidationRule {
        func validate(_ feed: PodcastFeed) -> [ValidationResult] {
            guard let channel = feed.channel else { return [] }
            return channel.items.enumerated().compactMap { idx, item in
                item.transcripts.isEmpty
                    ? ValidationResult(
                        severity: .warning,
                        message: "Transcript is required",
                        field: "channel.items[\(idx)].transcripts"
                    )
                    : nil
            }
        }
    }

    struct RequireMinimumEpisodesRule: ValidationRule {
        let minimum: Int

        func validate(_ feed: PodcastFeed) -> [ValidationResult] {
            guard let channel = feed.channel else {
                return [ValidationResult(
                    severity: .error,
                    message: "Channel is required",
                    field: "channel"
                )]
            }
            if channel.items.count < minimum {
                return [ValidationResult(
                    severity: .error,
                    message: "Feed must have at least \(minimum) episodes",
                    field: "channel.items"
                )]
            }
            return []
        }
    }

    // MARK: - Tests

    @Test("Custom rule produces results")
    func customRuleResults() {
        let item = Item(title: "Episode")
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [item]
        ))
        let results = validator.validate(
            feed, rules: [RequireTranscriptsRule()]
        )
        #expect(results.count == 1)
        #expect(results[0].field == "channel.items[0].transcripts")
    }

    @Test("Custom rule returns empty for compliant feed")
    func customRuleCompliant() {
        let item = Item(
            title: "Episode",
            transcripts: [Transcript(
                url: URL(string: "https://example.com/t.vtt")!,
                type: "text/vtt"
            )]
        )
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [item]
        ))
        let results = validator.validate(
            feed, rules: [RequireTranscriptsRule()]
        )
        #expect(results.isEmpty)
    }

    @Test("Multiple custom rules compose")
    func multipleRulesCompose() {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [Item(title: "Ep")]
        ))
        let results = validator.validate(feed, rules: [
            RequireTranscriptsRule(),
            RequireMinimumEpisodesRule(minimum: 5),
        ])
        #expect(results.count == 2)
    }

    @Test("Custom rule results are sorted by severity")
    func resultsSorted() {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            items: [Item(title: "Ep")]
        ))
        let results = validator.validate(feed, rules: [
            RequireTranscriptsRule(),
            RequireMinimumEpisodesRule(minimum: 5),
        ])
        // error from MinEpisodes should be first, warning from Transcripts second
        #expect(results[0].severity == .error)
        #expect(results[1].severity == .warning)
    }

    @Test("Custom rule on feed with no channel")
    func noChannelCustomRule() {
        let feed = PodcastFeed(channel: nil)
        let results = validator.validate(
            feed, rules: [RequireMinimumEpisodesRule(minimum: 1)]
        )
        #expect(results.count == 1)
        #expect(results[0].severity == .error)
    }
}
