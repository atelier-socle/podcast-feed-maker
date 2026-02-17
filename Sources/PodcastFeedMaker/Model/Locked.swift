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

/// The `<podcast:locked>` element from Podcast Namespace 2.0.
///
/// Tells podcast hosting platforms whether the feed owner has locked
/// the feed to prevent it from being imported by other platforms.
///
/// - Important: Channel-level only. Required by PSP-1.
///
/// Example:
/// ```xml
/// <podcast:locked owner="john@example.com">yes</podcast:locked>
/// ```
///
/// - SeeAlso: [Podcast NS — locked](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#locked)
public struct Locked: Sendable, Hashable, Equatable, Codable {

    /// Whether the feed is locked.
    public var isLocked: Bool

    /// The email address of the feed owner who has locked it.
    public var owner: String?

    /// Creates a new locked element.
    ///
    /// - Parameters:
    ///   - isLocked: Whether the feed is locked.
    ///   - owner: Optional owner email address.
    public init(isLocked: Bool, owner: String? = nil) {
        self.isLocked = isLocked
        self.owner = owner
    }
}
