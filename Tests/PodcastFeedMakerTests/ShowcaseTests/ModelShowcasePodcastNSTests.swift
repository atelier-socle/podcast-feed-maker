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
import Testing

@testable import PodcastFeedMaker

// MARK: - Podcast NS 2.0 Phase 1

@Suite("Podcast NS 2.0 -- Phase 1")
struct PodcastNS20Phase1Showcase {

    // MARK: - Locked

    @Test("Locked with owner email")
    func lockedWithOwner() {
        let locked = Locked(isLocked: true, owner: "owner@podcast.example")
        #expect(locked.isLocked == true)
        #expect(locked.owner == "owner@podcast.example")
    }

    @Test("Locked without owner")
    func lockedWithoutOwner() {
        let locked = Locked(isLocked: false)
        #expect(locked.isLocked == false)
        #expect(locked.owner == nil)
    }

    // MARK: - Transcript

    @Test("Transcript with all properties")
    func transcriptAllProperties() {
        let url = makeURL("https://example.com/ep1.vtt")
        let transcript = Transcript(url: url, type: "text/vtt", language: "en", rel: "captions")

        #expect(transcript.url == url)
        #expect(transcript.type == "text/vtt")
        #expect(transcript.language == "en")
        #expect(transcript.rel == "captions")
    }

    @Test("Transcript with required properties only")
    func transcriptRequiredOnly() {
        let url = makeURL("https://example.com/ep1.srt")
        let transcript = Transcript(url: url, type: "application/srt")

        #expect(transcript.language == nil)
        #expect(transcript.rel == nil)
    }

    @Test("Transcript.TranscriptType covers all known MIME types")
    func transcriptTypeAllCases() {
        let allCases = Transcript.TranscriptType.allCases
        #expect(allCases.count == 5)
        #expect(Transcript.TranscriptType.vtt.rawValue == "text/vtt")
        #expect(Transcript.TranscriptType.srt.rawValue == "application/srt")
        #expect(Transcript.TranscriptType.subrip.rawValue == "application/x-subrip")
        #expect(Transcript.TranscriptType.html.rawValue == "text/html")
        #expect(Transcript.TranscriptType.json.rawValue == "application/json")
    }

    // MARK: - Funding

    @Test("Funding links to a donation page")
    func fundingAllProperties() {
        let url = makeURL("https://www.patreon.com/swifttalk")
        let funding = Funding(url: url, message: "Support us on Patreon")

        #expect(funding.url == url)
        #expect(funding.message == "Support us on Patreon")
    }

    // MARK: - ChaptersLink

    @Test("ChaptersLink with default type")
    func chaptersLinkDefaultType() {
        let url = makeURL("https://example.com/ep1/chapters.json")
        let chapters = ChaptersLink(url: url)

        #expect(chapters.url == url)
        #expect(chapters.type == "application/json+chapters")
    }

    @Test("ChaptersLink with explicit type")
    func chaptersLinkExplicitType() {
        let url = makeURL("https://example.com/ep1/chapters.json")
        let chapters = ChaptersLink(url: url, type: "application/json")

        #expect(chapters.type == "application/json")
    }

    // MARK: - Soundbite

    @Test("Soundbite with title")
    func soundbiteWithTitle() {
        let soundbite = Soundbite(startTime: 73.0, duration: 60.0, title: "Best moment of the episode")

        #expect(soundbite.startTime == 73.0)
        #expect(soundbite.duration == 60.0)
        #expect(soundbite.title == "Best moment of the episode")
    }

    @Test("Soundbite without title")
    func soundbiteWithoutTitle() {
        let soundbite = Soundbite(startTime: 120.5, duration: 30.0)

        #expect(soundbite.startTime == 120.5)
        #expect(soundbite.duration == 30.0)
        #expect(soundbite.title == nil)
    }
}

// MARK: - Podcast NS 2.0 Phase 2

@Suite("Podcast NS 2.0 -- Phase 2")
struct PodcastNS20Phase2Showcase {

    // MARK: - PodcastPerson

    @Test("PodcastPerson with all properties")
    func personAllProperties() {
        let href = makeURL("https://janeswift.dev")
        let img = makeURL("https://janeswift.dev/headshot.jpg")

        let person = PodcastPerson(
            name: "Jane Swift",
            role: "host",
            group: "cast",
            href: href,
            img: img
        )

        #expect(person.name == "Jane Swift")
        #expect(person.role == "host")
        #expect(person.group == "cast")
        #expect(person.href == href)
        #expect(person.img == img)
    }

