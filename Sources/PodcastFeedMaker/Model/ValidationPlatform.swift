import Foundation

/// Represents a podcast distribution platform for feed validation purposes.
///
/// Each platform has specific requirements for RSS feed structure, required tags,
/// artwork dimensions, and supported media formats. The ``FeedValidator`` uses
/// these platforms to check feed compliance.
///
/// - SeeAlso: ``FeedValidator``
public enum ValidationPlatform: String, CaseIterable, Hashable, Equatable, Sendable, Codable {

    /// Apple Podcasts — requires HTTPS, artwork 1400-3000px, iTunes tags.
    case apple

    /// Spotify — requires MP3, artwork 1400-2048px, max 4000 bytes description.
    case spotify

    /// Amazon Music — broadest format support, artwork 1400-3000px.
    case amazon

    /// Podcast Index — all Podcast NS 2.0 tags, V4V validation.
    case podcastIndex

    /// PSP-1 — atom:link self, podcast:locked, podcast:guid required.
    case psp1
}

/// Severity level for validation results.
public enum ValidationSeverity: String, Hashable, Equatable, Sendable, Codable {

    /// A critical issue that will prevent the feed from being accepted.
    case error

    /// A non-critical issue that may affect discoverability or display.
    case warning

    /// An informational note about best practices.
    case info
}
