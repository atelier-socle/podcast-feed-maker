import Foundation

/// Metadata for an OPML document contained in the `<head>` element.
///
/// The head section provides information about the OPML document itself,
/// such as its title, creation date, and owner information. All properties
/// are optional per the OPML 2.0 specification.
///
/// ## Example
///
/// ```swift
/// let head = OPMLHead(
///     title: "My Podcast Subscriptions",
///     dateCreated: Date(),
///     ownerName: "John Doe",
///     ownerEmail: "john@example.com"
/// )
/// ```
///
/// - SeeAlso: ``OPMLDocument``
public struct OPMLHead: Sendable, Hashable, Equatable, Codable {

    // MARK: - Properties

    /// The title of the OPML document.
    public var title: String?

    /// The date the document was created.
    public var dateCreated: Date?

    /// The date the document was last modified.
    public var dateModified: Date?

    /// The name of the document owner.
    public var ownerName: String?

    /// The email address of the document owner.
    public var ownerEmail: String?

    /// The URL of the document owner's website.
    public var ownerId: URL?

    /// Documentation URL for the OPML format used.
    public var docs: URL?

    /// A comma-separated list of line numbers that are expanded.
    public var expansionState: String?

    /// The scroll position (line number at the top of the window).
    public var vertScrollState: Int?

    /// The x-coordinate of the window's top-left corner.
    public var windowTop: Int?

    /// The y-coordinate of the window's top-left corner.
    public var windowLeft: Int?

    /// The width of the window in pixels.
    public var windowBottom: Int?

    /// The height of the window in pixels.
    public var windowRight: Int?

    // MARK: - Initialization

    /// Creates a new OPML head.
    ///
    /// - Parameters:
    ///   - title: The document title.
    ///   - dateCreated: The creation date.
    ///   - dateModified: The last modification date.
    ///   - ownerName: The owner's name.
    ///   - ownerEmail: The owner's email.
    ///   - ownerId: The owner's website URL.
    ///   - docs: The documentation URL.
    ///   - expansionState: Comma-separated expanded line numbers.
    ///   - vertScrollState: The scroll position.
    ///   - windowTop: The window top coordinate.
    ///   - windowLeft: The window left coordinate.
    ///   - windowBottom: The window bottom coordinate.
    ///   - windowRight: The window right coordinate.
    public init(
        title: String? = nil,
        dateCreated: Date? = nil,
        dateModified: Date? = nil,
        ownerName: String? = nil,
        ownerEmail: String? = nil,
        ownerId: URL? = nil,
        docs: URL? = nil,
        expansionState: String? = nil,
        vertScrollState: Int? = nil,
        windowTop: Int? = nil,
        windowLeft: Int? = nil,
        windowBottom: Int? = nil,
        windowRight: Int? = nil
    ) {
        self.title = title
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.ownerName = ownerName
        self.ownerEmail = ownerEmail
        self.ownerId = ownerId
        self.docs = docs
        self.expansionState = expansionState
        self.vertScrollState = vertScrollState
        self.windowTop = windowTop
        self.windowLeft = windowLeft
        self.windowBottom = windowBottom
        self.windowRight = windowRight
    }
}
