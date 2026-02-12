import Foundation

// MARK: - Legacy XML Generation
//
// This file preserves the XML generation logic extracted from the original
// Models/ directory. Each type's `xmlRepresentation()` method has been
// adapted to work with the new Model/ types.
//
// When the full FeedGenerator is implemented (sync + streaming),
// this file should be replaced by proper Generator-layer code.

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
        guard let channel else {
            throw FeedError.missingChannelTag
        }

        let nsDecls = namespaces.map(\.xmlnsDeclaration).joined(separator: " ")

        return try """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="\(version)" \(nsDecls)>
        \(channel.xmlRepresentation())
        </rss>
        """
    }
}

// MARK: - Channel

extension Channel: XmlRepresentable {

    /// Generates the `<channel>` XML element with all tags.
    public func xmlRepresentation() throws -> String { // swiftlint:disable:this cyclomatic_complexity function_body_length
        var tags: [String] = []

        // RSS 2.0 Core (required)
        tags.append("<title>\(title.cleanSpecialChars())</title>")
        tags.append("<link>\(link.encodeURLQueryAllowed)</link>")
        tags.append("<description>\(description.cleanSpecialChars())</description>")

        // RSS 2.0 Core (optional)
        if let language { tags.append("<language>\(language)</language>") }
        if let copyright { tags.append("<copyright>\(copyright.cleanSpecialChars())</copyright>") }
        if let managingEditor { tags.append("<managingEditor>\(managingEditor)</managingEditor>") }
        // swiftlint:disable:next inclusive_language
        if let webMaster { tags.append("<webMaster>\(webMaster)</webMaster>") }
        if let pubDate { tags.append("<pubDate>\(pubDate.rcfPubDate)</pubDate>") }
        if let lastBuildDate { tags.append("<lastBuildDate>\(lastBuildDate.rcfPubDate)</lastBuildDate>") }
        for category in categories {
            tags.append(try category.xmlRepresentation())
        }
        if let generator { tags.append("<generator>\(generator.cleanSpecialChars())</generator>") }
        if let docs { tags.append("<docs>\(docs.encodeURLQueryAllowed)</docs>") }
        if let ttl { tags.append("<ttl>\(ttl)</ttl>") }
        if let image { tags.append(try image.xmlRepresentation()) }

        // iTunes Namespace
        if let itunesAuthor { tags.append("<itunes:author>\(itunesAuthor.cleanSpecialChars())</itunes:author>") }
        if let itunesBlock { tags.append("<itunes:block>\(itunesBlock.stringValue)</itunes:block>") }
        for cat in itunesCategories {
            tags.append(try cat.xmlRepresentation())
        }
        if let itunesComplete { tags.append("<itunes:complete>\(itunesComplete.stringValue)</itunes:complete>") }
        if let itunesExplicit { tags.append("<itunes:explicit>\(itunesExplicit.stringValue)</itunes:explicit>") }
        if let itunesImage { tags.append("<itunes:image href=\"\(itunesImage.encodeURLQueryAllowed)\" />") }
        if !itunesKeywords.isEmpty {
            tags.append("<itunes:keywords>\(itunesKeywords.joined(separator: ","))</itunes:keywords>")
        }
        if let itunesNewFeedUrl {
            tags.append("<itunes:new-feed-url>\(itunesNewFeedUrl.encodeURLQueryAllowed)</itunes:new-feed-url>")
        }
        if let itunesOwner { tags.append(try itunesOwner.xmlRepresentation()) }
        if let itunesSubtitle { tags.append("<itunes:subtitle>\(itunesSubtitle.cleanSpecialChars())</itunes:subtitle>") }
        if let itunesSummary { tags.append("<itunes:summary>\(itunesSummary.cleanSpecialChars())</itunes:summary>") }
        if let itunesTitle { tags.append("<itunes:title>\(itunesTitle.cleanSpecialChars())</itunes:title>") }
        if let itunesType { tags.append("<itunes:type>\(itunesType.rawValue)</itunes:type>") }
        if let itunesVerify { tags.append("<itunes:applepodcastsverify>\(itunesVerify)</itunes:applepodcastsverify>") }

        // Atom
        for atomLink in atomLinks {
            tags.append(try atomLink.xmlRepresentation())
        }

        // Podcast Namespace 2.0
        if let podcastGuid { tags.append(try podcastGuid.xmlRepresentation()) }
        if let locked { tags.append(try locked.xmlRepresentation()) }
        for fund in funding {
            tags.append(try fund.xmlRepresentation())
        }
        for person in persons {
            tags.append(try person.xmlRepresentation())
        }
        if let location { tags.append(try location.xmlRepresentation()) }
        if let license { tags.append(try license.xmlRepresentation()) }
        if let value { tags.append(try value.xmlRepresentation()) }
        if let medium { tags.append("<podcast:medium>\(medium.rawValue)</podcast:medium>") }
        for txt in txtRecords {
            tags.append(try txt.xmlRepresentation())
        }

        // Items
        for item in items {
            tags.append(try item.xmlRepresentation())
        }

        let body = tags.indentedTagsRepresentation
        return """
        <channel>
        \(body)
        </channel>
        """
    }
}

