import Foundation

/// The `<podcast:image>` element from Podcast Namespace 2.0.
///
/// A formalized image tag that expands use cases beyond square artwork.
/// Cross-compatible with `<itunes:image>` but supports aspect ratios,
/// dimensions, MIME types, and purpose tokens. Multiple images are allowed
/// per channel and per item.
///
/// - Important: This is a **different tag** from `<itunes:image>`, which only
///   has an `href` attribute. The parser distinguishes them by namespace prefix.
///
/// Example:
/// ```xml
/// <podcast:image href="https://example.com/art.jpg"
///                alt="Show artwork"
///                purpose="artwork"
///                aspect-ratio="1/1"
///                width="3000"
///                type="image/png" />
/// ```
///
/// - SeeAlso: [Podcast NS — image](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#image)
public struct PodcastImage: Sendable, Hashable, Equatable, Codable {

    /// The image URL (required).
    public var href: URL

    /// Accessibility-focused text replacement for the image content (recommended).
    public var alt: String?

    /// Aspect ratio following CSS syntax, e.g., `"1/1"`, `"16/9"`, `"4/1"` (recommended).
    public var aspectRatio: String?

    /// Width of the asset in pixels (recommended).
    public var width: Int?

    /// Height of the asset in pixels (optional).
    public var height: Int?

    /// MIME type, e.g., `"image/jpeg"`, `"image/png"`, `"video/mp4"` (optional).
    public var type: String?

    /// Space-separated purpose tokens, e.g., `"artwork"`, `"social"`, `"icon"`, `"canvas"` (optional).
    ///
    /// Max 128 characters. Indicates suggested uses of this media.
    public var purpose: String?

    /// Creates a new podcast image.
    ///
    /// - Parameters:
    ///   - href: The image URL.
    ///   - alt: Optional accessibility text.
    ///   - aspectRatio: Optional CSS aspect ratio string.
    ///   - width: Optional width in pixels.
    ///   - height: Optional height in pixels.
    ///   - type: Optional MIME type.
    ///   - purpose: Optional space-separated purpose tokens.
    public init(
        href: URL,
        alt: String? = nil,
        aspectRatio: String? = nil,
        width: Int? = nil,
        height: Int? = nil,
        type: String? = nil,
        purpose: String? = nil
    ) {
        self.href = href
        self.alt = alt
        self.aspectRatio = aspectRatio
        self.width = width
        self.height = height
        self.type = type
        self.purpose = purpose
    }
}
