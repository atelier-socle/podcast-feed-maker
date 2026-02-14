// MARK: - AuditRecommendation

/// A prioritized, actionable recommendation to improve a feed.
public struct AuditRecommendation: Sendable, Equatable, Codable {
    /// Priority level.
    public var priority: Priority

    /// Related category.
    public var category: AuditCategory

    /// Related criterion identifier.
    public var criterionId: String

    /// Human-readable message explaining what is missing and why it matters.
    public var message: String

    /// Concrete suggestion (e.g., XML snippet to add).
    public var suggestion: String?

    /// Impact on score if fixed (estimated points gained).
    public var potentialPoints: Int

    /// Creates a new recommendation.
    public init(
        priority: Priority,
        category: AuditCategory,
        criterionId: String,
        message: String,
        suggestion: String? = nil,
        potentialPoints: Int
    ) {
        self.priority = priority
        self.category = category
        self.criterionId = criterionId
        self.message = message
        self.suggestion = suggestion
        self.potentialPoints = potentialPoints
    }

    /// Priority levels for recommendations.
    public enum Priority: String, Sendable, Equatable, Codable, CaseIterable, Comparable {
        /// Blocks distribution on major platforms.
        case critical
        /// Significantly improves quality.
        case recommended
        /// Bonus, best practices.
        case niceToHave

        public static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.sortOrder < rhs.sortOrder
        }

        private var sortOrder: Int {
            switch self {
            case .critical: 0
            case .recommended: 1
            case .niceToHave: 2
            }
        }
    }
}
