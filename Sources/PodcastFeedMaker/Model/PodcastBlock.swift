import Foundation

/// The `<podcast:block>` element from Podcast Namespace 2.0.
///
/// Allows a podcast to indicate that it should not be listed on specific
/// platforms. Uses an optional `id` attribute to target a specific platform.
///
/// - Note: This is distinct from `<itunes:block>` which is a simple yes/no boolean.
///   `<podcast:block>` supports platform-specific targeting via the `id` attribute.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:block id="google">yes</podcast:block>
/// <podcast:block>yes</podcast:block>
/// ```
///
/// - SeeAlso: [Podcast NS — block](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#block)
public struct PodcastBlock: Sendable, Hashable, Equatable, Codable {

    /// Whether the block is active.
    public var isBlocked: Bool

    /// The platform service slug to target (e.g., `"google"`, `"amazon"`).
    ///
    /// If `nil`, the block applies to all platforms.
    public var id: String?

    /// Creates a new podcast block element.
    ///
    /// - Parameters:
    ///   - isBlocked: Whether the feed is blocked.
    ///   - id: Optional platform identifier.
    public init(isBlocked: Bool, id: String? = nil) {
        self.isBlocked = isBlocked
        self.id = id
    }
}
