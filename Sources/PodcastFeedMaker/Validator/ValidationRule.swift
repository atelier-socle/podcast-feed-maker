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

/// A protocol for defining custom validation rules.
///
/// Implement this protocol to add project-specific or domain-specific
/// validation logic beyond the built-in platform rules.
///
/// ## Example
///
/// ```swift
/// struct RequireTranscriptsRule: ValidationRule {
///     func validate(_ feed: PodcastFeed) -> [ValidationResult] {
///         guard let channel = feed.channel else { return [] }
///         return channel.items.enumerated().compactMap { idx, item in
///             item.transcripts.isEmpty
///                 ? ValidationResult(
///                     severity: .warning,
///                     message: "Episode should include a transcript",
///                     field: "channel.items[\(idx)].transcripts"
///                 )
///                 : nil
///         }
///     }
/// }
/// ```
public protocol ValidationRule: Sendable {

    /// Validates a feed and returns any issues found.
    ///
    /// - Parameter feed: The ``PodcastFeed`` to validate.
    /// - Returns: An array of ``ValidationResult`` for any issues found.
    ///   Return an empty array if the feed passes this rule.
    func validate(_ feed: PodcastFeed) -> [ValidationResult]
}
