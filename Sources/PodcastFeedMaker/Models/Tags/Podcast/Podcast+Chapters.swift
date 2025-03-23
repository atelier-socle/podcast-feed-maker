import Foundation

public extension Namespace.Podcast {
    struct Chapters: Hashable, Equatable, Sendable {
        public let url: URL
        public let type: String

        package init(
            url: URL,
            type: String
        ) {
            self.url = url
            self.type = type
        }

        public init(
            url: URL,
            type: ChaptersType
        ) {
            self.init(url: url, type: type.rawValue)
        }
    }
}

extension Namespace.Podcast.Chapters {
    /// The chapters format type.
    public enum ChaptersType: String, Hashable, Equatable, Sendable {
        /// JSON application type.
        case json = "application/json"
    }

    public enum ChaptersTypeError: Swift.Error, LocalizedError {
        case invalidType

        public var errorDescription: String? {
            switch self {
            case .invalidType:
                return "Invalid chapters type"
            }
        }
    }
}

extension Namespace.Podcast.Chapters: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        guard let type = ChaptersType(rawValue: type) else {
            throw ChaptersTypeError.invalidType
        }
        return """
        \t<podcast:chapters url="\(url.encodeURLQueryAllowed)" type="\(type.rawValue)"></podcast:chapters>
        """
    }
}
