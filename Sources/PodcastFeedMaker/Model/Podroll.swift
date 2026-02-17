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

/// The `<podcast:podroll>` element from Podcast Namespace 2.0.
///
/// Contains a list of recommended podcasts, using ``RemoteItem`` references
/// to identify each recommended feed.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:podroll>
///   <podcast:remoteItem feedGuid="917393e3-..." feedUrl="https://example.com/feed.xml" />
///   <podcast:remoteItem feedGuid="a1b2c3d4-..." />
/// </podcast:podroll>
/// ```
///
/// - SeeAlso: [Podcast NS — podroll](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#podroll)
public struct Podroll: Sendable, Hashable, Equatable, Codable {

    /// The list of recommended podcasts.
    public var remoteItems: [RemoteItem]

    /// Creates a new podroll.
    ///
    /// - Parameter remoteItems: The recommended podcast references.
    public init(remoteItems: [RemoteItem] = []) {
        self.remoteItems = remoteItems
    }
}
