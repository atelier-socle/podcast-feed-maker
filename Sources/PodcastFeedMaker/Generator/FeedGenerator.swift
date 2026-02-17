// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Generates a complete podcast RSS feed XML string from a ``PodcastFeed`` model.
///
/// `FeedGenerator` handles all 48 model types across all 7 namespaces,
/// producing well-formed, spec-compliant XML output.
///
/// Example:
/// ```swift
/// let generator = FeedGenerator()
/// let xml = try generator.generate(feed)
/// ```
///
/// - SeeAlso: ``StreamingFeedGenerator``, ``XMLBuilder``
public struct FeedGenerator: Sendable {

    // MARK: - Namespace Mode

    /// Controls how namespace declarations are included in the `<rss>` element.
    public enum NamespaceMode: Sendable, Equatable {
        /// Use ``NamespaceResolver`` to auto-detect namespaces from feed content.
        case auto
        /// Use the namespaces defined in ``PodcastFeed/namespaces`` as-is.
        case feedDefined
        /// Use a specific set of namespaces.
        case explicit([PodcastNamespace])
        /// Use the original namespace prefix-to-URI mappings from a parsed feed.
        case parsed
    }

    // MARK: - Configuration

    /// Whether to format the output with indentation. Defaults to `true`.
    public let prettyPrint: Bool

    /// Whether to include the XML declaration. Defaults to `true`.
    public let includeXMLDeclaration: Bool

    /// The XML encoding declaration. Defaults to `"UTF-8"`.
    public let encoding: String

    /// How namespace declarations are determined. Defaults to `.feedDefined`.
    public let namespaceMode: NamespaceMode

    /// Creates a new feed generator.
    ///
    /// - Parameters:
    ///   - prettyPrint: Whether to indent the output.
    ///   - includeXMLDeclaration: Whether to include `<?xml ... ?>`.
    ///   - encoding: The encoding declaration string.
    ///   - namespaceMode: How to determine namespace declarations.
    public init(
        prettyPrint: Bool = true,
        includeXMLDeclaration: Bool = true,
        encoding: String = "UTF-8",
        namespaceMode: NamespaceMode = .feedDefined
    ) {
        self.prettyPrint = prettyPrint
        self.includeXMLDeclaration = includeXMLDeclaration
        self.encoding = encoding
        self.namespaceMode = namespaceMode
    }

    // MARK: - Generation

    /// Generates the complete RSS feed XML string.
    ///
    /// - Parameter feed: The feed model.
    /// - Returns: A complete RSS XML string.
    /// - Throws: ``GeneratorError`` if the feed is invalid.
    public func generate(_ feed: PodcastFeed) throws -> String {
        guard let channel = feed.channel else {
            throw GeneratorError.missingChannel
        }

        let indentStr = prettyPrint ? "\t" : ""
        let b = XMLBuilder(indentString: indentStr)
        let nl = prettyPrint ? "\n" : ""

        var lines: [String] = []

        // XML Declaration
        if includeXMLDeclaration {
            lines.append("<?xml version=\"1.0\" encoding=\"\(encoding)\"?>")
        }

        // RSS open tag with namespaces
        let rssOpen = buildRSSOpenTag(feed)
        lines.append(rssOpen)

        // Channel
        let b1 = b.indented()
        lines.append(b1.openTag("channel"))

        let b2 = b1.indented()
        lines.append(contentsOf: generateChannelElements(channel, builder: b2))
        lines.append(contentsOf: generateChannelItems(channel, builder: b2))

        lines.append(b1.closeTag("channel"))
        lines.append("</rss>")

        return lines.joined(separator: nl)
    }

    // MARK: - Namespace Resolution

    func resolveNamespaces(_ feed: PodcastFeed) -> [PodcastNamespace] {
        switch namespaceMode {
        case .auto:
            return NamespaceResolver.resolve(feed)
        case .feedDefined:
            return feed.namespaces
        case .explicit(let namespaces):
            return namespaces
        case .parsed:
            return feed.namespaces
        }
    }

