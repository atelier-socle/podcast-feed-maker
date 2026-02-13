import Foundation

/// The root model representing a complete podcast RSS feed.
///
/// A `PodcastFeed` contains the RSS version, namespace declarations,
/// and the ``Channel`` with all feed-level and episode-level content.
///
/// This is a pure data model — XML generation and parsing are handled
/// by separate ``FeedGenerator`` and ``FeedParser`` types.
///
/// Example RSS structure:
/// ```xml
/// <?xml version="1.0" encoding="UTF-8"?>
/// <rss version="2.0" xmlns:itunes="..." xmlns:podcast="..." xmlns:atom="...">
///   <channel>
///     ...
///   </channel>
/// </rss>
/// ```
///
/// - SeeAlso: [RSS 2.0 Specification](https://www.rssboard.org/rss-specification)
public struct PodcastFeed: Sendable, Hashable, Equatable, Codable {

    /// The RSS specification version (default: `"2.0"`).
    public var version: String

    /// The XML namespaces to declare in the `<rss>` root element.
    public var namespaces: [PodcastNamespace]

    /// The feed's channel containing all podcast metadata and episodes.
    public var channel: Channel?

    /// Original namespace prefix-to-URI mappings from parsed XML.
    ///
    /// Key: prefix (e.g., `"apple"`), Value: URI (e.g., `"http://www.itunes.com/dtds/podcast-1.0.dtd"`).
    /// Used by ``FeedGenerator/NamespaceMode/parsed`` to reproduce original `<rss>` declarations.
    public var namespacePrefixes: [String: String]

    /// Creates a new podcast feed.
    ///
    /// - Parameters:
    ///   - version: The RSS version. Defaults to `"2.0"`.
    ///   - namespaces: The XML namespaces. Defaults to all standard namespaces.
    ///   - channel: The channel data. Optional for partial/incremental construction.
    public init(
        version: String = "2.0",
        namespaces: [PodcastNamespace] = PodcastNamespace.allStandard,
        channel: Channel? = nil,
        namespacePrefixes: [String: String] = [:]
    ) {
        self.version = version
        self.namespaces = namespaces
        self.channel = channel
        self.namespacePrefixes = namespacePrefixes
    }
}
