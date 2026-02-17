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

// MARK: - RSS 2.0 Item Showcase

@Suite("RSS 2.0 Item Showcase")
struct RSS20ItemShowcase {

    // MARK: - Item

    @Test("Item initializes with all properties set to nil/empty by default")
    func itemDefaults() {
        let item = Item()

        #expect(item.title == nil)
        #expect(item.link == nil)
        #expect(item.description == nil)
        #expect(item.author == nil)
        #expect(item.categories.isEmpty)
        #expect(item.comments == nil)
        #expect(item.enclosure == nil)
        #expect(item.guid == nil)
        #expect(item.pubDate == nil)
        #expect(item.source == nil)
        #expect(item.itunesAuthor == nil)
        #expect(item.itunesBlock == nil)
        #expect(item.itunesDuration == nil)
        #expect(item.itunesEpisode == nil)
        #expect(item.itunesEpisodeType == nil)
        #expect(item.itunesExplicit == nil)
        #expect(item.itunesImage == nil)
        #expect(item.itunesKeywords.isEmpty)
        #expect(item.itunesSeason == nil)
        #expect(item.itunesSubtitle == nil)
        #expect(item.itunesSummary == nil)
        #expect(item.itunesTitle == nil)
        #expect(item.atomLinks.isEmpty)
        #expect(item.dublinCore == nil)
        #expect(item.contentEncoded == nil)
        #expect(item.transcripts.isEmpty)
        #expect(item.chaptersLink == nil)
        #expect(item.soundbites.isEmpty)
        #expect(item.persons.isEmpty)
        #expect(item.locations.isEmpty)
        #expect(item.license == nil)
        #expect(item.alternateEnclosures.isEmpty)
        #expect(item.value == nil)
        #expect(item.socialInteractions.isEmpty)
        #expect(item.txtRecords.isEmpty)
        #expect(item.podcastSeason == nil)
        #expect(item.podcastEpisode == nil)
        #expect(item.podcastImages.isEmpty)
        #expect(item.podcastImagesSrcset == nil)
        #expect(item.podloveChapters == nil)
        #expect(item.unknownElements.isEmpty)
        #expect(item.xmlComments.isEmpty)
        #expect(item.cdataFields.isEmpty)
    }

    @Test("Item initializes with all RSS 2.0 core properties")
    func itemAllRSSProperties() {
        let linkURL = makeURL("https://swifttalk.dev/episodes/1")
        let commentsURL = makeURL("https://swifttalk.dev/episodes/1/comments")
        let enclosureURL = makeURL("https://cdn.swifttalk.dev/episode1.mp3")
        let sourceURL = makeURL("https://otherpodcast.com/feed.xml")
        let pubDate = Date(timeIntervalSince1970: 1_700_000_000)

        let item = Item(
            title: "Episode 1: Getting Started with Swift 6",
            link: linkURL,
            description: "An introduction to the strict concurrency features in Swift 6",
            author: "jane@swifttalk.dev (Jane Swift)",
            categories: [
                RSSCategory(value: "Programming"),
                RSSCategory(value: "Swift", domain: "https://swifttalk.dev/tags")
            ],
            comments: commentsURL,
            enclosure: Enclosure(url: enclosureURL, length: 48_576_000, type: "audio/mpeg"),
            guid: GUID(value: "swifttalk-ep001", isPermaLink: false),
            pubDate: pubDate,
            source: RSSSource(title: "Other Podcast", url: sourceURL)
        )

        #expect(item.title == "Episode 1: Getting Started with Swift 6")
        #expect(item.link == linkURL)
        #expect(item.description?.contains("Swift 6") == true)
        #expect(item.author == "jane@swifttalk.dev (Jane Swift)")
        #expect(item.categories.count == 2)
        #expect(item.categories[1].domain == "https://swifttalk.dev/tags")
        #expect(item.comments == commentsURL)
        #expect(item.enclosure?.url == enclosureURL)
        #expect(item.enclosure?.length == 48_576_000)
        #expect(item.enclosure?.type == "audio/mpeg")
        #expect(item.guid?.value == "swifttalk-ep001")
        #expect(item.guid?.isPermaLink == false)
        #expect(item.pubDate == pubDate)
        #expect(item.source?.title == "Other Podcast")
        #expect(item.source?.url == sourceURL)
    }

