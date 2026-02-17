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

// MARK: - Podcast NS Channel Elements

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func handlePodcastChannelEndElement(
        _ name: String, text: String
    ) {
        switch name {
        case "podcast:guid":
            if !text.isEmpty { chPodcastGuid = PodcastGuid(value: text) }

        case "podcast:locked":
            let owner = currentAttributes["owner"]
            chLocked = Locked(
                isLocked: parseBool(text) ?? false, owner: owner
            )

        case "podcast:medium":
            chMedium = PodcastMedium(rawValue: text)

        case "podcast:funding":
            if let urlStr = currentAttributes["url"],
                let url = URL(string: urlStr), !text.isEmpty
            {
                chFunding.append(Funding(url: url, message: text))
            }

        case "podcast:person":
            let person = buildPerson(text: text, attrs: currentAttributes)
            if let person { chPersons.append(person) }

        case "podcast:location":
            if !text.isEmpty {
                chLocations.append(
                    PodcastLocation(
                        name: text,
                        geo: currentAttributes["geo"],
                        osm: currentAttributes["osm"],
                        rel: currentAttributes["rel"],
                        country: currentAttributes["country"]
                    ))
            }

        case "podcast:license":
            if !text.isEmpty {
                chLicense = PodcastLicense(
                    identifier: text,
                    url: currentAttributes["url"]
                        .flatMap { URL(string: $0) }
                )
            }

        case "podcast:block":
            let block = PodcastBlock(
                isBlocked: parseBool(text) ?? false,
                id: currentAttributes["id"]
            )
            chPodcastBlocks.append(block)

        case "podcast:txt":
            if !text.isEmpty {
                chTxtRecords.append(
                    PodcastTxt(
                        value: text,
                        purpose: currentAttributes["purpose"]
                    ))
            }

        case "podcast:updateFrequency":
            chUpdateFrequency = UpdateFrequency(
                label: text.isEmpty ? nil : text,
                rrule: currentAttributes["rrule"],
                dtstart: currentAttributes["dtstart"],
                complete: currentAttributes["complete"]
                    .flatMap { parseBool($0) }
            )

        case "podcast:podping":
            chPodpingEnabled = parseBool(text)

        case "podcast:publisher":
            break  // Handled as container context in didStartElement/didEndElement

        case "podcast:chat":
            handlePodcastChat()

        case "podcast:trailer":
            handleTrailer(text: text)

        default:
            if !name.isEmpty, !Self.attributeOnlyElements.contains(name) {
                channelUnknownElements.append(
                    UnknownElement(
                        name: name, attributes: currentAttributes,
                        textContent: text.isEmpty ? nil : text
                    ))
            }
        }
    }

    private func handlePodcastChat() {
        guard let server = currentAttributes["server"],
            let proto = currentAttributes["protocol"]
        else { return }
        chChat = PodcastChat(
            server: server,
            protocol: proto,
            accountId: currentAttributes["accountId"],
            space: currentAttributes["space"],
            embedUrl: currentAttributes["embedUrl"]
                .flatMap { URL(string: $0) }
        )
    }

    private func handleTrailer(text: String) {
        guard let urlStr = currentAttributes["url"],
            let url = URL(string: urlStr),
            let pubDateStr = currentAttributes["pubdate"],
            let pubDate = DateParser.parse(pubDateStr),
            !text.isEmpty
        else { return }
        let trailer = Trailer(
            title: text,
            url: url,
            pubDate: pubDate,
            length: currentAttributes["length"].flatMap { Int($0) },
            type: currentAttributes["type"],
            season: currentAttributes["season"].flatMap { Int($0) }
        )
        chTrailers.append(trailer)
    }
}

// MARK: - Podcast NS Item Elements

