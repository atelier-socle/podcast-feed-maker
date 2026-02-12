import Foundation

/// The `<podcast:medium>` element from Podcast Namespace 2.0.
///
/// Declares the primary medium or content type of the feed. This tells
/// podcast apps what kind of content to expect in the feed.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:medium>podcast</podcast:medium>
/// ```
///
/// - SeeAlso: [Podcast NS — medium](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#medium)
public enum PodcastMedium: String, CaseIterable, Hashable, Equatable, Sendable, Codable {

    /// A standard podcast feed.
    case podcast

    /// A music feed.
    case music

    /// A video feed.
    case video

    /// A film feed.
    case film

    /// An audiobook feed.
    case audiobook

    /// A newsletter feed.
    case newsletter

    /// A blog feed.
    case blog

    /// A publisher feed (collection of other feeds).
    case publisher
}
