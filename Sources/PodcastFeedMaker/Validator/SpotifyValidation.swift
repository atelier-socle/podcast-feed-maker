import Foundation

// MARK: - Spotify Validation

/// Validates a feed against Spotify requirements.
///
/// Spotify accepts RSS feeds with specific constraints including
/// MP3-only audio passthrough and description length limits.
enum SpotifyValidation {

    /// Maximum description size in bytes.
    private static let maxDescriptionBytes = 4000

    /// Maximum enclosure size in bytes (200 MB).
    private static let maxEnclosureBytes = 200_000_000

    // MARK: - Public API

    /// Validates the feed against Spotify requirements.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Validation results for Spotify.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else {
            return [
                ValidationResult(
                    severity: .error,
                    message: "Feed must contain a <channel> element",
                    field: "channel",
                    platform: .spotify
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
                    platform: .spotify
                ))
        }
        if channel.description.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Channel description is required",
                    field: "channel.description",
                    platform: .spotify
                ))
        }
        if !channel.items.contains(where: { $0.enclosure != nil }) {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "At least one item with an enclosure is required",
                    field: "channel.items",
                    platform: .spotify
                ))
        }

        return results
    }

    // MARK: - Channel Recommended

    private static func validateChannelRecommended(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.description.data(using: .utf8)?.count ?? 0 > maxDescriptionBytes {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Description exceeds 4000 bytes",
                    field: "channel.description",
                    platform: .spotify
                ))
        }

        if channel.itunesImage == nil {
            results.append(
                ValidationResult(
                    severity: .info,
                    message: "Artwork 1400x1400 to 2048x2048 recommended",
                    field: "channel.itunesImage",
                    platform: .spotify
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

            guard let enclosure = item.enclosure else {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Enclosure is required for each item",
                        field: "\(prefix).enclosure",
                        platform: .spotify
                    ))
                continue
            }

            if enclosure.type != "audio/mpeg" && enclosure.type != "audio/mp3" {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Spotify recommends audio/mpeg (MP3); "
                            + "'\(enclosure.type)' may not stream correctly",
                        field: "\(prefix).enclosure.type",
                        platform: .spotify
                    ))
            }

            if enclosure.length > maxEnclosureBytes {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Enclosure exceeds 200 MB",
                        field: "\(prefix).enclosure.length",
                        platform: .spotify
                    ))
            }
        }

        return results
    }
}
