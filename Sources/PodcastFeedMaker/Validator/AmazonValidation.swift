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

// MARK: - Amazon Music Validation

/// Validates a feed against Amazon Music / Audible requirements.
///
/// Amazon Music has the broadest format support among major platforms.
/// Requirements are relatively lenient compared to Apple or Spotify.
enum AmazonValidation {

    // MARK: - Public API

    /// Validates the feed against Amazon Music requirements.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Validation results for Amazon Music.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else {
            return [
                ValidationResult(
                    severity: .error,
                    message: "Feed must contain a <channel> element",
                    field: "channel",
                    platform: .amazon
                )
            ]
        }

        var results: [ValidationResult] = []
        results += validateChannelRequired(channel)
        results += validateChannelRecommended(channel)
        results += validateItems(channel)
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
                    platform: .amazon
                ))
        }
        if channel.description.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Channel description is required",
                    field: "channel.description",
                    platform: .amazon
                ))
        }
        if !channel.items.contains(where: { $0.enclosure != nil }) {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "At least one item with an enclosure is required",
                    field: "channel.items",
                    platform: .amazon
                ))
        }

        return results
    }

    // MARK: - Channel Recommended

    private static func validateChannelRecommended(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.itunesImage == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "itunes:image is recommended (1400-3000px)",
                    field: "channel.itunesImage",
                    platform: .amazon
                ))
        }
        if channel.itunesCategories.isEmpty {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "itunes:category is recommended",
                    field: "channel.itunesCategories",
                    platform: .amazon
                ))
        }
        if channel.itunesExplicit == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "itunes:explicit is recommended",
                    field: "channel.itunesExplicit",
                    platform: .amazon
                ))
        }

        return results
    }

    // MARK: - Items

    private static func validateItems(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        for (idx, item) in channel.items.enumerated() {
            let prefix = "channel.items[\(idx)]"

            if item.enclosure == nil {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Enclosure is required for each item",
                        field: "\(prefix).enclosure",
                        platform: .amazon
                    ))
            }
            if item.guid == nil {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "GUID is recommended",
                        field: "\(prefix).guid",
                        platform: .amazon
                    ))
            }
        }

        return results
    }
}
