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

/// Validates a ``PodcastFeed`` against a ``FeedTemplate``.
///
/// Checks that all required and recommended tags are present at both
/// channel and item levels. Also detects tags present in the feed that
/// belong to a higher expertise level than the template.
///
/// ```swift
/// let validator = TemplateValidator()
/// let report = validator.validate(feed, against: BasicTemplate())
/// if report.isCompliant {
///     print("Feed meets basic template requirements")
/// }
/// ```
///
/// - SeeAlso: ``FeedTemplate``, ``TemplateValidationReport``
public struct TemplateValidator: Sendable {

    /// Creates a new template validator.
    public init() {}

    /// Validates a feed against a template.
    ///
    /// - Parameters:
    ///   - feed: The podcast feed to validate.
    ///   - template: The template to validate against.
    /// - Returns: A report containing all findings.
    public func validate<T: FeedTemplate>(
        _ feed: PodcastFeed,
        against template: T
    ) -> TemplateValidationReport {
        var results: [TemplateValidationResult] = []

        guard let channel = feed.channel else {
            results.append(
                TemplateValidationResult(
                    severity: .error,
                    tag: .title,
                    message: "Feed has no channel element"
                ))
            return TemplateValidationReport(level: template.level, results: results)
        }

        // Check required channel tags
        for tag in template.requiredChannelTags.sorted(by: { $0.rawValue < $1.rawValue })
        where !isChannelTagPresent(tag, in: channel) {
            results.append(
                TemplateValidationResult(
                    severity: .error,
                    tag: tag,
                    message: "Required channel tag \(tag.rawValue) is missing"
                ))
        }

        // Check recommended channel tags
        for tag in template.recommendedChannelTags.sorted(by: { $0.rawValue < $1.rawValue })
        where !isChannelTagPresent(tag, in: channel) {
            results.append(
                TemplateValidationResult(
                    severity: .warning,
                    tag: tag,
                    message: "Recommended channel tag \(tag.rawValue) is missing"
                ))
        }

        // Check items
        for (index, item) in channel.items.enumerated() {
            validateItem(item, at: index, template: template, results: &results)
        }

        // Detect channel-level mismatches
        detectChannelLevelMismatches(in: channel, template: template, results: &results)

        return TemplateValidationReport(level: template.level, results: results)
    }

    /// Detects the best-matching expertise level for a feed.
    ///
    /// Checks from expert down to basic, returning the highest level
    /// where the feed meets all required tags.
    ///
    /// - Parameter feed: The podcast feed to analyze.
    /// - Returns: The detected expertise level.
    public func detectLevel(_ feed: PodcastFeed) -> ExpertiseLevel {
        if validate(feed, against: ExpertTemplate()).isCompliant { return .expert }
        if validate(feed, against: AdvancedTemplate()).isCompliant { return .advanced }
        if validate(feed, against: StandardTemplate()).isCompliant { return .standard }
        return .basic
    }
}

// MARK: - Item Validation

extension TemplateValidator {

    private func validateItem<T: FeedTemplate>(
        _ item: Item,
        at index: Int,
        template: T,
        results: inout [TemplateValidationResult]
    ) {
        // Check required item tags
        for tag in template.requiredItemTags.sorted(by: { $0.rawValue < $1.rawValue })
        where !isItemTagPresent(tag, in: item) {
            results.append(
                TemplateValidationResult(
                    severity: .error,
                    tag: tag,
                    message: "Required item tag \(tag.rawValue) is missing in item[\(index)]"
                ))
        }

        // Check recommended item tags
        for tag in template.recommendedItemTags.sorted(by: { $0.rawValue < $1.rawValue })
        where !isItemTagPresent(tag, in: item) {
            results.append(
                TemplateValidationResult(
                    severity: .warning,
                    tag: tag,
                    message: "Recommended item tag \(tag.rawValue) is missing in item[\(index)]"
                ))
        }

        // Detect level mismatches — tags present that exceed template level
        detectLevelMismatches(in: item, template: template, itemIndex: index, results: &results)
    }
}

// MARK: - Channel Tag Presence

