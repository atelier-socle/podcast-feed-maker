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

// MARK: - AuditGrade Showcase

@Suite("Audit Grade Showcase")
struct AuditGradeShowcase {

    @Test("All 8 grades are defined and CaseIterable")
    func allGrades() {
        let grades = AuditGrade.allCases
        #expect(grades.count == 8)
        #expect(grades.contains(.aPlus))
        #expect(grades.contains(.a))
        #expect(grades.contains(.bPlus))
        #expect(grades.contains(.b))
        #expect(grades.contains(.cPlus))
        #expect(grades.contains(.c))
        #expect(grades.contains(.d))
        #expect(grades.contains(.f))
    }

    @Test(
        "from(score:) maps score ranges to correct grades",
        arguments: [
            (100, "A+"), (95, "A+"), (94, "A"), (90, "A"),
            (89, "B+"), (85, "B+"), (84, "B"), (80, "B"),
            (79, "C+"), (75, "C+"), (74, "C"), (70, "C"),
            (69, "D"), (60, "D"), (59, "F"), (0, "F")
        ] as [(Int, String)]
    )
    func fromScore(score: Int, expected: String) {
        #expect(AuditGrade.from(score: score).rawValue == expected)
    }

    @Test("Comparable: better grades sort first (aPlus < a < ... < f)")
    func comparableOrdering() {
        #expect(AuditGrade.aPlus < AuditGrade.a)
        #expect(AuditGrade.a < AuditGrade.bPlus)
        #expect(AuditGrade.bPlus < AuditGrade.b)
        #expect(AuditGrade.d < AuditGrade.f)
        let sorted = [AuditGrade.f, .aPlus, .c, .a].sorted()
        #expect(sorted == [.aPlus, .a, .c, .f])
    }

    @Test("Codable round-trip preserves raw values")
    func codableRoundTrip() throws {
        let original = AuditGrade.bPlus
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AuditGrade.self, from: data)
        #expect(decoded == original)
        #expect(decoded.rawValue == "B+")
    }
}

// MARK: - AuditCategory Showcase

@Suite("Audit Category Showcase")
struct AuditCategoryShowcase {

    @Test("All 5 categories are CaseIterable")
    func caseIterable() {
        let categories = AuditCategory.allCases
        #expect(categories.count == 5)
        #expect(categories.contains(.metadata))
        #expect(categories.contains(.episodes))
        #expect(categories.contains(.compliance))
        #expect(categories.contains(.accessibility))
        #expect(categories.contains(.discoverability))
    }

    @Test("Category weights sum to 1.0")
    func weightsSumToOne() {
        let total = AuditCategory.allCases.reduce(0.0) { $0 + $1.weight }
        #expect(abs(total - 1.0) < 0.001)
    }

    @Test("Each category has a human-readable displayName")
    func displayNames() {
        #expect(AuditCategory.metadata.displayName == "Metadata")
        #expect(AuditCategory.episodes.displayName == "Episodes")
        #expect(AuditCategory.compliance.displayName == "Compliance")
        #expect(AuditCategory.accessibility.displayName == "Accessibility")
        #expect(AuditCategory.discoverability.displayName == "Discoverability")
    }

    @Test("MaxPoints match expected allocations totaling 100")
    func maxPoints() {
        #expect(AuditCategory.metadata.maxPoints == 25)
        #expect(AuditCategory.episodes.maxPoints == 25)
        #expect(AuditCategory.compliance.maxPoints == 20)
        #expect(AuditCategory.accessibility.maxPoints == 15)
        #expect(AuditCategory.discoverability.maxPoints == 15)
        let total = AuditCategory.allCases.reduce(0) { $0 + $1.maxPoints }
        #expect(total == 100)
    }
}

// MARK: - AuditCriterion Showcase

@Suite("Audit Criterion Showcase")
struct AuditCriterionShowcase {

