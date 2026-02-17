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

// MARK: - FeedGenerator + Dublin Core, Podcast NS 2.0, Podlove

extension FeedGenerator {

    // MARK: - Dublin Core

    // swiftlint:disable:next cyclomatic_complexity
    func generateDublinCore(
        _ dc: DublinCore,
        builder b: XMLBuilder
    ) -> [String] {
        var lines: [String] = []
        if let creator = dc.creator { lines.append(b.element("dc:creator", content: creator)) }
        if let contributor = dc.contributor { lines.append(b.element("dc:contributor", content: contributor)) }
        if let date = dc.date { lines.append(b.element("dc:date", content: date)) }
        if let description = dc.description { lines.append(b.element("dc:description", content: description)) }
        if let format = dc.format { lines.append(b.element("dc:format", content: format)) }
        if let identifier = dc.identifier { lines.append(b.element("dc:identifier", content: identifier)) }
        if let language = dc.language { lines.append(b.element("dc:language", content: language)) }
        if let publisher = dc.publisher { lines.append(b.element("dc:publisher", content: publisher)) }
        if let relation = dc.relation { lines.append(b.element("dc:relation", content: relation)) }
        if let rights = dc.rights { lines.append(b.element("dc:rights", content: rights)) }
        if let source = dc.source { lines.append(b.element("dc:source", content: source)) }
        if let subject = dc.subject { lines.append(b.element("dc:subject", content: subject)) }
        if let title = dc.title { lines.append(b.element("dc:title", content: title)) }
        if let type = dc.type { lines.append(b.element("dc:type", content: type)) }
        if let coverage = dc.coverage { lines.append(b.element("dc:coverage", content: coverage)) }
        return lines
    }

    // MARK: - Podcast NS 2.0 Types

    func generateLocked(_ locked: Locked, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let owner = locked.owner { attrs.append(("owner", owner)) }
        return b.element("podcast:locked", content: XMLBuilder.boolYesNo(locked.isLocked), attributes: attrs)
    }

    func generateFunding(_ funding: Funding, builder b: XMLBuilder) -> String {
        b.element(
            "podcast:funding",
            content: funding.message,
            attributes: [("url", XMLBuilder.encodeURL(funding.url))]
        )
    }

    func generateTranscript(_ transcript: Transcript, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [
            ("url", XMLBuilder.encodeURL(transcript.url)),
            ("type", transcript.type)
        ]
        if let language = transcript.language { attrs.append(("language", language)) }
        if let rel = transcript.rel { attrs.append(("rel", rel)) }
        return b.selfClosingElement("podcast:transcript", attributes: attrs)
    }

    func generateChaptersLink(_ chapters: ChaptersLink, builder b: XMLBuilder) -> String {
        b.selfClosingElement(
            "podcast:chapters",
            attributes: [
                ("url", XMLBuilder.encodeURL(chapters.url)),
                ("type", chapters.type)
            ]
        )
    }

    func generateSoundbite(_ soundbite: Soundbite, builder b: XMLBuilder) -> String {
        let attrs: [(String, String)] = [
            ("startTime", "\(soundbite.startTime)"),
            ("duration", "\(soundbite.duration)")
        ]
        if let title = soundbite.title {
            return b.element("podcast:soundbite", content: title, attributes: attrs)
        }
        return b.selfClosingElement("podcast:soundbite", attributes: attrs)
    }

    func generatePerson(_ person: PodcastPerson, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let role = person.role { attrs.append(("role", role)) }
        if let group = person.group { attrs.append(("group", group)) }
        if let img = person.img { attrs.append(("img", XMLBuilder.encodeURL(img))) }
        if let href = person.href { attrs.append(("href", XMLBuilder.encodeURL(href))) }
        return b.element("podcast:person", content: person.name, attributes: attrs)
    }

    func generateLocation(_ location: PodcastLocation, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let rel = location.rel { attrs.append(("rel", rel)) }
        if let geo = location.geo { attrs.append(("geo", geo)) }
        if let osm = location.osm { attrs.append(("osm", osm)) }
        if let country = location.country { attrs.append(("country", country)) }
        return b.element("podcast:location", content: location.name, attributes: attrs)
    }

