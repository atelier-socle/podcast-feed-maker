import Foundation

/// The `<podcast:podroll>` element from Podcast Namespace 2.0.
///
/// Contains a list of recommended podcasts, using ``RemoteItem`` references
/// to identify each recommended feed.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:podroll>
///   <podcast:remoteItem feedGuid="917393e3-..." feedUrl="https://example.com/feed.xml" />
///   <podcast:remoteItem feedGuid="a1b2c3d4-..." />
/// </podcast:podroll>
/// ```
///
/// - SeeAlso: [Podcast NS — podroll](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#podroll)
public struct Podroll: Sendable, Hashable, Equatable, Codable {

    /// The list of recommended podcasts.
    public var remoteItems: [RemoteItem]

    /// Creates a new podroll.
    ///
    /// - Parameter remoteItems: The recommended podcast references.
    public init(remoteItems: [RemoteItem] = []) {
        self.remoteItems = remoteItems
    }
}
