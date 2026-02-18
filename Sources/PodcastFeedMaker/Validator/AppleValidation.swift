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

// MARK: - Apple Podcasts Validation

// MARK: - Audio Types

private let appleAllowedMediaTypes: Set<String> = [
    "audio/mpeg", "audio/mp3", "audio/x-m4a", "audio/mp4",
    "audio/m4a", "audio/aac", "audio/x-aac", "audio/wav",
    "audio/x-wav", "audio/ogg", "audio/opus", "audio/flac",
    "video/mp4", "video/quicktime", "video/x-m4v", "video/m4v"
]

private let applePreferredVideoTypes: Set<String> = [
    "video/mp4", "video/quicktime", "video/x-m4v", "video/m4v"
]

/// Validates a feed against Apple Podcasts requirements.
///
/// Apple Podcasts has strict requirements including HTTPS-only URLs,
/// iTunes tags, and artwork specifications.
enum AppleValidation {  // swiftlint:disable:this type_body_length

    // MARK: - Public API

    /// Validates the feed against Apple Podcasts requirements.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Validation results for Apple Podcasts.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else {
            return [
                ValidationResult(
                    severity: .error,
                    message: "Feed must contain a <channel> element",
                    field: "channel",
                    platform: .apple
                )
            ]
        }

        var results: [ValidationResult] = []
        results += validateChannelRequired(channel)
        results += validateChannelRecommended(channel)
        results += validateItems(channel)
        results += validateURLSchemes(channel)
        results += validateLengths(channel)
        results += validateCrossField(channel)
        return results
    }

    // MARK: - Channel Required

    private static func validateChannelRequired(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.title.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Channel title is required",
                    field: "channel.title",
                    platform: .apple
                ))
        }
        if channel.description.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Channel description is required",
                    field: "channel.description",
                    platform: .apple
                ))
        }
        if channel.itunesImage == nil {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "itunes:image is required",
                    field: "channel.itunesImage",
                    platform: .apple
                ))
        }
        if channel.itunesCategories.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "At least one itunes:category is required",
                    field: "channel.itunesCategories",
                    platform: .apple
                ))
        }
        if channel.itunesExplicit == nil {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "itunes:explicit is required",
                    field: "channel.itunesExplicit",
                    platform: .apple
                ))
        }
        if !channel.items.contains(where: { $0.enclosure != nil }) {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "At least one item with an enclosure is required",
                    field: "channel.items",
                    platform: .apple
                ))
        }

        return results
    }

    // MARK: - Channel Recommended

    private static func validateChannelRecommended(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.itunesAuthor == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "itunes:author is recommended",
                    field: "channel.itunesAuthor",
                    platform: .apple
                ))
        }
        if channel.itunesOwner == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "itunes:owner (name + email) is recommended",
                    field: "channel.itunesOwner",
                    platform: .apple
                ))
        }
        if channel.language == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Language is recommended",
                    field: "channel.language",
                    platform: .apple
                ))
        }
        if channel.itunesType == nil {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "itunes:type is recommended (episodic or serial)",
                    field: "channel.itunesType",
                    platform: .apple
                ))
        }
        if channel.itunesNewFeedUrl != nil {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "Feed migration URL is set. "
                        + "Remove after migration is complete.",
                    field: "channel.itunesNewFeedUrl",
                    platform: .apple
                ))
        }

        return results
    }

    // MARK: - Enclosure Format

    private static func validateEnclosureFormat(
        _ enclosure: Enclosure,
        field: String
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []
        if !appleAllowedMediaTypes.contains(enclosure.type) {
            let mimeType = Enclosure.MIMEType(rawValue: enclosure.type)
            let isVideo = mimeType?.isVideo ?? enclosure.type.hasPrefix("video/")
            if isVideo {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Video type '\(enclosure.type)' "
                            + "is not preferred by Apple Podcasts; "
                            + "use video/mp4 or video/quicktime",
                        field: "\(field).type",
                        platform: .apple
                    ))
            } else {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Enclosure type '\(enclosure.type)' "
                            + "is not a supported audio/video format",
                        field: "\(field).type",
                        platform: .apple
                    ))
            }
        }
        if let mimeType = Enclosure.MIMEType(rawValue: enclosure.type),
            mimeType.isHLS
        {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "Apple Podcasts delivers HLS via Podcasts Connect, "
                        + "not RSS enclosure. Consider podcast:alternateEnclosure",
                    field: "\(field).type",
                    platform: .apple
                ))
        }
        return results
    }

    // MARK: - Items

    // swiftlint:disable:next function_body_length
    private static func validateItems(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        for (idx, item) in channel.items.enumerated() {
            let prefix = "channel.items[\(idx)]"
            let hasTitle = item.title.map { !$0.isEmpty } ?? false
            let hasDescription = item.description.map { !$0.isEmpty } ?? false

            if !hasTitle && !hasDescription {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Item must have a title or description",
                        field: prefix,
                        platform: .apple
                    ))
            }
            if let enclosure = item.enclosure {
                results += validateEnclosureFormat(enclosure, field: "\(prefix).enclosure")
            }
            if item.guid == nil {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "GUID is recommended and should be unique",
                        field: "\(prefix).guid",
                        platform: .apple
                    ))
            }
            if item.itunesDuration == nil {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "itunes:duration is recommended",
                        field: "\(prefix).itunesDuration",
                        platform: .apple
                    ))
            }
            if item.itunesExplicit == nil {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "itunes:explicit is recommended per episode",
                        field: "\(prefix).itunesExplicit",
                        platform: .apple
                    ))
            }
            if item.pubDate == nil {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "pubDate is recommended",
                        field: "\(prefix).pubDate",
                        platform: .apple
                    ))
            }
            if item.itunesImage == nil {
                results.append(
                    ValidationResult(
                        severity: .info,
                        message: "itunes:image is recommended per episode",
                        field: "\(prefix).itunesImage",
                        platform: .apple
                    ))
            }
            if item.itunesEpisodeType == nil {
                results.append(
                    ValidationResult(
                        severity: .info,
                        message: "itunes:episodeType is recommended",
                        field: "\(prefix).itunesEpisodeType",
                        platform: .apple
                    ))
            }
        }

        return results
    }

    // MARK: - URL Schemes

    private static func validateURLSchemes(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if let imageURL = channel.itunesImage,
            imageURL.scheme?.lowercased() != "https"
        {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Artwork URL must use HTTPS",
                    field: "channel.itunesImage",
                    platform: .apple
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let enclosure = item.enclosure {
                if enclosure.url.scheme?.lowercased() != "https" {
                    results.append(
                        ValidationResult(
                            severity: .error,
                            message: "Enclosure URL must use HTTPS",
                            field: "channel.items[\(idx)].enclosure.url",
                            platform: .apple
                        ))
                }
                if !enclosure.url.absoluteString.allSatisfy(\.isASCII) {
                    results.append(
                        ValidationResult(
                            severity: .warning,
                            message: "Enclosure URL contains non-ASCII characters",
                            field: "channel.items[\(idx)].enclosure.url",
                            platform: .apple
                        ))
                }
            }
        }

        return results
    }

    // MARK: - Cross-Field

    private static func validateCrossField(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []
        for (idx, item) in channel.items.enumerated()
        where item.itunesDuration != nil && item.enclosure == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Item has itunes:duration but no enclosure",
                    field: "channel.items[\(idx)]",
                    platform: .apple
                ))
        }
        if channel.itunesType == .serial,
            !channel.items.contains(where: { $0.itunesSeason != nil || $0.itunesEpisode != nil })
        {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "Serial show has no items with itunes:season or itunes:episode",
                    field: "channel.itunesType",
                    platform: .apple
                ))
        }
        let hasVideoEnclosure = channel.items.contains { item in
            guard let type = item.enclosure?.type else { return false }
            let mimeType = Enclosure.MIMEType(rawValue: type)
            return mimeType?.isVideo ?? type.hasPrefix("video/")
        }
        if hasVideoEnclosure && channel.medium == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Feed has video enclosures but no podcast:medium. "
                        + "Consider setting it to video or mixed",
                    field: "channel.medium",
                    platform: .apple
                ))
        }
        return results
    }

    // MARK: - Length Checks

    private static func validateLengths(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.title.count > 255 {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Title should not exceed 255 characters",
                    field: "channel.title",
                    platform: .apple
                ))
        }
        if channel.description.data(using: .utf8)?.count ?? 0 > 4000 {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Description exceeds 4000 bytes",
                    field: "channel.description",
                    platform: .apple
                ))
        }
        for (idx, item) in channel.items.enumerated() {
            if let desc = item.description,
                desc.data(using: .utf8)?.count ?? 0 > 4000
            {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Item description exceeds 4000 bytes",
                        field: "channel.items[\(idx)].description",
                        platform: .apple
                    ))
            }
        }

        return results
    }
}