extension TemplateValidator {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func isChannelTagPresent(_ tag: FeedTag, in channel: Channel) -> Bool {
        switch tag {
        case .title:
            !channel.title.isEmpty
        case .link:
            true  // non-optional URL
        case .description:
            !channel.description.isEmpty
        case .language:
            channel.language != nil
        case .copyright:
            channel.copyright != nil
        case .pubDate:
            channel.pubDate != nil
        case .lastBuildDate:
            channel.lastBuildDate != nil
        case .itunesCategory:
            !channel.itunesCategories.isEmpty
        case .itunesExplicit:
            channel.itunesExplicit != nil
        case .itunesImage:
            channel.itunesImage != nil
        case .itunesAuthor:
            channel.itunesAuthor != nil
        case .itunesOwner:
            channel.itunesOwner != nil
        case .itunesType:
            channel.itunesType != nil
        case .atomLink:
            !channel.atomLinks.isEmpty
        case .podcastLocked:
            channel.locked != nil
        case .podcastGuid:
            channel.podcastGuid != nil
        case .podcastFunding:
            !channel.funding.isEmpty
        case .podcastPerson:
            !channel.persons.isEmpty
        case .podcastLocation:
            !channel.locations.isEmpty
        case .podcastLicense:
            channel.license != nil
        case .podcastMedium:
            channel.medium != nil
        case .podcastTrailer:
            !channel.trailers.isEmpty
        case .podcastPublisher:
            channel.publisher != nil
        case .podcastValue:
            channel.value != nil
        case .podcastBlock:
            !channel.podcastBlocks.isEmpty
        case .podcastTxt:
            !channel.txtRecords.isEmpty
        case .podcastPodroll:
            channel.podroll != nil
        case .podcastUpdateFrequency:
            channel.updateFrequency != nil
        case .podcastPodping:
            channel.podpingEnabled != nil
        case .podcastImages:
            channel.podcastImagesSrcset != nil
        case .podcastImage:
            !channel.podcastImages.isEmpty
        case .podcastChat:
            channel.chat != nil
        case .podcastLiveItem:
            !channel.liveItems.isEmpty
        case .dublinCore:
            channel.dublinCore != nil
        default:
            true  // item-only or non-channel tags → not applicable
        }
    }
}

// MARK: - Item Tag Presence

extension TemplateValidator {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func isItemTagPresent(_ tag: FeedTag, in item: Item) -> Bool {
        switch tag {
        case .itemTitle:
            item.title != nil && !(item.title?.isEmpty ?? true)
        case .itemLink:
            item.link != nil
        case .itemDescription:
            item.description != nil && !(item.description?.isEmpty ?? true)
        case .itemEnclosure:
            item.enclosure != nil
        case .itemGuid:
            item.guid != nil
        case .itemPubDate:
            item.pubDate != nil
        case .itemAuthor:
            item.author != nil
        case .itunesDuration:
            item.itunesDuration != nil
        case .itunesExplicit:
            item.itunesExplicit != nil
        case .itunesEpisode:
            item.itunesEpisode != nil
        case .itunesSeason:
            item.itunesSeason != nil
        case .itunesEpisodeType:
            item.itunesEpisodeType != nil
        case .itunesImage:
            item.itunesImage != nil
        case .podcastTranscript:
            !item.transcripts.isEmpty
        case .podcastChapters:
            item.chaptersLink != nil
        case .podcastSoundbite:
            !item.soundbites.isEmpty
        case .podcastPerson:
            !item.persons.isEmpty
        case .podcastLocation:
            !item.locations.isEmpty
        case .podcastLicense:
            item.license != nil
        case .podcastAlternateEnclosure:
            !item.alternateEnclosures.isEmpty
        case .podcastValue:
            item.value != nil
        case .podcastSocialInteract:
            !item.socialInteractions.isEmpty
        case .podcastSeason:
            item.podcastSeason != nil
        case .podcastEpisode:
            item.podcastEpisode != nil
        case .podcastImages:
            item.podcastImagesSrcset != nil
        case .podcastImage:
            !item.podcastImages.isEmpty
        case .podloveChapters:
            item.podloveChapters != nil
        case .podcastIntegrity:
            item.alternateEnclosures.contains { $0.integrity != nil }
        case .podcastValueTimeSplit:
            item.value?.timeSplits.isEmpty == false
        case .podcastRemoteItem:
            item.value?.timeSplits.contains { $0.remoteItem != nil } ?? false
        case .podcastContentLink:
            false  // contentLink is only on liveItem, not regular items
        case .contentEncoded:
            item.contentEncoded != nil
        case .dublinCore:
            item.dublinCore != nil
        default:
            true  // channel-only tags → not applicable at item level
        }
    }
}

