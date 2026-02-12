import Foundation

/// The `<podcast:soundbite>` element from Podcast Namespace 2.0.
///
/// Defines a short clip from an episode that can be used as a teaser
/// or preview. Multiple soundbites may be defined per item.
///
/// - Important: Item-level only.
///
/// Example:
/// ```xml
/// <podcast:soundbite startTime="73.0" duration="60.0">Best moment</podcast:soundbite>
/// ```
///
/// - SeeAlso: [Podcast NS — soundbite](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#soundbite)
public struct Soundbite: Sendable, Hashable, Equatable, Codable {

    /// The start time in seconds from the beginning of the episode.
    public var startTime: Double

    /// The duration of the soundbite in seconds.
    public var duration: Double

    /// An optional title or description for the soundbite.
    public var title: String?

    /// Creates a new soundbite.
    ///
    /// - Parameters:
    ///   - startTime: Start time in seconds.
    ///   - duration: Duration in seconds.
    ///   - title: Optional descriptive title.
    public init(startTime: Double, duration: Double, title: String? = nil) {
        self.startTime = startTime
        self.duration = duration
        self.title = title
    }
}
