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

/// A PSP-1 compliant feed template with Podcast NS 2.0 essentials.
///
/// Builds on ``BasicTemplate`` by adding `podcast:locked`, `podcast:guid`,
/// `atom:link` self, `itunes:owner`, and language as required fields.
/// Equivalent to ``PSP1Configuration`` in coverage.
///
/// **Namespaces**: itunes, atom, podcast
///
/// - SeeAlso: ``FeedTemplate``, ``ExpertiseLevel/standard``, ``PSP1Configuration``
public struct StandardTemplate: FeedTemplate, Sendable, Hashable {

    public init() {}

    public let level: ExpertiseLevel = .standard
    public let name: String = "Standard"

    public let requiredChannelTags: Set<FeedTag> = [
        // RSS 2.0 core
        .title, .link, .description,
        // iTunes (all Basic required + author, owner)
        .itunesCategory, .itunesExplicit, .itunesImage,
        .itunesAuthor, .itunesOwner,
        // Atom
        .atomLink,
        // Podcast NS 2.0
        .podcastLocked, .podcastGuid,
        // RSS optional but PSP-1 required
        .language
    ]

    public let recommendedChannelTags: Set<FeedTag> = [
        .copyright, .pubDate, .itunesType, .podcastMedium
    ]

    public let requiredItemTags: Set<FeedTag> = [
        .itemTitle, .itemEnclosure, .itemGuid
    ]

    public let recommendedItemTags: Set<FeedTag> = [
        .itemDescription, .itemPubDate,
        .itunesDuration, .itunesExplicit, .itunesEpisodeType
    ]

    public let namespaces: Set<PodcastNamespace> = [.itunes, .atom, .podcast]

    public let platformPreset: PlatformPreset = .all

    /// All tags used by this template (required + recommended, both scopes).
    public static let allTags: Set<FeedTag> = {
        let template = StandardTemplate()
        return template.allTags
    }()
}