    @Test("Item location convenience accessor works")
    func itemLocationConvenience() {
        var item = Item(title: "Location Test")

        item.location = PodcastLocation(name: "Tokyo", country: "JP")
        #expect(item.locations.count == 1)
        #expect(item.location?.name == "Tokyo")

        item.location = nil
        #expect(item.locations.isEmpty)
    }

    @Test("ITunesEpisodeType has all three cases")
    func itunesEpisodeTypeCases() {
        let allCases = ITunesEpisodeType.allCases
        #expect(allCases.count == 3)
        #expect(ITunesEpisodeType.full.rawValue == "full")
        #expect(ITunesEpisodeType.trailer.rawValue == "trailer")
        #expect(ITunesEpisodeType.bonus.rawValue == "bonus")
    }

    @Test("ITunesShowType has both cases")
    func itunesShowTypeCases() {
        let allCases = ITunesShowType.allCases
        #expect(allCases.count == 2)
        #expect(ITunesShowType.episodic.rawValue == "episodic")
        #expect(ITunesShowType.serial.rawValue == "serial")
    }

    // MARK: - Enclosure

    @Test("Enclosure initializes with string type")
    func enclosureStringInit() {
        let url = makeURL("https://cdn.example.com/episode.mp3")
        let enclosure = Enclosure(url: url, length: 24_576_000, type: "audio/mpeg")

        #expect(enclosure.url == url)
        #expect(enclosure.length == 24_576_000)
        #expect(enclosure.type == "audio/mpeg")
    }

    @Test("Enclosure initializes with MIMEType enum")
    func enclosureMIMETypeInit() {
        let url = makeURL("https://cdn.example.com/episode.opus")
        let enclosure = Enclosure(url: url, length: 12_000_000, mimeType: .opus)

        #expect(enclosure.type == "audio/opus")
    }

    @Test("Enclosure.MIMEType covers all 11 audio/video/document formats")
    func enclosureMIMETypeAllCases() {
        let allCases = Enclosure.MIMEType.allCases
        #expect(allCases.count == 11)
        #expect(Enclosure.MIMEType.aac.rawValue == "audio/aac")
        #expect(Enclosure.MIMEType.m4a.rawValue == "audio/m4a")
        #expect(Enclosure.MIMEType.mpeg.rawValue == "audio/mpeg")
        #expect(Enclosure.MIMEType.ogg.rawValue == "audio/ogg")
        #expect(Enclosure.MIMEType.opus.rawValue == "audio/opus")
        #expect(Enclosure.MIMEType.wav.rawValue == "audio/wav")
        #expect(Enclosure.MIMEType.flac.rawValue == "audio/flac")
        #expect(Enclosure.MIMEType.quicktime.rawValue == "video/quicktime")
        #expect(Enclosure.MIMEType.mp4.rawValue == "video/mp4")
        #expect(Enclosure.MIMEType.m4v.rawValue == "video/m4v")
        #expect(Enclosure.MIMEType.pdf.rawValue == "application/pdf")
    }

    @Test("Enclosure convenience factories create typed enclosures")
    func enclosureConvenienceFactories() throws {
        let mp3 = try #require(Enclosure.mp3(url: "https://cdn.example.com/ep1.mp3", length: 48_000_000))
        #expect(mp3.type == "audio/mpeg")
        #expect(mp3.length == 48_000_000)

        let m4a = try #require(Enclosure.m4a(url: "https://cdn.example.com/ep1.m4a", length: 36_000_000))
        #expect(m4a.type == "audio/m4a")

        let mp4 = try #require(Enclosure.mp4(url: "https://cdn.example.com/ep1.mp4", length: 120_000_000))
        #expect(mp4.type == "video/mp4")
    }

    @Test("Enclosure factory returns nil for invalid URL")
    func enclosureFactoryInvalidURL() {
        let result = Enclosure.mp3(url: "", length: 0)
        #expect(result == nil)
    }

    // MARK: - GUID

    @Test("GUID defaults isPermaLink to true")
    func guidDefaultPermaLink() {
        let guid = GUID(value: "https://example.com/episodes/42")
        #expect(guid.value == "https://example.com/episodes/42")
        #expect(guid.isPermaLink == true)
    }

    @Test("GUID with isPermaLink set to false for opaque identifiers")
    func guidNonPermaLink() {
        let guid = GUID(value: "550e8400-e29b-41d4-a716-446655440000", isPermaLink: false)
        #expect(guid.isPermaLink == false)
    }

