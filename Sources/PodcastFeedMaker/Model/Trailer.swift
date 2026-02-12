import Foundation

/// The `<podcast:trailer>` element from Podcast Namespace 2.0.
///
/// Defines a trailer or preview for the podcast or a specific season.
/// Multiple trailers can be defined per channel.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:trailer url="https://example.com/trailer.mp3"
///                  pubdate="Thu, 01 Apr 2021 08:00:00 EST"
///                  length="12345678" type="audio/mpeg"
///                  season="2">Season 2 Trailer</podcast:trailer>
/// ```
///
/// - SeeAlso: [Podcast NS — trailer](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#trailer)
public struct Trailer: Sendable, Hashable, Equatable, Codable {

    /// The title of the trailer.
    public var title: String

    /// The URL of the trailer media file.
    public var url: URL

    /// The publication date of the trailer.
    public var pubDate: Date

    /// The file size in bytes.
    public var length: Int?

    /// The MIME type of the trailer (e.g., `"audio/mpeg"`).
    public var type: String?

    /// The season number this trailer is associated with.
    public var season: Int?

    /// Creates a new trailer.
    ///
    /// - Parameters:
    ///   - title: The trailer title.
    ///   - url: The media file URL.
    ///   - pubDate: The publication date.
    ///   - length: Optional file size in bytes.
    ///   - type: Optional MIME type.
    ///   - season: Optional season number.
    public init(
        title: String,
        url: URL,
        pubDate: Date,
        length: Int? = nil,
        type: String? = nil,
        season: Int? = nil
    ) {
        self.title = title
        self.url = url
        self.pubDate = pubDate
        self.length = length
        self.type = type
        self.season = season
    }
}
