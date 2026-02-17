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

/// An `<atom:link>` element from the Atom namespace (RFC 4287).
///
/// Defines a relationship between the feed and a web resource.
/// The most common use in podcasting is the `self` link that references
/// the feed's own URL.
///
/// Example:
/// ```xml
/// <atom:link href="https://example.com/feed.xml" rel="self"
///            type="application/rss+xml" />
/// ```
///
/// - SeeAlso: [Atom RFC 4287 — Link](https://datatracker.ietf.org/doc/html/rfc4287#section-4.2.7)
public struct AtomLink: Sendable, Hashable, Equatable, Codable {

    /// The URI of the linked resource.
    public var href: URL

    /// The link relation type (e.g., `"self"`, `"alternate"`, `"enclosure"`).
    public var rel: String?

    /// The MIME type of the linked resource (e.g., `"application/rss+xml"`).
    public var type: String?

    /// The language of the linked resource (BCP 47).
    public var hreflang: String?

    /// A human-readable title for the link.
    public var title: String?

    /// The advisory length of the linked resource in octets.
    public var length: Int?

    /// Creates a new Atom link.
    ///
    /// - Parameters:
    ///   - href: The URI of the linked resource.
    ///   - rel: Optional relationship type.
    ///   - type: Optional MIME type.
    ///   - hreflang: Optional language code.
    ///   - title: Optional display title.
    ///   - length: Optional content length.
    public init(
        href: URL,
        rel: String? = nil,
        type: String? = nil,
        hreflang: String? = nil,
        title: String? = nil,
        length: Int? = nil
    ) {
        self.href = href
        self.rel = rel
        self.type = type
        self.hreflang = hreflang
        self.title = title
        self.length = length
    }
}

// MARK: - Convenience Initializers

extension AtomLink {

    /// Creates a self-referencing Atom link for the feed URL.
    ///
    /// - Parameter href: The feed's own URL.
    /// - Returns: An AtomLink with `rel="self"` and `type="application/rss+xml"`.
    public static func selfLink(href: URL) -> AtomLink {
        AtomLink(href: href, rel: "self", type: "application/rss+xml")
    }
}
