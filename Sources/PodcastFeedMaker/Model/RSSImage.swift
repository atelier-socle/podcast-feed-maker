import Foundation

/// The `<image>` element from the RSS 2.0 specification.
///
/// Specifies a GIF, JPEG, or PNG image that represents the channel.
/// The image is displayed in podcast directories and feed readers.
///
/// - Note: Modern podcast feeds typically use `<itunes:image>` for artwork.
///   The RSS 2.0 `<image>` element has a 144x400 pixel maximum per the spec.
///
/// Example:
/// ```xml
/// <image>
///   <url>https://example.com/logo.png</url>
///   <title>My Podcast</title>
///   <link>https://example.com</link>
/// </image>
/// ```
///
/// - SeeAlso: [RSS 2.0 — image](https://www.rssboard.org/rss-specification#ltimagegtSubelementOfLtchannelgt)
public struct RSSImage: Sendable, Hashable, Equatable, Codable {

    /// The URL of the image.
    public var url: URL

    /// Describes the image; used in the ALT attribute of the HTML `<img>` tag.
    public var title: String

    /// The URL of the site. When the image is rendered, it links to this URL.
    public var link: URL

    /// The width of the image in pixels. Maximum value is 144, default is 88.
    public var width: Int?

    /// The height of the image in pixels. Maximum value is 400, default is 31.
    public var height: Int?

    /// Text included in the TITLE attribute of the link around the image.
    public var imageDescription: String?

    /// Creates a new RSS image element.
    ///
    /// - Parameters:
    ///   - url: The image URL.
    ///   - title: The image title (alt text).
    ///   - link: The URL the image links to.
    ///   - width: Optional width in pixels (max 144).
    ///   - height: Optional height in pixels (max 400).
    ///   - imageDescription: Optional title attribute text.
    public init(
        url: URL,
        title: String,
        link: URL,
        width: Int? = nil,
        height: Int? = nil,
        imageDescription: String? = nil
    ) {
        self.url = url
        self.title = title
        self.link = link
        self.width = width
        self.height = height
        self.imageDescription = imageDescription
    }
}
