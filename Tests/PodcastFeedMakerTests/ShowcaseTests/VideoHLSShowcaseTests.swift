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

// MARK: - Video & HLS MIME Types

@Suite("Video & HLS MIME Types")
struct VideoHLSMIMETypeShowcase {

    @Test("HLS and streaming MIME type raw values are correct")
    func hlsAndStreamingRawValues() {
        #expect(Enclosure.MIMEType.hlsManifest.rawValue == "application/x-mpegURL")
        #expect(Enclosure.MIMEType.hlsAudioManifest.rawValue == "audio/mpegurl")
        #expect(Enclosure.MIMEType.mpegTS.rawValue == "video/MP2T")
    }

    @Test("Video format raw values are correct")
    func videoRawValues() {
        #expect(Enclosure.MIMEType.webm.rawValue == "video/webm")
        #expect(Enclosure.MIMEType.matroska.rawValue == "video/x-matroska")
        #expect(Enclosure.MIMEType.quicktime.rawValue == "video/quicktime")
        #expect(Enclosure.MIMEType.m4v.rawValue == "video/m4v")
    }

    @Test("New audio format raw values are correct")
    func audioRawValues() {
        #expect(Enclosure.MIMEType.aiff.rawValue == "audio/aiff")
        #expect(Enclosure.MIMEType.aac.rawValue == "audio/aac")
        #expect(Enclosure.MIMEType.ogg.rawValue == "audio/ogg")
        #expect(Enclosure.MIMEType.webmAudio.rawValue == "audio/webm")
        #expect(Enclosure.MIMEType.matroskaAudio.rawValue == "audio/x-matroska")
    }

    @Test("isVideo returns true for all video formats, false for others")
    func isVideoClassification() {
        let videoTypes: [Enclosure.MIMEType] = [
            .webm, .matroska, .mp4, .quicktime, .m4v, .mpegTS, .avi, .wmv, .threeGP, .threeGP2
        ]
        for vType in videoTypes {
            #expect(vType.isVideo, "\(vType.rawValue) should be video")
        }
        #expect(!Enclosure.MIMEType.mpeg.isVideo)
        #expect(!Enclosure.MIMEType.aiff.isVideo)
        #expect(!Enclosure.MIMEType.hlsManifest.isVideo)
        #expect(!Enclosure.MIMEType.pdf.isVideo)
    }

    @Test("isAudio returns true for audio formats, false for video")
    func isAudioClassification() {
        let audioTypes: [Enclosure.MIMEType] = [
            .aiff, .aac, .ogg, .webmAudio, .matroskaAudio, .hlsAudioManifest, .mpeg, .wma
        ]
        for aType in audioTypes {
            #expect(aType.isAudio, "\(aType.rawValue) should be audio")
        }
        #expect(!Enclosure.MIMEType.webm.isAudio)
        #expect(!Enclosure.MIMEType.hlsManifest.isAudio)
        #expect(!Enclosure.MIMEType.pdf.isAudio)
    }

    @Test("isHLS returns true only for HLS manifests")
    func isHLSClassification() {
        #expect(Enclosure.MIMEType.hlsManifest.isHLS)
        #expect(Enclosure.MIMEType.hlsAudioManifest.isHLS)
        #expect(!Enclosure.MIMEType.mpeg.isHLS)
        #expect(!Enclosure.MIMEType.mpegTS.isHLS)
    }

    @Test("isStreaming includes HLS and MPEG-TS but not downloadable formats")
    func isStreamingClassification() {
        #expect(Enclosure.MIMEType.hlsManifest.isStreaming)
        #expect(Enclosure.MIMEType.hlsAudioManifest.isStreaming)
        #expect(Enclosure.MIMEType.mpegTS.isStreaming)
        #expect(!Enclosure.MIMEType.mp4.isStreaming)
        #expect(!Enclosure.MIMEType.mpeg.isStreaming)
    }
}

// MARK: - Video & HLS Factories

@Suite("Video & HLS Factories")
struct VideoHLSFactoryShowcase {

    @Test("Video factories create correct MIME types")
    func videoFactories() throws {
        let mov = try #require(Enclosure.mov(url: "https://cdn.example.com/ep.mov", length: 200_000_000))
        #expect(mov.type == "video/quicktime")

        let m4v = try #require(Enclosure.m4v(url: "https://cdn.example.com/ep.m4v", length: 80_000_000))
        #expect(m4v.type == "video/m4v")

        let webm = try #require(Enclosure.webm(url: "https://cdn.example.com/ep.webm", length: 50_000_000))
        #expect(webm.type == "video/webm")
    }

