import Foundation

// MARK: - Apple Podcasts Validation

// MARK: - Audio Types

private let appleAllowedAudioTypes: Set<String> = [
    "audio/mpeg", "audio/mp3", "audio/x-m4a", "audio/mp4",
    "audio/m4a", "audio/aac", "audio/x-aac", "audio/wav",
    "audio/x-wav", "audio/ogg", "audio/opus", "audio/flac",
    "video/mp4", "video/quicktime", "video/x-m4v"
]

/// Validates a feed against Apple Podcasts requirements.
///
/// Apple Podcasts has strict requirements including HTTPS-only URLs,
/// iTunes tags, and artwork specifications.
enum AppleValidation {

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
                if !appleAllowedAudioTypes.contains(enclosure.type) {
                    results.append(
                        ValidationResult(
                            severity: .error,
                            message: "Enclosure type '\(enclosure.type)' "
                                + "is not a supported audio/video format",
                            field: "\(prefix).enclosure.type",
                            platform: .apple
                        ))
                }
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
            if let enclosure = item.enclosure,
                enclosure.url.scheme?.lowercased() != "https"
            {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Enclosure URL must use HTTPS",
                        field: "channel.items[\(idx)].enclosure.url",
                        platform: .apple
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
        if channel.description.count > 4000 {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Description should not exceed 4000 characters",
                    field: "channel.description",
                    platform: .apple
                ))
        }

        return results
    }
}
