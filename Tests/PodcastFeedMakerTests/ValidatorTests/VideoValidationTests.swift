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

// MARK: - Shared Helpers

private let baseURL = makeURL("https://example.com")
private let artURL = makeURL("https://example.com/art.jpg")
private let epImgURL = makeURL("https://example.com/ep.jpg")
private let mp4URL = makeURL("https://example.com/ep.mp4")
private let mp3URL = makeURL("https://example.com/ep.mp3")
private let fundURL = makeURL("https://example.com/fund")

private func feed(items: [Item], medium: PodcastMedium? = nil) -> PodcastFeed {
    PodcastFeed(
        channel: Channel(
            title: "Video Podcast", link: baseURL, description: "A video podcast",
            language: "en", items: items, itunesAuthor: "Author",
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false, itunesImage: artURL,
            itunesOwner: ITunesOwner(name: "Host", email: "h@e.com"),
            itunesType: .episodic, medium: medium
        ))
}

private func vItem(_ type: String = "video/mp4", length: Int = 50_000_000) -> Item {
    Item(
        title: "Video Episode",
        enclosure: Enclosure(url: mp4URL, length: length, type: type),
        guid: GUID(value: "vid-1", isPermaLink: false), pubDate: Date(),
        itunesDuration: 1200, itunesEpisodeType: .full,
        itunesExplicit: false, itunesImage: epImgURL)
}

private func aItem(_ type: String = "audio/mpeg", length: Int = 10_000_000) -> Item {
    Item(
        title: "Audio Episode",
        enclosure: Enclosure(url: mp3URL, length: length, type: type),
        guid: GUID(value: "aud-1", isPermaLink: false), pubDate: Date(),
        itunesDuration: 600, itunesEpisodeType: .full,
        itunesExplicit: false, itunesImage: epImgURL)
}

// MARK: - Apple Video Validation

@Suite("Apple Video Validation")
struct AppleVideoValidationTests {

    private let validator = FeedValidator()

    @Test("video/mp4 with HTTPS produces no type error")
    func videoMp4Passes() {
        let report = validator.validate(feed(items: [vItem()], medium: .video), for: .apple)
        #expect(report.errors.filter { $0.field.contains("enclosure.type") }.isEmpty)
    }

    @Test("video/webm produces warning, not error")
    func videoWebmWarning() {
        let report = validator.validate(feed(items: [vItem("video/webm")], medium: .video), for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.type"
                    && $0.message.contains("not preferred") && $0.message.contains("video/mp4")
            })
        #expect(report.errors.filter { $0.field == "channel.items[0].enclosure.type" }.isEmpty)
    }

    @Test("HLS manifest enclosure produces info about Podcasts Connect")
    func hlsManifestInfo() {
        let report = validator.validate(
            feed(items: [vItem("application/x-mpegURL")], medium: .video), for: .apple)
        #expect(
            report.infos.contains {
                $0.field == "channel.items[0].enclosure.type"
                    && $0.message.contains("HLS") && $0.message.contains("Podcasts Connect")
            })
    }

    @Test("Video enclosure without medium produces warning")
    func videoWithoutMediumWarning() {
        let report = validator.validate(feed(items: [vItem()], medium: nil), for: .apple)
        #expect(
            report.warnings.contains {
                $0.field == "channel.medium" && $0.message.contains("video")
            })
    }

    @Test("Video enclosure with medium .video produces no medium warning")
    func videoWithMediumNoWarning() {
        let report = validator.validate(feed(items: [vItem()], medium: .video), for: .apple)
        #expect(report.warnings.filter { $0.field == "channel.medium" }.isEmpty)
    }

    @Test("Video enclosure with medium .mixed produces no medium warning")
    func videoWithMixedMediumNoWarning() {
        let report = validator.validate(feed(items: [vItem()], medium: .mixed), for: .apple)
        #expect(report.warnings.filter { $0.field == "channel.medium" }.isEmpty)
    }

    @Test("Unsupported non-video type produces error, not warning")
    func unsupportedAudioTypeIsError() {
        let report = validator.validate(
            feed(items: [vItem("audio/x-ms-wma")], medium: .podcast), for: .apple)
        #expect(
            report.errors.contains {
                $0.field == "channel.items[0].enclosure.type" && $0.message.contains("not a supported")
            })
    }

    @Test("video/quicktime is allowed with no type issues")
    func videoQuicktimePasses() {
        let report = validator.validate(
            feed(items: [vItem("video/quicktime")], medium: .video), for: .apple)
        let issues =
            report.errors.filter { $0.field.contains("enclosure.type") }
            + report.warnings.filter { $0.field.contains("enclosure.type") && $0.message.contains("not preferred") }
        #expect(issues.isEmpty)
    }
}

// MARK: - Spotify Video Validation

@Suite("Spotify Video Validation")
struct SpotifyVideoValidationTests {

    private let validator = FeedValidator()

    @Test("video/mp4 produces no type warning")
    func videoMp4NoWarning() {
        let report = validator.validate(feed(items: [vItem()]), for: .spotify)
        #expect(report.warnings.filter { $0.field.contains("enclosure.type") }.isEmpty)
    }

