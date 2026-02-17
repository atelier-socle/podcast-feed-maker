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

/// The `<podcast:integrity>` element from Podcast Namespace 2.0.
///
/// Provides a verification hash for media file integrity within
/// an ``AlternateEnclosure``.
///
/// Example:
/// ```xml
/// <podcast:integrity type="sri" value="sha256-C7yR...base64..." />
/// ```
///
/// - SeeAlso: [Podcast NS — integrity](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#alternate-enclosure)
public struct PodcastIntegrity: Sendable, Hashable, Equatable, Codable {

    /// The integrity check type (e.g., `"sri"` for Subresource Integrity).
    public var type: String

    /// The hash value for verification.
    public var value: String

    /// Creates a new integrity check.
    ///
    /// - Parameters:
    ///   - type: The integrity type (e.g., `"sri"`).
    ///   - value: The hash value.
    public init(type: String, value: String) {
        self.type = type
        self.value = value
    }
}