extension FeedParserDelegate {

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func handlePodcastItemEndElement(
        _ name: String, text: String
    ) {
        switch name {
        case "podcast:soundbite":
            handleSoundbite(text: text)

        case "podcast:person":
            if let person = buildPerson(
                text: text, attrs: currentAttributes
            ) {
                currentItem?.persons.append(person)
            }

        case "podcast:location":
            if !text.isEmpty {
                currentItem?.locations.append(
                    PodcastLocation(
                        name: text,
                        geo: currentAttributes["geo"],
                        osm: currentAttributes["osm"],
                        rel: currentAttributes["rel"],
                        country: currentAttributes["country"]
                    ))
            }

        case "podcast:license":
            if !text.isEmpty {
                currentItem?.license = PodcastLicense(
                    identifier: text,
                    url: currentAttributes["url"]
                        .flatMap { URL(string: $0) }
                )
            }

        case "podcast:socialInteract":
            handleSocialInteract()

        case "podcast:txt":
            if !text.isEmpty {
                currentItem?.txtRecords.append(
                    PodcastTxt(
                        value: text,
                        purpose: currentAttributes["purpose"]
                    ))
            }

        case "podcast:season":
            if let number = Int(text) {
                currentItem?.podcastSeason = PodcastSeason(
                    number: number,
                    name: currentAttributes["name"]
                )
            }

        case "podcast:episode":
            if let number = Double(text) {
                currentItem?.podcastEpisode = PodcastEpisode(
                    number: number,
                    display: currentAttributes["display"]
                )
            }

        case "podcast:block":
            break

        default:
            if !name.isEmpty, !Self.attributeOnlyElements.contains(name) {
                currentItem?.unknownElements.append(
                    UnknownElement(
                        name: name, attributes: currentAttributes,
                        textContent: text.isEmpty ? nil : text
                    ))
            }
        }
    }

    private func handleSoundbite(text: String) {
        guard let startStr = currentAttributes["startTime"],
            let startTime = Double(startStr),
            let durStr = currentAttributes["duration"],
            let duration = Double(durStr)
        else { return }
        let title = text.isEmpty ? nil : text
        currentItem?.soundbites.append(
            Soundbite(
                startTime: startTime, duration: duration,
                title: title
            )
        )
    }

    private func handleSocialInteract() {
        guard let uri = currentAttributes["uri"],
            let proto = currentAttributes["protocol"]
        else { return }
        let interact = SocialInteract(
            uri: uri,
            protocol: proto,
            accountId: currentAttributes["accountId"],
            accountUrl: currentAttributes["accountUrl"]
                .flatMap { URL(string: $0) },
            priority: currentAttributes["priority"]
                .flatMap { Int($0) }
        )
        switch currentContext {
        case .item:
            currentItem?.socialInteractions.append(interact)
        case .liveItem:
            currentLiveItem?.socialInteractions.append(interact)
        default: break
        }
    }
}

// MARK: - Podcast Value

extension FeedParserDelegate {

    func handlePodcastValueStart(_ attrs: [String: String]) {
        guard let type = attrs["type"],
            let method = attrs["method"]
        else { return }
        currentValue = PodcastValue(
            type: type, method: method,
            suggested: attrs["suggested"]
        )
        pushContext(.podcastValue)
    }

    func handlePodcastValueEndElement(
        _ name: String, text: String
    ) {
        // Elements inside podcast:value are attribute-only
        // (valueRecipient, valueTimeSplit) handled via start attrs
    }

    func finalizePodcastValue() {
        guard let value = currentValue else { return }
        let parentContext = contextStack.dropLast().last ?? .root
        switch parentContext {
        case .channel:
            chValue = value
        case .item:
            currentItem?.value = value
        case .liveItem:
            if currentContext == .podcastValue {
                currentLiveItem?.value = value
            }
        default: break
        }
        currentValue = nil
    }

