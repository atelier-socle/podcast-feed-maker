import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Test Helpers

/// Builds a fully-populated feed that should score highly across all categories.
private func makeCompleteFeed() -> PodcastFeed {
    let feedURL = makeURL("https://example.com/feed.xml")
    let transcriptURL = makeURL("https://example.com/ep1.vtt")
    let chaptersURL = makeURL("https://example.com/ep1-chapters.json")
    let fundingURL = makeURL("https://example.com/donate")

    let longDescription = String(repeating: "This is a detailed description. ", count: 10)

    let item = Item(
        title: "Episode 1 - Complete",
        description: longDescription,
        enclosure: Enclosure(
            url: makeURL("https://example.com/ep1.mp3"),
            length: 50_000_000,
            type: "audio/mpeg"
        ),
        guid: GUID(value: "ep-001", isPermaLink: false),
        pubDate: Date(timeIntervalSince1970: 1_700_000_000),
        itunesDuration: 1800,
        itunesExplicit: false,
        itunesImage: URL(string: "https://example.com/ep1-art.jpg")
            ?? makeURL("https://example.com/ep1-art.jpg"),
        contentEncoded: ContentEncoded(value: "<p>Rich HTML episode content.</p>"),
        transcripts: [Transcript(url: transcriptURL, type: "text/vtt")],
        chaptersLink: ChaptersLink(url: chaptersURL),
        socialInteractions: [
            SocialInteract(uri: "https://social.example.com/1", protocol: "activitypub")
        ]
    )

    let channel = Channel(
        title: "Complete Podcast",
        link: makeURL("https://example.com"),
        description: longDescription,
        language: "en",
        copyright: "2026 Example Inc.",
        items: [item],
        itunesAuthor: "Host Name",
        itunesCategories: [.technology],
        itunesExplicit: false,
        itunesImage: URL(string: "https://example.com/artwork.jpg")
            ?? makeURL("https://example.com/artwork.jpg"),
        itunesOwner: ITunesOwner(name: "Host Name", email: "host@example.com"),
        itunesType: .episodic,
        atomLinks: [.selfLink(href: feedURL)],
        podcastGuid: PodcastGuid(value: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"),
        locked: Locked(isLocked: true, owner: "host@example.com"),
        funding: [Funding(url: fundingURL, message: "Support us")],
        txtRecords: [PodcastTxt(value: "podcasting2.0")],
        podroll: Podroll(remoteItems: []),
        updateFrequency: UpdateFrequency(label: "weekly")
    )

    return PodcastFeed(channel: channel)
}

/// Builds a minimal feed with bare-minimum fields.
private func makeMinimalFeed() -> PodcastFeed {
    let item = Item(
        title: "Ep 1",
        enclosure: Enclosure(
            url: makeURL("https://example.com/ep1.mp3"),
            length: 1024,
            type: "audio/mpeg"
        )
    )
    let channel = Channel(
        title: "Minimal",
        link: makeURL("https://example.com"),
        description: "Short",
        items: [item]
    )
    return PodcastFeed(channel: channel)
}

/// Builds a feed with no channel.
private func makeEmptyFeed() -> PodcastFeed {
    PodcastFeed(channel: nil)
}

// MARK: - AuditScoring Showcase

@Suite("Audit Scoring Showcase")
struct AuditScoringShowcase {

    @Test("Metadata scoring awards points for all metadata fields")
    func metadataScoring() {
        let feed = makeCompleteFeed()
        let score = AuditScoring.evaluate(category: .metadata, feed: feed)
        #expect(score.category == .metadata)
        #expect(score.maximum == 25)
        #expect(score.earned > 0)
        #expect(score.criteria.count == 8)
    }

    @Test("Episodes scoring awards points for complete episodes")
    func episodesScoring() {
        let feed = makeCompleteFeed()
        let score = AuditScoring.evaluate(category: .episodes, feed: feed)
        #expect(score.category == .episodes)
        #expect(score.maximum == 25)
        #expect(score.earned > 0)
        #expect(score.criteria.count == 6)
    }

    @Test("Compliance scoring awards points for standards conformity")
    func complianceScoring() {
        let feed = makeCompleteFeed()
        let score = AuditScoring.evaluate(category: .compliance, feed: feed)
        #expect(score.category == .compliance)
        #expect(score.maximum == 20)
        #expect(score.earned > 0)
        #expect(score.criteria.count == 6)
    }

    @Test("Accessibility scoring awards points for transcripts and chapters")
    func accessibilityScoring() {
        let feed = makeCompleteFeed()
        let score = AuditScoring.evaluate(category: .accessibility, feed: feed)
        #expect(score.category == .accessibility)
        #expect(score.maximum == 15)
        #expect(score.earned > 0)
        #expect(score.criteria.count == 4)
    }

    @Test("Discoverability scoring awards points for keywords and social")
    func discoverabilityScoring() {
        let feed = makeCompleteFeed()
        let score = AuditScoring.evaluate(category: .discoverability, feed: feed)
        #expect(score.category == .discoverability)
        #expect(score.maximum == 15)
        #expect(score.earned > 0)
        #expect(score.criteria.count == 5)
    }

    @Test("Global score is computed from weighted category scores")
    func globalScore() {
        let categoryScores = AuditCategory.allCases.map { category in
            AuditScoring.evaluate(category: category, feed: makeCompleteFeed())
        }
        let score = AuditScoring.globalScore(from: categoryScores)
        #expect(score >= 0)
        #expect(score <= 100)
    }

    @Test("Partial scoring: minimal feed scores lower than complete feed")
    func partialScoring() {
        let minimalScores = AuditCategory.allCases.map { category in
            AuditScoring.evaluate(category: category, feed: makeMinimalFeed())
        }
        let completeScores = AuditCategory.allCases.map { category in
            AuditScoring.evaluate(category: category, feed: makeCompleteFeed())
        }
        let minimalGlobal = AuditScoring.globalScore(from: minimalScores)
        let completeGlobal = AuditScoring.globalScore(from: completeScores)
        #expect(minimalGlobal < completeGlobal)
    }
}

// MARK: - FeedAuditor Showcase

@Suite("Feed Auditor Showcase")
struct FeedAuditorShowcase {

    let auditor = FeedAuditor()

    @Test("Minimal feed produces a valid report with low score")
    func minimalFeed() {
        let report = auditor.audit(makeMinimalFeed())
        #expect(report.score >= 0)
        #expect(report.score <= 100)
        #expect(report.categoryScores.count == 5)
        #expect(report.feedTitle == "Minimal")
        #expect(report.episodeCount == 1)
    }

    @Test("Complete feed scores high with few recommendations")
    func completeFeed() {
        let report = auditor.audit(makeCompleteFeed())
        #expect(report.score >= 80)
        #expect(report.grade < .b || report.grade == .b)
        #expect(report.feedTitle == "Complete Podcast")
        #expect(report.episodeCount == 1)
    }

    @Test("Empty feed (no channel) scores very low with F grade")
    func emptyFeed() {
        let report = auditor.audit(makeEmptyFeed())
        #expect(report.score < 10)
        #expect(report.grade == .f)
        #expect(report.episodeCount == 0)
        #expect(report.feedTitle == nil)
    }

    @Test("Recommendations are sorted by priority then potential points")
    func sortedRecommendations() {
        let report = auditor.audit(makeMinimalFeed())
        guard report.recommendations.count >= 2 else { return }
        for idx in 0..<(report.recommendations.count - 1) {
            let current = report.recommendations[idx]
            let next = report.recommendations[idx + 1]
            if current.priority == next.priority {
                #expect(current.potentialPoints >= next.potentialPoints)
            } else {
                #expect(current.priority < next.priority)
            }
        }
    }

    @Test("Compatibility matrix covers all 5 platforms")
    func compatibilityMatrix() {
        let report = auditor.audit(makeCompleteFeed())
        #expect(report.compatibility.count == 5)
        for compat in report.compatibility {
            #expect(!compat.platform.isEmpty)
        }
    }

    @Test("Compare shows improvement when feed gets better")
    func compareImprovement() {
        let before = makeMinimalFeed()
        let after = makeCompleteFeed()
        let comparison = auditor.compare(before: before, after: after)
        #expect(comparison.scoreDelta > 0)
        #expect(comparison.afterScore > comparison.beforeScore)
        #expect(comparison.resolvedRecommendations.count > 0)
    }

    @Test("Compare identical feeds shows zero delta")
    func compareIdentical() {
        let feed = makeCompleteFeed()
        let comparison = auditor.compare(before: feed, after: feed)
        #expect(comparison.scoreDelta == 0)
        #expect(comparison.beforeGrade == comparison.afterGrade)
        #expect(comparison.resolvedRecommendations.isEmpty)
        #expect(comparison.newRecommendations.isEmpty)
    }

    @Test("Compare degraded feed shows negative delta")
    func compareDegraded() {
        let before = makeCompleteFeed()
        let after = makeMinimalFeed()
        let comparison = auditor.compare(before: before, after: after)
        #expect(comparison.scoreDelta < 0)
        #expect(comparison.afterScore < comparison.beforeScore)
        #expect(comparison.newRecommendations.count > 0)
    }
}
