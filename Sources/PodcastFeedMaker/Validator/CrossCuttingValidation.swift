import Foundation

// MARK: - Cross-Cutting Validation

/// Universal validation rules applied regardless of platform.
enum CrossCuttingValidation {

    /// Runs all cross-cutting checks on the feed.
    ///
    /// - Parameter feed: The feed to validate.
    /// - Returns: Universal validation results.
    static func validate(_ feed: PodcastFeed) -> [ValidationResult] {
        guard let channel = feed.channel else { return [] }

        var results: [ValidationResult] = []
        results += checkGuidUniqueness(channel)
        results += checkURLFormats(channel)
        results += checkItemMinimumContent(channel)
        return results
    }

    // MARK: - GUID Uniqueness

    private static func checkGuidUniqueness(
        _ channel: Channel
    ) -> [ValidationResult] {
        var seen: [String: Int] = [:]
        var results: [ValidationResult] = []
        for (idx, item) in channel.items.enumerated() {
            guard let guid = item.guid else { continue }
            if let firstIdx = seen[guid.value] {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Duplicate GUID '\(guid.value)' "
                            + "(also at items[\(firstIdx)])",
                        field: "channel.items[\(idx)].guid"
                    ))
            } else {
                seen[guid.value] = idx
            }
        }
        return results
    }

    // MARK: - URL Format

    private static func checkURLFormats(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []

        if channel.link.absoluteString.isEmpty {
            results.append(
                ValidationResult(
                    severity: .warning,
                    message: "Channel link URL is empty",
                    field: "channel.link"
                ))
        }

        for (idx, item) in channel.items.enumerated() {
            if let link = item.link,
                link.absoluteString.isEmpty
            {
                results.append(
                    ValidationResult(
                        severity: .warning,
                        message: "Item link URL is empty",
                        field: "channel.items[\(idx)].link"
                    ))
            }
        }

        return results
    }

    // MARK: - Item Minimum Content

    private static func checkItemMinimumContent(
        _ channel: Channel
    ) -> [ValidationResult] {
        var results: [ValidationResult] = []
        for (idx, item) in channel.items.enumerated() {
            let hasTitle = item.title.map { !$0.isEmpty } ?? false
            let hasDescription = item.description.map { !$0.isEmpty } ?? false
            if !hasTitle && !hasDescription {
                results.append(
                    ValidationResult(
                        severity: .error,
                        message: "Item must have at least a title or description",
                        field: "channel.items[\(idx)]"
                    ))
            }
        }
        return results
    }
}