    func handleValueRecipientAttributes(_ attrs: [String: String]) {
        guard let type = attrs["type"],
            let address = attrs["address"],
            let splitStr = attrs["split"],
            let split = Int(splitStr)
        else { return }
        let recipient = ValueRecipient(
            name: attrs["name"],
            type: type,
            address: address,
            customKey: attrs["customKey"],
            customValue: attrs["customValue"],
            split: split,
            fee: attrs["fee"].flatMap { parseBool($0) }
        )
        switch currentContext {
        case .podcastValue:
            currentValue?.recipients.append(recipient)
        case .valueTimeSplit:
            timeSplitRecipients.append(recipient)
        default: break
        }
    }
}

// MARK: - Value Time Split

extension FeedParserDelegate {

    func handleValueTimeSplitStart(_ attrs: [String: String]) {
        guard let startStr = attrs["startTime"],
            let startTime = Double(startStr),
            let durStr = attrs["duration"],
            let duration = Double(durStr)
        else { return }
        currentTimeSplit = ValueTimeSplit(
            startTime: startTime, duration: duration
        )
        if let pct = attrs["remotePercentage"].flatMap({ Int($0) }) {
            currentTimeSplit?.remotePercentage = pct
        }
        timeSplitRecipients = []
        timeSplitRemoteItem = nil
        pushContext(.valueTimeSplit)
    }

    func handleValueTimeSplitEndElement(
        _ name: String, text: String
    ) {
        // nested elements handled via start attributes
    }

    func finalizeValueTimeSplit() {
        guard var split = currentTimeSplit else { return }
        split.recipients = timeSplitRecipients
        split.remoteItem = timeSplitRemoteItem
        currentValue?.timeSplits.append(split)
        currentTimeSplit = nil
    }
}

// MARK: - Alternate Enclosure

extension FeedParserDelegate {

    func handleAlternateEnclosureStart(_ attrs: [String: String]) {
        guard let type = attrs["type"] else { return }
        let isInLiveItem = currentContext == .liveItem
        let enc = AlternateEnclosure(
            type: type,
            length: attrs["length"].flatMap { Int($0) },
            bitrate: attrs["bitrate"].flatMap { Int($0) },
            height: attrs["height"].flatMap { Int($0) },
            language: attrs["lang"],
            title: attrs["title"],
            isDefault: attrs["default"].flatMap { parseBool($0) }
        )
        if isInLiveItem {
            liveItemAltEnclosure = enc
            liveItemAltEncSources = []
            liveItemAltEncIntegrity = nil
        } else {
            currentAltEnclosure = enc
            altEnclosureSources = []
            altEnclosureIntegrity = nil
        }
        pushContext(.alternateEnclosure)
    }

    func handleAlternateEnclosureEndElement(
        _ name: String, text: String
    ) {
        // nested source/integrity handled via start attrs
    }

    func finalizeAlternateEnclosure() {
        let parentContext = contextStack.dropLast().last ?? .root
        if parentContext == .liveItem {
            guard var enc = liveItemAltEnclosure else { return }
            enc.sources = liveItemAltEncSources
            enc.integrity = liveItemAltEncIntegrity
            currentLiveItem?.alternateEnclosures.append(enc)
            liveItemAltEnclosure = nil
        } else {
            guard var enc = currentAltEnclosure else { return }
            enc.sources = altEnclosureSources
            enc.integrity = altEnclosureIntegrity
            currentItem?.alternateEnclosures.append(enc)
            currentAltEnclosure = nil
        }
    }

    func handlePodcastSourceAttributes(_ attrs: [String: String]) {
        guard let uri = attrs["uri"] else { return }
        let source = PodcastSource(
            uri: uri, contentType: attrs["contentType"]
        )
        let parentContext = contextStack.dropLast().last ?? .root
        if parentContext == .liveItem {
            liveItemAltEncSources.append(source)
        } else {
            altEnclosureSources.append(source)
        }
    }

    func handlePodcastIntegrityAttributes(_ attrs: [String: String]) {
        guard let type = attrs["type"],
            let value = attrs["value"]
        else { return }
        let integrity = PodcastIntegrity(type: type, value: value)
        let parentContext = contextStack.dropLast().last ?? .root
        if parentContext == .liveItem {
            liveItemAltEncIntegrity = integrity
        } else {
            altEnclosureIntegrity = integrity
        }
    }
}

