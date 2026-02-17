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

/// The `<podcast:license>` element from Podcast Namespace 2.0.
///
/// Specifies the license under which the podcast (channel-level) or
/// an individual episode (item-level) is released.
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:license url="https://creativecommons.org/licenses/by/4.0/">cc-by-4.0</podcast:license>
/// ```
///
/// - SeeAlso: [Podcast NS — license](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#license)
public struct PodcastLicense: Sendable, Hashable, Equatable, Codable {

    /// The license identifier (e.g., `"cc-by-4.0"`, `"cc-by-sa-4.0"`).
    public var identifier: String

    /// An optional URL to the full license text.
    public var url: URL?

    /// Creates a new podcast license.
    ///
    /// - Parameters:
    ///   - identifier: The license identifier string.
    ///   - url: Optional URL to the license text.
    public init(identifier: String, url: URL? = nil) {
        self.identifier = identifier
        self.url = url
    }
}