    func generateLicense(_ license: PodcastLicense, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let url = license.url { attrs.append(("url", XMLBuilder.encodeURL(url))) }
        return b.element("podcast:license", content: license.identifier, attributes: attrs)
    }

    func generateValue(_ value: PodcastValue, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        var attrs: [(String, String)] = [
            ("type", value.type),
            ("method", value.method)
        ]
        if let suggested = value.suggested { attrs.append(("suggested", suggested)) }
        lines.append(b.openTag("podcast:value", attributes: attrs))
        let b2 = b.indented()
        for recipient in value.recipients {
            lines.append(generateValueRecipient(recipient, builder: b2))
        }
        for timeSplit in value.timeSplits {
            lines.append(contentsOf: generateValueTimeSplit(timeSplit, builder: b2))
        }
        lines.append(b.closeTag("podcast:value"))
        return lines
    }

    func generateValueRecipient(_ recipient: ValueRecipient, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let name = recipient.name { attrs.append(("name", name)) }
        attrs.append(("type", recipient.type))
        attrs.append(("address", recipient.address))
        if let customKey = recipient.customKey { attrs.append(("customKey", customKey)) }
        if let customValue = recipient.customValue { attrs.append(("customValue", customValue)) }
        attrs.append(("split", "\(recipient.split)"))
        if let fee = recipient.fee { attrs.append(("fee", XMLBuilder.boolTrueFalse(fee))) }
        return b.selfClosingElement("podcast:valueRecipient", attributes: attrs)
    }

    func generateValueTimeSplit(_ timeSplit: ValueTimeSplit, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        var attrs: [(String, String)] = [
            ("startTime", "\(timeSplit.startTime)"),
            ("duration", "\(timeSplit.duration)")
        ]
        if let remotePercentage = timeSplit.remotePercentage {
            attrs.append(("remotePercentage", "\(remotePercentage)"))
        }
        lines.append(b.openTag("podcast:valueTimeSplit", attributes: attrs))
        let b2 = b.indented()
        for recipient in timeSplit.recipients {
            lines.append(generateValueRecipient(recipient, builder: b2))
        }
        if let remoteItem = timeSplit.remoteItem {
            lines.append(generateRemoteItem(remoteItem, builder: b2))
        }
        lines.append(b.closeTag("podcast:valueTimeSplit"))
        return lines
    }

    func generatePodcastBlock(_ block: PodcastBlock, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let id = block.id { attrs.append(("id", id)) }
        return b.element("podcast:block", content: XMLBuilder.boolYesNo(block.isBlocked), attributes: attrs)
    }

    func generatePodcastTxt(_ txt: PodcastTxt, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let purpose = txt.purpose { attrs.append(("purpose", purpose)) }
        return b.element("podcast:txt", content: txt.value, attributes: attrs)
    }