// MARK: - Live Item

extension FeedParserDelegate {

    func handleLiveItemStart(_ attrs: [String: String]) {
        guard let statusStr = attrs["status"],
            let status = PodcastLiveItem.LiveStatus(rawValue: statusStr),
            let startStr = attrs["start"],
            let startDate = DateParser.parse(startStr)
        else { return }
        let endDate = attrs["end"].flatMap { DateParser.parse($0) }
        currentLiveItem = PodcastLiveItem(
            status: status, start: startDate, end: endDate
        )
        pushContext(.liveItem)
    }

    func handleLiveItemEndElement(_ name: String, text: String) {
        switch name {
        case "title":
            currentLiveItem?.title = text.isEmpty ? nil : text
        case "description":
            currentLiveItem?.description = text.isEmpty ? nil : text
        case "guid":
            let isPermaLink =
                parseBool(
                    currentAttributes["isPermaLink"] ?? "true"
                ) ?? true
            if !text.isEmpty {
                currentLiveItem?.guid = GUID(
                    value: text, isPermaLink: isPermaLink
                )
            }
        case "podcast:contentLink":
            if let hrefStr = currentAttributes["href"],
                let href = URL(string: hrefStr), !text.isEmpty
            {
                currentLiveItem?.contentLinks.append(
                    ContentLink(href: href, title: text)
                )
            }
        case "podcast:person":
            if let person = buildPerson(
                text: text, attrs: currentAttributes
            ) {
                currentLiveItem?.persons.append(person)
            }
        case "podcast:socialInteract":
            handleSocialInteract()
        default:
            break
        }
    }

    func finalizeLiveItem() {
        if let liveItem = currentLiveItem {
            chLiveItems.append(liveItem)
        }
        currentLiveItem = nil
    }
}

// MARK: - Remote Item & Podroll

extension FeedParserDelegate {

    func handleRemoteItemAttributes(_ attrs: [String: String]) {
        guard let feedGuid = attrs["feedGuid"] else { return }
        let remote = RemoteItem(
            feedGuid: feedGuid,
            feedUrl: attrs["feedUrl"].flatMap { URL(string: $0) },
            itemGuid: attrs["itemGuid"],
            medium: attrs["medium"]
        )
        switch currentContext {
        case .podroll:
            podrollItems.append(remote)
        case .valueTimeSplit:
            timeSplitRemoteItem = remote
        case .podcastPublisher:
            chPublisherRemoteItem = remote
        default: break
        }
    }
}

// MARK: - Transcript & Chapters Link

extension FeedParserDelegate {

    func handleTranscriptAttributes(_ attrs: [String: String]) {
        guard let urlStr = attrs["url"],
            let url = URL(string: urlStr),
            let type = attrs["type"]
        else { return }
        let transcript = Transcript(
            url: url, type: type,
            language: attrs["language"],
            rel: attrs["rel"]
        )
        currentItem?.transcripts.append(transcript)
    }

    func handleChaptersLinkAttributes(_ attrs: [String: String]) {
        guard let urlStr = attrs["url"],
            let url = URL(string: urlStr)
        else { return }
        let type = attrs["type"] ?? "application/json+chapters"
        currentItem?.chaptersLink = ChaptersLink(url: url, type: type)
    }
}

// MARK: - Podlove Chapters

extension FeedParserDelegate {

    func handlePodloveChapterAttributes(_ attrs: [String: String]) {
        guard let start = attrs["start"],
            let title = attrs["title"]
        else { return }
        let chapter = PodloveChapter(
            start: start, title: title,
            href: attrs["href"].flatMap { URL(string: $0) },
            image: attrs["image"].flatMap { URL(string: $0) }
        )
        podloveChapterList.append(chapter)
    }
}
