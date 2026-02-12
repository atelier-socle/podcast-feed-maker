import Foundation

/// The `<podcast:season>` element from Podcast Namespace 2.0.
///
/// Provides richer season metadata than the simple `<itunes:season>` integer.
/// Includes a season number and an optional human-readable name.
///
/// Example:
/// ```xml
/// <podcast:season name="Mysteries of the Deep">3</podcast:season>
/// ```
///
/// - SeeAlso: [Podcast NS — season](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#season)
public struct PodcastSeason: Sendable, Hashable, Equatable, Codable {

    /// The season number.
    public var number: Int

    /// An optional human-readable name for the season.
    public var name: String?

    /// Creates a new podcast season.
    ///
    /// - Parameters:
    ///   - number: The season number.
    ///   - name: Optional season name.
    public init(number: Int, name: String? = nil) {
        self.number = number
        self.name = name
    }
}
