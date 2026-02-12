import Foundation

/// The `<source>` element from the RSS 2.0 specification.
///
/// Identifies the RSS channel that the item came from, useful when
/// aggregating items from multiple feeds.
///
/// Example:
/// ```xml
/// <source url="https://example.com/feed.xml">Example Feed</source>
/// ```
///
/// - SeeAlso: [RSS 2.0 — source](https://www.rssboard.org/rss-specification#ltsourcegtSubelementOfLtitemgt)
public struct RSSSource: Sendable, Hashable, Equatable, Codable {

    /// The name of the RSS channel the item came from.
    public var title: String

    /// The URL of the source feed's XML document.
    public var url: URL

    /// Creates a new RSS source element.
    ///
    /// - Parameters:
    ///   - title: The source feed name.
    ///   - url: The URL of the source feed.
    public init(title: String, url: URL) {
        self.title = title
        self.url = url
    }
}
