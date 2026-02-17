// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Testing

@testable import PodcastFeedMaker

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
                return [
                    ValidationResult(
                        severity: .error,
                        message: "Channel is required",
                        field: "channel"
                    )
                ]
            }
            if channel.items.count < minimum {
                return [
                    ValidationResult(
                        severity: .error,
                        message: "Feed must have at least \(minimum) episodes",
                        field: "channel.items"
                    )
                ]
            }
            return []
        }
    }

    // MARK: - Tests

    @Test("Custom rule produces results")
    func customRuleResults() {
        let item = Item(title: "Episode")
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
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
        let transcriptURL = makeURL("https://example.com/t.vtt")
        let item = Item(
            title: "Episode",
            transcripts: [
                Transcript(
                    url: transcriptURL,
                    type: "text/vtt"
                )
            ]
        )
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
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
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "desc",
                items: [Item(title: "Ep")]
            ))
        let results = validator.validate(
            feed,
            rules: [
                RequireTranscriptsRule(),
                RequireMinimumEpisodesRule(minimum: 5)
            ])
        #expect(results.count == 2)
    }

    @Test("Custom rule results are sorted by severity")
    func resultsSorted() {
        let url = makeURL("https://example.com")
        let feed = PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "desc",
                items: [Item(title: "Ep")]
            ))
        let results = validator.validate(
            feed,
            rules: [
                RequireTranscriptsRule(),
                RequireMinimumEpisodesRule(minimum: 5)
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
