import Foundation

/// A protocol for defining custom validation rules.
///
/// Implement this protocol to add project-specific or domain-specific
/// validation logic beyond the built-in platform rules.
///
/// ## Example
///
/// ```swift
/// struct RequireTranscriptsRule: ValidationRule {
///     func validate(_ feed: PodcastFeed) -> [ValidationResult] {
///         guard let channel = feed.channel else { return [] }
///         return channel.items.enumerated().compactMap { idx, item in
///             item.transcripts.isEmpty
///                 ? ValidationResult(
///                     severity: .warning,
///                     message: "Episode should include a transcript",
///                     field: "channel.items[\(idx)].transcripts"
///                 )
///                 : nil
///         }
///     }
/// }
/// ```
public protocol ValidationRule: Sendable {

    /// Validates a feed and returns any issues found.
    ///
    /// - Parameter feed: The ``PodcastFeed`` to validate.
    /// - Returns: An array of ``ValidationResult`` for any issues found.
    ///   Return an empty array if the feed passes this rule.
    func validate(_ feed: PodcastFeed) -> [ValidationResult]
}
