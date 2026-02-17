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

/// The `<podcast:person>` element from Podcast Namespace 2.0.
///
/// Identifies a person of interest related to the podcast or episode,
/// such as hosts, guests, editors, or producers.
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:person href="https://example.com/john" img="https://example.com/john.jpg"
///                 role="host" group="cast">John Doe</podcast:person>
/// ```
///
/// - SeeAlso: [Podcast NS — person](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#person)
public struct PodcastPerson: Sendable, Hashable, Equatable, Codable {

    /// The person's name.
    public var name: String

    /// The role of the person (e.g., `"host"`, `"guest"`, `"editor"`).
    ///
    /// Uses the Podcast Taxonomy roles. If `nil`, defaults to `"host"`.
    public var role: String?

    /// The group the person belongs to (e.g., `"cast"`, `"writing"`, `"creative direction"`).
    ///
    /// Uses the Podcast Taxonomy groups. If `nil`, defaults to `"cast"`.
    public var group: String?

    /// A URL to a page about the person.
    public var href: URL?

    /// A URL to an image of the person.
    public var img: URL?

    /// Creates a new podcast person.
    ///
    /// - Parameters:
    ///   - name: The person's name.
    ///   - role: Optional role (defaults to `"host"` if omitted).
    ///   - group: Optional group (defaults to `"cast"` if omitted).
    ///   - href: Optional URL to a page about the person.
    ///   - img: Optional URL to the person's image.
    public init(
        name: String,
        role: String? = nil,
        group: String? = nil,
        href: URL? = nil,
        img: URL? = nil
    ) {
        self.name = name
        self.role = role
        self.group = group
        self.href = href
        self.img = img
    }
}
