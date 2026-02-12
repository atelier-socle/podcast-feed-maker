import Foundation

/// The `<category>` element from the RSS 2.0 specification.
///
/// Specifies one or more categories that the channel or item belongs to.
/// Each category may optionally include a `domain` attribute that identifies
/// a categorization taxonomy.
///
/// - Note: This is the RSS 2.0 core category, distinct from `<itunes:category>`.
///
/// Example:
/// ```xml
/// <category domain="http://www.example.com/categories">Technology</category>
/// ```
///
/// - SeeAlso: [RSS 2.0 — category](https://www.rssboard.org/rss-specification#ltcategorygtSubelementOfLtitemgt)
public struct RSSCategory: Sendable, Hashable, Equatable, Codable {

    /// The category name.
    public var value: String

    /// An optional domain URL identifying the taxonomy.
    public var domain: String?

    /// Creates a new RSS category.
    ///
    /// - Parameters:
    ///   - value: The category name.
    ///   - domain: An optional taxonomy domain URL.
    public init(value: String, domain: String? = nil) {
        self.value = value
        self.domain = domain
    }
}
