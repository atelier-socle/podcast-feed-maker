import Foundation

/// The `<podcast:location>` element from Podcast Namespace 2.0.
///
/// Describes a location relevant to the podcast or episode. Can include
/// geographic coordinates, an OpenStreetMap reference, a relationship type,
/// and a country code. Up to 2 location tags are allowed per channel/item
/// (one `"creator"` + one `"subject"`).
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:location rel="creator" geo="geo:30.2672,-97.7431"
///                   osm="R113314" country="US">Austin, TX</podcast:location>
/// <podcast:location rel="subject" geo="geo:48.8566,2.3522"
///                   osm="R7444" country="FR">Paris</podcast:location>
/// ```
///
/// - SeeAlso: [Podcast NS — location](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#location)
public struct PodcastLocation: Sendable, Hashable, Equatable, Codable {

    /// The human-readable place name (required, max 128 characters).
    public var name: String

    /// A geo URI (RFC 5870) with coordinates (e.g., `"geo:30.2672,-97.7431"`).
    public var geo: String?

    /// An OpenStreetMap identifier (e.g., `"R113314"`).
    ///
    /// Format: a single character type prefix (`N`, `W`, `R`) followed by the OSM ID number.
    public var osm: String?

    /// Relationship type — `"creator"` (where made) or `"subject"` (what it's about).
    public var rel: String?

    /// ISO 3166-1 alpha-2 country code (e.g., `"US"`, `"FR"`, `"GB"`).
    public var country: String?

    /// Creates a new podcast location.
    ///
    /// - Parameters:
    ///   - name: The place name.
    ///   - geo: Optional geo URI with coordinates.
    ///   - osm: Optional OpenStreetMap identifier.
    ///   - rel: Optional relationship type (`"creator"` or `"subject"`).
    ///   - country: Optional ISO 3166-1 alpha-2 country code.
    public init(
        name: String,
        geo: String? = nil,
        osm: String? = nil,
        rel: String? = nil,
        country: String? = nil
    ) {
        self.name = name
        self.geo = geo
        self.osm = osm
        self.rel = rel
        self.country = country
    }
}
