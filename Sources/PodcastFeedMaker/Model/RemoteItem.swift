import Foundation

/// The `<podcast:remoteItem>` element from Podcast Namespace 2.0.
///
/// References an item from another podcast feed, enabling cross-podcast
/// linking (e.g., in podrolls or value time splits).
///
/// Example:
/// ```xml
/// <podcast:remoteItem feedGuid="917393e3-1b1e-5cef-ace4-edaa54e1f3e1"
///                     feedUrl="https://example.com/feed.xml"
///                     itemGuid="episode-001"
///                     medium="podcast" />
/// ```
///
/// - SeeAlso: [Podcast NS — remoteItem](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#remote-item)
public struct RemoteItem: Sendable, Hashable, Equatable, Codable {

    /// The podcast:guid of the remote feed.
    public var feedGuid: String

    /// The URL of the remote feed (optional but recommended).
    public var feedUrl: URL?

    /// The GUID of the specific item in the remote feed.
    public var itemGuid: String?

    /// The medium type of the remote feed.
    public var medium: String?

    /// Creates a new remote item reference.
    ///
    /// - Parameters:
    ///   - feedGuid: The podcast:guid of the remote feed.
    ///   - feedUrl: Optional URL of the remote feed.
    ///   - itemGuid: Optional GUID of the specific item.
    ///   - medium: Optional medium type.
    public init(
        feedGuid: String,
        feedUrl: URL? = nil,
        itemGuid: String? = nil,
        medium: String? = nil
    ) {
        self.feedGuid = feedGuid
        self.feedUrl = feedUrl
        self.itemGuid = itemGuid
        self.medium = medium
    }
}