    @Test("Criterion stores all fields correctly")
    func criterionFields() {
        let criterion = AuditCriterion(
            identifier: "test.field",
            name: "Test Field",
            category: .metadata,
            maxPoints: 5
        )
        #expect(criterion.identifier == "test.field")
        #expect(criterion.name == "Test Field")
        #expect(criterion.category == .metadata)
        #expect(criterion.maxPoints == 5)
    }

    @Test("CriterionResult records evaluation outcome")
    func criterionResult() {
        let criterion = AuditCriterion(
            identifier: "meta.art",
            name: "Artwork",
            category: .metadata,
            maxPoints: 5
        )
        let result = AuditCriterionResult(
            criterion: criterion,
            pointsAwarded: 5,
            passed: true,
            detail: "HTTPS artwork found"
        )
        #expect(result.passed)
        #expect(result.pointsAwarded == 5)
        #expect(result.detail == "HTTPS artwork found")
    }

    @Test("Partial scoring awards fewer than maxPoints")
    func partialScoring() {
        let criterion = AuditCriterion(
            identifier: "meta.desc",
            name: "Description",
            category: .metadata,
            maxPoints: 4
        )
        let result = AuditCriterionResult(
            criterion: criterion,
            pointsAwarded: 2,
            passed: false,
            detail: "Description is only 50 characters"
        )
        #expect(!result.passed)
        #expect(result.pointsAwarded < criterion.maxPoints)
    }
}

// MARK: - AuditReport Showcase

@Suite("Audit Report Showcase")
struct AuditReportShowcase {

    @Test("Report contains all expected fields")
    func fullReport() {
        let score = AuditCategoryScore(
            category: .metadata,
            earned: 20,
            maximum: 25,
            weightedScore: 20.0,
            criteria: []
        )
        let rec = AuditRecommendation(
            priority: .recommended,
            category: .metadata,
            criterionId: "metadata.copyright",
            message: "Add copyright",
            potentialPoints: 2
        )
        let compat = PlatformCompatibilityResult(
            platform: "Apple Podcasts",
            isCompatible: true,
            errorCount: 0,
            warningCount: 1,
            status: .warnings
        )
        let report = AuditReport(
            score: 80,
            grade: .b,
            categoryScores: [score],
            recommendations: [rec],
            compatibility: [compat],
            feedTitle: "Test Podcast",
            episodeCount: 5,
            auditDate: Date()
        )
        #expect(report.score == 80)
        #expect(report.grade == .b)
        #expect(report.categoryScores.count == 1)
        #expect(report.recommendations.count == 1)
        #expect(report.compatibility.count == 1)
        #expect(report.feedTitle == "Test Podcast")
        #expect(report.episodeCount == 5)
    }

    @Test("Report metadata captures feed title and episode count")
    func reportMetadata() {
        let report = AuditReport(
            score: 95,
            grade: .aPlus,
            categoryScores: [],
            recommendations: [],
            compatibility: [],
            feedTitle: "My Show",
            episodeCount: 42,
            auditDate: Date()
        )
        #expect(report.feedTitle == "My Show")
        #expect(report.episodeCount == 42)
    }

    @Test("Report is Codable with JSON round-trip")
    func codableJSON() throws {
        let report = AuditReport(
            score: 72,
            grade: .c,
            categoryScores: [],
            recommendations: [],
            compatibility: [],
            episodeCount: 0,
            auditDate: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let data = try JSONEncoder().encode(report)
        let decoded = try JSONDecoder().decode(AuditReport.self, from: data)
        #expect(decoded.score == 72)
        #expect(decoded.grade == .c)
    }

    @Test("Report conforms to Sendable")
    func sendable() {
        let report = AuditReport(
            score: 90,
            grade: .a,
            categoryScores: [],
            recommendations: [],
            compatibility: [],
            episodeCount: 1,
            auditDate: Date()
        )
        let sendCheck: any Sendable = report
        #expect(sendCheck is AuditReport)
    }
}

// MARK: - AuditRecommendation Showcase

@Suite("Audit Recommendation Showcase")
struct AuditRecommendationShowcase {

