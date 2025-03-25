import Foundation

public extension Namespace.Podcast {

    /// The `<podcast:location>` tag from the Podcast Namespace.
    ///
    /// This tag provides the geographical location associated with a podcast or episode.
    /// It combines a human-readable place name with geographic coordinates.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#location).
    ///
    /// - Example:
    /// ```xml
    /// <podcast:location geo="geo:48.8566,2.3522">Paris, France</podcast:location>
    /// ```
    struct Location: Hashable, Equatable, Sendable {

        /// A descriptive location string (e.g. `"New York, NY, USA"`).
        public let place: String

        /// The latitude coordinate.
        public let latitude: Double

        /// The longitude coordinate.
        public let longitude: Double

        /// Initializes a new `<podcast:location>` tag.
        ///
        /// - Parameters:
        ///   - place: A readable label of the location (city, region, country).
        ///   - latitude: The latitude component of the location.
        ///   - longitude: The longitude component of the location.
        public init(
            place: String,
            latitude: Double,
            longitude: Double
        ) {
            self.place = place
            self.latitude = latitude
            self.longitude = longitude
        }
    }
}

extension Namespace.Podcast.Location: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:location>` tag.
    ///
    /// Includes both the textual place and the `geo:` coordinates attribute.
    ///
    /// Example output:
    /// ```xml
    /// <podcast:location geo="geo:51.5074,-0.1278">London, UK</podcast:location>
    /// ```
    ///
    /// - Returns: A properly formatted `<podcast:location>` element.
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:location geo="geo:\(latitude),\(longitude)">\(place)</podcast:location>
        """
    }
}
