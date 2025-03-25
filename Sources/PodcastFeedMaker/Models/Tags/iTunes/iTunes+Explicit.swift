public extension Namespace.iTunes {

    /// The `<itunes:explicit>` tag from the Apple Podcasts namespace.
    ///
    /// This tag indicates whether the episode or podcast contains explicit content.
    /// Platforms like Apple Podcasts use it to inform users and filter content appropriately.
    ///
    /// - Important: This tag is defined in the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itcb54353390).
    ///
    /// - Note: Valid values in XML are:
    ///     - `"true"` → content is explicit
    ///     - `"false"` → content is clean or not explicit
    ///
    /// - Example:
    /// ```xml
    /// <itunes:explicit>true</itunes:explicit>
    /// ```
    struct Explicit: Hashable, Equatable, Sendable {

        /// The string value to include in XML: `"true"` or `"false"`.
        public let value: String

        /// Internal initializer with raw string.
        ///
        /// - Parameter value: The string representation (`"true"` or `"false"`).
        package init(value: String) {
            self.value = value
        }

        /// Public initializer using an enum describing the type.
        ///
        /// - Parameter type: One of `.yes`, `.no`, or `.clean`.
        public init(_ type: ExplicitType) {
            self.init(value: type.formattedValue)
        }

        /// The level of explicit content for the episode or show.
        ///
        /// Used to generate correct Apple Podcasts metadata.
        public enum ExplicitType: String, Hashable, Equatable, Sendable {
            /// Indicates explicit content (`<itunes:explicit>true</itunes:explicit>`).
            case yes
            /// Indicates clean content (`<itunes:explicit>false</itunes:explicit>`).
            case no
            /// Also indicates clean content (`<itunes:explicit>false</itunes:explicit>`).
            case clean

            /// The XML-compatible string value.
            ///
            /// - `"true"` for `.yes`
            /// - `"false"` for `.no` and `.clean`
            var formattedValue: String {
                switch self {
                case .yes:
                    true.stringValue
                case .no, .clean:
                    false.stringValue
                }
            }
        }
    }
}

extension Namespace.iTunes.Explicit: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:explicit>` tag.
    ///
    /// - Returns: A properly formatted XML tag indicating explicit content status.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:explicit>\(value)</itunes:explicit>
        """
    }
}