    @Test("Recommendation stores all fields including optional suggestion")
    func allFields() {
        let rec = AuditRecommendation(
            priority: .critical,
            category: .episodes,
            criterionId: "episodes.enclosures",
            message: "Add enclosures to all episodes",
            suggestion: "<enclosure url=\"...\" length=\"...\" type=\"audio/mpeg\"/>",
            potentialPoints: 5
        )
        #expect(rec.priority == .critical)
        #expect(rec.category == .episodes)
        #expect(rec.criterionId == "episodes.enclosures")
        #expect(rec.message == "Add enclosures to all episodes")
        #expect(rec.suggestion != nil)
        #expect(rec.potentialPoints == 5)
    }

    @Test("Priority has 3 cases and is CaseIterable")
    func priorityCaseIterable() {
        let priorities = AuditRecommendation.Priority.allCases
        #expect(priorities.count == 3)
        #expect(priorities.contains(.critical))
        #expect(priorities.contains(.recommended))
        #expect(priorities.contains(.niceToHave))
    }

    @Test("Priority Comparable: critical sorts before recommended before niceToHave")
    func priorityComparable() {
        #expect(AuditRecommendation.Priority.critical < .recommended)
        #expect(AuditRecommendation.Priority.recommended < .niceToHave)
        let sorted: [AuditRecommendation.Priority] = [.niceToHave, .critical, .recommended].sorted()
        #expect(sorted == [.critical, .recommended, .niceToHave])
    }

    @Test("Recommendations sort by priority then by potential points descending")
    func sortedRecommendations() {
        let recs = [
            AuditRecommendation(
                priority: .niceToHave, category: .discoverability,
                criterionId: "d.k", message: "Keywords", potentialPoints: 3
            ),
            AuditRecommendation(
                priority: .critical, category: .episodes,
                criterionId: "e.enc", message: "Enclosures", potentialPoints: 5
            ),
            AuditRecommendation(
                priority: .recommended, category: .metadata,
                criterionId: "m.art", message: "Artwork", potentialPoints: 5
            ),
            AuditRecommendation(
                priority: .critical, category: .episodes,
                criterionId: "e.has", message: "Has episodes", potentialPoints: 3
            )
        ]
        let sorted = recs.sorted { lhs, rhs in
            if lhs.priority != rhs.priority { return lhs.priority < rhs.priority }
            return lhs.potentialPoints > rhs.potentialPoints
        }
        #expect(sorted[0].criterionId == "e.enc")
        #expect(sorted[1].criterionId == "e.has")
        #expect(sorted[2].criterionId == "m.art")
        #expect(sorted[3].criterionId == "d.k")
    }
}

// MARK: - PlatformCompatibility Showcase

@Suite("Platform Compatibility Showcase")
struct PlatformCompatibilityShowcase {

    @Test("PlatformCompatibilityResult stores all fields")
    func allFields() {
        let result = PlatformCompatibilityResult(
            platform: "Spotify",
            isCompatible: true,
            errorCount: 0,
            warningCount: 2,
            status: .warnings
        )
        #expect(result.platform == "Spotify")
        #expect(result.isCompatible)
        #expect(result.errorCount == 0)
        #expect(result.warningCount == 2)
        #expect(result.status == .warnings)
    }

    @Test("CompatibilityStatus has 3 cases: ok, warnings, incompatible")
    func statusCases() {
        let ok = PlatformCompatibilityResult.CompatibilityStatus.ok
        let warn = PlatformCompatibilityResult.CompatibilityStatus.warnings
        let bad = PlatformCompatibilityResult.CompatibilityStatus.incompatible
        #expect(ok.rawValue == "ok")
        #expect(warn.rawValue == "warnings")
        #expect(bad.rawValue == "incompatible")
    }

