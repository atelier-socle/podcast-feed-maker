import Foundation

/// The `<podcast:episode>` element from Podcast Namespace 2.0.
///
/// Provides richer episode numbering metadata than the simple `<itunes:episode>` integer.
/// Includes a number value and an optional display string for custom formatting.
///
/// Example:
/// ```xml
/// <podcast:episode display="EP3">3</podcast:episode>
/// ```
///
/// - SeeAlso: [Podcast NS — episode](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#episode)
public struct PodcastEpisode: Sendable, Hashable, Equatable, Codable {

    /// The episode number.
    public var number: Double

    /// An optional display string for custom formatting (e.g., `"EP3"`, `"3a"`).
    public var display: String?

    /// Creates a new podcast episode number.
    ///
    /// - Parameters:
    ///   - number: The episode number (supports decimal for sub-episodes like `3.5`).
    ///   - display: Optional custom display string.
    public init(number: Double, display: String? = nil) {
        self.number = number
        self.display = display
    }
}
