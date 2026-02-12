import Foundation

/// The `<podcast:location>` element from Podcast Namespace 2.0.
///
/// Describes a location relevant to the podcast or episode. Can include
/// geographic coordinates and an OpenStreetMap reference.
///
/// - Important: Used at both channel and item level.
///
/// Example:
/// ```xml
/// <podcast:location geo="geo:30.2672,-97.7431" osm="R113314">Austin, TX</podcast:location>
/// ```
///
/// - SeeAlso: [Podcast NS — location](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#location)
public struct PodcastLocation: Sendable, Hashable, Equatable, Codable {

    /// The human-readable place name.
    public var name: String

    /// A geo URI (RFC 5870) with coordinates (e.g., `"geo:30.2672,-97.7431"`).
    public var geo: String?

    /// An OpenStreetMap identifier (e.g., `"R113314"`).
    ///
    /// Format: a single character type prefix (`N`, `W`, `R`) followed by the OSM ID number.
    public var osm: String?

    /// Creates a new podcast location.
    ///
    /// - Parameters:
    ///   - name: The place name.
    ///   - geo: Optional geo URI with coordinates.
    ///   - osm: Optional OpenStreetMap identifier.
    public init(name: String, geo: String? = nil, osm: String? = nil) {
        self.name = name
        self.geo = geo
        self.osm = osm
    }
}
