import Foundation

// MARK: - Podcast Index Validation

/// Validates a feed against Podcast Index requirements.
///
/// Podcast Index focuses on Podcast Namespace 2.0 tags and
/// Value-for-Value (V4V) payment configuration.
enum PodcastIndexValidation {

    // MARK: - Public API

    /// Validates the feed against Podcast Index requirements.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Validation results for Podcast Index.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else {
            return [
                ValidationResult(
                    severity: .error,
                    message: "Feed must contain a <channel> element",
                    field: "channel",
                    platform: .podcastIndex
                )
            ]
        }

        var results: [ValidationResult] = []
        results += validateChannelRecommended(channel)
        results += validateItems(channel)
        results += validateValue(channel)
        results += validateCrossField(channel)
        return results
    }

    // MARK: - Channel Recommended

    private static func validateChannelRecommended(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.locked == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "podcast:locked is recommended",
                    field: "channel.locked",
                    platform: .podcastIndex
                ))
        }
        if channel.podcastGuid == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "podcast:guid is recommended",
                    field: "channel.podcastGuid",
                    platform: .podcastIndex
                ))
        }
        if channel.funding.isEmpty {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "podcast:funding is encouraged",
                    field: "channel.funding",
                    platform: .podcastIndex
                ))
        }
        if channel.medium == nil {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "podcast:medium is recommended",
                    field: "channel.medium",
                    platform: .podcastIndex
                ))
        }
        if !channel.txtRecords.contains(where: { $0.purpose == "verify" }) {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "podcast:txt with purpose=\"verify\" is recommended "
                        + "for ownership verification",
                    field: "channel.txtRecords",
                    platform: .podcastIndex
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

            if item.transcripts.isEmpty {
                results.append(
                    ValidationResult(
                        severity: .info,
                        message: "podcast:transcript is encouraged",
                        field: "\(prefix).transcripts",
                        platform: .podcastIndex
                    ))
            }
            if item.chaptersLink == nil {
                results.append(
                    ValidationResult(
                        severity: .info,
                        message: "podcast:chapters is encouraged",
                        field: "\(prefix).chaptersLink",
                        platform: .podcastIndex
                    ))
            }
            if item.persons.isEmpty {
                results.append(
                    ValidationResult(
                        severity: .info,
                        message: "podcast:person is encouraged",
                        field: "\(prefix).persons",
                        platform: .podcastIndex
                    ))
            }
        }

        return results
    }

    // MARK: - Cross-Field

    private static func validateCrossField(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if let value = channel.value {
            for timeSplit in value.timeSplits {
                if let remote = timeSplit.remoteItem, remote.feedGuid.isEmpty {
                    results.append(
                        ValidationResult(
                            severity: .warning,
                            message: "valueTimeSplit remoteItem has empty feedGuid",
                            field: "channel.value.timeSplits",
                            platform: .podcastIndex
                        ))
                }
            }
        }

        for (idx, item) in channel.items.enumerated()
        where !item.alternateEnclosures.isEmpty {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "Item has alternate enclosures for enhanced delivery",
                    field: "channel.items[\(idx)].alternateEnclosures",
                    platform: .podcastIndex
                ))
        }

        return results
    }

    // MARK: - Value (V4V)

    private static func validateValue(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if let value = channel.value {
            if value.recipients.isEmpty {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "podcast:value must have at least one "
                            + "valueRecipient",
                        field: "channel.value.recipients",
                        platform: .podcastIndex
                    ))
            } else {
                let totalSplit = value.recipients.reduce(0) { $0 + $1.split }
                if totalSplit != 100 {
                    results.append(
                        ValidationResult(
                            severity: .warning,
                            message: "Value recipient splits sum to \(totalSplit), "
                                + "expected 100",
                            field: "channel.value.recipients",
                            platform: .podcastIndex
                        ))
                }
            }
        } else {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "podcast:value is encouraged for V4V support",
                    field: "channel.value",
                    platform: .podcastIndex
                ))
        }

        return results
    }
}
