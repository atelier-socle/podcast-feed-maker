import Foundation

/// The deprecated `<podcast:images>` element from Podcast Namespace 2.0.
///
/// Uses an `srcset` attribute containing multiple image URLs with width
/// descriptors. Superseded by ``PodcastImage`` (singular `<podcast:image>`).
///
/// Parsed for round-trip fidelity but not recommended for new feed generation.
///
/// Example:
/// ```xml
/// <podcast:images srcset="https://example.com/art-1500.jpg 1500w,
///                         https://example.com/art-600.jpg 600w,
///                         https://example.com/art-300.jpg 300w" />
/// ```
///
/// - SeeAlso: ``PodcastImage``
public struct PodcastImages: Sendable, Hashable, Equatable, Codable {

    /// The `srcset` string containing multiple image URLs with width descriptors.
    ///
    /// Format: `"url1 1500w, url2 600w, url3 300w"`
    public var srcset: String

    /// Creates a new deprecated podcast images element.
    ///
    /// - Parameter srcset: The srcset attribute value.
    public init(srcset: String) {
        self.srcset = srcset
    }
}
