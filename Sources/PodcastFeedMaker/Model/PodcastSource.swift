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

/// The `<podcast:source>` element from Podcast Namespace 2.0.
///
/// Specifies a source URI for media within an ``AlternateEnclosure``.
/// Multiple sources allow fallback locations for the same media.
///
/// Example:
/// ```xml
/// <podcast:source uri="https://example.com/ep1.opus" />
/// <podcast:source uri="ipfs://QmUNLLs..." />
/// ```
///
/// - SeeAlso: [Podcast NS — source](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#alternate-enclosure)
public struct PodcastSource: Sendable, Hashable, Equatable, Codable {

    /// The URI of the media source.
    ///
    /// Can be any URI scheme (HTTPS, IPFS, etc.).
    public var uri: String

    /// An optional content type override for this specific source.
    public var contentType: String?

    /// Creates a new podcast source.
    ///
    /// - Parameters:
    ///   - uri: The media source URI.
    ///   - contentType: Optional content type override.
    public init(uri: String, contentType: String? = nil) {
        self.uri = uri
        self.contentType = contentType
    }
}
