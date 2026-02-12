import Foundation

/// The `<podcast:chapters>` element from Podcast Namespace 2.0.
///
/// Links to an external JSON Chapters file that defines chapter markers
/// for the episode. The JSON format is defined by the Podcast Namespace spec.
///
/// - Important: Item-level only.
///
/// Example:
/// ```xml
/// <podcast:chapters url="https://example.com/ep1/chapters.json"
///                   type="application/json+chapters" />
/// ```
///
/// - SeeAlso: [Podcast NS — chapters](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#chapters)
/// - SeeAlso: [JSON Chapters Format](https://github.com/Podcastindex-org/podcast-namespace/blob/main/chapters/jsonChapters.md)
public struct ChaptersLink: Sendable, Hashable, Equatable, Codable {

    /// The URL of the chapters file.
    public var url: URL

    /// The MIME type of the chapters file (typically `"application/json+chapters"`).
    public var type: String

    /// Creates a new chapters link.
    ///
    /// - Parameters:
    ///   - url: The URL to the chapters JSON file.
    ///   - type: The MIME type. Defaults to `"application/json+chapters"`.
    public init(url: URL, type: String = "application/json+chapters") {
        self.url = url
        self.type = type
    }
}
