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

// MARK: - FeedAuditor

/// Audits a podcast feed and produces a comprehensive quality report.
///
/// The auditor evaluates 29 criteria across 5 categories:
/// **Metadata**, **Episodes**, **Compliance**, **Accessibility**,
/// and **Discoverability**. It produces a weighted global score (0–100),
/// letter grade, actionable recommendations, and a cross-platform
/// compatibility matrix.
///
/// ```swift
/// let feed = try FeedParser().parse(xml)
/// let report = FeedAuditor().audit(feed)
/// print("Score: \(report.score)/100 (\(report.grade.rawValue))")
/// ```
///
/// - SeeAlso: ``AuditReport``, ``AuditScoring``, ``AuditComparison``
public struct FeedAuditor: Sendable {

    /// Creates a new feed auditor.
    public init() {}

    /// Audit a parsed feed and return a complete report.
    public func audit(_ feed: PodcastFeed) -> AuditReport {
        let categoryScores = AuditCategory.allCases.map { category in
            AuditScoring.evaluate(category: category, feed: feed)
        }
        let score = AuditScoring.globalScore(from: categoryScores)
        let grade = AuditGrade.from(score: score)
        let recommendations = generateRecommendations(from: categoryScores)
        let compatibility = buildCompatibility(feed)

        return AuditReport(
            score: score,
            grade: grade,
            categoryScores: categoryScores,
            recommendations: recommendations,
            compatibility: compatibility,
            feedTitle: feed.channel?.title,
            episodeCount: feed.channel?.items.count ?? 0,
            auditDate: Date()
        )
    }

    /// Compare two feeds and return the evolution.
    public func compare(before: PodcastFeed, after: PodcastFeed) -> AuditComparison {
        let beforeReport = audit(before)
        let afterReport = audit(after)
        return Self.compare(before: beforeReport, after: afterReport)
    }

    /// Compare two existing reports.
    public static func compare(
        before: AuditReport,
        after: AuditReport
    ) -> AuditComparison {
        let categoryDeltas = AuditCategory.allCases.map { category in
            let bScore = before.categoryScores.first { $0.category == category }?.earned ?? 0
            let aScore = after.categoryScores.first { $0.category == category }?.earned ?? 0
            return AuditCategoryDelta(
                category: category,
                beforeScore: bScore,
                afterScore: aScore,
                delta: aScore - bScore
            )
        }

        let beforeIds = Set(before.recommendations.map(\.criterionId))
        let afterIds = Set(after.recommendations.map(\.criterionId))

        let resolved = before.recommendations.filter { !afterIds.contains($0.criterionId) }
        let new = after.recommendations.filter { !beforeIds.contains($0.criterionId) }

        return AuditComparison(
            beforeScore: before.score,
            afterScore: after.score,
            scoreDelta: after.score - before.score,
            beforeGrade: before.grade,
            afterGrade: after.grade,
            categoryDeltas: categoryDeltas,
            resolvedRecommendations: resolved,
            newRecommendations: new
        )
    }
}

// MARK: - Recommendation Generation

extension FeedAuditor {

    func generateRecommendations(
        from categoryScores: [AuditCategoryScore]
    ) -> [AuditRecommendation] {
        var recommendations: [AuditRecommendation] = []

        for categoryScore in categoryScores {
            for result in categoryScore.criteria where !result.passed {
                let priority = Self.priority(for: result.criterion)
                let message = Self.message(for: result.criterion)
                let potential = result.criterion.maxPoints - result.pointsAwarded

                guard potential > 0 else { continue }

                recommendations.append(
                    AuditRecommendation(
                        priority: priority,
                        category: categoryScore.category,
                        criterionId: result.criterion.identifier,
                        message: message,
                        potentialPoints: potential
                    ))
            }
        }

        recommendations.sort { lhs, rhs in
            if lhs.priority != rhs.priority {
                return lhs.priority < rhs.priority
            }
            return lhs.potentialPoints > rhs.potentialPoints
        }
        return recommendations
    }

    private static let criticalCriteria: Set<String> = [
        "episodes.hasEpisodes", "episodes.enclosures"
    ]

    private static let recommendedCriteria: Set<String> = [
        "metadata.artwork", "metadata.description", "metadata.owner",
        "compliance.guid", "compliance.locked", "compliance.atomSelf",
        "compliance.explicit"
    ]

    private static func priority(
        for criterion: AuditCriterion
    ) -> AuditRecommendation.Priority {
        if criticalCriteria.contains(criterion.identifier) {
            return .critical
        }
        if recommendedCriteria.contains(criterion.identifier) {
            return .recommended
        }
        return .niceToHave
    }

    static func message(for criterion: AuditCriterion) -> String {
        recommendationMessages[criterion.identifier] ?? "Improve \(criterion.name)"
    }
}

// MARK: - Recommendation Messages

extension FeedAuditor {

