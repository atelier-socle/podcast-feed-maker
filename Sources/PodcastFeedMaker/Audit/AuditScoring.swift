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

// MARK: - AuditScoring

/// Weighted scoring engine for feed audits.
///
/// Evaluates all criteria in each ``AuditCategory`` against a ``PodcastFeed``
/// and computes per-category and global scores.
public struct AuditScoring: Sendable {

    /// Evaluate all criteria for a category against a feed.
    public static func evaluate(
        category: AuditCategory,
        feed: PodcastFeed
    ) -> AuditCategoryScore {
        let results: [AuditCriterionResult]
        switch category {
        case .metadata: results = evaluateMetadata(feed)
        case .episodes: results = evaluateEpisodes(feed)
        case .compliance: results = evaluateCompliance(feed)
        case .accessibility: results = evaluateAccessibility(feed)
        case .discoverability: results = evaluateDiscoverability(feed)
        }

        let earned = results.reduce(0) { $0 + $1.pointsAwarded }
        let maximum = category.maxPoints
        let percentage = maximum > 0 ? Double(earned) / Double(maximum) : 0
        let weightedScore = percentage * category.weight * 100

        return AuditCategoryScore(
            category: category,
            earned: earned,
            maximum: maximum,
            weightedScore: weightedScore,
            criteria: results
        )
    }

    /// Calculate the global weighted score from category scores.
    public static func globalScore(from categoryScores: [AuditCategoryScore]) -> Int {
        let total = categoryScores.reduce(0.0) { $0 + $1.weightedScore }
        return Int(total.rounded())
    }
}

// MARK: - Criteria Definitions

extension AuditScoring {

    // MARK: Metadata Criteria

    static let metadataArtwork = AuditCriterion(
        identifier: "metadata.artwork", name: "Artwork",
        category: .metadata, maxPoints: 5
    )
    static let metadataDescription = AuditCriterion(
        identifier: "metadata.description", name: "Description",
        category: .metadata, maxPoints: 4
    )
    static let metadataCategory = AuditCriterion(
        identifier: "metadata.category", name: "Category",
        category: .metadata, maxPoints: 3
    )
    static let metadataLanguage = AuditCriterion(
        identifier: "metadata.language", name: "Language",
        category: .metadata, maxPoints: 3
    )
    static let metadataAuthor = AuditCriterion(
        identifier: "metadata.author", name: "Author",
        category: .metadata, maxPoints: 3
    )
    static let metadataOwner = AuditCriterion(
        identifier: "metadata.owner", name: "Owner",
        category: .metadata, maxPoints: 3
    )
    static let metadataLink = AuditCriterion(
        identifier: "metadata.link", name: "Link",
        category: .metadata, maxPoints: 2
    )
    static let metadataCopyright = AuditCriterion(
        identifier: "metadata.copyright", name: "Copyright",
        category: .metadata, maxPoints: 2
    )

    // MARK: Episodes Criteria

    static let episodesHasEpisodes = AuditCriterion(
        identifier: "episodes.hasEpisodes", name: "Has Episodes",
        category: .episodes, maxPoints: 5
    )
    static let episodesEnclosures = AuditCriterion(
        identifier: "episodes.enclosures", name: "Valid Enclosures",
        category: .episodes, maxPoints: 5
    )
    static let episodesDurations = AuditCriterion(
        identifier: "episodes.durations", name: "Durations",
        category: .episodes, maxPoints: 4
    )
    static let episodesUniqueGuids = AuditCriterion(
        identifier: "episodes.uniqueGuids", name: "Unique GUIDs",
        category: .episodes, maxPoints: 4
    )
    static let episodesDescriptions = AuditCriterion(
        identifier: "episodes.descriptions", name: "Episode Descriptions",
        category: .episodes, maxPoints: 4
    )
    static let episodesPubDates = AuditCriterion(
        identifier: "episodes.pubDates", name: "Publication Dates",
        category: .episodes, maxPoints: 3
    )

    // MARK: Compliance Criteria

    static let complianceLocked = AuditCriterion(
        identifier: "compliance.locked", name: "Podcast Locked",
        category: .compliance, maxPoints: 4
    )
    static let complianceGuid = AuditCriterion(
        identifier: "compliance.guid", name: "Podcast GUID",
        category: .compliance, maxPoints: 4
    )
    static let complianceAtomSelf = AuditCriterion(
        identifier: "compliance.atomSelf", name: "Atom Self Link",
        category: .compliance, maxPoints: 3
    )
    static let complianceExplicit = AuditCriterion(
        identifier: "compliance.explicit", name: "iTunes Explicit",
        category: .compliance, maxPoints: 3
    )
    static let complianceType = AuditCriterion(
        identifier: "compliance.type", name: "iTunes Type",
        category: .compliance, maxPoints: 3
    )
    static let complianceEpisodeArtwork = AuditCriterion(
        identifier: "compliance.episodeArtwork", name: "Episode Artwork",
        category: .compliance, maxPoints: 3
    )

    // MARK: Accessibility Criteria

    static let accessibilityTranscripts = AuditCriterion(
        identifier: "accessibility.transcripts", name: "Transcripts",
        category: .accessibility, maxPoints: 5
    )
    static let accessibilityChapters = AuditCriterion(
        identifier: "accessibility.chapters", name: "Chapters",
        category: .accessibility, maxPoints: 4
    )
    static let accessibilityRichDescriptions = AuditCriterion(
        identifier: "accessibility.richDescriptions", name: "Rich Descriptions",
        category: .accessibility, maxPoints: 3
    )
    /// Alt text artwork — awarded by default since no spec supports it yet.
    static let accessibilityAltText = AuditCriterion(
        identifier: "accessibility.altText", name: "Alt Text Artwork",
        category: .accessibility, maxPoints: 3
    )

    // MARK: Discoverability Criteria

    static let discoverabilityKeywords = AuditCriterion(
        identifier: "discoverability.keywords", name: "Keywords/Tags",
        category: .discoverability, maxPoints: 3
    )
    static let discoverabilityFunding = AuditCriterion(
        identifier: "discoverability.funding", name: "Funding",
        category: .discoverability, maxPoints: 3
    )
    static let discoverabilitySocial = AuditCriterion(
        identifier: "discoverability.social", name: "Social Interact",
        category: .discoverability, maxPoints: 3
    )
    static let discoverabilityPodroll = AuditCriterion(
        identifier: "discoverability.podroll", name: "Podroll",
        category: .discoverability, maxPoints: 3
    )
    static let discoverabilityUpdateFrequency = AuditCriterion(
        identifier: "discoverability.updateFrequency", name: "Update Frequency",
        category: .discoverability, maxPoints: 3
    )
}
