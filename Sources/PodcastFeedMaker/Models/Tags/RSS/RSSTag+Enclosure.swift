import Foundation

public extension RSSTag {
    /// The episode content, file size, and file type information.
    ///
    /// The `<enclosure>` tag has three attributes: URL, length, and type:
    ///
    /// - **URL**. The URL attribute points to your podcast media file. Specify the full file extension within the URL attribute. This determines whether or not content appears in the podcast directory. Supported file formats include M4A, MP3, MOV, MP4, M4V, and PDF.
    /// - **Length**. The length attribute is the file size in bytes. You can find this information in the properties of your podcast file (on a Mac, choose File > Get Info and refer to the size field).
    /// - **Type**. The type attribute provides the correct category for the type of file you are using. The type values for the supported file formats are: audio/x-m4a, audio/mpeg, video/quicktime, video/mp4, video/x-m4v, and application/pdf.
    /// For example:
    /// ```xml
    /// <enclosure
    /// url="http://mypodcast.com/episode001.mp3"
    /// length="5650889"
    /// type="audio/mpeg
    ////>
    ///```
    struct Enclosure: Hashable, Equatable, Sendable {
        public let url: URL
        public let length: Int
        public let type: String
        
        package init(
            url: URL,
            length: Int,
            type: String
        ) {
            self.url = url
            self.length = length
            self.type = type
        }
        
        public init(
            url: URL,
            length: Int,
            type: EnclosureType
        ) {
            self.url = url
            self.length = length
            self.type = type.rawValue
        }
    }
}

public extension RSSTag.Enclosure {
    /// The enclosure type for content file.
    ///
    /// The type attribute provides the correct category for the type of file you are using.
    ///
    /// The type values for the supported file formats are:
    /// - audio/x-m4a
    /// - audio/mpeg
    /// - video/quicktime
    /// - video/mp4
    /// - video/x-m4v
    /// - application/pdf
    enum EnclosureType: String, Hashable, Equatable, Sendable {
        /// Audio m4a file type.
        case m4a = "audio/m4a" // "audio/x-m4a"
        /// Audio mpeg file type.
        case mpeg = "audio/mpeg"
        /// Video quicktime file type.
        case quicktime = "video/quicktime"
        /// Video mp4 file type.
        case mp4 = "video/mp4"
        /// Video m4v file type.
        case m4v = "video/m4v" // "video/x-m4v"
        /// Application pdf file type.
        case pdf = "application/pdf"
    }

    enum EnclosureError: Swift.Error, LocalizedError {
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
