import Foundation

/// RSS Namespace Declarations.
///
/// Podcast feeds utilize RSS 2.0 tags and require extensions from three namespaces (itunes, podcast, and atom).
/// These namespace declarations must be made in the opening of your XML.
/// >information: see [PSP-1 Podcast RSS Specification RSS Namespace Declarations](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification?tab=readme-ov-file#required-rss-namespace-declarations)
public enum Namespace: CaseIterable, Hashable, Equatable, Sendable {
    public static let allCases: [Namespace] = [.itunes, .atom, .podcast, .rdf]

    /// Atom Syndication Format namespace.
    case atom

    /// Apple Podcasts (iTunes) Syndication Format namespace.
    case itunes

    /// RSS Namespace Extension for Podcasting (Tag Specification).
    case podcast

    /// RDF Site Summary 1.0 Content Module Specification namespace.
    case rdf

    // MARK: Optional

    /// Podlove Simple Chapters (PSC) Specification namespace.
    case psc

    /// Custom module specification namespace.
    case custom(String)

    /// XMLNS content module.
    var xmlns: String {
        switch self {
        case .itunes:
            "xmlns:itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\""
        case .podcast:
            "xmlns:podcast=\"https://podcastindex.org/namespace/1.0\""
        case .atom:
            "xmlns:atom=\"http://www.w3.org/2005/Atom\""
        case .rdf:
            "xmlns:content=\"http://purl.org/rss/1.0/modules/content/\""
        case .psc:
            "xmlns:psc=\"http://podlove.org/simple-chapters\""
        case let .custom(value):
            value
        }
    }
}

/// Defines required namespaces for PSP-1 Podcast Standards Project validation.
public extension Namespace {
    /// Atom Syndication Format namespace.
    ///
    /// The namespace name `http://www.w3.org/2005/Atom` is intended for use as per [The Atom Syndication Format](https://datatracker.ietf.org/doc/html/rfc4287), a December 2005 Proposed Standard developed by the [IETF atompub Working Group](https://datatracker.ietf.org/wg/atompub/about/).
    enum Atom: Hashable, Equatable, Sendable {}

    /// Apple Podcasts (iTunes) Syndication Format namespace.
    ///
    /// Get more details by following [Podcast RSS Feed requirements](https://podcasters.apple.com/support/823-podcast-requirements).
    enum iTunes: Hashable, Equatable, Sendable {}

    /// RSS Namespace Extension for Podcasting (Tag Specification).
    ///
    /// A wholistic RSS namespace for podcasting that is meant to synthesize the fragmented world of podcast namespaces.
    /// As elements are canonized, they will be added to this document so developers can begin implementation.
    /// The specifications below are considered locked and the team will prioritize backward compatibility.
    /// We are operating under the [Rules for Standards-Makers](http://scripting.com/2017/05/09/rulesForStandardsmakers.html).
    enum Podcast: Hashable, Equatable, Sendable {}

    /// RDF Site Summary 1.0 Content Module Specification namespace.
    ///
    /// With the [RDF Site Summary 1.0 Content Module Specification](https://web.resource.org/rss/1.0/modules/content/) namespace included, you can enclose all portions of your XML that contain embedded HTML in a CDATA section to prevent formatting issues and to ensure proper link functionality.
    enum RDF: Hashable, Equatable, Sendable {}

    /// Podlove Simple Chapters (PSC) Specification namespace.
    ///
    /// Podlove Simple Chapters is an XML 1.0 based format meant to extend file formats like Atom Syndication [1](https://podlove.org/simple-chapters/#footnote_atom) and RSS 2.0 [2](https://podlove.org/simple-chapters/#footnote_rss) that reference enclosures (podcasts).
    /// As the name implies, this format defines simple chapter structures in media files.
    enum PSC: Hashable, Equatable, Sendable {}
}

/// Defines RSS common tags.
public enum RSSTag: Hashable, Equatable, Sendable {}
