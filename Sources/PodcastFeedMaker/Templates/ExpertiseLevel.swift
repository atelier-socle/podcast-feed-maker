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

/// The expertise level of a feed template, from basic to expert.
///
/// Each level corresponds to a built-in template that progressively adds
/// more podcast tags and namespaces. Use this to classify feeds by
/// complexity or to detect which template best matches an existing feed.
///
/// - SeeAlso: ``FeedTemplate``
public enum ExpertiseLevel: Int, CaseIterable, Hashable, Equatable, Sendable, Codable, Comparable {

    /// Minimal iTunes feed — RSS 2.0 core + basic iTunes tags.
    ///
    /// Sufficient for Apple Podcasts and Spotify submission.
    case basic = 0

    /// PSP-1 compliant feed — adds Podcast NS 2.0 essentials.
    ///
    /// Includes `podcast:locked`, `podcast:guid`, `atom:link` self,
    /// and all iTunes required tags.
    case standard = 1

    /// Podcast Namespace 2.0 phases 1-3 — rich metadata.
    ///
    /// Adds transcripts, chapters, soundbites, persons, locations,
    /// licenses, alternate enclosures, and content:encoded.
    case advanced = 2

    /// Full 7-namespace coverage — every supported tag.
    ///
    /// Includes Dublin Core, Podlove Simple Chapters, V4V,
    /// social interactions, podroll, live items, and all phase 4+ tags.
    case expert = 3

    public static func < (lhs: ExpertiseLevel, rhs: ExpertiseLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - CustomStringConvertible

extension ExpertiseLevel: CustomStringConvertible {

    public var description: String {
        switch self {
        case .basic: "basic"
        case .standard: "standard"
        case .advanced: "advanced"
        case .expert: "expert"
        }
    }
}
