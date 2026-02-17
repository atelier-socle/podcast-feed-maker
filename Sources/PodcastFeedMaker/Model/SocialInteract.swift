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

/// The `<podcast:socialInteract>` element from Podcast Namespace 2.0.
///
/// Links to a social media post or thread related to the episode,
/// enabling podcast apps to display comments or discussions.
///
/// - Important: Item-level only.
///
/// Example:
/// ```xml
/// <podcast:socialInteract uri="https://mastodon.social/@host/12345"
///                         protocol="activitypub"
///                         accountId="@host@mastodon.social"
///                         accountUrl="https://mastodon.social/@host" />
/// ```
///
/// - SeeAlso: [Podcast NS — socialInteract](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#social-interact)
public struct SocialInteract: Sendable, Hashable, Equatable, Codable {

    /// The URI of the social media post or thread.
    public var uri: String

    /// The protocol used (e.g., `"activitypub"`, `"twitter"`, `"disabled"`).
    public var `protocol`: String

    /// The account ID on the social platform.
    public var accountId: String?

    /// The URL to the account's profile page.
    public var accountUrl: URL?

    /// An optional priority value for ordering (lower = higher priority).
    public var priority: Int?

    /// Creates a new social interaction element.
    ///
    /// - Parameters:
    ///   - uri: The social media post URI.
    ///   - protocol: The social protocol.
    ///   - accountId: Optional account identifier.
    ///   - accountUrl: Optional account profile URL.
    ///   - priority: Optional display priority.
    public init(
        uri: String,
        protocol: String,
        accountId: String? = nil,
        accountUrl: URL? = nil,
        priority: Int? = nil
    ) {
        self.uri = uri
        self.protocol = `protocol`
        self.accountId = accountId
        self.accountUrl = accountUrl
        self.priority = priority
    }
}
