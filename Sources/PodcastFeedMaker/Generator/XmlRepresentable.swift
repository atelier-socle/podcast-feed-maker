import Foundation

// MARK: - XmlRepresentable Protocol

/// A protocol defining the ability to convert an object to an XML representation.
///
/// Types conforming to `XmlRepresentable` must implement the `xmlRepresentation()` method,
/// which returns the XML content as a `String`.
public protocol XmlRepresentable: Sendable {

    /// Returns the XML representation of the conforming object.
    ///
    /// - Throws: An error if the XML generation fails.
    /// - Returns: A `String` containing the XML representation.
    func xmlRepresentation() throws -> String
}

// MARK: - PodcastFeed

extension PodcastFeed: XmlRepresentable {

    /// Errors thrown during feed XML generation.
    public enum FeedError: Swift.Error, LocalizedError {

        /// Thrown when the channel is `nil` during XML conversion.
        case missingChannelTag

        public var errorDescription: String? {
            switch self {
            case .missingChannelTag:
                return "Missing channel tag"
            }
        }
    }

    /// Generates the complete RSS feed XML.
    public func xmlRepresentation() throws -> String {
        guard channel != nil else {
            throw FeedError.missingChannelTag
        }
        return try FeedGenerator().generate(self)
    }
}

// MARK: - Channel

extension Channel: XmlRepresentable {

    /// Generates the `<channel>` XML element with all tags.
    public func xmlRepresentation() throws -> String {
        let feed = PodcastFeed(channel: self)
        let xml = try FeedGenerator().generate(feed)

        // Extract just the <channel>...</channel> portion
        guard let channelStart = xml.range(of: "<channel>"),
            let channelEnd = xml.range(of: "</channel>", options: .backwards)
        else {
            return xml
        }
        return String(xml[channelStart.lowerBound...channelEnd.upperBound])
    }
}

// MARK: - Item

extension Item: XmlRepresentable {

    /// Generates the `<item>` XML element with all tags.
    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder(depth: 1)
        let gen = FeedGenerator()
        let lines = gen.generateItem(self, builder: b)
        return lines.joined(separator: "\n")
    }
}

// MARK: - Simple Types

extension Enclosure: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        return b.selfClosingElement(
            "enclosure",
            attributes: [
                ("url", XMLBuilder.encodeURL(url)),
                ("length", "\(length)"),
                ("type", "\(type)")
            ]
        )
    }
}

extension GUID: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        return b.element("guid", content: value, attributes: [("isPermaLink", "\(isPermaLink)")])
    }
}

extension RSSImage: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        let b1 = b.indented()
        var lines: [String] = []
        lines.append(b.openTag("image"))
        lines.append(b1.element("url", content: XMLBuilder.encodeURL(url)))
        lines.append(b1.element("title", content: title))
        lines.append(b1.element("link", content: XMLBuilder.encodeURL(link)))
        if let width { lines.append(b1.element("width", content: "\(width)")) }
        if let height { lines.append(b1.element("height", content: "\(height)")) }
        if let imageDescription { lines.append(b1.element("description", content: imageDescription)) }
        lines.append(b.closeTag("image"))
        return lines.joined(separator: "\n")
    }
}

extension RSSCategory: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        if let domain {
            return b.element("category", content: value, attributes: [("domain", domain)])
        }
        return b.element("category", content: value)
    }
}

extension RSSSource: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        return b.element("source", content: title, attributes: [("url", XMLBuilder.encodeURL(url))])
    }
}

extension ITunesOwner: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        let b1 = b.indented()
        return [
            b.openTag("itunes:owner"),
            b1.element("itunes:name", content: name),
            b1.element("itunes:email", content: email),
            b.closeTag("itunes:owner")
        ].joined(separator: "\n")
    }
}

extension ITunesCategory: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        if subcategories.isEmpty {
            return b.selfClosingElement("itunes:category", attributes: [("text", XMLBuilder.escape(text))])
        }
        let subs = subcategories.map {
            XMLBuilder().selfClosingElement("itunes:category", attributes: [("text", XMLBuilder.escape($0.text))])
        }.joined()
        return "<itunes:category text=\"\(XMLBuilder.escape(text))\">\(subs)</itunes:category>"
    }
}

