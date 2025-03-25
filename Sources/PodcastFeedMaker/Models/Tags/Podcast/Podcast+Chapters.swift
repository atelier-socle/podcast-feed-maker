import Foundation

public extension Namespace.Podcast {

    /// The `<podcast:chapters>` tag from the Podcast Namespace.
    ///
    /// This tag points to a chapters file that describes the timeline structure of the episode.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#chapters).
    ///
    /// - Note: The chapters file is typically in JSON format and must be publicly accessible via HTTPS.
    struct Chapters: Hashable, Equatable, Sendable {

        /// The URL to the chapters JSON file.
        public let url: URL

        /// The MIME type of the chapters document (e.g. `application/json`).
        public let type: String

        /// Internal initializer with raw type.
        ///
        /// - Parameters:
        ///   - url: The chapters file URL.
        ///   - type: The MIME type as string.
        package init(
            url: URL,
            type: String
        ) {
            self.url = url
            self.type = type
        }

        /// Public initializer using a strongly typed chapters format.
        ///
        /// - Parameters:
        ///   - url: The chapters file URL.
        ///   - type: The MIME type using the `ChaptersType` enum.
        public init(
            url: URL,
            type: ChaptersType
        ) {
            self.init(url: url, type: type.rawValue)
        }
    }
}

extension Namespace.Podcast.Chapters {

    /// Supported MIME types for `<podcast:chapters>`.
    ///
    /// - Note: As of Podcast Namespace v1.0, only JSON is officially supported.
    public enum ChaptersType: String, Hashable, Equatable, Sendable {
        /// JSON chapter format (default).
        case json = "application/json"
    }

    /// Errors thrown by the `Chapters` XML conversion logic.
    public enum ChaptersTypeError: Swift.Error, LocalizedError {
        /// Raised when the MIME type is unsupported.
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

    /// Generates the XML representation of the `<podcast:chapters>` tag.
    ///
    /// - Returns: An indented and valid XML `<podcast:chapters>` element.
    /// - Throws: If the URL is invalid or the type is unsupported.
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
