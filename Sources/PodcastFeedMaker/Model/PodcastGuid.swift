import Foundation

/// The `<podcast:guid>` element from Podcast Namespace 2.0.
///
/// A globally unique, permanent identifier for the podcast. This GUID
/// persists across hosting changes and feed URL migrations.
///
/// - Important: Channel-level only. Required by PSP-1.
///
/// Example:
/// ```xml
/// <podcast:guid>917393e3-1b1e-5cef-ace4-edaa54e1f3e1</podcast:guid>
/// ```
///
/// - SeeAlso: [Podcast NS — guid](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#guid)
public struct PodcastGuid: Sendable, Hashable, Equatable, Codable {

    /// The UUID string for the podcast.
    public var value: String

    /// Creates a new podcast GUID.
    ///
    /// - Parameter value: The UUID string (should be a UUIDv5 per the spec).
    public init(value: String) {
        self.value = value
    }
}
