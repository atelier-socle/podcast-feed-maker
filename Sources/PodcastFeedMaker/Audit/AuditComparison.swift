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

// MARK: - AuditComparison

/// Comparison between two audit reports (before/after).
public struct AuditComparison: Sendable, Equatable, Codable {
    /// Score of the earlier feed.
    public var beforeScore: Int

    /// Score of the later feed.
    public var afterScore: Int

    /// Score delta (afterScore - beforeScore).
    public var scoreDelta: Int

    /// Grade of the earlier feed.
    public var beforeGrade: AuditGrade

    /// Grade of the later feed.
    public var afterGrade: AuditGrade

    /// Per-category deltas.
    public var categoryDeltas: [AuditCategoryDelta]

    /// Recommendations that were resolved (present in before, absent in after).
    public var resolvedRecommendations: [AuditRecommendation]

    /// New recommendations that appeared (absent in before, present in after).
    public var newRecommendations: [AuditRecommendation]

    /// Creates a new audit comparison.
    public init(
        beforeScore: Int,
        afterScore: Int,
        scoreDelta: Int,
        beforeGrade: AuditGrade,
        afterGrade: AuditGrade,
        categoryDeltas: [AuditCategoryDelta],
        resolvedRecommendations: [AuditRecommendation],
        newRecommendations: [AuditRecommendation]
    ) {
        self.beforeScore = beforeScore
        self.afterScore = afterScore
        self.scoreDelta = scoreDelta
        self.beforeGrade = beforeGrade
        self.afterGrade = afterGrade
        self.categoryDeltas = categoryDeltas
        self.resolvedRecommendations = resolvedRecommendations
        self.newRecommendations = newRecommendations
    }
}

// MARK: - AuditCategoryDelta

/// Score delta for a single audit category.
public struct AuditCategoryDelta: Sendable, Equatable, Codable {
    /// Which category.
    public var category: AuditCategory

    /// Score in the earlier report.
    public var beforeScore: Int

    /// Score in the later report.
    public var afterScore: Int

    /// Delta (afterScore - beforeScore).
    public var delta: Int

    /// Creates a new category delta.
    public init(
        category: AuditCategory,
        beforeScore: Int,
        afterScore: Int,
        delta: Int
    ) {
        self.category = category
        self.beforeScore = beforeScore
        self.afterScore = afterScore
        self.delta = delta
    }
}