// MARK: - Item

extension Item: XmlRepresentable {

    /// Generates the `<item>` XML element with all tags.
    public func xmlRepresentation() throws -> String { // swiftlint:disable:this cyclomatic_complexity
        var tags: [String] = []

        // RSS 2.0 Core
        if let title { tags.append("<title>\(title.cleanSpecialChars())</title>") }
        if let link { tags.append("<link>\(link.encodeURLQueryAllowed)</link>") }
        if let description { tags.append("<description>\(description.cleanSpecialChars())</description>") }
        if let author { tags.append("<author>\(author.cleanSpecialChars())</author>") }
        for category in categories {
            tags.append(try category.xmlRepresentation())
        }
        if let comments { tags.append("<comments>\(comments.encodeURLQueryAllowed)</comments>") }
        if let enclosure { tags.append(try enclosure.xmlRepresentation()) }
        if let guid { tags.append(try guid.xmlRepresentation()) }
        if let pubDate { tags.append("<pubDate>\(pubDate.rcfPubDate)</pubDate>") }
        if let source { tags.append(try source.xmlRepresentation()) }

        // iTunes
        if let itunesAuthor { tags.append("<itunes:author>\(itunesAuthor.cleanSpecialChars())</itunes:author>") }
        if let itunesBlock { tags.append("<itunes:block>\(itunesBlock.stringValue)</itunes:block>") }
        if let itunesDuration { tags.append("<itunes:duration>\(itunesDuration)</itunes:duration>") }
        if let itunesEpisode { tags.append("<itunes:episode>\(itunesEpisode)</itunes:episode>") }
        if let itunesEpisodeType { tags.append("<itunes:episodeType>\(itunesEpisodeType.rawValue)</itunes:episodeType>") }
        if let itunesExplicit { tags.append("<itunes:explicit>\(itunesExplicit.stringValue)</itunes:explicit>") }
        if let itunesImage { tags.append("<itunes:image href=\"\(itunesImage.encodeURLQueryAllowed)\" />") }
        if !itunesKeywords.isEmpty {
            tags.append("<itunes:keywords>\(itunesKeywords.joined(separator: ","))</itunes:keywords>")
        }
        if let itunesSeason { tags.append("<itunes:season>\(itunesSeason)</itunes:season>") }
        if let itunesSubtitle { tags.append("<itunes:subtitle>\(itunesSubtitle.cleanSpecialChars())</itunes:subtitle>") }
        if let itunesSummary { tags.append("<itunes:summary>\(itunesSummary.cleanSpecialChars())</itunes:summary>") }
        if let itunesTitle { tags.append("<itunes:title>\(itunesTitle.cleanSpecialChars())</itunes:title>") }

        // Podcast NS 2.0
        for transcript in transcripts {
            tags.append(try transcript.xmlRepresentation())
        }
        if let chaptersLink { tags.append(try chaptersLink.xmlRepresentation()) }
        for soundbite in soundbites {
            tags.append(try soundbite.xmlRepresentation())
        }
        for person in persons {
            tags.append(try person.xmlRepresentation())
        }
        if let location { tags.append(try location.xmlRepresentation()) }
        if let license { tags.append(try license.xmlRepresentation()) }

        // Content Module
        if let contentEncoded {
            tags.append("<content:encoded><![CDATA[\(contentEncoded.value)]]></content:encoded>")
        }

        let body = tags.doubleIndentedTagsRepresentation
        return """
        \t<item>
        \(body)
        \t</item>
        """
    }
}

// MARK: - Simple Types

extension Enclosure: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        try url.isValid()
        return "<enclosure url=\"\(url.encodeURLQueryAllowed)\" length=\"\(length)\" type=\"\(type)\" />"
    }
}

extension GUID: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        "<guid isPermaLink=\"\(isPermaLink)\">\(value)</guid>"
    }
}

extension RSSImage: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        """
        <image>
        \t<url>\(url.encodeURLQueryAllowed)</url>
        \t<title>\(title.cleanSpecialChars())</title>
        \t<link>\(link.encodeURLQueryAllowed)</link>
        </image>
        """
    }
}

