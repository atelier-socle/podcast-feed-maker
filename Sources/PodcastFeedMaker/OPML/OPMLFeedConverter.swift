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

/// Converts between ``PodcastFeed`` and ``OPMLOutline`` representations.
///
/// `OPMLFeedConverter` provides bidirectional conversion:
/// - Feed → Outline: creates an `OPMLOutline` from feed channel metadata
/// - Outline → Feed: creates a minimal `PodcastFeed` stub from an outline
///
/// ## Feed → Outline
///
/// ```swift
/// let outline = OPMLFeedConverter.outline(from: feed)
/// // outline.text = channel.title, outline.xmlUrl = atom:link self, etc.
/// ```
///
/// ## Feeds → Document
///
/// ```swift
/// let document = OPMLFeedConverter.document(
///     from: feeds, title: "My Subscriptions"
/// )
/// ```
///
/// - SeeAlso: ``OPMLDocument``, ``PodcastFeed``
public enum OPMLFeedConverter {

    // MARK: - Feed → Outline

    /// Creates an OPML outline from a podcast feed.
    ///
    /// Maps channel metadata to outline attributes:
    /// - `text` / `title`: channel title
    /// - `xmlUrl`: atom:link self (or channel link as fallback)
    /// - `htmlUrl`: channel link
    /// - `description`: channel description
    /// - `language`: channel language
    /// - `type`: always `"rss"`
    ///
    /// - Parameter feed: The podcast feed.
    /// - Returns: An OPML outline, or `nil` if the feed has no channel.
    public static func outline(from feed: PodcastFeed) -> OPMLOutline? {
        guard let channel = feed.channel else { return nil }

        let feedURL =
            channel.atomLinks.first { $0.rel == "self" }?.href
            ?? channel.link

        return OPMLOutline(
            text: channel.title,
            type: "rss",
            xmlUrl: feedURL,
            htmlUrl: channel.link,
            description: channel.description,
            language: channel.language,
            title: channel.title
        )
    }

    // MARK: - Feeds → Document

    /// Creates an OPML document from multiple feeds.
    ///
    /// - Parameters:
    ///   - feeds: The podcast feeds to include.
    ///   - title: The document title.
    ///   - ownerName: Optional owner name.
    /// - Returns: An OPML document with one outline per feed.
    public static func document(
        from feeds: [PodcastFeed],
        title: String = "Podcast Subscriptions",
        ownerName: String? = nil
    ) -> OPMLDocument {
        let outlines = feeds.compactMap { outline(from: $0) }

        return OPMLDocument(
            head: OPMLHead(
                title: title,
                dateCreated: Date(),
                ownerName: ownerName
            ),
            outlines: outlines
        )
    }

    // MARK: - Outline → Feed

    /// Creates a minimal podcast feed stub from an OPML outline.
    ///
    /// The resulting feed contains only metadata extractable from
    /// the outline attributes. Use this as a starting point for
    /// fetching and parsing the actual feed.
    ///
    /// - Parameter outline: The OPML outline.
    /// - Returns: A minimal feed, or `nil` if the outline has no xmlUrl.
    public static func feed(from outline: OPMLOutline) -> PodcastFeed? {
        guard let xmlUrl = outline.xmlUrl else { return nil }

        let link = outline.htmlUrl ?? xmlUrl

        var channel = Channel(
            title: outline.title ?? outline.text,
            link: link,
            description: outline.description ?? ""
        )
        channel.language = outline.language

        // Add atom:link self pointing to the feed URL
        channel.atomLinks = [
            AtomLink(href: xmlUrl, rel: "self", type: "application/rss+xml")
        ]

        return PodcastFeed(channel: channel)
    }

    // MARK: - Document → Feeds

    /// Creates minimal feed stubs from all podcast outlines in a document.
    ///
    /// - Parameter document: The OPML document.
    /// - Returns: An array of minimal feed stubs.
    public static func feeds(from document: OPMLDocument) -> [PodcastFeed] {
        document.podcastFeeds.compactMap { feed(from: $0) }
    }
}
