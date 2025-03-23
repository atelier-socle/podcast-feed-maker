public extension Namespace.iTunes {
    struct ChannelType: Hashable, Equatable, Sendable {
        public let type: ChannelTypeValue

        public init(type: ChannelTypeValue) {
            self.type = type
        }
    }

    enum ChannelTypeValue: String, Hashable, Equatable, Sendable {
        case episodic, serial
    }
}

extension Namespace.iTunes.ChannelType: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:type>\(type.rawValue)</itunes:type>
        """
    }
}
