public extension Namespace.iTunes {
    struct EpisodeType: Hashable, Equatable, Sendable {
        public let value: String

        package init(value: String) {
            self.value = value
        }

        public init(type: EpisodeTypeValue) {
            self.init(value: type.rawValue)
        }
    }

    enum EpisodeTypeValue: String, Hashable, Equatable, Sendable {
        case full
        case trailer
        case bonus
    }
}

extension Namespace.iTunes.EpisodeType: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        """
        \t<itunes:episodeType>\(value)</itunes:episodeType>
        """
    }
}
