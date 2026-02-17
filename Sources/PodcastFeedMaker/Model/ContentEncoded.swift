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

/// The `<content:encoded>` element from the Content Module namespace.
///
/// Contains the full HTML content of a feed item, typically used to
/// provide rich show notes or episode descriptions with formatting.
///
/// - Important: Item-level only. Content is typically wrapped in `CDATA`.
///
/// Example:
/// ```xml
/// <content:encoded><![CDATA[<p>Full show notes with <strong>HTML</strong>.</p>]]></content:encoded>
/// ```
///
/// - SeeAlso: [Content Module Specification](http://web.resource.org/rss/1.0/modules/content/)
public struct ContentEncoded: Sendable, Hashable, Equatable, Codable {

    /// The HTML content string.
    public var value: String

    /// Creates a new content:encoded element.
    ///
    /// - Parameter value: The HTML content.
    public init(value: String) {
        self.value = value
    }
}
