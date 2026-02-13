import Foundation

/// The `<podcast:publisher>` element from Podcast Namespace 2.0.
///
/// Links a podcast feed to its publisher feed parent.
/// Contains exactly one `<podcast:remoteItem>` sub-element with
/// `medium="publisher"`.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:publisher>
///     <podcast:remoteItem medium="publisher"
///                         feedGuid="003af0a0-..."
///                         feedUrl="https://example.com/publisher.xml" />
/// </podcast:publisher>
/// ```
///
/// - SeeAlso: [Podcast NS — publisher](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#publisher)
public struct PodcastPublisher: Sendable, Hashable, Equatable, Codable {

    /// The remote item pointing to the publisher feed.
    public var remoteItem: RemoteItem

    /// Creates a new podcast publisher.
    ///
    /// - Parameter remoteItem: A remote item reference to the publisher feed.
    public init(remoteItem: RemoteItem) {
        self.remoteItem = remoteItem
    }
}