extension RSSCategory: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        if let domain {
            return "<category domain=\"\(domain)\">\(value.cleanSpecialChars())</category>"
        }
        return "<category>\(value.cleanSpecialChars())</category>"
    }
}

extension RSSSource: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        "<source url=\"\(url.encodeURLQueryAllowed)\">\(title.cleanSpecialChars())</source>"
    }
}

extension ITunesOwner: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        """
        <itunes:owner>
        \t<itunes:name>\(name.cleanSpecialChars())</itunes:name>
        \t<itunes:email>\(email)</itunes:email>
        </itunes:owner>
        """
    }
}

extension ITunesCategory: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        if subcategories.isEmpty {
            return "<itunes:category text=\"\(text.cleanSpecialChars())\" />"
        }
        let subs = subcategories.map { "<itunes:category text=\"\($0.text.cleanSpecialChars())\" />" }.joined()
        return "<itunes:category text=\"\(text.cleanSpecialChars())\">\(subs)</itunes:category>"
    }
}

extension AtomLink: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs = "href=\"\(href.encodeURLQueryAllowed)\""
        if let rel { attrs += " rel=\"\(rel)\"" }
        if let type { attrs += " type=\"\(type)\"" }
        return "<atom:link \(attrs) />"
    }
}

// MARK: - Podcast Namespace Types

extension PodcastGuid: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        "<podcast:guid>\(value)</podcast:guid>"
    }
}

extension Locked: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs = ""
        if let owner { attrs = " owner=\"\(owner)\"" }
        return "<podcast:locked\(attrs)>\(isLocked.stringValue)</podcast:locked>"
    }
}

extension Funding: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        "<podcast:funding url=\"\(url.encodeURLQueryAllowed)\">\(message.cleanSpecialChars())</podcast:funding>"
    }
}

extension Transcript: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        try url.isValid()
        var attrs = "url=\"\(url.encodeURLQueryAllowed)\" type=\"\(type)\""
        if let language { attrs += " language=\"\(language)\"" }
        if let rel { attrs += " rel=\"\(rel)\"" }
        return "<podcast:transcript \(attrs) />"
    }
}

extension ChaptersLink: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        try url.isValid()
        return "<podcast:chapters url=\"\(url.encodeURLQueryAllowed)\" type=\"\(type)\" />"
    }
}

extension Soundbite: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        if let title {
            return "<podcast:soundbite startTime=\"\(startTime)\" duration=\"\(duration)\">\(title)</podcast:soundbite>"
        }
        return "<podcast:soundbite startTime=\"\(startTime)\" duration=\"\(duration)\" />"
    }
}

extension PodcastPerson: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs = ""
        if let role { attrs += " role=\"\(role)\"" }
        if let group { attrs += " group=\"\(group)\"" }
        if let img { attrs += " img=\"\(img.encodeURLQueryAllowed)\"" }
        if let href { attrs += " href=\"\(href.encodeURLQueryAllowed)\"" }
        return "<podcast:person\(attrs)>\(name.cleanSpecialChars())</podcast:person>"
    }
}

extension PodcastLocation: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs = ""
        if let geo { attrs += " geo=\"\(geo)\"" }
        if let osm { attrs += " osm=\"\(osm)\"" }
        return "<podcast:location\(attrs)>\(name.cleanSpecialChars())</podcast:location>"
    }
}

extension PodcastLicense: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        if let url {
            return "<podcast:license url=\"\(url.encodeURLQueryAllowed)\">\(identifier)</podcast:license>"
        }
        return "<podcast:license>\(identifier)</podcast:license>"
    }
}

extension PodcastTxt: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        if let purpose {
            return "<podcast:txt purpose=\"\(purpose)\">\(value)</podcast:txt>"
        }
        return "<podcast:txt>\(value)</podcast:txt>"
    }
}

extension PodcastValue: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs = "type=\"\(type)\" method=\"\(method)\""
        if let suggested { attrs += " suggested=\"\(suggested)\"" }
        let recipientTags = try recipients.map { try $0.xmlRepresentation() }.joined(separator: "\n")
        return """
        <podcast:value \(attrs)>
        \(recipientTags)
        </podcast:value>
        """
    }
}

extension ValueRecipient: XmlRepresentable {

    public func xmlRepresentation() throws -> String {
        var attrs = "type=\"\(type)\" address=\"\(address)\" split=\"\(split)\""
        if let name { attrs = "name=\"\(name)\" " + attrs }
        if let fee { attrs += " fee=\"\(fee)\"" }
        if let customKey { attrs += " customKey=\"\(customKey)\"" }
        if let customValue { attrs += " customValue=\"\(customValue)\"" }
        return "<podcast:valueRecipient \(attrs) />"
    }
}
