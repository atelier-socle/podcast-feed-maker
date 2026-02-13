import Foundation

/// Represents an XML namespace declaration used in podcast RSS feeds.
///
/// Podcast feeds based on RSS 2.0 use multiple namespace extensions such as
/// `itunes`, `podcast`, `atom`, `dc`, `content`, and `psc`.
///
/// Each namespace contributes an `xmlns:prefix="uri"` declaration to the root `<rss>` element.
///
/// - SeeAlso: [RSS 2.0 Specification](https://www.rssboard.org/rss-specification)
public enum PodcastNamespace: Hashable, Equatable, Sendable, Codable {

    /// iTunes/Apple Podcasts namespace.
    ///
    /// URI: `http://www.itunes.com/dtds/podcast-1.0.dtd`
    case itunes

    /// Atom Syndication Format namespace (RFC 4287).
    ///
    /// URI: `http://www.w3.org/2005/Atom`
    case atom

    /// Podcast Namespace 2.0 from Podcastindex.org.
    ///
    /// URI: `https://podcastindex.org/namespace/1.0`
    case podcast

    /// Dublin Core metadata namespace.
    ///
    /// URI: `http://purl.org/dc/elements/1.1/`
    case dublinCore

    /// RDF Content Module namespace.
    ///
    /// URI: `http://purl.org/rss/1.0/modules/content/`
    case content

    /// Podlove Simple Chapters namespace.
    ///
    /// URI: `http://podlove.org/simple-chapters`
    case podloveSimpleChapters

    /// Custom namespace with a raw `xmlns` declaration string.
    case custom(String)

    // MARK: - Namespace Metadata

    /// The XML namespace prefix used in element names (e.g., `itunes`, `podcast`, `atom`).
    public var prefix: String {
        switch self {
        case .itunes: "itunes"
        case .atom: "atom"
        case .podcast: "podcast"
        case .dublinCore: "dc"
        case .content: "content"
        case .podloveSimpleChapters: "psc"
        case .custom: ""
        }
    }

    /// The full namespace URI.
    public var uri: String {
        switch self {
        case .itunes: "http://www.itunes.com/dtds/podcast-1.0.dtd"
        case .atom: "http://www.w3.org/2005/Atom"
        case .podcast: "https://podcastindex.org/namespace/1.0"
        case .dublinCore: "http://purl.org/dc/elements/1.1/"
        case .content: "http://purl.org/rss/1.0/modules/content/"
        case .podloveSimpleChapters: "http://podlove.org/simple-chapters"
        case .custom(let value): value
        }
    }

    /// The full `xmlns:prefix="uri"` declaration for inclusion in the `<rss>` root element.
    public var xmlnsDeclaration: String {
        switch self {
        case .itunes:
            #"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#
        case .atom:
            #"xmlns:atom="http://www.w3.org/2005/Atom""#
        case .podcast:
            #"xmlns:podcast="https://podcastindex.org/namespace/1.0""#
        case .dublinCore:
            #"xmlns:dc="http://purl.org/dc/elements/1.1/""#
        case .content:
            #"xmlns:content="http://purl.org/rss/1.0/modules/content/""#
        case .podloveSimpleChapters:
            #"xmlns:psc="http://podlove.org/simple-chapters""#
        case .custom(let value):
            value
        }
    }

    /// All standard podcast namespaces (excludes custom).
    public static let allStandard: [PodcastNamespace] = [
        .itunes, .atom, .podcast, .dublinCore, .content, .podloveSimpleChapters
    ]
}

// MARK: - Codable

extension PodcastNamespace {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let uri = try container.decode(String.self)
        switch uri {
        case "http://www.itunes.com/dtds/podcast-1.0.dtd": self = .itunes
        case "http://www.w3.org/2005/Atom": self = .atom
        case "https://podcastindex.org/namespace/1.0": self = .podcast
        case "http://purl.org/dc/elements/1.1/": self = .dublinCore
        case "http://purl.org/rss/1.0/modules/content/": self = .content
        case "http://podlove.org/simple-chapters": self = .podloveSimpleChapters
        default: self = .custom(uri)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(uri)
    }
}

// MARK: - Comparable

extension PodcastNamespace: Comparable {

    public static func < (lhs: PodcastNamespace, rhs: PodcastNamespace) -> Bool {
        lhs.uri < rhs.uri
    }
}