    @Test("PodcastPerson with name only defaults role and group to nil")
    func personNameOnly() {
        let person = PodcastPerson(name: "Anonymous Guest")

        #expect(person.name == "Anonymous Guest")
        #expect(person.role == nil)
        #expect(person.group == nil)
        #expect(person.href == nil)
        #expect(person.img == nil)
    }

    @Test("PodcastPerson.Role enum covers common podcast taxonomy roles")
    func personRoleEnum() {
        let allRoles = PodcastPerson.Role.allCases
        #expect(allRoles.count == 8)
        #expect(PodcastPerson.Role.host.rawValue == "host")
        #expect(PodcastPerson.Role.guest.rawValue == "guest")
        #expect(PodcastPerson.Role.editor.rawValue == "editor")
        #expect(PodcastPerson.Role.producer.rawValue == "producer")
        #expect(PodcastPerson.Role.writer.rawValue == "writer")
        #expect(PodcastPerson.Role.designer.rawValue == "designer")
        #expect(PodcastPerson.Role.composer.rawValue == "composer")
        #expect(PodcastPerson.Role.narrator.rawValue == "narrator")
    }

    // MARK: - PodcastLocation

    @Test("PodcastLocation with all attributes")
    func locationAllProperties() {
        let location = PodcastLocation(
            name: "Austin, TX",
            geo: "geo:30.2672,-97.7431",
            osm: "R113314",
            rel: "creator",
            country: "US"
        )

        #expect(location.name == "Austin, TX")
        #expect(location.geo == "geo:30.2672,-97.7431")
        #expect(location.osm == "R113314")
        #expect(location.rel == "creator")
        #expect(location.country == "US")
    }

    @Test("PodcastLocation with name only")
    func locationNameOnly() {
        let location = PodcastLocation(name: "Somewhere beautiful")

        #expect(location.name == "Somewhere beautiful")
        #expect(location.geo == nil)
        #expect(location.osm == nil)
        #expect(location.rel == nil)
        #expect(location.country == nil)
    }

    @Test("PodcastLocation subject relationship")
    func locationSubject() {
        let location = PodcastLocation(
            name: "Paris",
            geo: "geo:48.8566,2.3522",
            osm: "R7444",
            rel: "subject",
            country: "FR"
        )

        #expect(location.rel == "subject")
        #expect(location.country == "FR")
    }

    // MARK: - PodcastSeason

    @Test("PodcastSeason with name")
    func seasonWithName() {
        let season = PodcastSeason(number: 3, name: "Mysteries of the Deep")

        #expect(season.number == 3)
        #expect(season.name == "Mysteries of the Deep")
    }

    @Test("PodcastSeason number only")
    func seasonNumberOnly() {
        let season = PodcastSeason(number: 1)

        #expect(season.number == 1)
        #expect(season.name == nil)
    }

    // MARK: - PodcastEpisode

    @Test("PodcastEpisode with display string")
    func episodeWithDisplay() {
        let episode = PodcastEpisode(number: 3.0, display: "EP3")

        #expect(episode.number == 3.0)
        #expect(episode.display == "EP3")
    }

    @Test("PodcastEpisode supports decimal sub-episodes")
    func episodeDecimalNumber() {
        let episode = PodcastEpisode(number: 3.5, display: "3a")

        #expect(episode.number == 3.5)
        #expect(episode.display == "3a")
    }

    @Test("PodcastEpisode number only")
    func episodeNumberOnly() {
        let episode = PodcastEpisode(number: 42.0)

        #expect(episode.number == 42.0)
        #expect(episode.display == nil)
    }
}

// MARK: - Podcast NS 2.0 Phase 3

@Suite("Podcast NS 2.0 -- Phase 3")
struct PodcastNS20Phase3Showcase {

    // MARK: - Trailer

    @Test("Trailer with all properties")
    func trailerAllProperties() {
        let url = makeURL("https://cdn.example.com/season2-trailer.mp3")
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let trailer = Trailer(
            title: "Season 2 Trailer",
            url: url,
            pubDate: pubDate,
            length: 5_242_880,
            type: "audio/mpeg",
            season: 2
        )

        #expect(trailer.title == "Season 2 Trailer")
        #expect(trailer.url == url)
        #expect(trailer.pubDate == pubDate)
        #expect(trailer.length == 5_242_880)
        #expect(trailer.type == "audio/mpeg")
        #expect(trailer.season == 2)
    }

