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

/// Represents a podcast distribution platform for feed validation purposes.
///
/// Each platform has specific requirements for RSS feed structure, required tags,
/// artwork dimensions, and supported media formats. The ``FeedValidator`` uses
/// these platforms to check feed compliance.
///
/// - SeeAlso: ``FeedValidator``
public enum ValidationPlatform: String, CaseIterable, Hashable, Equatable, Sendable, Codable {

    /// Apple Podcasts — requires HTTPS, artwork 1400-3000px, iTunes tags.
    case apple

    /// Spotify — requires MP3, artwork 1400-2048px, max 4000 bytes description.
    case spotify

    /// Amazon Music — broadest format support, artwork 1400-3000px.
    case amazon

    /// Podcast Index — all Podcast NS 2.0 tags, V4V validation.
    case podcastIndex

    /// PSP-1 — atom:link self, podcast:locked, podcast:guid required.
    case psp1
}

/// Severity level for validation results.
///
/// Cases are ordered by severity: ``error`` > ``warning`` > ``info``.
/// Conforms to `Comparable` — `error` is the highest severity.
public enum ValidationSeverity: Int, Hashable, Equatable, Sendable, Codable, Comparable {

    /// An informational note about best practices.
    case info = 0

    /// A non-critical issue that may affect discoverability or display.
    case warning = 1

    /// A critical issue that will prevent the feed from being accepted.
    case error = 2

    public static func < (
        lhs: ValidationSeverity, rhs: ValidationSeverity
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