    func generatePodroll(_ podroll: Podroll, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("podcast:podroll"))
        let b2 = b.indented()
        for item in podroll.remoteItems {
            lines.append(generateRemoteItem(item, builder: b2))
        }
        lines.append(b.closeTag("podcast:podroll"))
        return lines
    }

    func generateRemoteItem(_ item: RemoteItem, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [("feedGuid", item.feedGuid)]
        if let feedUrl = item.feedUrl { attrs.append(("feedUrl", XMLBuilder.encodeURL(feedUrl))) }
        if let itemGuid = item.itemGuid { attrs.append(("itemGuid", itemGuid)) }
        if let medium = item.medium { attrs.append(("medium", medium)) }
        return b.selfClosingElement("podcast:remoteItem", attributes: attrs)
    }

    func generateUpdateFrequency(_ freq: UpdateFrequency, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let rrule = freq.rrule { attrs.append(("rrule", rrule)) }
        if let dtstart = freq.dtstart { attrs.append(("dtstart", dtstart)) }
        if let complete = freq.complete { attrs.append(("complete", XMLBuilder.boolTrueFalse(complete))) }
        if let label = freq.label {
            return b.element("podcast:updateFrequency", content: label, attributes: attrs)
        }
        return b.selfClosingElement("podcast:updateFrequency", attributes: attrs)
    }

    func generatePublisher(_ publisher: PodcastPublisher, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("podcast:publisher"))
        let b2 = b.indented()
        lines.append(generateRemoteItem(publisher.remoteItem, builder: b2))
        lines.append(b.closeTag("podcast:publisher"))
        return lines
    }

    func generateChat(_ chat: PodcastChat, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [
            ("server", chat.server),
            ("protocol", chat.protocol)
        ]
        if let accountId = chat.accountId { attrs.append(("accountId", accountId)) }
        if let space = chat.space { attrs.append(("space", space)) }
        if let embedUrl = chat.embedUrl { attrs.append(("embedUrl", XMLBuilder.encodeURL(embedUrl))) }
        return b.selfClosingElement("podcast:chat", attributes: attrs)
    }

    func generateTrailer(_ trailer: Trailer, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [
            ("url", XMLBuilder.encodeURL(trailer.url)),
            ("pubdate", XMLBuilder.rfc2822Date(trailer.pubDate))
        ]
        if let length = trailer.length { attrs.append(("length", "\(length)")) }
        if let type = trailer.type { attrs.append(("type", type)) }
        if let season = trailer.season { attrs.append(("season", "\(season)")) }
        return b.element("podcast:trailer", content: trailer.title, attributes: attrs)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func generateLiveItem(
        _ liveItem: PodcastLiveItem,
        builder b: XMLBuilder
    ) -> [String] {
        var lines: [String] = []
        var attrs: [(String, String)] = [
            ("status", liveItem.status.rawValue),
            ("start", XMLBuilder.iso8601Date(liveItem.start))
        ]
        if let end = liveItem.end { attrs.append(("end", XMLBuilder.iso8601Date(end))) }
        lines.append(b.openTag("podcast:liveItem", attributes: attrs))
        let b2 = b.indented()

        if let title = liveItem.title { lines.append(b2.element("title", content: title)) }
        if let description = liveItem.description { lines.append(b2.smartElement("description", content: description)) }
        if let enclosure = liveItem.enclosure { lines.append(generateEnclosure(enclosure, builder: b2)) }
        if let guid = liveItem.guid { lines.append(generateGUID(guid, builder: b2)) }
        if let itunesImage = liveItem.itunesImage {
            lines.append(b2.selfClosingElement("itunes:image", attributes: [("href", XMLBuilder.encodeURL(itunesImage))]))
        }
        for contentLink in liveItem.contentLinks {
            lines.append(generateContentLink(contentLink, builder: b2))
        }
        for person in liveItem.persons {
            lines.append(generatePerson(person, builder: b2))
        }
        for altEnc in liveItem.alternateEnclosures {
            lines.append(contentsOf: generateAlternateEnclosure(altEnc, builder: b2))
        }
        if let value = liveItem.value {
            lines.append(contentsOf: generateValue(value, builder: b2))
        }
        for social in liveItem.socialInteractions {
            lines.append(generateSocialInteract(social, builder: b2))
        }

        lines.append(b.closeTag("podcast:liveItem"))
        return lines
    }

    func generateContentLink(_ link: ContentLink, builder b: XMLBuilder) -> String {
        b.element(
            "podcast:contentLink",
            content: link.title,
            attributes: [("href", XMLBuilder.encodeURL(link.href))]
        )
    }

    func generateAlternateEnclosure(_ altEnc: AlternateEnclosure, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        var attrs: [(String, String)] = [("type", altEnc.type)]
        if let length = altEnc.length { attrs.append(("length", "\(length)")) }
        if let bitrate = altEnc.bitrate { attrs.append(("bitrate", "\(bitrate)")) }
        if let height = altEnc.height { attrs.append(("height", "\(height)")) }
        if let language = altEnc.language { attrs.append(("lang", language)) }
        if let title = altEnc.title { attrs.append(("title", title)) }
        if let isDefault = altEnc.isDefault { attrs.append(("default", XMLBuilder.boolTrueFalse(isDefault))) }

        lines.append(b.openTag("podcast:alternateEnclosure", attributes: attrs))
        let b2 = b.indented()
        for source in altEnc.sources {
            lines.append(generatePodcastSource(source, builder: b2))
        }
        if let integrity = altEnc.integrity {
            lines.append(generatePodcastIntegrity(integrity, builder: b2))
        }
        lines.append(b.closeTag("podcast:alternateEnclosure"))
        return lines
    }

    func generatePodcastSource(_ source: PodcastSource, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [("uri", source.uri)]
        if let contentType = source.contentType { attrs.append(("contentType", contentType)) }
        return b.selfClosingElement("podcast:source", attributes: attrs)
    }

    func generatePodcastIntegrity(_ integrity: PodcastIntegrity, builder b: XMLBuilder) -> String {
        b.selfClosingElement(
            "podcast:integrity",
            attributes: [
                ("type", integrity.type),
                ("value", integrity.value)
            ]
        )
    }

    func generateSocialInteract(_ social: SocialInteract, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [
            ("uri", social.uri),
            ("protocol", social.protocol)
        ]
        if let accountId = social.accountId { attrs.append(("accountId", accountId)) }
        if let accountUrl = social.accountUrl { attrs.append(("accountUrl", XMLBuilder.encodeURL(accountUrl))) }
        if let priority = social.priority { attrs.append(("priority", "\(priority)")) }
        return b.selfClosingElement("podcast:socialInteract", attributes: attrs)
    }

    func generatePodcastSeason(_ season: PodcastSeason, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let name = season.name { attrs.append(("name", name)) }
        return b.element("podcast:season", content: "\(season.number)", attributes: attrs)
    }

    func generatePodcastEpisode(_ episode: PodcastEpisode, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = []
        if let display = episode.display { attrs.append(("display", display)) }
        let numberStr: String
        if episode.number.truncatingRemainder(dividingBy: 1) == 0 {
            numberStr = "\(Int(episode.number))"
        } else {
            numberStr = "\(episode.number)"
        }
        return b.element("podcast:episode", content: numberStr, attributes: attrs)
    }

    // MARK: - Podlove Simple Chapters

    func generatePodloveChapters(_ chapters: PodloveChapters, builder b: XMLBuilder) -> [String] {
        var lines: [String] = []
        lines.append(b.openTag("psc:chapters", attributes: [("version", chapters.version)]))
        let b2 = b.indented()
        for chapter in chapters.chapters {
            lines.append(generatePodloveChapter(chapter, builder: b2))
        }
        lines.append(b.closeTag("psc:chapters"))
        return lines
    }

    func generatePodloveChapter(_ chapter: PodloveChapter, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [
            ("start", chapter.start),
            ("title", XMLBuilder.escape(chapter.title))
        ]
        if let href = chapter.href { attrs.append(("href", XMLBuilder.encodeURL(href))) }
        if let image = chapter.image { attrs.append(("image", XMLBuilder.encodeURL(image))) }
        return b.selfClosingElement("psc:chapter", attributes: attrs)
    }

    // MARK: - Podcast Image

    func generatePodcastImage(_ image: PodcastImage, builder b: XMLBuilder) -> String {
        var attrs: [(String, String)] = [("href", XMLBuilder.encodeURL(image.href))]
        if let alt = image.alt { attrs.append(("alt", alt)) }
        if let aspectRatio = image.aspectRatio { attrs.append(("aspect-ratio", aspectRatio)) }
        if let width = image.width { attrs.append(("width", "\(width)")) }
        if let height = image.height { attrs.append(("height", "\(height)")) }
        if let type = image.type { attrs.append(("type", type)) }
        if let purpose = image.purpose { attrs.append(("purpose", purpose)) }
        return b.selfClosingElement("podcast:image", attributes: attrs)
    }

    func generatePodcastImagesSrcset(_ images: PodcastImages, builder b: XMLBuilder) -> String {
        b.selfClosingElement("podcast:images", attributes: [("srcset", images.srcset)])
    }
}