    // MARK: - Channel Elements

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func generateChannelElements(
        _ channel: Channel,
        builder b: XMLBuilder
    ) -> [String] {
        var lines: [String] = []

        // RSS 2.0 Core (required)
        lines.append(b.element("title", content: channel.title))
        lines.append(b.element("link", content: XMLBuilder.encodeURL(channel.link)))
        lines.append(emitElement("description", content: channel.description, cdataFields: channel.cdataFields, builder: b))

        // Atom links (early, important for validators)
        for atomLink in channel.atomLinks {
            lines.append(generateAtomLink(atomLink, builder: b))
        }

        // RSS 2.0 Core (optional)
        if let language = channel.language { lines.append(b.element("language", content: language)) }
        if let copyright = channel.copyright { lines.append(b.element("copyright", content: copyright)) }
        if let managingEditor = channel.managingEditor { lines.append(b.element("managingEditor", content: managingEditor)) }
        if let webMaster = channel.webMaster { lines.append(b.element("webMaster", content: webMaster)) }
        if let pubDate = channel.pubDate { lines.append(b.element("pubDate", content: XMLBuilder.rfc2822Date(pubDate))) }
        if let lastBuildDate = channel.lastBuildDate {
            lines.append(b.element("lastBuildDate", content: XMLBuilder.rfc2822Date(lastBuildDate)))
        }
        for category in channel.categories {
            lines.append(generateRSSCategory(category, builder: b))
        }
        if let generator = channel.generator { lines.append(b.element("generator", content: generator)) }
        if let docs = channel.docs { lines.append(b.element("docs", content: XMLBuilder.encodeURL(docs))) }
        if let cloud = channel.cloud { lines.append(generateRSSCloud(cloud, builder: b)) }
        if let ttl = channel.ttl { lines.append(b.element("ttl", content: "\(ttl)")) }
        if let rating = channel.rating { lines.append(b.element("rating", content: rating)) }
        if let image = channel.image { lines.append(contentsOf: generateRSSImage(image, builder: b)) }
        if let textInput = channel.textInput { lines.append(contentsOf: generateRSSTextInput(textInput, builder: b)) }
        if let skipSchedule = channel.skipSchedule { lines.append(contentsOf: generateSkipSchedule(skipSchedule, builder: b)) }

        // iTunes Namespace
        if let itunesAuthor = channel.itunesAuthor { lines.append(b.element("itunes:author", content: itunesAuthor)) }
        if let itunesBlock = channel.itunesBlock {
            lines.append(b.element("itunes:block", content: XMLBuilder.boolYesNo(itunesBlock)))
        }
        for cat in channel.itunesCategories {
            lines.append(contentsOf: generateITunesCategory(cat, builder: b))
        }
        if let itunesComplete = channel.itunesComplete {
            lines.append(b.element("itunes:complete", content: XMLBuilder.boolYesNo(itunesComplete)))
        }
        if let itunesExplicit = channel.itunesExplicit {
            lines.append(b.element("itunes:explicit", content: XMLBuilder.boolTrueFalse(itunesExplicit)))
        }
        if let itunesImage = channel.itunesImage {
            lines.append(b.selfClosingElement("itunes:image", attributes: [("href", XMLBuilder.encodeURL(itunesImage))]))
        }
        for podcastImage in channel.podcastImages {
            lines.append(generatePodcastImage(podcastImage, builder: b))
        }
        if let podcastImagesSrcset = channel.podcastImagesSrcset {
            lines.append(generatePodcastImagesSrcset(podcastImagesSrcset, builder: b))
        }
        if !channel.itunesKeywords.isEmpty {
            lines.append(b.element("itunes:keywords", content: channel.itunesKeywords.joined(separator: ",")))
        }
        if let itunesNewFeedUrl = channel.itunesNewFeedUrl {
            lines.append(b.element("itunes:new-feed-url", content: XMLBuilder.encodeURL(itunesNewFeedUrl)))
        }
        if let itunesOwner = channel.itunesOwner {
            lines.append(contentsOf: generateITunesOwner(itunesOwner, builder: b))
        }
        if let itunesSubtitle = channel.itunesSubtitle { lines.append(b.element("itunes:subtitle", content: itunesSubtitle)) }
        if let itunesSummary = channel.itunesSummary {
            lines.append(emitElement("itunes:summary", content: itunesSummary, cdataFields: channel.cdataFields, builder: b))
        }
        if let itunesTitle = channel.itunesTitle { lines.append(b.element("itunes:title", content: itunesTitle)) }
        if let itunesType = channel.itunesType { lines.append(b.element("itunes:type", content: itunesType.rawValue)) }
        if let itunesVerify = channel.itunesVerify {
            lines.append(b.element("itunes:applepodcastsverify", content: XMLBuilder.boolTrueFalse(itunesVerify)))
        }

        // Dublin Core
        if let dc = channel.dublinCore {
            lines.append(contentsOf: generateDublinCore(dc, builder: b))
        }

        // Podcast Namespace 2.0
        if let podcastGuid = channel.podcastGuid {
            lines.append(b.element("podcast:guid", content: podcastGuid.value))
        }
        if let locked = channel.locked {
            lines.append(generateLocked(locked, builder: b))
        }
        if let medium = channel.medium {
            lines.append(b.element("podcast:medium", content: medium.rawValue))
        }
        for fund in channel.funding {
            lines.append(generateFunding(fund, builder: b))
        }
        for person in channel.persons {
            lines.append(generatePerson(person, builder: b))
        }
        for location in channel.locations {
            lines.append(generateLocation(location, builder: b))
        }
        if let license = channel.license {
            lines.append(generateLicense(license, builder: b))
        }
        if let value = channel.value {
            lines.append(contentsOf: generateValue(value, builder: b))
        }
        for block in channel.podcastBlocks {
            lines.append(generatePodcastBlock(block, builder: b))
        }
        for txt in channel.txtRecords {
            lines.append(generatePodcastTxt(txt, builder: b))
        }
        if let podroll = channel.podroll {
            lines.append(contentsOf: generatePodroll(podroll, builder: b))
        }
        if let updateFrequency = channel.updateFrequency {
            lines.append(generateUpdateFrequency(updateFrequency, builder: b))
        }
        if let podpingEnabled = channel.podpingEnabled {
            lines.append(b.element("podcast:podping", content: XMLBuilder.boolTrueFalse(podpingEnabled)))
        }
        if let publisher = channel.publisher {
            lines.append(contentsOf: generatePublisher(publisher, builder: b))
        }
        if let chat = channel.chat {
            lines.append(generateChat(chat, builder: b))
        }

        // Trailers
        for trailer in channel.trailers {
            lines.append(generateTrailer(trailer, builder: b))
        }

        // Live Items
        for liveItem in channel.liveItems {
            lines.append(contentsOf: generateLiveItem(liveItem, builder: b))
        }

        // Round-trip preservation
        for unknown in channel.unknownElements {
            lines.append(generateUnknownElement(unknown, builder: b))
        }
        for comment in channel.xmlComments {
            lines.append("\(b.indent)<!-- \(comment) -->")
        }

        return lines
    }

