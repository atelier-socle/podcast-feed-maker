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

/// Identifies a specific tag or element across all 7 supported namespaces.
///
/// Channel-level RSS tags use plain names (`title`, `link`, `description`).
/// Item-level RSS tags use the `item` prefix (`itemTitle`, `itemEnclosure`).
/// Namespace tags use a single case regardless of scope — placement in
/// ``FeedTemplate/requiredChannelTags`` vs ``FeedTemplate/requiredItemTags``
/// determines where they're checked.
///
/// - SeeAlso: ``FeedTemplate``, ``TemplateValidator``
public enum FeedTag: String, CaseIterable, Hashable, Equatable, Sendable {

    // MARK: - RSS 2.0 Channel

    /// `<title>` — channel title.
    case title

    /// `<link>` — channel link.
    case link

    /// `<description>` — channel description.
    case description

    /// `<language>` — channel language.
    case language

    /// `<copyright>` — channel copyright.
    case copyright

    /// `<pubDate>` — channel publication date.
    case pubDate

    /// `<lastBuildDate>` — channel last build date.
    case lastBuildDate

    // MARK: - RSS 2.0 Item

    /// `<item><title>` — item title.
    case itemTitle

    /// `<item><link>` — item link.
    case itemLink

    /// `<item><description>` — item description.
    case itemDescription

    /// `<item><enclosure>` — item enclosure (media file).
    case itemEnclosure

    /// `<item><guid>` — item globally unique identifier.
    case itemGuid

    /// `<item><pubDate>` — item publication date.
    case itemPubDate

    /// `<item><author>` — item author.
    case itemAuthor

    // MARK: - iTunes Namespace

    /// `<itunes:category>` — iTunes category.
    case itunesCategory

    /// `<itunes:explicit>` — explicit content flag.
    case itunesExplicit

    /// `<itunes:image>` — podcast/episode artwork.
    case itunesImage

    /// `<itunes:author>` — podcast/episode author.
    case itunesAuthor

    /// `<itunes:owner>` — podcast owner (name + email).
    case itunesOwner

    /// `<itunes:type>` — show type (episodic/serial).
    case itunesType

    /// `<itunes:duration>` — episode duration.
    case itunesDuration

    /// `<itunes:episode>` — episode number.
    case itunesEpisode

    /// `<itunes:season>` — season number.
    case itunesSeason

    /// `<itunes:episodeType>` — episode type (full/trailer/bonus).
    case itunesEpisodeType

    // MARK: - Atom Namespace

    /// `<atom:link>` — Atom link (typically rel="self").
    case atomLink

    // MARK: - Podcast Namespace 2.0

    /// `<podcast:locked>` — feed lock status.
    case podcastLocked

    /// `<podcast:guid>` — globally unique feed identifier.
    case podcastGuid

    /// `<podcast:funding>` — donation/support links.
    case podcastFunding

    /// `<podcast:person>` — people (hosts, guests, etc.).
    case podcastPerson

    /// `<podcast:location>` — geographic locations.
    case podcastLocation

    /// `<podcast:license>` — license information.
    case podcastLicense

    /// `<podcast:medium>` — primary content type.
    case podcastMedium

    /// `<podcast:transcript>` — episode transcript files.
    case podcastTranscript

    /// `<podcast:chapters>` — JSON chapters link.
    case podcastChapters

    /// `<podcast:soundbite>` — audio soundbites.
    case podcastSoundbite

    /// `<podcast:alternateEnclosure>` — alternative media files.
    case podcastAlternateEnclosure

    /// `<podcast:trailer>` — show/season trailers.
    case podcastTrailer

    /// `<podcast:publisher>` — publisher/network info.
    case podcastPublisher

    /// `<podcast:value>` — Value-for-Value configuration.
    case podcastValue

    /// `<podcast:block>` — platform-specific block directives.
    case podcastBlock

    /// `<podcast:txt>` — free-form text records.
    case podcastTxt

    /// `<podcast:podroll>` — recommended podcasts.
    case podcastPodroll

    /// `<podcast:updateFrequency>` — update schedule hints.
    case podcastUpdateFrequency

    /// `<podcast:podping>` — podping notification flag.
    case podcastPodping

    /// `<podcast:images>` — podcast images (deprecated srcset).
    case podcastImages

    /// `<podcast:image>` — podcast image tags.
    case podcastImage

    /// `<podcast:chat>` — chat/discussion room.
    case podcastChat

    /// `<podcast:liveItem>` — live streaming episodes.
    case podcastLiveItem

    /// `<podcast:socialInteract>` — social interaction references.
    case podcastSocialInteract

    /// `<podcast:season>` — rich season metadata.
    case podcastSeason

    /// `<podcast:episode>` — rich episode metadata.
    case podcastEpisode

    /// `<podcast:integrity>` — content integrity verification.
    case podcastIntegrity

    /// `<podcast:valueTimeSplit>` — time-based value splits.
    case podcastValueTimeSplit

    /// `<podcast:remoteItem>` — remote item references.
    case podcastRemoteItem

    /// `<podcast:contentLink>` — content links (live items).
    case podcastContentLink

    // MARK: - Content Module

    /// `<content:encoded>` — rich HTML content.
    case contentEncoded

    // MARK: - Dublin Core

    /// Dublin Core metadata elements.
    case dublinCore

    // MARK: - Podlove Simple Chapters

    /// `<psc:chapters>` — Podlove chapter markers.
    case podloveChapters

    // MARK: - Computed Properties

    /// The ``PodcastNamespace`` this tag belongs to, or `nil` for RSS 2.0 core tags.
    public var namespace: PodcastNamespace? {
        switch self {
        case .title, .link, .description, .language, .copyright, .pubDate, .lastBuildDate,
            .itemTitle, .itemLink, .itemDescription, .itemEnclosure, .itemGuid, .itemPubDate,
            .itemAuthor:
            nil

        case .itunesCategory, .itunesExplicit, .itunesImage, .itunesAuthor, .itunesOwner,
            .itunesType, .itunesDuration, .itunesEpisode, .itunesSeason, .itunesEpisodeType:
            .itunes

        case .atomLink:
            .atom

        case .podcastLocked, .podcastGuid, .podcastFunding, .podcastPerson, .podcastLocation,
            .podcastLicense, .podcastMedium, .podcastTranscript, .podcastChapters,
            .podcastSoundbite, .podcastAlternateEnclosure, .podcastTrailer, .podcastPublisher,
            .podcastValue, .podcastBlock, .podcastTxt, .podcastPodroll, .podcastUpdateFrequency,
            .podcastPodping, .podcastImages, .podcastImage, .podcastChat, .podcastLiveItem,
            .podcastSocialInteract, .podcastSeason, .podcastEpisode, .podcastIntegrity,
            .podcastValueTimeSplit, .podcastRemoteItem, .podcastContentLink:
            .podcast

        case .contentEncoded:
            .content

        case .dublinCore:
            .dublinCore

        case .podloveChapters:
            .podloveSimpleChapters
        }
    }

    /// The minimum ``ExpertiseLevel`` at which this tag first appears.
    ///
    /// Computed by checking each built-in template's tag sets in order.
    public var minimumLevel: ExpertiseLevel {
        if BasicTemplate.allTags.contains(self) { return .basic }
        if StandardTemplate.allTags.contains(self) { return .standard }
        if AdvancedTemplate.allTags.contains(self) { return .advanced }
        return .expert
    }
}
