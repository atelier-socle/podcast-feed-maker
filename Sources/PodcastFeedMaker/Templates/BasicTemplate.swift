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

/// A minimal feed template targeting Apple Podcasts and Spotify.
///
/// Requires only RSS 2.0 core fields and essential iTunes tags.
/// This is the minimum viable podcast feed for major platforms.
///
/// **Namespaces**: itunes, atom
///
/// - SeeAlso: ``FeedTemplate``, ``ExpertiseLevel/basic``
public struct BasicTemplate: FeedTemplate, Sendable, Hashable {

    public init() {}

    public let level: ExpertiseLevel = .basic
    public let name: String = "Basic"

    public let requiredChannelTags: Set<FeedTag> = [
        .title, .link, .description,
        .itunesCategory, .itunesExplicit, .itunesImage
    ]

    public let recommendedChannelTags: Set<FeedTag> = [
        .language, .itunesAuthor, .itunesType
    ]

    public let requiredItemTags: Set<FeedTag> = [
        .itemTitle, .itemEnclosure
    ]

    public let recommendedItemTags: Set<FeedTag> = [
        .itemDescription, .itemGuid, .itemPubDate,
        .itunesDuration, .itunesExplicit
    ]

    public let namespaces: Set<PodcastNamespace> = [.itunes, .atom]

    public let platformPreset: PlatformPreset = .majorPlatforms

    /// All tags used by this template (required + recommended, both scopes).
    public static let allTags: Set<FeedTag> = {
        let template = BasicTemplate()
        return template.allTags
    }()
}
