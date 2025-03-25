import Foundation

public extension Namespace.Podcast {

    /// The `<podcast:transcript>` tag from the Podcast Namespace.
    ///
    /// This tag provides a URL to a transcript file associated with the episode.
    /// It improves accessibility and enables platforms to display time-synced captions.
    ///
    /// - Important: This tag is defined in the [Podcast Namespace specification](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript).
    /// - Note: Apple Podcasts prefers `text/vtt` over other formats when multiple transcripts are provided.
    struct Transcript: Hashable, Equatable, Sendable {

        /// The URL pointing to the transcript file.
        public let url: URL

        /// The MIME type of the transcript file.
        public let type: String

        /// Internal initializer using a raw string type.
        ///
        /// - Parameters:
        ///   - url: The transcript file URL.
        ///   - type: The MIME type as string.
        package init(
            url: URL,
            type: String
        ) {
            self.url = url
            self.type = type
        }

        /// Public initializer using a strongly typed transcript format.
        ///
        /// - Parameters:
        ///   - url: The transcript file URL.
        ///   - type: A known `TranscriptType` MIME enum.
        public init(
            url: URL,
            type: TranscriptType
        ) {
            self.init(url: url, type: type.rawValue)
        }
    }
}

extension Namespace.Podcast.Transcript {

    /// Supported MIME types for `<podcast:transcript>`.
    ///
    /// - Note: Apple Podcasts prefers `text/vtt` over `application/srt` or `application/x-subrip`.
    public enum TranscriptType: String, Hashable, Equatable, Sendable {
        /// WebVTT format.
        case vtt = "text/vtt"
        /// Standard SRT format.
        case srt = "application/srt"
        /// SubRip format alternative.
        case subrip = "application/x-subrip"
    }

    /// Error raised when the transcript type is invalid or unrecognized.
    public enum TranscriptTypeError: Swift.Error, LocalizedError {
        case invalidType

        public var errorDescription: String? {
            switch self {
            case .invalidType:
                return "Invalid transcript type"
            }
        }
    }
}

extension Namespace.Podcast.Transcript: XmlRepresentable {

    /// Generates the XML representation of the `<podcast:transcript>` tag.
    ///
    /// - Returns: A `<podcast:transcript>` tag with required `url` and `type` attributes.
    /// - Throws: If the `URL` is invalid or the `type` is not supported.
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        guard let type = TranscriptType(rawValue: type) else {
            throw TranscriptTypeError.invalidType
        }

        return """
        \t<podcast:transcript url="\(url.encodeURLQueryAllowed)" type="\(type.rawValue)" />
        """
    }
}
