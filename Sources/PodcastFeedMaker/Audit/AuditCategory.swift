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

// MARK: - AuditCategory

/// The 5 audit categories with their weights and point allocations.
///
/// Each category contributes a weighted fraction to the global score:
/// - **Metadata** (25%): Channel metadata quality
/// - **Episodes** (25%): Episode completeness and quality
/// - **Compliance** (20%): Standards conformity (PSP-1, Podcast NS)
/// - **Accessibility** (15%): Transcripts, chapters, rich descriptions
/// - **Discoverability** (15%): SEO, keywords, links, social
public enum AuditCategory: String, Sendable, Equatable, Hashable, Codable, CaseIterable {
    case metadata
    case episodes
    case compliance
    case accessibility
    case discoverability

    /// Weight as a fraction — all weights sum to 1.0.
    public var weight: Double {
        switch self {
        case .metadata: 0.25
        case .episodes: 0.25
        case .compliance: 0.20
        case .accessibility: 0.15
        case .discoverability: 0.15
        }
    }

    /// Human-readable display name.
    public var displayName: String {
        switch self {
        case .metadata: "Metadata"
        case .episodes: "Episodes"
        case .compliance: "Compliance"
        case .accessibility: "Accessibility"
        case .discoverability: "Discoverability"
        }
    }

    /// Maximum raw points for this category.
    public var maxPoints: Int {
        switch self {
        case .metadata: 25
        case .episodes: 25
        case .compliance: 20
        case .accessibility: 15
        case .discoverability: 15
        }
    }
}
