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

/// The `<podcast:publisher>` element from Podcast Namespace 2.0.
///
/// Links a podcast feed to its publisher feed parent.
/// Contains exactly one `<podcast:remoteItem>` sub-element with
/// `medium="publisher"`.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:publisher>
///     <podcast:remoteItem medium="publisher"
///                         feedGuid="003af0a0-..."
///                         feedUrl="https://example.com/publisher.xml" />
/// </podcast:publisher>
/// ```
///
/// - SeeAlso: [Podcast NS — publisher](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#publisher)
public struct PodcastPublisher: Sendable, Hashable, Equatable, Codable {

    /// The remote item pointing to the publisher feed.
    public var remoteItem: RemoteItem

    /// Creates a new podcast publisher.
    ///
    /// - Parameter remoteItem: A remote item reference to the publisher feed.
    public init(remoteItem: RemoteItem) {
        self.remoteItem = remoteItem
    }
}