    // MARK: - RSSImage

    @Test("RSSImage initializes with all properties")
    func rssImageAllProperties() {
        let imageURL = makeURL("https://example.com/podcast-logo.png")
        let siteURL = makeURL("https://example.com")

        let image = RSSImage(
            url: imageURL,
            title: "Podcast Logo",
            link: siteURL,
            width: 88,
            height: 31,
            imageDescription: "The official podcast logo"
        )

        #expect(image.url == imageURL)
        #expect(image.title == "Podcast Logo")
        #expect(image.link == siteURL)
        #expect(image.width == 88)
        #expect(image.height == 31)
        #expect(image.imageDescription == "The official podcast logo")
    }

    @Test("RSSImage initializes with required properties only")
    func rssImageRequiredOnly() {
        let url = makeURL("https://example.com/logo.jpg")
        let link = makeURL("https://example.com")
        let image = RSSImage(url: url, title: "Logo", link: link)

        #expect(image.width == nil)
        #expect(image.height == nil)
        #expect(image.imageDescription == nil)
    }

    // MARK: - RSSCategory

    @Test("RSSCategory with and without domain")
    func rssCategoryDomain() {
        let simple = RSSCategory(value: "Technology")
        #expect(simple.value == "Technology")
        #expect(simple.domain == nil)

        let withDomain = RSSCategory(value: "Swift", domain: "https://example.com/tags")
        #expect(withDomain.domain == "https://example.com/tags")
    }

    // MARK: - RSSCloud

    @Test("RSSCloud initializes with all five required properties")
    func rssCloudAllProperties() {
        let cloud = RSSCloud(
            domain: "rpc.podcasts.example.com",
            port: 80,
            path: "/RPC2",
            registerProcedure: "pingMe",
            protocolType: "soap"
        )

        #expect(cloud.domain == "rpc.podcasts.example.com")
        #expect(cloud.port == 80)
        #expect(cloud.path == "/RPC2")
        #expect(cloud.registerProcedure == "pingMe")
        #expect(cloud.protocolType == "soap")
    }

    // MARK: - RSSTextInput

    @Test("RSSTextInput initializes with all properties")
    func rssTextInputAllProperties() {
        let url = makeURL("https://example.com/search")
        let textInput = RSSTextInput(
            title: "Search",
            description: "Search our episodes",
            name: "query",
            link: url
        )

        #expect(textInput.title == "Search")
        #expect(textInput.description == "Search our episodes")
        #expect(textInput.name == "query")
        #expect(textInput.link == url)
    }

    // MARK: - SkipSchedule

    @Test("SkipSchedule with hours and days")
    func skipScheduleHoursAndDays() {
        let schedule = SkipSchedule(hours: [0, 1, 2, 3], days: [.saturday, .sunday])

        #expect(schedule.hours.count == 4)
        #expect(schedule.hours.contains(0))
        #expect(schedule.hours.contains(3))
        #expect(schedule.days.contains(.saturday))
        #expect(schedule.days.contains(.sunday))
        #expect(!schedule.days.contains(.monday))
    }

    @Test("SkipSchedule.Day has all seven days of the week")
    func skipScheduleAllDays() {
        let allDays = SkipSchedule.Day.allCases
        #expect(allDays.count == 7)
        #expect(SkipSchedule.Day.monday.rawValue == "Monday")
        #expect(SkipSchedule.Day.tuesday.rawValue == "Tuesday")
        #expect(SkipSchedule.Day.wednesday.rawValue == "Wednesday")
        #expect(SkipSchedule.Day.thursday.rawValue == "Thursday")
        #expect(SkipSchedule.Day.friday.rawValue == "Friday")
        #expect(SkipSchedule.Day.saturday.rawValue == "Saturday")
        #expect(SkipSchedule.Day.sunday.rawValue == "Sunday")
    }

    @Test("SkipSchedule defaults to empty sets")
    func skipScheduleDefaults() {
        let schedule = SkipSchedule()
        #expect(schedule.hours.isEmpty)
        #expect(schedule.days.isEmpty)
    }

    // MARK: - RSSSource

    @Test("RSSSource identifies the originating feed")
    func rssSourceAllProperties() {
        let url = makeURL("https://otherpodcast.com/feed.xml")
        let source = RSSSource(title: "The Other Podcast", url: url)

        #expect(source.title == "The Other Podcast")
        #expect(source.url == url)
    }
}
