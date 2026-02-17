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

/// The `<podcast:episode>` element from Podcast Namespace 2.0.
///
/// Provides richer episode numbering metadata than the simple `<itunes:episode>` integer.
/// Includes a number value and an optional display string for custom formatting.
///
/// Example:
/// ```xml
/// <podcast:episode display="EP3">3</podcast:episode>
/// ```
///
/// - SeeAlso: [Podcast NS — episode](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#episode)
public struct PodcastEpisode: Sendable, Hashable, Equatable, Codable {

    /// The episode number.
    public var number: Double

    /// An optional display string for custom formatting (e.g., `"EP3"`, `"3a"`).
    public var display: String?

    /// Creates a new podcast episode number.
    ///
    /// - Parameters:
    ///   - number: The episode number (supports decimal for sub-episodes like `3.5`).
    ///   - display: Optional custom display string.
    public init(number: Double, display: String? = nil) {
        self.number = number
        self.display = display
    }
}
