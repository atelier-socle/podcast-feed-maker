import Foundation

/// The `<podcast:license>` element from Podcast Namespace 2.0.
///
/// Specifies the license under which the podcast (channel-level) or
/// an individual episode (item-level) is released.
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:license url="https://creativecommons.org/licenses/by/4.0/">cc-by-4.0</podcast:license>
/// ```
///
/// - SeeAlso: [Podcast NS — license](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#license)
public struct PodcastLicense: Sendable, Hashable, Equatable, Codable {

    /// The license identifier (e.g., `"cc-by-4.0"`, `"cc-by-sa-4.0"`).
    public var identifier: String

    /// An optional URL to the full license text.
    public var url: URL?

    /// Creates a new podcast license.
    ///
    /// - Parameters:
    ///   - identifier: The license identifier string.
    ///   - url: Optional URL to the license text.
    public init(identifier: String, url: URL? = nil) {
        self.identifier = identifier
        self.url = url
    }
}
