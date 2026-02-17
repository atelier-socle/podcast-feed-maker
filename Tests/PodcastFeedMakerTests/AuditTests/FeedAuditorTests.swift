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

// MARK: - FeedAuditorTests

@Suite("Feed Auditor")
struct FeedAuditorTests {

    private let auditor = FeedAuditor()

    // MARK: - Helpers

    /// Builds a minimal channel with only the three RSS-required fields.
    private func makeMinimalChannel() -> Channel {
        Channel(
            title: "My Podcast",
            link: makeURL("https://example.com"),
            description: "A great podcast about technology and innovation"
                + " that everyone should listen to for learning new things every week"
        )
    }

    /// Builds a single item with an enclosure and a long-enough description.
    private func makeBasicItem(index: Int = 1) -> Item {
        let enclosureURL = URL(string: "https://example.com/ep\(index).mp3")
        let imageURL = URL(string: "https://example.com/ep\(index).jpg")
        return Item(
            title: "Episode \(index)",
            description: "A detailed description of episode \(index)"
                + " that is meaningful and informative for listeners",
            enclosure: Enclosure(
                url: enclosureURL ?? makeURL("https://example.com/ep.mp3"),
                length: 12_345_678,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep\(index)", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 3600,
            itunesImage: imageURL ?? makeURL("https://example.com/ep.jpg")
        )
    }

    /// Builds a well-formed channel with all common metadata and N items.
    private func makeWellFormedChannel(itemCount: Int = 3) -> Channel {
        var channel = makeMinimalChannel()
        channel.language = "en"
        channel.itunesAuthor = "Host"
        channel.itunesOwner = ITunesOwner(name: "Host", email: "host@example.com")
        channel.itunesImage = makeURL("https://example.com/art.jpg")
        channel.itunesCategories = [ITunesCategory(text: "Technology")]
        channel.itunesExplicit = false
        channel.itunesType = .episodic
        channel.copyright = "2024"
        channel.atomLinks = [
            AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))
        ]
        channel.locked = Locked(isLocked: true, owner: "host@example.com")
        channel.podcastGuid = PodcastGuid(value: "550e8400-e29b-41d4-a716-446655440000")
        channel.items = (1...itemCount).map { makeBasicItem(index: $0) }
        return channel
    }

    /// Builds a near-perfect channel with all Podcast NS 2.0 tags filled.
    private func makeNearPerfectChannel() -> Channel {
        var channel = makeWellFormedChannel(itemCount: 3)

        // Discoverability
        channel.txtRecords = [PodcastTxt(value: "technology swift podcast")]
        channel.funding = [
            Funding(
                url: makeURL("https://example.com/donate"),
                message: "Support the show"
            )
        ]
        channel.podroll = Podroll(remoteItems: [
            RemoteItem(feedGuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890")
        ])
        channel.updateFrequency = UpdateFrequency(
            label: "Weekly on Fridays",
            rrule: "FREQ=WEEKLY;BYDAY=FR"
        )

        // Enrich items with accessibility + social
        channel.items = channel.items.enumerated().map { index, item in
            var enriched = item
            let transcriptURL =
                URL(string: "https://example.com/ep\(index + 1).vtt")
                ?? makeURL("https://example.com/ep.vtt")
            let chaptersLinkURL =
                URL(string: "https://example.com/ep\(index + 1)/chapters.json")
                ?? makeURL("https://example.com/ep/chapters.json")
            enriched.transcripts = [
                Transcript(
                    url: transcriptURL,
                    type: "text/vtt",
                    language: "en"
                )
            ]
            enriched.chaptersLink = ChaptersLink(
                url: chaptersLinkURL
            )
            enriched.contentEncoded = ContentEncoded(
                value: "<p>Full show notes with <strong>HTML</strong> content"
                    + " that provides detailed episode information and links.</p>"
            )
            enriched.socialInteractions = [
                SocialInteract(
                    uri: "https://mastodon.social/@host/\(index + 1)",
                    protocol: "activitypub"
                )
            ]
            return enriched
        }
        return channel
    }

    // MARK: - Test 1: Audit Empty Feed

    @Test("empty feed scores very low with grade F")
    func auditEmptyFeed() {
        let feed = PodcastFeed(channel: nil)
        let report = auditor.audit(feed)

        // Only accessibility.altText (3 pts) is awarded by default
        #expect(report.score == 3)
        #expect(report.grade == .f)
        #expect(!report.recommendations.isEmpty)
        #expect(report.episodeCount == 0)
        #expect(report.feedTitle == nil)
    }

    // MARK: - Test 2: Audit Minimal Feed

    @Test("minimal feed scores low but not zero with correct episode count")
    func auditMinimalFeed() {
        var channel = makeMinimalChannel()
        var item = Item()
        item.title = "Episode 1"
        item.description =
            "A detailed description of the first episode"
            + " that is meaningful and informative"
        item.enclosure = Enclosure(
            url: makeURL("https://example.com/ep1.mp3"),
            length: 12_345_678,
            type: "audio/mpeg"
        )
        channel.items = [item]

        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        #expect(report.score > 3)
        #expect(report.score < 60)
        #expect(report.grade == .f)
        #expect(report.episodeCount == 1)
        #expect(report.feedTitle == "My Podcast")
    }

    // MARK: - Test 3: Audit Well-Formed Feed

    @Test("well-formed feed with all metadata scores above 60")
    func auditWellFormedFeed() {
        let channel = makeWellFormedChannel(itemCount: 3)
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        #expect(report.score > 60)
        #expect(report.grade <= .d)
        #expect(report.episodeCount == 3)
        #expect(report.feedTitle == "My Podcast")
    }

    // MARK: - Test 4: Audit Near-Perfect Feed

    @Test("near-perfect feed with all tags scores at least 90")
    func auditNearPerfectFeed() {
        let channel = makeNearPerfectChannel()
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        #expect(report.score >= 90)
        #expect(report.grade <= .a)
    }

    // MARK: - Test 5: Recommendations Ordered by Priority

    @Test("recommendations are ordered critical first, then recommended, then niceToHave")
    func recommendationsOrderedByPriority() {
        let feed = PodcastFeed(channel: nil)
        let report = auditor.audit(feed)

        let priorities = report.recommendations.map(\.priority)
        for index in priorities.indices.dropLast() {
            let message: Comment = "Recommendation at index \(index) should not have lower priority than index \(index + 1)"
            #expect(
                priorities[index] <= priorities[index + 1],
                message
            )
        }
    }

    // MARK: - Test 6: Recommendations Ordered by Impact Within Priority

    @Test("within same priority, recommendations are sorted by descending potential points")
    func recommendationsOrderedByImpactWithinPriority() {
        let feed = PodcastFeed(channel: nil)
        let report = auditor.audit(feed)

        // Group recommendations by priority
        let grouped = Dictionary(grouping: report.recommendations) { $0.priority }
        for (_, recs) in grouped {
            for index in recs.indices.dropLast() {
                let message: Comment = "Within same priority, recommendation at index \(index) should have >= potentialPoints than index \(index + 1)"
                #expect(
                    recs[index].potentialPoints >= recs[index + 1].potentialPoints,
                    message
                )
            }
        }
    }

    // MARK: - Test 7: No Recommendations for Perfect Feed

    @Test("perfect feed has empty or near-empty recommendations")
    func noRecommendationsForPerfectFeed() {
        let channel = makeNearPerfectChannel()
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        // A truly complete feed should have very few or zero recommendations
        #expect(report.recommendations.isEmpty)
    }

    // MARK: - Test 8: Compatibility Matrix Has All 5 Platforms

    @Test("compatibility matrix includes all 5 validation platforms")
    func compatibilityMatrixAllPlatforms() {
        let channel = makeWellFormedChannel()
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        let platformNames = Set(report.compatibility.map(\.platform))
        let expected: Set<String> = [
            "Apple Podcasts",
            "Spotify",
            "Amazon Music",
            "Podcast Index",
            "PSP-1"
        ]
        #expect(platformNames == expected)
        #expect(report.compatibility.count == 5)
    }

    // MARK: - Test 9: Feed Title in Report

    @Test("feedTitle matches channel title")
    func feedTitleInReport() {
        let channel = makeMinimalChannel()
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        #expect(report.feedTitle == "My Podcast")
    }

    // MARK: - Test 10: Episode Count in Report

    @Test("episodeCount matches items count")
    func episodeCountInReport() {
        let channel = makeWellFormedChannel(itemCount: 5)
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        #expect(report.episodeCount == 5)
    }

    // MARK: - Test 11: Compare Two Feeds

    @Test("comparing minimal and improved feed shows positive score delta")
    func compareTwoFeeds() {
        // Before: minimal feed
        var minimalChannel = makeMinimalChannel()
        var item = Item()
        item.title = "Episode 1"
        item.description =
            "A detailed description of the first episode"
            + " that is meaningful and informative"
        item.enclosure = Enclosure(
            url: makeURL("https://example.com/ep1.mp3"),
            length: 12_345_678,
            type: "audio/mpeg"
        )
        minimalChannel.items = [item]
        let before = PodcastFeed(channel: minimalChannel)

        // After: well-formed feed
        let after = PodcastFeed(channel: makeWellFormedChannel())

        let comparison = auditor.compare(before: before, after: after)

        #expect(comparison.scoreDelta > 0)
        #expect(comparison.afterScore > comparison.beforeScore)
        #expect(!comparison.resolvedRecommendations.isEmpty)
        #expect(comparison.categoryDeltas.count == AuditCategory.allCases.count)
    }
}
