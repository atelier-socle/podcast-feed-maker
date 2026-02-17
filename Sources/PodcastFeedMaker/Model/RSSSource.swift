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

/// The `<source>` element from the RSS 2.0 specification.
///
/// Identifies the RSS channel that the item came from, useful when
/// aggregating items from multiple feeds.
///
/// Example:
/// ```xml
/// <source url="https://example.com/feed.xml">Example Feed</source>
/// ```
///
/// - SeeAlso: [RSS 2.0 — source](https://www.rssboard.org/rss-specification#ltsourcegtSubelementOfLtitemgt)
public struct RSSSource: Sendable, Hashable, Equatable, Codable {

    /// The name of the RSS channel the item came from.
    public var title: String

    /// The URL of the source feed's XML document.
    public var url: URL

    /// Creates a new RSS source element.
    ///
    /// - Parameters:
    ///   - title: The source feed name.
    ///   - url: The URL of the source feed.
    public init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
}
