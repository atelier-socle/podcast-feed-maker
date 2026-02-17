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

/// The deprecated `<podcast:images>` element from Podcast Namespace 2.0.
///
/// Uses an `srcset` attribute containing multiple image URLs with width
/// descriptors. Superseded by ``PodcastImage`` (singular `<podcast:image>`).
///
/// Parsed for round-trip fidelity but not recommended for new feed generation.
///
/// Example:
/// ```xml
/// <podcast:images srcset="https://example.com/art-1500.jpg 1500w,
///                         https://example.com/art-600.jpg 600w,
///                         https://example.com/art-300.jpg 300w" />
/// ```
///
/// - SeeAlso: ``PodcastImage``
public struct PodcastImages: Sendable, Hashable, Equatable, Codable {

    /// The `srcset` string containing multiple image URLs with width descriptors.
    ///
    /// Format: `"url1 1500w, url2 600w, url3 300w"`
    public var srcset: String

    /// Creates a new deprecated podcast images element.
    ///
    /// - Parameter srcset: The srcset attribute value.
    public init(srcset: String) {
        self.srcset = srcset
    }
}
