import Foundation

/// The `<podcast:locked>` element from Podcast Namespace 2.0.
///
/// Tells podcast hosting platforms whether the feed owner has locked
/// the feed to prevent it from being imported by other platforms.
///
/// - Important: Channel-level only. Required by PSP-1.
///
/// Example:
/// ```xml
/// <podcast:locked owner="john@example.com">yes</podcast:locked>
/// ```
///
/// - SeeAlso: [Podcast NS — locked](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#locked)
public struct Locked: Sendable, Hashable, Equatable, Codable {

    /// Whether the feed is locked.
    public var isLocked: Bool

    /// The email address of the feed owner who has locked it.
    public var owner: String?

    /// Creates a new locked element.
    ///
    /// - Parameters:
    ///   - isLocked: Whether the feed is locked.
    ///   - owner: Optional owner email address.
    public init(isLocked: Bool, owner: String? = nil) {
        self.isLocked = isLocked
        self.owner = owner
    }
}
