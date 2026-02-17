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

/// A single outline node in an OPML document.
///
/// `OPMLOutline` is a recursive tree structure where each outline can contain
/// child outlines. In podcast OPML files, leaf outlines typically represent
/// individual podcast subscriptions with `type = "rss"` and an `xmlUrl`
/// pointing to the feed. Container outlines group feeds into categories.
///
/// ## Podcast Subscription Outline
///
/// ```swift
/// let subscription = OPMLOutline(
///     text: "Accidental Tech Podcast",
///     type: "rss",
///     xmlUrl: URL(string: "https://atp.fm/episodes?format=rss")!,
///     htmlUrl: URL(string: "https://atp.fm")!
/// )
/// ```
///
/// ## Category Outline
///
/// ```swift
/// let category = OPMLOutline(
///     text: "Technology",
///     children: [subscription1, subscription2]
/// )
/// ```
///
/// - SeeAlso: ``OPMLDocument``, ``OPMLParser``
public struct OPMLOutline: Sendable, Hashable, Equatable, Codable {

    // MARK: - Required Attribute

    /// The display text for this outline (required by OPML spec).
    public var text: String

    // MARK: - Standard Attributes

    /// The outline type (e.g., `"rss"`, `"link"`, `"include"`).
    public var type: String?

    /// The URL of the XML feed (typically an RSS feed URL).
    public var xmlUrl: URL?

    /// The URL of the HTML page associated with this outline.
    public var htmlUrl: URL?

    /// A brief description of the outline.
    public var description: String?

    /// The language of the feed (BCP 47 / ISO 639).
    public var language: String?

    /// The title of the feed (often same as ``text``).
    public var title: String?

    /// The version of the feed format (e.g., `"RSS"`, `"RSS2"`, `"RSS1"`).
    public var version: String?

    /// The creation date of this outline.
    public var created: Date?

    /// The category of this outline (comma-separated path like `"/Technology/Software"`).
    public var category: String?

    /// Whether this outline node is a comment (`true`) or not.
    public var isComment: Bool?

    /// Whether this outline node is a breakpoint (`true`) or not.
    public var isBreakpoint: Bool?

    /// The URL for an included OPML file (when ``type`` is `"include"`).
    public var url: URL?

    // MARK: - Custom Attributes

    /// Non-standard attributes for round-trip preservation.
    ///
    /// Attributes not recognized as standard OPML 2.0 attributes are stored
    /// here to enable lossless round-trip parsing and generation.
    public var customAttributes: [String: String]

    // MARK: - Children

    /// Child outline nodes (empty for leaf nodes).
    public var children: [OPMLOutline]

    // MARK: - Initialization

    /// Creates a new OPML outline.
    ///
    /// - Parameters:
    ///   - text: The display text (required).
    ///   - type: The outline type.
    ///   - xmlUrl: The XML feed URL.
    ///   - htmlUrl: The HTML page URL.
    ///   - description: A brief description.
    ///   - language: The feed language.
    ///   - title: The feed title.
    ///   - version: The feed format version.
    ///   - created: The creation date.
    ///   - category: The category path.
    ///   - isComment: Whether this is a comment node.
    ///   - isBreakpoint: Whether this is a breakpoint node.
    ///   - url: The URL for included OPML files.
    ///   - customAttributes: Non-standard attributes.
    ///   - children: Child outline nodes.
    public init(
        text: String,
        type: String? = nil,
        xmlUrl: URL? = nil,
        htmlUrl: URL? = nil,
        description: String? = nil,
        language: String? = nil,
        title: String? = nil,
        version: String? = nil,
        created: Date? = nil,
        category: String? = nil,
        isComment: Bool? = nil,
        isBreakpoint: Bool? = nil,
        url: URL? = nil,
        customAttributes: [String: String] = [:],
        children: [OPMLOutline] = []
    ) {
        self.text = text
        self.type = type
        self.xmlUrl = xmlUrl
        self.htmlUrl = htmlUrl
        self.description = description
        self.language = language
        self.title = title
        self.version = version
        self.created = created
        self.category = category
        self.isComment = isComment
        self.isBreakpoint = isBreakpoint
        self.url = url
        self.customAttributes = customAttributes
        self.children = children
    }

    // MARK: - Computed Helpers

    /// Whether this outline is a leaf node (has no children).
    public var isLeaf: Bool {
        children.isEmpty
    }

    /// Whether this outline represents a podcast subscription
    /// (type is `"rss"` and ``xmlUrl`` is present).
    public var isPodcastFeed: Bool {
        type?.lowercased() == "rss" && xmlUrl != nil
    }

    /// Returns all leaf outlines in this subtree (depth-first).
    public var allLeaves: [OPMLOutline] {
        if isLeaf { return [self] }
        return children.flatMap(\.allLeaves)
    }

    /// Returns all outlines in this subtree (depth-first, including self).
    public var allOutlines: [OPMLOutline] {
        [self] + children.flatMap(\.allOutlines)
    }
}