    @Test("Trailer with required properties only")
    func trailerRequiredOnly() {
        let url = makeURL("https://cdn.example.com/preview.mp3")
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let trailer = Trailer(title: "Show Preview", url: url, pubDate: pubDate)

        #expect(trailer.length == nil)
        #expect(trailer.type == nil)
        #expect(trailer.season == nil)
    }

    // MARK: - PodcastLicense

    @Test("PodcastLicense with URL")
    func licenseWithURL() {
        let url = makeURL("https://creativecommons.org/licenses/by/4.0/")
        let license = PodcastLicense(identifier: "cc-by-4.0", url: url)

        #expect(license.identifier == "cc-by-4.0")
        #expect(license.url == url)
    }

    @Test("PodcastLicense identifier only")
    func licenseIdentifierOnly() {
        let license = PodcastLicense(identifier: "cc-by-sa-4.0")

        #expect(license.identifier == "cc-by-sa-4.0")
        #expect(license.url == nil)
    }

    // MARK: - AlternateEnclosure + PodcastSource + PodcastIntegrity

    @Test("AlternateEnclosure with all properties including sources and integrity")
    func alternateEnclosureComplete() {
        let altEnc = AlternateEnclosure(
            type: "audio/opus",
            length: 18_000_000,
            bitrate: 128_000,
            height: 0,
            language: "en",
            title: "High Quality Opus",
            isDefault: true,
            sources: [
                PodcastSource(uri: "https://cdn.example.com/ep1.opus"),
                PodcastSource(uri: "ipfs://QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn", contentType: "audio/opus")
            ],
            integrity: PodcastIntegrity(type: "sri", value: "sha256-C7yRJuJMwYk3JYONn3V2AUHR3L4rFAF3GJHP+eR3jYg=")
        )

        #expect(altEnc.type == "audio/opus")
        #expect(altEnc.length == 18_000_000)
        #expect(altEnc.bitrate == 128_000)
        #expect(altEnc.height == 0)
        #expect(altEnc.language == "en")
        #expect(altEnc.title == "High Quality Opus")
        #expect(altEnc.isDefault == true)
        #expect(altEnc.sources.count == 2)
        #expect(altEnc.sources[0].uri == "https://cdn.example.com/ep1.opus")
        #expect(altEnc.sources[0].contentType == nil)
        #expect(altEnc.sources[1].uri.hasPrefix("ipfs://"))
        #expect(altEnc.sources[1].contentType == "audio/opus")
        #expect(altEnc.integrity?.type == "sri")
        #expect(altEnc.integrity?.value.hasPrefix("sha256-") == true)
    }

    @Test("AlternateEnclosure with minimal properties")
    func alternateEnclosureMinimal() {
        let altEnc = AlternateEnclosure(type: "audio/mpeg")

        #expect(altEnc.type == "audio/mpeg")
        #expect(altEnc.length == nil)
        #expect(altEnc.bitrate == nil)
        #expect(altEnc.height == nil)
        #expect(altEnc.language == nil)
        #expect(altEnc.title == nil)
        #expect(altEnc.isDefault == nil)
        #expect(altEnc.sources.isEmpty)
        #expect(altEnc.integrity == nil)
    }

    @Test("PodcastSource with optional content type")
    func podcastSourceProperties() {
        let sourceHTTPS = PodcastSource(uri: "https://cdn.example.com/episode.mp3")
        #expect(sourceHTTPS.uri == "https://cdn.example.com/episode.mp3")
        #expect(sourceHTTPS.contentType == nil)

        let sourceIPFS = PodcastSource(uri: "ipfs://QmHash123", contentType: "audio/mpeg")
        #expect(sourceIPFS.contentType == "audio/mpeg")
    }

    @Test("PodcastIntegrity holds type and hash value")
    func podcastIntegrityProperties() {
        let integrity = PodcastIntegrity(
            type: "sri",
            value: "sha256-C7yRJuJMwYk3JYONn3V2AUHR3L4rFAF3GJHP+eR3jYg="
        )

        #expect(integrity.type == "sri")
        #expect(integrity.value.hasPrefix("sha256-"))
    }
}
