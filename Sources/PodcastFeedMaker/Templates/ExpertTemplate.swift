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

/// A full-coverage feed template using all 7 namespaces.
///
/// Builds on ``AdvancedTemplate`` by adding Dublin Core, Podlove Simple Chapters,
/// V4V (Value-for-Value), social interactions, podroll, live items, and
/// all phase 4+ Podcast Namespace 2.0 tags.
///
/// **Namespaces**: itunes, atom, podcast, content, dublinCore, podloveSimpleChapters
///
/// - SeeAlso: ``FeedTemplate``, ``ExpertiseLevel/expert``
public struct ExpertTemplate: FeedTemplate, Sendable, Hashable {

    public init() {}

    public let level: ExpertiseLevel = .expert
    public let name: String = "Expert"

    public let requiredChannelTags: Set<FeedTag> = [
        // RSS 2.0 core
        .title, .link, .description,
        // iTunes
        .itunesCategory, .itunesExplicit, .itunesImage,
        .itunesAuthor, .itunesOwner,
        // Atom
        .atomLink,
        // Podcast NS 2.0 (Advanced required + funding, person)
        .podcastLocked, .podcastGuid, .podcastMedium,
        .podcastFunding, .podcastPerson,
        // RSS optional
        .language
    ]

    public let recommendedChannelTags: Set<FeedTag> = [
        .copyright, .pubDate, .lastBuildDate, .itunesType,
        .podcastLocation, .podcastLicense, .podcastPublisher, .podcastTrailer,
        .podcastValue, .podcastBlock, .podcastTxt, .podcastPodroll,
        .podcastUpdateFrequency, .podcastPodping, .podcastImages, .podcastChat,
        .podcastLiveItem, .dublinCore
    ]

    public let requiredItemTags: Set<FeedTag> = [
        .itemTitle, .itemEnclosure, .itemGuid,
        .itemPubDate, .itunesDuration, .itunesExplicit,
        .podcastTranscript
    ]

    public let recommendedItemTags: Set<FeedTag> = [
        .itemDescription,
        .itunesEpisode, .itunesSeason, .itunesEpisodeType, .itunesImage,
        .podcastChapters, .podcastSoundbite, .podcastPerson,
        .podcastLocation, .podcastLicense, .podcastAlternateEnclosure,
        .podcastValue, .podcastSocialInteract, .podcastSeason, .podcastEpisode,
        .podcastImages, .podloveChapters, .podcastIntegrity, .podcastValueTimeSplit,
        .podcastRemoteItem, .podcastContentLink,
        .contentEncoded, .dublinCore
    ]

    public let namespaces: Set<PodcastNamespace> = Set(PodcastNamespace.allStandard)

    public let platformPreset: PlatformPreset = .all

    /// All tags used by this template (required + recommended, both scopes).
    public static let allTags: Set<FeedTag> = {
        let template = ExpertTemplate()
        return template.allTags
    }()
}
