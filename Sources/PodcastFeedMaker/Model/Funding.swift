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

/// The `<podcast:funding>` element from Podcast Namespace 2.0.
///
/// Points listeners to a donation or support page for the podcast.
/// Multiple funding elements are allowed per channel.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:funding url="https://example.com/donate">Support the show</podcast:funding>
/// ```
///
/// - SeeAlso: [Podcast NS — funding](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#funding)
public struct Funding: Sendable, Hashable, Equatable, Codable {

    /// The URL to the funding or donation page.
    public var url: URL

    /// A human-readable label for the funding link.
    public var message: String

    /// Creates a new funding element.
    ///
    /// - Parameters:
    ///   - url: The funding page URL.
    ///   - message: A descriptive label (e.g., "Support the show").
    public init(url: URL, message: String) {
        self.url = url
        self.message = message
    }
}
