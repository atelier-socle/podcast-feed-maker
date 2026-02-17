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

/// The `<podcast:txt>` element from Podcast Namespace 2.0.
///
/// A free-form text element that can hold various metadata such as
/// verification strings, attribution text, or other custom values.
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:txt purpose="verify">S6lpp-7ZCn8-VZNOk</podcast:txt>
/// ```
///
/// - SeeAlso: [Podcast NS — txt](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#txt)
public struct PodcastTxt: Sendable, Hashable, Equatable, Codable {

    /// The text content.
    public var value: String

    /// An optional purpose identifier that describes the text's use.
    ///
    /// Common values: `"verify"` for domain verification strings.
    public var purpose: String?

    /// Creates a new podcast txt element.
    ///
    /// - Parameters:
    ///   - value: The text content.
    ///   - purpose: Optional purpose identifier.
    public init(value: String, purpose: String? = nil) {
        self.value = value
        self.purpose = purpose
    }
}
