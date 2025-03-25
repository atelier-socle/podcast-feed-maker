import Foundation

public extension Namespace.iTunes {

    /// The `<itunes:image>` tag from the Apple Podcasts namespace.
    ///
    /// This tag specifies a custom image for the podcast or episode.
    /// The image should follow Apple’s recommended dimensions and format for proper display.
    ///
    /// - Important: This tag is defined by the [Apple Podcasts specification](https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12).
    /// - Note: The image must be accessible via HTTPS and preferably square (e.g., 1400x1400 up to 3000x3000 px, JPEG or PNG).
    ///
    /// - Example:
    /// ```xml
    /// <itunes:image href="https://example.com/image.jpg" />
    /// ```
    struct Image: Hashable, Equatable, Sendable {

        /// The URL of the image resource.
        public let url: URL

        /// Creates a new `<itunes:image>` tag.
        ///
        /// - Parameter url: The absolute URL of the image (must be HTTPS).
        public init(url: URL) {
            self.url = url
        }
    }
}

extension Namespace.iTunes.Image: XmlRepresentable {

    /// Generates the XML representation of the `<itunes:image>` tag.
    ///
    /// - Returns: A self-closing `<itunes:image>` tag with the required `href` attribute.
    /// - Throws: If the URL is not valid (via `url.isValid()`).
    public func xmlRepresentation() throws -> String {
        try url.isValid()

        return """
        \t<itunes:image href="\(url.encodeURLQueryAllowed)" />
        """
    }
}
