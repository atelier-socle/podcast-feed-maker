import Foundation

// MARK: - AuditReport

/// Complete audit report for a podcast feed.
///
/// Contains the global score, per-category breakdowns, prioritized
/// recommendations, and a cross-platform compatibility matrix.
public struct AuditReport: Sendable, Equatable, Codable {
    /// Global score 0–100.
    public var score: Int

    /// Letter grade (A+ to F).
    public var grade: AuditGrade

    /// Per-category scores.
    public var categoryScores: [AuditCategoryScore]

    /// Prioritized recommendations.
    public var recommendations: [AuditRecommendation]

    /// Platform compatibility matrix.
    public var compatibility: [PlatformCompatibilityResult]

    /// Feed title (from channel, if present).
    public var feedTitle: String?

    /// Number of episodes in the feed.
    public var episodeCount: Int

    /// When the audit was performed.
    public var auditDate: Date

    /// Creates a new audit report.
    public init(
        score: Int,
        grade: AuditGrade,
        categoryScores: [AuditCategoryScore],
        recommendations: [AuditRecommendation],
        compatibility: [PlatformCompatibilityResult],
        feedTitle: String? = nil,
        episodeCount: Int,
        auditDate: Date
    ) {
        self.score = score
        self.grade = grade
        self.categoryScores = categoryScores
        self.recommendations = recommendations
        self.compatibility = compatibility
        self.feedTitle = feedTitle
        self.episodeCount = episodeCount
        self.auditDate = auditDate
    }
}

// MARK: - AuditCategoryScore

/// Score for a single audit category.
public struct AuditCategoryScore: Sendable, Equatable, Codable {
    /// Which category.
    public var category: AuditCategory

    /// Points earned.
    public var earned: Int

    /// Maximum possible points.
    public var maximum: Int

    /// Weighted contribution to global score.
    public var weightedScore: Double

    /// Individual criterion results.
    public var criteria: [AuditCriterionResult]

    /// Percentage (earned / maximum x 100).
    public var percentage: Int {
        guard maximum > 0 else { return 0 }
        return earned * 100 / maximum
    }

    /// Creates a new category score.
    public init(
        category: AuditCategory,
        earned: Int,
        maximum: Int,
        weightedScore: Double,
        criteria: [AuditCriterionResult]
    ) {
        self.category = category
        self.earned = earned
        self.maximum = maximum
        self.weightedScore = weightedScore
        self.criteria = criteria
    }
}
