import Foundation

// MARK: - PSP-1 Validation

/// Validates a feed against the Podcast Standards Project v1 specification.
///
/// PSP-1 defines strict structural requirements including mandatory
/// `atom:link[rel=self]`, `podcast:locked`, and `podcast:guid`.
enum PSP1Validation {

    /// Maximum recommended length for text values.
    private static let maxTextLength = 255

    // MARK: - Public API

    /// Validates the feed against PSP-1 requirements.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Validation results for PSP-1.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else {
            return [
                ValidationResult(
                    severity: .error,
                    message: "Feed must contain a <channel> element",
                    field: "channel",
                    platform: .psp1
                )
            ]
        }

        var results: [ValidationResult] = []
        results += validateChannelRequired(channel)
        results += validateChannelRecommended(channel)
        results += validateItems(channel)
        results += validateWhitespace(channel)
        results += validateTextLengths(channel)
        return results
    }

    // MARK: - Channel Required

    // swiftlint:disable:next function_body_length
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
                    platform: .psp1
                ))
        }
        if channel.description.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "Channel description is required",
                    field: "channel.description",
                    platform: .psp1
                ))
        }
        if !channel.atomLinks.contains(where: { $0.rel == "self" }) {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "atom:link with rel=\"self\" is required",
                    field: "channel.atomLinks",
                    platform: .psp1
                ))
        }
        if channel.locked == nil {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "podcast:locked is required",
                    field: "channel.locked",
                    platform: .psp1
                ))
        }
        if channel.podcastGuid == nil {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "podcast:guid is required",
                    field: "channel.podcastGuid",
                    platform: .psp1
                ))
        }
        if channel.itunesImage == nil {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "itunes:image is required",
                    field: "channel.itunesImage",
                    platform: .psp1
                ))
        }
        if channel.itunesCategories.isEmpty {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "itunes:category is required",
                    field: "channel.itunesCategories",
                    platform: .psp1
                ))
        }
        if channel.itunesExplicit == nil {
            results.append(
                ValidationResult(
                    severity: .error,
                    message: "itunes:explicit is required",
                    field: "channel.itunesExplicit",
                    platform: .psp1
                ))
        }

        return results
    }

    // MARK: - Channel Recommended

    private static func validateChannelRecommended(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.language == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Language is recommended",
                    field: "channel.language",
                    platform: .psp1
                ))
        }
        if channel.itunesAuthor == nil {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "itunes:author is recommended",
                    field: "channel.itunesAuthor",
                    platform: .psp1
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
            let hasTitle = item.title.map { !$0.isEmpty } ?? false
            let hasDescription = item.description.map { !$0.isEmpty } ?? false

            if !hasTitle && !hasDescription {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Item must have a title or description",
                        field: prefix,
                        platform: .psp1
                    ))
            }
            if item.enclosure == nil {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Enclosure is required",
                        field: "\(prefix).enclosure",
                        platform: .psp1
                    ))
            }
            if item.guid == nil {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "GUID is required",
                        field: "\(prefix).guid",
                        platform: .psp1
                    ))
            }
        }

        return results
    }

    // MARK: - Whitespace

    private static func validateWhitespace(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if hasLeadingOrTrailingWhitespace(channel.title) {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Title has leading or trailing whitespace",
                    field: "channel.title",
                    platform: .psp1
                ))
        }
        if hasLeadingOrTrailingWhitespace(channel.description) {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Description has leading or trailing whitespace",
                    field: "channel.description",
                    platform: .psp1
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            let prefix = "channel.items[\(idx)]"
            if let title = item.title,
                hasLeadingOrTrailingWhitespace(title)
            {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Item title has leading or trailing whitespace",
                        field: "\(prefix).title",
                        platform: .psp1
                    ))
            }
        }

        return results
    }

    // MARK: - Text Lengths

    private static func validateTextLengths(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.title.count > maxTextLength {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Title exceeds \(maxTextLength) characters",
                    field: "channel.title",
                    platform: .psp1
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let title = item.title, title.count > maxTextLength {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Item title exceeds \(maxTextLength) characters",
                        field: "channel.items[\(idx)].title",
                        platform: .psp1
                    ))
            }
        }

        return results
    }

    // MARK: - Helpers

    private static func hasLeadingOrTrailingWhitespace(
        _ string: String
    ) -> Bool {
        let trimmed = string.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return trimmed != string
    }
}
