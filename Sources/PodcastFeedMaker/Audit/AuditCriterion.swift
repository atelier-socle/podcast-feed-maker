// MARK: - AuditCriterion

/// Definition of a single audit criterion.
///
/// Each criterion belongs to an ``AuditCategory`` and awards up to
/// ``maxPoints`` when the corresponding feed requirement is met.
public struct AuditCriterion: Sendable, Equatable, Hashable, Codable {
    /// Unique identifier (e.g., `"metadata.artwork"`, `"episodes.enclosures"`).
    public var identifier: String

    /// Human-readable name.
    public var name: String

    /// Which category this belongs to.
    public var category: AuditCategory

    /// Maximum points this criterion can award.
    public var maxPoints: Int

    /// Creates a new audit criterion.
    public init(
        identifier: String,
        name: String,
        category: AuditCategory,
        maxPoints: Int
    ) {
        self.identifier = identifier
        self.name = name
        self.category = category
        self.maxPoints = maxPoints
    }
}

// MARK: - AuditCriterionResult

/// Result of evaluating a single criterion against a feed.
public struct AuditCriterionResult: Sendable, Equatable, Codable {
    /// The criterion that was evaluated.
    public var criterion: AuditCriterion

    /// Points awarded (0 to ``AuditCriterion/maxPoints``).
    public var pointsAwarded: Int

    /// Whether the criterion passed fully.
    public var passed: Bool

    /// Optional detail message (e.g., "3 of 10 episodes missing duration").
    public var detail: String?

    /// Creates a new criterion result.
    public init(
        criterion: AuditCriterion,
        pointsAwarded: Int,
        passed: Bool,
        detail: String? = nil
    ) {
        self.criterion = criterion
        self.pointsAwarded = pointsAwarded
        self.passed = passed
        self.detail = detail
    }
}
