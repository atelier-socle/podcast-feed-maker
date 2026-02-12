import Foundation

/// The `<podcast:funding>` element from Podcast Namespace 2.0.
///
/// Points listeners to a donation or support page for the podcast.
/// Multiple funding elements are allowed per channel.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:funding url="https://example.com/donate">Support the show</podcast:funding>
/// ```
///
/// - SeeAlso: [Podcast NS — funding](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#funding)
public struct Funding: Sendable, Hashable, Equatable, Codable {

    /// The URL to the funding or donation page.
    public var url: URL

    /// A human-readable label for the funding link.
    public var message: String

    /// Creates a new funding element.
    ///
    /// - Parameters:
    ///   - url: The funding page URL.
    ///   - message: A descriptive label (e.g., "Support the show").
    public init(url: URL, message: String) {
        self.url = url
        self.message = message
    }
}
