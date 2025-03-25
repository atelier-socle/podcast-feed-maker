import Foundation

/// RSS Namespace Declarations used in podcast feeds.
///
/// Podcast RSS feeds based on [RSS 2.0](https://validator.w3.org/feed/docs/rss2.html) often use
/// multiple extensions defined by external namespaces such as `itunes`, `podcast`, and `atom`.
///
/// These declarations must be included at the top-level `<rss>` tag as attributes.
///
/// - Important: The [PSP-1 Podcast RSS Specification](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification#required-rss-namespace-declarations)
/// requires support for `itunes`, `atom`, and `podcast`.
///
/// - Example:
/// ```xml
/// <rss version="2.0"
///      xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
///      xmlns:podcast="https://podcastindex.org/namespace/1.0"
///      xmlns:atom="http://www.w3.org/2005/Atom">
/// ```
public enum Namespace: CaseIterable, Hashable, Equatable, Sendable {

    /// List of all default namespaces used in podcast feeds.
    public static let allCases: [Namespace] = [.itunes, .atom, .podcast, .rdf]

    /// Atom Syndication Format namespace.
    ///
    /// Used for `<atom:link>` and other elements as per [RFC 4287](https://tools.ietf.org/html/rfc4287).
    case atom

    /// Apple Podcasts (iTunes) Syndication Format namespace.
    ///
    /// Required for `<itunes:title>`, `<itunes:image>`, `<itunes:author>`, etc.
    case itunes

    /// Podcast Namespace from Podcastindex.org.
    ///
    /// Defines modern podcasting tags such as `<podcast:transcript>`, `<podcast:guid>`, etc.
    case podcast

    /// RDF Site Summary 1.0 Content Module namespace.
    ///
    /// Used for `<content:encoded>` to include rich HTML descriptions.
    case rdf

    // MARK: Optional Namespaces

    /// Podlove Simple Chapters (PSC) Specification namespace.
    ///
    /// Provides support for `<psc:chapters>` when integrating chapter-based metadata.
    case psc

    /// Custom namespace string for advanced integrations.
    case custom(String)

    /// Returns the `xmlns:` declaration string to inject into the top-level `<rss>` tag.
    var xmlns: String {
        switch self {
        case .itunes:
            #"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#
        case .podcast:
            #"xmlns:podcast="https://podcastindex.org/namespace/1.0""#
        case .atom:
            #"xmlns:atom="http://www.w3.org/2005/Atom""#
        case .rdf:
            #"xmlns:content="http://purl.org/rss/1.0/modules/content/""#
        case .psc:
            #"xmlns:psc="http://podlove.org/simple-chapters""#
        case let .custom(value):
            value
        }
    }
}

/// Defines required namespaces for PSP-1 Podcast Standards Project validation.
public extension Namespace {
    /// Atom Syndication Format namespace (RFC 4287).
    ///
    /// Reference: [RFC 4287](https://datatracker.ietf.org/doc/html/rfc4287)
    ///
    /// The namespace name `http://www.w3.org/2005/Atom` is intended for use as per [The Atom Syndication Format](https://datatracker.ietf.org/doc/html/rfc4287), a December 2005 Proposed Standard developed by the [IETF atompub Working Group](https://datatracker.ietf.org/wg/atompub/about/).
    enum Atom: Hashable, Equatable, Sendable {}

    /// Apple Podcasts (iTunes) Syndication Format namespace.
    ///
    /// Reference: [Apple Podcasts RSS Feed Requirements](https://podcasters.apple.com/support/823-podcast-requirements)
    enum iTunes: Hashable, Equatable, Sendable {}

    /// Podcast Namespace Specification by Podcastindex.org.
    ///
    /// Reference: [Podcast Namespace Spec](https://github.com/Podcastindex-org/podcast-namespace)
    ///
    /// A wholistic RSS namespace for podcasting that is meant to synthesize the fragmented world of podcast namespaces.
    /// As elements are canonized, they will be added to this document so developers can begin implementation.
    /// The specifications below are considered locked and the team will prioritize backward compatibility.
    /// We are operating under the [Rules for Standards-Makers](http://scripting.com/2017/05/09/rulesForStandardsmakers.html).
    enum Podcast: Hashable, Equatable, Sendable {}

    /// RDF Content Module (RSS 1.0 extension).
    ///
    /// With the [RDF Site Summary 1.0 Content Module Specification](https://web.resource.org/rss/1.0/modules/content/) namespace included, you can enclose all portions of your XML that contain embedded HTML in a CDATA section to prevent formatting issues and to ensure proper link functionality.
    enum RDF: Hashable, Equatable, Sendable {}

    /// Podlove Simple Chapters (PSC) format.
    ///
    /// Reference: [Podlove Simple Chapters](https://podlove.org/simple-chapters/)
    ///
    /// Podlove Simple Chapters is an XML 1.0 based format meant to extend file formats like Atom Syndication [1](https://podlove.org/simple-chapters/#footnote_atom) and RSS 2.0 [2](https://podlove.org/simple-chapters/#footnote_rss) that reference enclosures (podcasts).
    /// As the name implies, this format defines simple chapter structures in media files.
    enum PSC: Hashable, Equatable, Sendable {}
}

/// A namespace grouping RSS 2.0 standard tags used in podcast feeds.
///
/// All tags defined under `RSSTag` conform to `XmlRepresentable`
/// and represent specific XML elements of a podcast RSS feed,
/// such as `<title>`, `<description>`, `<link>`, etc.
///
/// - Note: These tags follow the [RSS 2.0 specification](https://validator.w3.org/feed/docs/rss2.html)
/// and are extended by additional namespaces (`itunes`, `podcast`, etc.) when needed.
public enum RSSTag: Hashable, Equatable, Sendable {}