extension AtomLink: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        var attrs: [(String, String)] = [("href", XMLBuilder.encodeURL(href))]
        if let rel { attrs.append(("rel", rel)) }
        if let type { attrs.append(("type", type)) }
        if let hreflang { attrs.append(("hreflang", hreflang)) }
        if let title { attrs.append(("title", XMLBuilder.escape(title))) }
        if let length { attrs.append(("length", "\(length)")) }
        return b.selfClosingElement("atom:link", attributes: attrs)
    }
}

// MARK: - Podcast Namespace Types

extension PodcastGuid: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        XMLBuilder().element("podcast:guid", content: value)
    }
}

extension Locked: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = []
        if let owner { attrs.append(("owner", owner)) }
        return XMLBuilder().element("podcast:locked", content: XMLBuilder.boolYesNo(isLocked), attributes: attrs)
    }
}

extension Funding: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        XMLBuilder().element("podcast:funding", content: message, attributes: [("url", XMLBuilder.encodeURL(url))])
    }
}

extension Transcript: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = [
            ("url", XMLBuilder.encodeURL(url)),
            ("type", type)
        ]
        if let language { attrs.append(("language", language)) }
        if let rel { attrs.append(("rel", rel)) }
        return XMLBuilder().selfClosingElement("podcast:transcript", attributes: attrs)
    }
}

extension ChaptersLink: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        XMLBuilder().selfClosingElement(
            "podcast:chapters",
            attributes: [
                ("url", XMLBuilder.encodeURL(url)),
                ("type", type)
            ]
        )
    }
}

extension Soundbite: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let attrs: [(String, String)] = [
            ("startTime", "\(startTime)"),
            ("duration", "\(duration)")
        ]
        if let title {
            return XMLBuilder().element("podcast:soundbite", content: title, attributes: attrs)
        }
        return XMLBuilder().selfClosingElement("podcast:soundbite", attributes: attrs)
    }
}

extension PodcastPerson: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = []
        if let role { attrs.append(("role", role)) }
        if let group { attrs.append(("group", group)) }
        if let img { attrs.append(("img", XMLBuilder.encodeURL(img))) }
        if let href { attrs.append(("href", XMLBuilder.encodeURL(href))) }
        return XMLBuilder().element("podcast:person", content: name, attributes: attrs)
    }
}

extension PodcastLocation: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = []
        if let geo { attrs.append(("geo", geo)) }
        if let osm { attrs.append(("osm", osm)) }
        return XMLBuilder().element("podcast:location", content: name, attributes: attrs)
    }
}

extension PodcastLicense: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = []
        if let url { attrs.append(("url", XMLBuilder.encodeURL(url))) }
        return XMLBuilder().element("podcast:license", content: identifier, attributes: attrs)
    }
}

extension PodcastTxt: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = []
        if let purpose { attrs.append(("purpose", purpose)) }
        return XMLBuilder().element("podcast:txt", content: value, attributes: attrs)
    }
}

extension PodcastValue: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        let b = XMLBuilder()
        var attrs: [(String, String)] = [("type", type), ("method", method)]
        if let suggested { attrs.append(("suggested", suggested)) }
        var lines = [b.openTag("podcast:value", attributes: attrs)]
        for recipient in recipients {
            lines.append(try recipient.xmlRepresentation())
        }
        lines.append(b.closeTag("podcast:value"))
        return lines.joined(separator: "\n")
    }
}

extension ValueRecipient: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs: [(String, String)] = []
        if let name { attrs.append(("name", name)) }
        attrs.append(("type", type))
        attrs.append(("address", address))
        if let customKey { attrs.append(("customKey", customKey)) }
        if let customValue { attrs.append(("customValue", customValue)) }
        attrs.append(("split", "\(split)"))
        if let fee { attrs.append(("fee", XMLBuilder.boolTrueFalse(fee))) }
        return XMLBuilder().selfClosingElement("podcast:valueRecipient", attributes: attrs)
    }
}
