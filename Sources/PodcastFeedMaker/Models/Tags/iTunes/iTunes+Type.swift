public extension Namespace.iTunes {

    /// The `<itunes:type>` tag from the Apple Podcasts namespace.
    ///
    /// This tag defines how episodes in the podcast should be consumed:
    /// either in **episodic** (default) or **serial** order.
    ///
    /// - Important: This tag is **optional**, but highly recommended to guide app behavior.
    /// - SeeAlso: [Apple Podcasts – Podcast Type](https://help.apple.com/itc/podcasts_connect/#/itcb54353390)
    ///
    /// - Example:
    /// ```xml
    /// <itunes:type>serial</itunes:type>
    /// ```
    struct ChannelType: Hashable, Equatable, Sendable {

        /// The type of the podcast channel (`.episodic` or `.serial`).
        public let type: ChannelTypeValue

        /// Initializes a new `<itunes:type>` tag.
        ///
        /// - Parameter type: The podcast presentation style.
        public init(type: ChannelTypeValue) {
            self.type = type
        }
    }

    /// Possible values for the `<itunes:type>` tag.
    ///
    /// - `episodic`: Episodes can be listened to in any order (default).
    /// - `serial`: Episodes should be consumed in a specific sequence (e.g., narrative series).
    enum ChannelTypeValue: String, Hashable, Equatable, Sendable {
        case episodic
        case serial
    }
}

extension Namespace.iTunes.ChannelType: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:type>` tag.
    ///
    /// - Returns: A valid `<itunes:type>` element with the selected value.
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:type>\(type.rawValue)</itunes:type>
        """
    }
}