    @Test("HLS factories create correct MIME types")
    func hlsFactories() throws {
        let hls = try #require(Enclosure.hls(url: "https://cdn.example.com/stream.m3u8", length: 0))
        #expect(hls.type == "application/x-mpegURL")
        #expect(hls.length == 0)

        let hlsAudio = try #require(
            Enclosure.hlsAudio(url: "https://cdn.example.com/audio.m3u8", length: 0)
        )
        #expect(hlsAudio.type == "audio/mpegurl")
    }

    @Test("Audio factories create correct MIME types")
    func audioFactories() throws {
        let aac = try #require(Enclosure.aac(url: "https://cdn.example.com/ep.aac", length: 12_000_000))
        #expect(aac.type == "audio/aac")

        let ogg = try #require(Enclosure.ogg(url: "https://cdn.example.com/ep.ogg", length: 8_000_000))
        #expect(ogg.type == "audio/ogg")

        let aiff = try #require(Enclosure.aiff(url: "https://cdn.example.com/ep.aiff", length: 40_000_000))
        #expect(aiff.type == "audio/aiff")

        let webmA = try #require(
            Enclosure.webmAudio(url: "https://cdn.example.com/ep.webm", length: 15_000_000)
        )
        #expect(webmA.type == "audio/webm")
    }

    @Test("Factories return nil for invalid URL")
    func invalidURLReturnsNil() {
        #expect(Enclosure.hls(url: "", length: 0) == nil)
        #expect(Enclosure.webm(url: "", length: 100) == nil)
        #expect(Enclosure.mov(url: "", length: 100) == nil)
    }
}

// MARK: - Video Feed Building

@Suite("Video Feed Building")
struct VideoFeedBuildingShowcase {

    @Test("DSL builds a video podcast feed with mp4 enclosure")
    func dslVideoFeed() throws {
        let url = makeURL("https://example.com")
        let enc = try #require(
            Enclosure.mp4(url: "https://cdn.example.com/ep1.mp4", length: 150_000_000)
        )
        let feed = PodcastFeed {
            Channel(title: "Video Show", link: url, description: "A video podcast")
                .medium(.video)
                .explicit(false)
            Item(title: "Episode 1", enclosure: enc)
                .duration(1800)
                .guid("ep-001", isPermaLink: false)
        }

        let channel = try #require(feed.channel)
        #expect(channel.title == "Video Show")
        #expect(channel.medium == .video)
        #expect(channel.items.count == 1)
        #expect(channel.items[0].enclosure?.type == "video/mp4")
        #expect(channel.items[0].enclosure?.length == 150_000_000)
    }

    @Test("DSL builds a feed with HLS streaming enclosure")
    func dslHLSFeed() throws {
        let url = makeURL("https://example.com")
        let hlsEnc = try #require(
            Enclosure.hls(url: "https://cdn.example.com/live.m3u8", length: 0)
        )
        let feed = PodcastFeed {
            Channel(title: "Live Stream", link: url, description: "HLS streaming podcast")
            Item(title: "Live Event", enclosure: hlsEnc)
                .guid("live-001", isPermaLink: false)
        }

        let item = try #require(feed.channel?.items.first)
        #expect(item.enclosure?.type == "application/x-mpegURL")
        #expect(item.enclosure?.length == 0)
    }

    @Test("DSL builds a mixed-media feed with audio and video episodes")
    func dslMixedMediaFeed() throws {
        let url = makeURL("https://example.com")
        let videoEnc = try #require(
            Enclosure.webm(url: "https://cdn.example.com/ep1.webm", length: 90_000_000)
        )
        let audioEnc = try #require(
            Enclosure.aiff(url: "https://cdn.example.com/ep2.aiff", length: 40_000_000)
        )
        let feed = PodcastFeed {
            Channel(title: "Mixed Show", link: url, description: "Audio and video")
            Item(title: "Video Episode", enclosure: videoEnc)
                .guid("vid-001", isPermaLink: false)
            Item(title: "Audio Episode", enclosure: audioEnc)
                .guid("aud-001", isPermaLink: false)
        }

        let channel = try #require(feed.channel)
        #expect(channel.items.count == 2)
        #expect(channel.items[0].enclosure?.type == "video/webm")
        #expect(channel.items[1].enclosure?.type == "audio/aiff")
    }

    @Test("Video feed generates valid XML and can be parsed back")
    func videoFeedGenerateAndParse() throws {
        let url = makeURL("https://example.com")
        let enc = try #require(
            Enclosure.mov(url: "https://cdn.example.com/ep.mov", length: 200_000_000)
        )
        let feed = PodcastFeed {
            Channel(title: "QuickTime Show", link: url, description: "MOV podcast")
            Item(title: "Episode", enclosure: enc).guid("qt-001", isPermaLink: false)
        }

        let generator = FeedGenerator()
        let xml = try generator.generate(feed)
        #expect(xml.contains("video/quicktime"))
        #expect(xml.contains("200000000"))

        let parsed = try FeedParser().parse(xml)
        let parsedEnc = try #require(parsed.channel?.items.first?.enclosure)
        #expect(parsedEnc.type == "video/quicktime")
        #expect(parsedEnc.length == 200_000_000)
    }
}