    @Test("FeedAuditor produces compatibility results for all 5 platforms")
    func fivePlatforms() {
        let channel = Channel(
            title: "Compat Test",
            link: makeURL("https://example.com"),
            description: "Testing compatibility",
            items: [
                Item(
                    title: "Ep 1",
                    enclosure: Enclosure(
                        url: makeURL("https://example.com/ep1.mp3"),
                        length: 1024,
                        type: "audio/mpeg"
                    )
                )
            ]
        )
        let feed = PodcastFeed(channel: channel)
        let report = FeedAuditor().audit(feed)
        #expect(report.compatibility.count == 5)
        let platforms = Set(report.compatibility.map(\.platform))
        #expect(platforms.contains("Apple Podcasts"))
        #expect(platforms.contains("Spotify"))
        #expect(platforms.contains("Amazon Music"))
        #expect(platforms.contains("Podcast Index"))
        #expect(platforms.contains("PSP-1"))
    }
}

// MARK: - AuditComparison Showcase

@Suite("Audit Comparison Showcase")
struct AuditComparisonShowcase {

    @Test("Score delta is afterScore minus beforeScore")
    func scoreDelta() {
        let comparison = AuditComparison(
            beforeScore: 60,
            afterScore: 85,
            scoreDelta: 25,
            beforeGrade: .d,
            afterGrade: .bPlus,
            categoryDeltas: [],
            resolvedRecommendations: [],
            newRecommendations: []
        )
        #expect(comparison.scoreDelta == 25)
        #expect(comparison.afterScore - comparison.beforeScore == comparison.scoreDelta)
    }

    @Test("Grade change is tracked between before and after")
    func gradeChange() {
        let comparison = AuditComparison(
            beforeScore: 55,
            afterScore: 92,
            scoreDelta: 37,
            beforeGrade: .f,
            afterGrade: .a,
            categoryDeltas: [],
            resolvedRecommendations: [],
            newRecommendations: []
        )
        #expect(comparison.beforeGrade == .f)
        #expect(comparison.afterGrade == .a)
    }

    @Test("Category deltas track per-category changes")
    func categoryDeltas() {
        let delta = AuditCategoryDelta(
            category: .metadata,
            beforeScore: 15,
            afterScore: 23,
            delta: 8
        )
        #expect(delta.category == .metadata)
        #expect(delta.delta == 8)
        #expect(delta.afterScore - delta.beforeScore == delta.delta)
    }

    @Test("Resolved and new recommendations are tracked separately")
    func resolvedAndNewRecs() {
        let resolved = AuditRecommendation(
            priority: .critical, category: .episodes,
            criterionId: "episodes.enclosures", message: "Fixed", potentialPoints: 5
        )
        let new = AuditRecommendation(
            priority: .niceToHave, category: .discoverability,
            criterionId: "discoverability.podroll", message: "New", potentialPoints: 3
        )
        let comparison = AuditComparison(
            beforeScore: 70,
            afterScore: 75,
            scoreDelta: 5,
            beforeGrade: .c,
            afterGrade: .cPlus,
            categoryDeltas: [],
            resolvedRecommendations: [resolved],
            newRecommendations: [new]
        )
        #expect(comparison.resolvedRecommendations.count == 1)
        #expect(comparison.newRecommendations.count == 1)
        #expect(comparison.resolvedRecommendations[0].criterionId == "episodes.enclosures")
        #expect(comparison.newRecommendations[0].criterionId == "discoverability.podroll")
    }
}

// MARK: - AuditCategoryScore Showcase

@Suite("Audit Category Score Showcase")
struct AuditCategoryScoreShowcase {

    @Test("Percentage is computed from earned and maximum")
    func percentage() {
        let score = AuditCategoryScore(
            category: .metadata,
            earned: 20,
            maximum: 25,
            weightedScore: 20.0,
            criteria: []
        )
        #expect(score.percentage == 80)
    }

    @Test("Percentage is 0 when maximum is 0")
    func percentageZeroMax() {
        let score = AuditCategoryScore(
            category: .metadata,
            earned: 0,
            maximum: 0,
            weightedScore: 0,
            criteria: []
        )
        #expect(score.percentage == 0)
    }
}