    // MARK: - Channel Items

    private func generateChannelItems(_ channel: Channel, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        for item in channel.items {
            lines.append(contentsOf: generateItem(item, builder: b))
        }
        return lines
    }

    // MARK: - Item Generation

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    package func generateItem(_ item: Item, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []

        lines.append(b.openTag("item"))
        let b2 = b.indented()

        // RSS 2.0 Core
        if let title = item.title { lines.append(b2.element("title", content: title)) }
        if let link = item.link { lines.append(b2.element("link", content: XMLBuilder.encodeURL(link))) }
        if let description = item.description {
            lines.append(emitElement("description", content: description, cdataFields: item.cdataFields, builder: b2))
        }
        if let author = item.author { lines.append(b2.element("author", content: author)) }
        for category in item.categories {
            lines.append(generateRSSCategory(category, builder: b2))
        }
        if let comments = item.comments { lines.append(b2.element("comments", content: XMLBuilder.encodeURL(comments))) }
        if let enclosure = item.enclosure { lines.append(generateEnclosure(enclosure, builder: b2)) }
        if let guid = item.guid { lines.append(generateGUID(guid, builder: b2)) }
        if let pubDate = item.pubDate { lines.append(b2.element("pubDate", content: XMLBuilder.rfc2822Date(pubDate))) }
        if let source = item.source { lines.append(generateRSSSource(source, builder: b2)) }

        // iTunes
        if let itunesAuthor = item.itunesAuthor { lines.append(b2.element("itunes:author", content: itunesAuthor)) }
        if let itunesBlock = item.itunesBlock {
            lines.append(b2.element("itunes:block", content: XMLBuilder.boolYesNo(itunesBlock)))
        }
        if let itunesDuration = item.itunesDuration { lines.append(b2.element("itunes:duration", content: "\(itunesDuration)")) }
        if let itunesEpisode = item.itunesEpisode { lines.append(b2.element("itunes:episode", content: "\(itunesEpisode)")) }
        if let itunesEpisodeType = item.itunesEpisodeType {
            lines.append(b2.element("itunes:episodeType", content: itunesEpisodeType.rawValue))
        }
        if let itunesExplicit = item.itunesExplicit {
            lines.append(b2.element("itunes:explicit", content: XMLBuilder.boolTrueFalse(itunesExplicit)))
        }
        if let itunesImage = item.itunesImage {
            lines.append(b2.selfClosingElement("itunes:image", attributes: [("href", XMLBuilder.encodeURL(itunesImage))]))
        }
        for podcastImage in item.podcastImages {
            lines.append(generatePodcastImage(podcastImage, builder: b2))
        }
        if let podcastImagesSrcset = item.podcastImagesSrcset {
            lines.append(generatePodcastImagesSrcset(podcastImagesSrcset, builder: b2))
        }
        if !item.itunesKeywords.isEmpty {
            lines.append(b2.element("itunes:keywords", content: item.itunesKeywords.joined(separator: ",")))
        }
        if let itunesSeason = item.itunesSeason { lines.append(b2.element("itunes:season", content: "\(itunesSeason)")) }
        if let itunesSubtitle = item.itunesSubtitle { lines.append(b2.element("itunes:subtitle", content: itunesSubtitle)) }
        if let itunesSummary = item.itunesSummary {
            lines.append(emitElement("itunes:summary", content: itunesSummary, cdataFields: item.cdataFields, builder: b2))
        }
        if let itunesTitle = item.itunesTitle { lines.append(b2.element("itunes:title", content: itunesTitle)) }

        // Atom
        for atomLink in item.atomLinks {
            lines.append(generateAtomLink(atomLink, builder: b2))
        }

        // Dublin Core
        if let dc = item.dublinCore {
            lines.append(contentsOf: generateDublinCore(dc, builder: b2))
        }

        // Podcast NS 2.0
        for transcript in item.transcripts {
            lines.append(generateTranscript(transcript, builder: b2))
        }
        if let chaptersLink = item.chaptersLink {
            lines.append(generateChaptersLink(chaptersLink, builder: b2))
        }
        for soundbite in item.soundbites {
            lines.append(generateSoundbite(soundbite, builder: b2))
        }
        for person in item.persons {
            lines.append(generatePerson(person, builder: b2))
        }
        for location in item.locations {
            lines.append(generateLocation(location, builder: b2))
        }
        if let license = item.license {
            lines.append(generateLicense(license, builder: b2))
        }
        for altEnc in item.alternateEnclosures {
            lines.append(contentsOf: generateAlternateEnclosure(altEnc, builder: b2))
        }
        if let value = item.value {
            lines.append(contentsOf: generateValue(value, builder: b2))
        }
        for social in item.socialInteractions {
            lines.append(generateSocialInteract(social, builder: b2))
        }
        for txt in item.txtRecords {
            lines.append(generatePodcastTxt(txt, builder: b2))
        }
        if let podcastSeason = item.podcastSeason {
            lines.append(generatePodcastSeason(podcastSeason, builder: b2))
        }
        if let podcastEpisode = item.podcastEpisode {
            lines.append(generatePodcastEpisode(podcastEpisode, builder: b2))
        }

        // Podlove Simple Chapters
        if let podloveChapters = item.podloveChapters {
            lines.append(contentsOf: generatePodloveChapters(podloveChapters, builder: b2))
        }

        // Round-trip preservation
        for unknown in item.unknownElements {
            lines.append(generateUnknownElement(unknown, builder: b2))
        }
        for comment in item.xmlComments {
            lines.append("\(b2.indent)<!-- \(comment) -->")
        }

        // Content Module (last, always CDATA)
        if let contentEncoded = item.contentEncoded {
            lines.append(b2.cdataElement("content:encoded", content: contentEncoded.value))
        }

        lines.append(b.closeTag("item"))
        return lines
    }

}
