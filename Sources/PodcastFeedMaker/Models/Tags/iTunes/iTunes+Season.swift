import Foundation

public extension Namespace.iTunes {

    /// The `<itunes:season>` tag from the Apple Podcasts namespace.
    ///
    /// This tag specifies the season number that the episode belongs to.
    /// It helps platforms organize episodes within seasonal groupings, especially for serialized podcasts.
    ///
    /// - Important: Must be a **positive integer**. Season numbers should start at 1.
    /// - SeeAlso: [Apple Podcasts – Seasons & Episodes](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:season>2</itunes:season>
    /// ```
    struct Season: Hashable, Equatable, Sendable {

        /// The season number (must be ≥ 1).
        public let value: Int

        // Errors related to the `<itunes:season>` tag.
        public enum SeasonError: Swift.Error, LocalizedError {
            case invalidValue

            public var errorDescription: String? {
                "Season value must be a positive integer (1 or higher)."
            }
        }

        /// Initializes a new `<itunes:season>` tag.
        ///
        /// - Parameter value: The number of the season.
        /// - Throws: `SeasonError.invalidValue` if the value is less than 1.
        public init(value: Int) throws {
            guard value >= 1 else {
                throw SeasonError.invalidValue
            }
            self.value = value
        }
    }
}

extension Namespace.iTunes.Season: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:season>` tag.
    ///
    /// - Returns: A formatted XML tag with the season number.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:season>\(value)</itunes:season>
        """
    }
}
