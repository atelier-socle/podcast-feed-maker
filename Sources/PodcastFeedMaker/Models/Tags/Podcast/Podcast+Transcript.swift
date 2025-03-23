import Foundation

public extension Namespace.Podcast {
    struct Transcript: Hashable, Equatable, Sendable {
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
            type: TranscriptType
        ) {
            self.init(url: url, type: type.rawValue)
        }
    }
}

extension Namespace.Podcast.Transcript {
    /// The transcript format type.
    ///
    ///  Apple Podcasts will prefer VTT format over SRT format if multiple instances are included. A valid type attribute is required. Accepted types include text/vtt, application/srt, application/x-subrip.
    public enum TranscriptType: String, Hashable, Equatable, Sendable {
        /// VTT text type.
        case vtt = "text/vtt"
        /// SRT application type.
        case srt = "application/srt"
        /// SUBRIP application type.
        case subrip = "application/x-subrip"
    }

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