    @Test("video/webm produces warning about MP4 format")
    func videoWebmWarning() {
        let report = validator.validate(feed(items: [vItem("video/webm")]), for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.type" && $0.message.contains("MP4")
            })
    }

    @Test("Video over 500 MB produces warning")
    func videoOver500MBWarning() {
        let report = validator.validate(
            feed(items: [vItem("video/mp4", length: 600_000_000)]), for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.length" && $0.message.contains("500 MB")
            })
    }

    @Test("Video at exactly 500 MB produces no size warning")
    func videoAt500MBNoWarning() {
        let report = validator.validate(
            feed(items: [vItem("video/mp4", length: 500_000_000)]), for: .spotify)
        #expect(report.warnings.filter { $0.field.contains("enclosure.length") }.isEmpty)
    }

    @Test("Video under 500 MB produces no size warning")
    func videoUnder500MBNoWarning() {
        let report = validator.validate(
            feed(items: [vItem("video/mp4", length: 200_000_000)]), for: .spotify)
        #expect(report.warnings.filter { $0.field.contains("enclosure.length") }.isEmpty)
    }

    @Test("Audio over 200 MB still uses 200 MB limit, not 500 MB")
    func audioOver200MBWarning() {
        let report = validator.validate(
            feed(items: [aItem("audio/mpeg", length: 250_000_000)]), for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.length" && $0.message.contains("200 MB")
            })
        #expect(report.warnings.filter { $0.message.contains("500 MB") }.isEmpty)
    }

    @Test("Audio at 400 MB does not trigger 500 MB video limit")
    func audioDoesNotUse500MBLimit() {
        let report = validator.validate(
            feed(items: [aItem("audio/x-m4a", length: 400_000_000)]), for: .spotify)
        #expect(report.warnings.filter { $0.message.contains("500 MB") }.isEmpty)
    }

    @Test("Non-MP3 audio still produces format warning")
    func nonMp3AudioWarning() {
        let report = validator.validate(feed(items: [aItem("audio/x-m4a")]), for: .spotify)
        #expect(
            report.warnings.contains {
                $0.field == "channel.items[0].enclosure.type" && $0.message.contains("MP3")
            })
    }

    @Test("Non-MP3 + over 200 MB cross-field check applies to audio, not video")
    func crossFieldNonMp3LargeAudioOnly() {
        let audioReport = validator.validate(
            feed(items: [aItem("audio/x-m4a", length: 250_000_000)]), for: .spotify)
        #expect(
            audioReport.warnings.contains {
                $0.message.contains("Non-MP3") && $0.message.contains("200 MB")
            })
        let videoReport = validator.validate(
            feed(items: [vItem("video/webm", length: 250_000_000)]), for: .spotify)
        #expect(
            videoReport.warnings.filter {
                $0.message.contains("Non-MP3") && $0.message.contains("200 MB")
            }.isEmpty)
    }
}

// MARK: - Podcast Index Video Validation

@Suite("Podcast Index Video Validation")
struct PodcastIndexVideoValidationTests {

    private let validator = FeedValidator()

    private func indexFeed(items: [Item]) -> PodcastFeed {
        PodcastFeed(
            channel: Channel(
                title: "Video Podcast", link: baseURL, description: "A video podcast",
                items: items, podcastGuid: PodcastGuid(value: "abc-123"),
                locked: Locked(isLocked: false),
                funding: [Funding(url: fundURL, message: "Support us")],
                medium: .video, txtRecords: [PodcastTxt(value: "abc", purpose: "verify")]
            ))
    }

    @Test("Video enclosure with no alternateEnclosures produces HLS info")
    func videoNoAlternateEnclosuresInfo() {
        let report = validator.validate(indexFeed(items: [vItem()]), for: .podcastIndex)
        #expect(
            report.infos.contains {
                $0.field == "channel.items[0].enclosure"
                    && $0.message.contains("alternateEnclosure") && $0.message.contains("HLS")
            })
    }

    @Test("Video enclosure with alternateEnclosures does not produce HLS info")
    func videoWithAlternateEnclosuresNoHLSInfo() {
        var item = vItem()
        item.alternateEnclosures = [
            AlternateEnclosure(
                type: "application/x-mpegURL",
                sources: [PodcastSource(uri: "https://example.com/ep.m3u8")])
        ]
        let report = validator.validate(indexFeed(items: [item]), for: .podcastIndex)
        let hlsInfos = report.infos.filter {
            $0.field.contains("enclosure") && $0.message.contains("HLS")
                && $0.message.contains("alternateEnclosure")
        }
        #expect(hlsInfos.isEmpty)
    }

    @Test("Video with alternateEnclosures still gets presence info")
    func videoWithAlternateEnclosuresPresenceInfo() {
        var item = vItem()
        item.alternateEnclosures = [
            AlternateEnclosure(
                type: "application/x-mpegURL",
                sources: [PodcastSource(uri: "https://example.com/ep.m3u8")])
        ]
        let report = validator.validate(indexFeed(items: [item]), for: .podcastIndex)
        #expect(
            report.infos.contains {
                $0.field == "channel.items[0].alternateEnclosures"
                    && $0.message.contains("alternate enclosures")
            })
    }

    @Test("Audio enclosure does not produce HLS info")
    func audioNoHLSInfo() {
        let report = validator.validate(indexFeed(items: [aItem()]), for: .podcastIndex)
        #expect(
            report.infos.filter {
                $0.field.contains(".enclosure") && $0.message.contains("HLS")
            }.isEmpty)
    }
}
