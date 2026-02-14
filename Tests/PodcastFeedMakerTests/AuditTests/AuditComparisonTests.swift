import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Audit Comparison

@Suite("Audit Comparison")
struct AuditComparisonTests {

    private let auditor = FeedAuditor()

    // MARK: - Helpers

    /// A minimal feed that fails most criteria.
    private func minimalFeed() -> PodcastFeed {
        let url = makeURL("http://example.com")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short"
        )
        return PodcastFeed(channel: channel)
    }

    /// An improved feed with better metadata, episodes, and compliance.
    private func improvedFeed() -> PodcastFeed {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let feedURL = makeURL("https://example.com/feed.xml")
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let chaptersURL = makeURL("https://example.com/ep1-chapters.json")
        let fundingURL = makeURL("https://example.com/donate")

        let longDescription = String(repeating: "A podcast about technology. ", count: 10)

        let item = Item(
            title: "Episode 1",
            description: String(repeating: "Episode about tech topics. ", count: 5),
            enclosure: Enclosure(
                url: makeURL("https://example.com/ep1.mp3"),
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 1800,
            itunesExplicit: false,
            itunesImage: imageURL,
            contentEncoded: ContentEncoded(value: "<p>Rich episode description.</p>"),
            transcripts: [
                Transcript(url: transcriptURL, type: "text/vtt")
            ],
            chaptersLink: ChaptersLink(url: chaptersURL),
            socialInteractions: [
                SocialInteract(
                    uri: "https://social.example.com/post/1",
                    protocol: "activitypub"
                )
            ]
        )

        let channel = Channel(
            title: "Test Podcast",
            link: url,
            description: longDescription,
            language: "en",
            copyright: "2024 Test",
            items: [item],
            itunesAuthor: "Host Name",
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false,
            itunesImage: imageURL,
            itunesOwner: ITunesOwner(name: "Host", email: "host@example.com"),
            itunesType: .episodic,
            atomLinks: [
                AtomLink(href: feedURL, rel: "self", type: "application/rss+xml")
            ],
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "host@example.com"),
            funding: [Funding(url: fundingURL, message: "Support us")],
            txtRecords: [PodcastTxt(value: "keywords=tech,swift")],
            podroll: Podroll(remoteItems: []),
            updateFrequency: UpdateFrequency(label: "weekly")
        )

        return PodcastFeed(channel: channel)
    }

    /// A feed with episodes but still missing many metadata and compliance fields.
    private func partialFeed() -> PodcastFeed {
        let url = makeURL("http://example.com")
        let item = Item(
            title: "Episode 1",
            description: String(repeating: "Interesting content here. ", count: 5),
            enclosure: Enclosure(
                url: makeURL("https://example.com/ep1.mp3"),
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 600
        )
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short",
            items: [item]
        )
        return PodcastFeed(channel: channel)
    }

    // MARK: - 1. Same Feed Produces Delta 0

    @Test("Comparing same feed yields scoreDelta of 0")
    func sameFeedDeltaZero() {
        let feed = partialFeed()
        let comparison = auditor.compare(before: feed, after: feed)

        #expect(comparison.scoreDelta == 0)
        #expect(comparison.beforeScore == comparison.afterScore)
        #expect(comparison.beforeGrade == comparison.afterGrade)
    }

    // MARK: - 2. Improved Feed Produces Positive Delta

    @Test("Improved feed produces positive scoreDelta")
    func improvedFeedPositiveDelta() {
        let before = minimalFeed()
        let after = improvedFeed()
        let comparison = auditor.compare(before: before, after: after)

        #expect(comparison.scoreDelta > 0)
        #expect(comparison.afterScore > comparison.beforeScore)
    }

    // MARK: - 3. Degraded Feed Produces Negative Delta

    @Test("Degraded feed produces negative scoreDelta")
    func degradedFeedNegativeDelta() {
        let before = improvedFeed()
        let after = minimalFeed()
        let comparison = auditor.compare(before: before, after: after)

        #expect(comparison.scoreDelta < 0)
        #expect(comparison.afterScore < comparison.beforeScore)
    }

    // MARK: - 4. Category Deltas Correct

    @Test("Category deltas have correct before, after, and delta values")
    func categoryDeltasCorrect() {
        let before = minimalFeed()
        let after = improvedFeed()
        let comparison = auditor.compare(before: before, after: after)

        let beforeReport = auditor.audit(before)
        let afterReport = auditor.audit(after)

        for categoryDelta in comparison.categoryDeltas {
            let expectedBefore =
                beforeReport.categoryScores
                .first { $0.category == categoryDelta.category }?.earned ?? 0
            let expectedAfter =
                afterReport.categoryScores
                .first { $0.category == categoryDelta.category }?.earned ?? 0

            #expect(categoryDelta.beforeScore == expectedBefore)
            #expect(categoryDelta.afterScore == expectedAfter)
            #expect(categoryDelta.delta == expectedAfter - expectedBefore)
        }
    }

    // MARK: - 5. Resolved Recommendations

    @Test("Resolved recommendations are in before but not after")
    func resolvedRecommendations() {
        let before = minimalFeed()
        let after = improvedFeed()
        let comparison = auditor.compare(before: before, after: after)

        let beforeReport = auditor.audit(before)
        let afterReport = auditor.audit(after)
        let afterIds = Set(afterReport.recommendations.map(\.criterionId))

        // Every resolved recommendation should exist in before but not in after
        for resolved in comparison.resolvedRecommendations {
            let existsInBefore = beforeReport.recommendations.contains {
                $0.criterionId == resolved.criterionId
            }
            #expect(existsInBefore)
            #expect(!afterIds.contains(resolved.criterionId))
        }

        // The resolved count should match expectations
        let beforeIds = Set(beforeReport.recommendations.map(\.criterionId))
        let expectedResolved = beforeIds.subtracting(afterIds)
        #expect(comparison.resolvedRecommendations.count == expectedResolved.count)
    }

    // MARK: - 6. New Recommendations

    @Test("New recommendations are in after but not before")
    func newRecommendations() {
        let before = improvedFeed()
        let after = partialFeed()
        let comparison = auditor.compare(before: before, after: after)

        let beforeReport = auditor.audit(before)
        let afterReport = auditor.audit(after)
        let beforeIds = Set(beforeReport.recommendations.map(\.criterionId))

        // Every new recommendation should exist in after but not in before
        for newRec in comparison.newRecommendations {
            let existsInAfter = afterReport.recommendations.contains {
                $0.criterionId == newRec.criterionId
            }
            #expect(existsInAfter)
            #expect(!beforeIds.contains(newRec.criterionId))
        }

        // The new count should match expectations
        let afterIds = Set(afterReport.recommendations.map(\.criterionId))
        let expectedNew = afterIds.subtracting(beforeIds)
        #expect(comparison.newRecommendations.count == expectedNew.count)
    }

    // MARK: - 7. Grade Changes Correctly

    @Test("Grade improves from F/D to higher grade when feed is enhanced")
    func gradeChanges() {
        let before = minimalFeed()
        let after = improvedFeed()
        let comparison = auditor.compare(before: before, after: after)

        // AuditGrade Comparable: better grades are "less than" (aPlus < f)
        // so afterGrade < beforeGrade means after is a better grade
        #expect(comparison.afterGrade < comparison.beforeGrade)

        // The minimal feed with no episodes should be F or D
        let lowGrades: [AuditGrade] = [.f, .d]
        #expect(lowGrades.contains(comparison.beforeGrade))
    }

    // MARK: - 8. AuditCategoryDelta Model

    @Test("AuditCategoryDelta stores all fields correctly")
    func categoryDeltaModel() {
        let delta = AuditCategoryDelta(
            category: .metadata,
            beforeScore: 5,
            afterScore: 20,
            delta: 15
        )

        #expect(delta.category == .metadata)
        #expect(delta.beforeScore == 5)
        #expect(delta.afterScore == 20)
        #expect(delta.delta == 15)
    }

    // MARK: - 9. Static Compare Method

    @Test("FeedAuditor.compare(before:after:) works with AuditReport inputs")
    func staticCompareMethod() {
        let before = minimalFeed()
        let after = improvedFeed()

        let beforeReport = auditor.audit(before)
        let afterReport = auditor.audit(after)

        let comparison = FeedAuditor.compare(before: beforeReport, after: afterReport)

        #expect(comparison.scoreDelta == afterReport.score - beforeReport.score)
        #expect(comparison.beforeScore == beforeReport.score)
        #expect(comparison.afterScore == afterReport.score)
        #expect(comparison.beforeGrade == beforeReport.grade)
        #expect(comparison.afterGrade == afterReport.grade)

        // Category deltas should cover all 5 categories
        #expect(comparison.categoryDeltas.count == AuditCategory.allCases.count)

        // Static compare should produce the same result as instance compare
        let instanceComparison = auditor.compare(before: before, after: after)
        #expect(comparison.scoreDelta == instanceComparison.scoreDelta)
        #expect(comparison.beforeGrade == instanceComparison.beforeGrade)
        #expect(comparison.afterGrade == instanceComparison.afterGrade)
        #expect(
            comparison.resolvedRecommendations.count
                == instanceComparison.resolvedRecommendations.count)
        #expect(
            comparison.newRecommendations.count
                == instanceComparison.newRecommendations.count)
    }
}
