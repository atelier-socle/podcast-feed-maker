import Foundation

/// The root model representing an RSS feed structure for a podcast.
///
/// A `Feed` instance represents the full RSS `<rss>` envelope and its associated metadata.
/// It contains a version, a list of XML namespaces, and a `<channel>` element representing the podcast’s content.
///
/// By default, the feed conforms to RSS 2.0 and includes the standard podcast-related namespaces.
///
/// - Important: A feed must include a `<channel>` in order to be valid.
public struct Feed: Sendable {

    /// The version of the RSS specification used (default: `"2.0"`).
    ///
    /// This is injected into the root `<rss>` element as an attribute.
    public let version: String

    /// The list of XML namespaces to declare in the `<rss>` root element.
    ///
    /// Each `Namespace` contributes an `xmlns:prefix` declaration.
    public let namespaces: [Namespace]

    /// The content container for the feed.
    ///
    /// The `<channel>` element holds the podcast title, description, episodes, etc.
    public let channel: RSSTag.Channel?

    /// Initializes a new RSS feed model.
    ///
    /// - Parameters:
    ///   - version: The RSS version (usually `"2.0"`).
    ///   - namespaces: A list of XML namespaces to include. Defaults to all supported ones.
    ///   - channel: The main `<channel>` tag holding the podcast data.
    public init(
        version: String = "2.0",
        namespaces: [Namespace] = Namespace.allCases,
        channel: RSSTag.Channel?
    ) {
        self.namespaces = namespaces
        self.version = version
        self.channel = channel
    }
}

extension Feed: XmlRepresentable {

    /// Returns the complete XML representation of the feed.
    ///
    /// This includes:
    /// - The XML declaration header (`<?xml version="1.0" encoding="UTF-8"?>`)
    /// - The opening `<rss>` tag with version and namespaces
    /// - The inner channel representation (if present)
    /// - The closing `</rss>` tag
    ///
    /// - Returns: A full RSS feed as a valid XML string.
    /// - Throws: `FeedError.missingChannelTag` if the channel is `nil`.
    public func xmlRepresentation() throws -> String {
        guard let channel else {
            throw FeedError.missingChannelTag
        }

        let namespaces = namespaces.map(\.xmlns).joined(separator: " ")

        return try """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="\(version)" \(namespaces)>
        \(channel.xmlRepresentation())
        </rss>
        """
    }

    /// Errors thrown by the `Feed` model during XML generation.
    public enum FeedError: Swift.Error, LocalizedError {

        /// Thrown when the channel is `nil` during XML conversion.
        case missingChannelTag

        /// A localized description of the error.
        public var errorDescription: String? {
            switch self {
            case .missingChannelTag:
                return "Missing channel tag"
            }
        }
    }
}