// MARK: - Level Mismatch Detection

extension TemplateValidator {

    private func detectLevelMismatches<T: FeedTemplate>(
        in item: Item,
        template: T,
        itemIndex: Int,
        results: inout [TemplateValidationResult]
    ) {
        let templateTags = template.allTags
        let itemTags = presentItemTags(in: item)

        for tag in itemTags.sorted(by: { $0.rawValue < $1.rawValue })
        where !templateTags.contains(tag) && tag.minimumLevel > template.level {
            results.append(
                TemplateValidationResult(
                    severity: .info,
                    tag: tag,
                    message:
                        "\(tag.rawValue) is a \(tag.minimumLevel)-level feature in item[\(itemIndex)]. "
                        + "Consider upgrading to .\(tag.minimumLevel) template.",
                    suggestedLevel: tag.minimumLevel
                ))
        }
    }

    private func detectChannelLevelMismatches<T: FeedTemplate>(
        in channel: Channel,
        template: T,
        results: inout [TemplateValidationResult]
    ) {
        let templateTags = template.allTags
        let channelTags = presentChannelTags(in: channel)

        for tag in channelTags.sorted(by: { $0.rawValue < $1.rawValue })
        where !templateTags.contains(tag) && tag.minimumLevel > template.level {
            results.append(
                TemplateValidationResult(
                    severity: .info,
                    tag: tag,
                    message:
                        "\(tag.rawValue) is a \(tag.minimumLevel)-level feature. "
                        + "Consider upgrading to .\(tag.minimumLevel) template.",
                    suggestedLevel: tag.minimumLevel
                ))
        }
    }
}

// MARK: - Tag Collection Helpers

extension TemplateValidator {

    private func presentChannelTags(in channel: Channel) -> Set<FeedTag> {
        var tags = Set<FeedTag>()
        for tag in FeedTag.allCases where isChannelTagPresent(tag, in: channel) && tag != .link {
            switch tag {
            case .itemTitle, .itemLink, .itemDescription, .itemEnclosure,
                .itemGuid, .itemPubDate, .itemAuthor:
                continue  // item-only tags
            default:
                if !isAlwaysTrue(tag, isChannel: true) {
                    tags.insert(tag)
                }
            }
        }
        return tags
    }

    private func presentItemTags(in item: Item) -> Set<FeedTag> {
        var tags = Set<FeedTag>()
        for tag in FeedTag.allCases where isItemTagPresent(tag, in: item) {
            switch tag {
            case .title, .link, .description, .language, .copyright, .pubDate,
                .lastBuildDate:
                continue  // channel-only tags
            default:
                if !isAlwaysTrue(tag, isChannel: false) {
                    tags.insert(tag)
                }
            }
        }
        return tags
    }

    private func isAlwaysTrue(_ tag: FeedTag, isChannel: Bool) -> Bool {
        if isChannel {
            switch tag {
            case .itemTitle, .itemLink, .itemDescription, .itemEnclosure,
                .itemGuid, .itemPubDate, .itemAuthor,
                .podcastTranscript, .podcastChapters, .podcastSoundbite,
                .podcastAlternateEnclosure, .podcastSocialInteract,
                .podcastSeason, .podcastEpisode, .podcastIntegrity,
                .podcastValueTimeSplit, .podcastRemoteItem, .podcastContentLink,
                .contentEncoded, .podloveChapters:
                return true
            default:
                return false
            }
        } else {
            switch tag {
            case .title, .link, .description, .language, .copyright, .pubDate,
                .lastBuildDate, .itunesCategory, .itunesOwner, .itunesType,
                .atomLink, .podcastLocked, .podcastGuid, .podcastFunding,
                .podcastMedium, .podcastTrailer, .podcastPublisher,
                .podcastBlock, .podcastTxt, .podcastPodroll,
                .podcastUpdateFrequency, .podcastPodping, .podcastChat,
                .podcastLiveItem:
                return true
            default:
                return false
            }
        }
    }
}
