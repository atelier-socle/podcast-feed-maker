import Foundation

/// The `<podcast:publisher>` element from Podcast Namespace 2.0.
///
/// Identifies the publisher or network that distributes the podcast.
/// Links to the publisher's podcast:guid for cross-referencing.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:publisher guid="917393e3-..." url="https://publisher.example.com">
///   Publisher Network Name
/// </podcast:publisher>
/// ```
///
/// - SeeAlso: [Podcast NS — publisher](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#publisher)
public struct PodcastPublisher: Sendable, Hashable, Equatable, Codable {

    /// The publisher's name.
    public var name: String

    /// The podcast:guid of the publisher's feed.
    public var guid: String?

    /// A URL to the publisher's website.
    public var url: URL?

    /// Creates a new podcast publisher.
    ///
    /// - Parameters:
    ///   - name: The publisher's name.
    ///   - guid: Optional podcast:guid of the publisher.
    ///   - url: Optional publisher website URL.
    public init(name: String, guid: String? = nil, url: URL? = nil) {
        self.name = name
        self.guid = guid
        self.url = url
    }
}
