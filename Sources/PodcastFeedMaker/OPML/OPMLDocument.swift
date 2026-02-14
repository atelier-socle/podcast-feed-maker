import Foundation

/// The root model representing a complete OPML document.
///
/// An `OPMLDocument` contains a version string, optional head metadata,
/// and a list of top-level outline nodes. OPML (Outline Processor Markup
/// Language) is the standard format for exchanging podcast subscription
/// lists between apps.
///
/// ## Creating an OPML Document
///
/// ```swift
/// let doc = OPMLDocument(
///     version: "2.0",
///     head: OPMLHead(title: "My Podcasts"),
///     outlines: [
///         OPMLOutline(
///             text: "Accidental Tech Podcast",
///             type: "rss",
///             xmlUrl: URL(string: "https://atp.fm/episodes?format=rss")!
///         )
///     ]
/// )
/// ```
///
/// ## Parsing and Generating
///
/// Use ``OPMLParser`` to parse OPML XML into an `OPMLDocument`,
/// and ``OPMLGenerator`` to generate XML from an `OPMLDocument`.
///
/// - SeeAlso: ``OPMLHead``, ``OPMLOutline``, ``OPMLParser``, ``OPMLGenerator``
public struct OPMLDocument: Sendable, Hashable, Equatable, Codable {

    // MARK: - Properties

    /// The OPML specification version (typically `"1.0"`, `"1.1"`, or `"2.0"`).
    public var version: String

    /// Optional head metadata (title, dates, owner, window state).
    public var head: OPMLHead?

    /// The top-level outline nodes in the `<body>` element.
    public var outlines: [OPMLOutline]

    // MARK: - Initialization

    /// Creates a new OPML document.
    ///
    /// - Parameters:
    ///   - version: The OPML version. Defaults to `"2.0"`.
    ///   - head: Optional head metadata.
    ///   - outlines: The top-level outline nodes. Defaults to empty.
    public init(
        version: String = "2.0",
        head: OPMLHead? = nil,
        outlines: [OPMLOutline] = []
    ) {
        self.version = version
        self.head = head
        self.outlines = outlines
    }

    // MARK: - Computed Helpers

    /// The document title from the head, if present.
    public var title: String? {
        head?.title
    }

    /// All podcast feed outlines across the entire document (depth-first).
    ///
    /// Returns only outlines where ``OPMLOutline/isPodcastFeed`` is `true`
    /// (type is `"rss"` with a non-nil ``OPMLOutline/xmlUrl``).
    public var podcastFeeds: [OPMLOutline] {
        outlines.flatMap(\.allOutlines).filter(\.isPodcastFeed)
    }

    /// The total number of outlines in the document (all levels).
    public var totalOutlineCount: Int {
        outlines.reduce(0) { $0 + $1.allOutlines.count }
    }

    /// All unique feed URLs across the entire document.
    public var feedURLs: [URL] {
        podcastFeeds.compactMap(\.xmlUrl)
    }
}