    private static let recommendationMessages: [String: String] = {
        var messages: [String: String] = [:]
        populateMetadataMessages(&messages)
        populateEpisodeMessages(&messages)
        populateComplianceMessages(&messages)
        populateAccessibilityMessages(&messages)
        populateDiscoverabilityMessages(&messages)
        return messages
    }()

    private static func populateMetadataMessages(_ messages: inout [String: String]) {
        messages["metadata.artwork"] =
            "Add a <itunes:image> with a square image "
            + "(1400x1400 to 3000x3000 pixels) hosted on HTTPS"
        messages["metadata.description"] =
            "Write a description of at least 100 characters that describes "
            + "your podcast's content and value proposition"
        messages["metadata.category"] =
            "Add at least one <itunes:category> to help listeners discover your podcast"
        messages["metadata.language"] =
            "Add a <language> tag (e.g., en, fr) for proper localization on platforms"
        messages["metadata.author"] =
            "Add <itunes:author> with the creator or show name"
        messages["metadata.owner"] =
            "Add <itunes:owner> with <itunes:name> and <itunes:email> "
            + "— required by Apple Podcasts"
        messages["metadata.link"] =
            "Add a <link> to your podcast's website (HTTPS preferred)"
        messages["metadata.copyright"] =
            "Add a <copyright> notice to protect your content"
    }

    private static func populateEpisodeMessages(_ messages: inout [String: String]) {
        messages["episodes.hasEpisodes"] =
            "Your feed has no episodes. Add at least one <item> with an enclosure"
        messages["episodes.enclosures"] =
            "Ensure every episode has a valid <enclosure> with url, type, "
            + "and length attributes"
        messages["episodes.durations"] =
            "Add <itunes:duration> to each episode for proper display on podcast apps"
        messages["episodes.uniqueGuids"] =
            "Each episode must have a unique <guid>"
        messages["episodes.descriptions"] =
            "Write meaningful descriptions (>50 chars) for each episode"
        messages["episodes.pubDates"] =
            "Add valid RFC 822 <pubDate> to each episode for proper sorting"
    }

    private static func populateComplianceMessages(_ messages: inout [String: String]) {
        messages["compliance.locked"] =
            "Add <podcast:locked> to prevent unauthorized feed moves"
        messages["compliance.guid"] =
            "Add <podcast:guid> with a UUID v4 to guarantee "
            + "feed portability across platforms"
        messages["compliance.atomSelf"] =
            "Add <atom:link rel=\"self\"> pointing to your feed URL for autodiscovery"
        messages["compliance.explicit"] =
            "Set <itunes:explicit> to true or false — required by Apple Podcasts"
        messages["compliance.type"] =
            "Set <itunes:type> to episodic or serial for proper episode ordering"
        messages["compliance.episodeArtwork"] =
            "Add episode-level <itunes:image> for visual differentiation in podcast apps"
    }

    private static func populateAccessibilityMessages(_ messages: inout [String: String]) {
        messages["accessibility.transcripts"] =
            "Add <podcast:transcript> to improve accessibility and SEO "
            + "— recommended by Podcast Index"
        messages["accessibility.chapters"] =
            "Add <podcast:chapters> for interactive navigation within episodes"
        messages["accessibility.richDescriptions"] =
            "Use <content:encoded> with HTML for rich episode descriptions"
    }

    private static func populateDiscoverabilityMessages(_ messages: inout [String: String]) {
        messages["discoverability.keywords"] =
            "Add keywords to improve discoverability via <podcast:txt> "
            + "or <itunes:keywords>"
        messages["discoverability.funding"] =
            "Add <podcast:funding> to let listeners support your podcast financially"
        messages["discoverability.social"] =
            "Add <podcast:socialInteract> to enable comments and social engagement"
        messages["discoverability.podroll"] =
            "Add <podcast:podroll> to cross-promote related podcasts"
        messages["discoverability.updateFrequency"] =
            "Set <podcast:updateFrequency> so apps know when to check for new episodes"
    }
}

// MARK: - Platform Compatibility

extension FeedAuditor {

    func buildCompatibility(_ feed: PodcastFeed) -> [PlatformCompatibilityResult] {
        let validator = FeedValidator()
        return ValidationPlatform.allCases.map { platform in
            let report = validator.validate(feed, for: platform)
            let status: PlatformCompatibilityResult.CompatibilityStatus
            if !report.errors.isEmpty {
                status = .incompatible
            } else if !report.warnings.isEmpty {
                status = .warnings
            } else {
                status = .ok
            }
            return PlatformCompatibilityResult(
                platform: platform.displayName,
                isCompatible: report.isValid,
                errorCount: report.errors.count,
                warningCount: report.warnings.count,
                status: status
            )
        }
    }
}

// MARK: - ValidationPlatform Display Name

extension ValidationPlatform {
    var displayName: String {
        switch self {
        case .apple: "Apple Podcasts"
        case .spotify: "Spotify"
        case .amazon: "Amazon Music"
        case .podcastIndex: "Podcast Index"
        case .psp1: "PSP-1"
        }
    }
}
