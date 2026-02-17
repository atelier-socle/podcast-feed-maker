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

// MARK: - AuditGrade

/// Letter grade based on score ranges.
///
/// | Grade | Score Range |
/// |-------|-------------|
/// | A+    | 95–100      |
/// | A     | 90–94       |
/// | B+    | 85–89       |
/// | B     | 80–84       |
/// | C+    | 75–79       |
/// | C     | 70–74       |
/// | D     | 60–69       |
/// | F     | 0–59        |
public enum AuditGrade: String, Sendable, Equatable, Codable, CaseIterable, Comparable {
    case aPlus = "A+"
    case a = "A"
    case bPlus = "B+"
    case b = "B"
    case cPlus = "C+"
    case c = "C"
    case d = "D"
    case f = "F"

    /// Derives a grade from a numeric score (0–100).
    public static func from(score: Int) -> AuditGrade {
        switch score {
        case 95...100: .aPlus
        case 90...94: .a
        case 85...89: .bPlus
        case 80...84: .b
        case 75...79: .cPlus
        case 70...74: .c
        case 60...69: .d
        default: .f
        }
    }

    // Comparable uses declaration order: aPlus (best) < f (worst) in raw enum,
    // but we want aPlus > f semantically. We override to reflect "higher is better".
    public static func < (lhs: AuditGrade, rhs: AuditGrade) -> Bool {
        lhs.numericOrder > rhs.numericOrder
    }

    /// Internal ordering — higher value = better grade.
    private var numericOrder: Int {
        switch self {
        case .aPlus: 7
        case .a: 6
        case .bPlus: 5
        case .b: 4
        case .cPlus: 3
        case .c: 2
        case .d: 1
        case .f: 0
        }
    }
}
