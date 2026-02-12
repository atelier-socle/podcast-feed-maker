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

    // MARK: - Core Types

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

    /// An educational course feed.
    case course

    /// A mixed-medium list feed (items reference different medium types).
    case mixed

    // MARK: - List Variants

    /// A list of podcast feeds.
    case podcastL

    /// A list of music feeds.
    case musicL

    /// A list of video feeds.
    case videoL

    /// A list of film feeds.
    case filmL

    /// A list of audiobook feeds.
    case audiobookL

    /// A list of newsletter feeds.
    case newsletterL

    /// A list of blog feeds.
    case blogL

    /// A list of course feeds.
    case courseL
}
