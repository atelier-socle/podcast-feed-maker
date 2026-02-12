import Foundation

/// The `<guid>` element for an RSS 2.0 item.
///
/// A globally unique identifier for the item. When present, an aggregator may
/// choose to use this string to determine if an item is new.
///
/// - Important: Required by Apple Podcasts and PSP-1 for each `<item>`.
///
/// Example:
/// ```xml
/// <guid isPermaLink="false">episode-001-unique-id</guid>
/// ```
///
/// - SeeAlso: [RSS 2.0 — guid](https://www.rssboard.org/rss-specification#ltguidgtSubelementOfLtitemgt)
public struct GUID: Sendable, Hashable, Equatable, Codable {

    /// The unique identifier value.
    public var value: String

    /// Whether the GUID is a permalink (a URL that can be opened in a browser).
    ///
    /// Defaults to `true` per the RSS 2.0 spec. When `false`, the GUID is treated
    /// as an opaque identifier.
    public var isPermaLink: Bool

    /// Creates a new GUID.
    ///
    /// - Parameters:
    ///   - value: The unique identifier string.
    ///   - isPermaLink: Whether the value is a valid URL. Defaults to `true`.
    public init(value: String, isPermaLink: Bool = true) {
        self.value = value
        self.isPermaLink = isPermaLink
    }
}
