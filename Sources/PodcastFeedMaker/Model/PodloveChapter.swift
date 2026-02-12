import Foundation

/// A single chapter marker in the Podlove Simple Chapters format.
///
/// Represents a chapter within an episode, with a start time, title,
/// and optional URL and image.
///
/// Example:
/// ```xml
/// <psc:chapter start="00:00:00.000" title="Intro"
///              href="https://example.com" image="https://example.com/img.jpg" />
/// ```
///
/// - SeeAlso: [Podlove Simple Chapters](https://podlove.org/simple-chapters/)
public struct PodloveChapter: Sendable, Hashable, Equatable, Codable {

    /// The start time in the Normal Play Time (NPT) format (e.g., `"00:05:30.000"`).
    public var start: String

    /// The chapter title.
    public var title: String

    /// An optional URL associated with this chapter.
    public var href: URL?

    /// An optional image URL for this chapter.
    public var image: URL?

    /// Creates a new Podlove chapter.
    ///
    /// - Parameters:
    ///   - start: The start time in NPT format.
    ///   - title: The chapter title.
    ///   - href: Optional associated URL.
    ///   - image: Optional chapter image URL.
    public init(start: String, title: String, href: URL? = nil, image: URL? = nil) {
        self.start = start
        self.title = title
        self.href = href
        self.image = image
    }
}

// MARK: - PodloveChapters

/// A container for Podlove Simple Chapters, wrapping multiple ``PodloveChapter`` entries.
///
/// Represents the `<psc:chapters>` element that contains one or more
/// `<psc:chapter>` entries.
///
/// Example:
/// ```xml
/// <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
///   <psc:chapter start="00:00:00.000" title="Intro" />
///   <psc:chapter start="00:05:30.000" title="Main Topic" />
/// </psc:chapters>
/// ```
///
/// - SeeAlso: [Podlove Simple Chapters](https://podlove.org/simple-chapters/)
public struct PodloveChapters: Sendable, Hashable, Equatable, Codable {

    /// The Podlove Simple Chapters version (typically `"1.2"`).
    public var version: String

    /// The chapter entries.
    public var chapters: [PodloveChapter]

    /// Creates a new Podlove chapters container.
    ///
    /// - Parameters:
    ///   - version: The PSC version. Defaults to `"1.2"`.
    ///   - chapters: The chapter entries.
    public init(version: String = "1.2", chapters: [PodloveChapter] = []) {
        self.version = version
        self.chapters = chapters
    }
}
