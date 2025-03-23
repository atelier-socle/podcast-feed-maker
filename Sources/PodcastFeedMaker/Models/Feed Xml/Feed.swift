import Foundation

public struct Feed: Hashable, Equatable, Sendable {
    public let version: String
    public let namespaces: [Namespace]
    public let channel: RSSTag.Channel?

    public init(
        version: String = "2.0",
        namespaces: [Namespace] = Namespace.allCases,
        channel: RSSTag.Channel?
    ) {
        self.namespaces = namespaces
        self.version = version
        self.channel = channel
    }
}

extension Feed: XmlRepresentable {
    public func xmlRepresentation() throws -> String {
        guard let channel else {
            throw FeedError.missingChannelTag
        }
        let namespaces = namespaces.map(\.xmlns).joined(separator: " ")

        return try """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="\(version)" \(namespaces)>
        \(channel.xmlRepresentation())
        </rss>
        """
    }

    public enum FeedError: Swift.Error, LocalizedError {
        case missingChannelTag

        public var errorDescription: String? {
            switch self {
            case .missingChannelTag:
                return "Missing channel tag"
            }
        }
    }
}
