import Foundation

public extension RSSTag {

    /// The `<enclosure>` tag for episode media files in a podcast RSS feed.
    ///
    /// This tag provides metadata about the audio, video, or PDF content for a specific episode.
    ///
    /// The tag includes 3 required attributes:
    /// - `url`: The direct link to the media file
    /// - `length`: The size of the file in bytes
    /// - `type`: The MIME type of the file
    ///
    /// - Important: This tag is **required** by [PSP-1](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification#item-elements)
    ///   and [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/#/itc2b3780e76) for each `<item>`.
    ///
    /// Example:
    /// ```xml
    /// <enclosure
    ///     url="https://mypodcast.com/episode001.mp3"
    ///     length="5650889"
    ///     type="audio/mpeg" />
    /// ```
    struct Enclosure: Hashable, Equatable, Sendable {

        /// The public URL of the media file.
        public let url: URL

        /// The size of the media file in bytes.
        public let length: Int

        /// The MIME type string for the file.
        public let type: String

        /// Internal initializer allowing full control over `type`.
        ///
        /// - Parameters:
        ///   - url: The URL of the media file.
        ///   - length: The file size in bytes.
        ///   - type: The MIME type as a string.
        package init(
            url: URL,
            length: Int,
            type: String
        ) {
            self.url = url
            self.length = length
            self.type = type
        }

        /// Initializes a new `<enclosure>` using a typed MIME value.
        ///
        /// - Parameters:
        ///   - url: The URL to the audio, video, or document file.
        ///   - length: File size in bytes.
        ///   - type: MIME type as defined by `EnclosureType`.
        public init(
            url: URL,
            length: Int,
            type: EnclosureType
        ) {
            self.init(url: url, length: length, type: type.rawValue)
        }
    }
}

public extension RSSTag.Enclosure {

    /// Supported MIME types for enclosures.
    ///
    /// Use these values to provide standards-compliant content types.
    enum EnclosureType: String, Hashable, Equatable, Sendable {
        /// Audio m4a file type.
        case m4a = "audio/m4a"
        /// Audio mpeg file type.
        case mpeg = "audio/mpeg"
        /// Video quicktime file type.
        case quicktime = "video/quicktime"
        /// Video mp4 file type.
        case mp4 = "video/mp4"
        /// Video m4v file type.
        case m4v = "video/m4v"
        /// Application pdf file type.
        case pdf = "application/pdf"
    }

    /// Errors related to invalid enclosure types.
    enum EnclosureError: Swift.Error, LocalizedError {
        /// Raised when the MIME type is not recognized.
        case invalidType

        public var errorDescription: String? {
            switch self {
            case .invalidType:
                return "Invalid enclosure type"
            }
        }
    }
}

extension RSSTag.Enclosure: XmlRepresentable {

    /// Generates the XML representation of the `<enclosure>` tag.
    ///
    /// Validates the URL and ensures the MIME type is known.
    ///
    /// - Returns: A self-closing `<enclosure>` tag with all required attributes.
    /// - Throws: `EnclosureError.invalidType` if the MIME type is not allowed.
    /// - Throws: Any error from `url.isValid()`.
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        guard let enclosureType = EnclosureType(rawValue: type) else {
            throw EnclosureError.invalidType
        }

        return """
        \t<enclosure url="\(url.encodeURLQueryAllowed)" length="\(length)" type="\(enclosureType.rawValue)" />
        """
    }
}
