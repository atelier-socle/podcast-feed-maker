import Foundation

public extension Namespace.Podcast {
    struct Location: Hashable, Equatable, Sendable {
        /// The place describing city, region, country.
        public let place: String
        public let latitude: Double
        public let longitude: Double

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
    /*
     <podcast:location geo="geo:30.3321838,-81.65565099999999">Jacksonville, FL, USA</podcast:location>
     */
    public func xmlRepresentation() throws -> String {
        """
        \t<podcast:location geo="geo:\(latitude),\(longitude)">\(place)</podcast:location>
        """
    }
}
