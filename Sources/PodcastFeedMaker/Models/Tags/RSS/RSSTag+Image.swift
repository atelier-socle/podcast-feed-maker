import Foundation

public extension RSSTag {

    /// The `<image>` tag in an RSS feed.
    ///
    /// This tag defines a representative image for the entire podcast feed.
    /// It is typically displayed in podcast directories and aggregators.
    ///
    /// - Note: The `<image>` tag is part of the [RSS 2.0 specification](https://cyber.harvard.edu/rss/rss.html#ltimagegtSubelementOfLtchannelgt),
    /// but is **less commonly used** in favor of `<itunes:image>` in modern podcast platforms.
    ///
    /// - Important: The image URL **must be less than 144×400** pixels per the RSS spec.
    struct Image: Hashable, Equatable, Sendable {

        /// The URL of the image to display.
        public let url: URL

        /// The title for the image, usually matching the podcast title.
        public let title: String

        /// The link associated with the image (usually the podcast website).
        public let link: URL

        /// Initializes a new `<image>` tag for RSS 2.0 feeds.
        ///
        /// - Parameters:
        ///   - url: The direct URL to the image (must be under 144×400 px).
        ///   - title: Text displayed when hovering or used as alt text.
        ///   - link: A URL linking back to the podcast or website.
        public init(
            url: URL,
            title: String,
            link: URL
        ) {
            self.url = url
            self.title = title
            self.link = link
        }
    }
}

extension RSSTag.Image: XmlRepresentable {
    private func formattedTags() throws -> String {
        let tags: [String] = [
            "\t<url>\(url.encodeURLQueryAllowed)</url>",
            "\t<title>\(title.cleanSpecialChars())</title>",
            "\t<link>\(link.encodeURLQueryAllowed)</link>"
        ].compactMap { $0 }

        return tags.doubleIndentedTagsRepresentation
    }

    /// Generates the XML representation of the `<image>` block.
    ///
    /// Example:
    /// ```xml
    /// <image>
    ///   <url>https://example.com/logo.png</url>
    ///   <title>My Podcast</title>
    ///   <link>https://example.com</link>
    /// </image>
    /// ```
    ///
    /// - Returns: A complete `<image>` XML block.
    /// - Throws: If the image URL or link URL is invalid.
    public func xmlRepresentation() throws -> String {
        try url.isValid()
        try link.isValid()

        return try """
        \t<image>
        \(formattedTags())
        \t\t</image>
        """
    }
}
