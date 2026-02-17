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
