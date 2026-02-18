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

// MARK: - Video MIME Type Round-Trip

@Suite("Video MIME Type Round-Trip")
struct VideoRoundTripTests {

    private let generator = FeedGenerator()
    private let parser = FeedParser()

    /// Creates a feed with a single item using the given enclosure.
    private func makeFeed(enclosure: Enclosure) -> PodcastFeed {
        let linkURL = makeURL("https://example.com")
        var channel = Channel(title: "Video Show", link: linkURL, description: "A video podcast")
        var item = Item()
        item.title = "Episode"
        item.enclosure = enclosure
        item.guid = GUID(value: "ep1", isPermaLink: false)
        channel.items = [item]
        return PodcastFeed(version: "2.0", channel: channel)
    }

    /// Generates XML from a feed, parses it back, and returns the parsed enclosure.
    private func roundTrip(_ feed: PodcastFeed) throws -> Enclosure {
        let xml = try generator.generate(feed)
        let parsed = try parser.parse(xml)
        let parsedItem = try #require(parsed.channel?.items.first)
        return try #require(parsedItem.enclosure)
    }

    // MARK: - HLS Streaming

    @Test("HLS manifest enclosure round-trips with application/x-mpegURL")
    func hlsManifestRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/stream/master.m3u8")
        let enclosure = Enclosure(url: url, length: 0, mimeType: .hlsManifest)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "application/x-mpegURL")
        #expect(result.url == url)
        #expect(result.length == 0)
    }

    @Test("HLS audio manifest enclosure round-trips with audio/mpegurl")
    func hlsAudioManifestRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/audio/playlist.m3u8")
        let enclosure = Enclosure(url: url, length: 0, mimeType: .hlsAudioManifest)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "audio/mpegurl")
        #expect(result.url == url)
        #expect(result.length == 0)
    }

    // MARK: - Video Formats

    @Test("WebM video enclosure round-trips with video/webm")
    func webmRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep.webm")
        let enclosure = Enclosure(url: url, length: 50_000_000, mimeType: .webm)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "video/webm")
        #expect(result.url == url)
        #expect(result.length == 50_000_000)
    }

    @Test("Matroska video enclosure round-trips with video/x-matroska")
    func matroskaRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep.mkv")
        let enclosure = Enclosure(url: url, length: 120_000_000, mimeType: .matroska)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "video/x-matroska")
        #expect(result.url == url)
        #expect(result.length == 120_000_000)
    }

    @Test("QuickTime MOV enclosure round-trips with video/quicktime")
    func quicktimeRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep.mov")
        let enclosure = Enclosure(url: url, length: 200_000_000, mimeType: .quicktime)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "video/quicktime")
        #expect(result.url == url)
        #expect(result.length == 200_000_000)
    }

    @Test("M4V video enclosure round-trips with video/m4v")
    func m4vRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep.m4v")
        let enclosure = Enclosure(url: url, length: 80_000_000, mimeType: .m4v)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "video/m4v")
        #expect(result.url == url)
        #expect(result.length == 80_000_000)
    }

    @Test("MPEG-TS enclosure round-trips with video/MP2T")
    func mpegTSRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/segment.ts")
        let enclosure = Enclosure(url: url, length: 5_000_000, mimeType: .mpegTS)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "video/MP2T")
        #expect(result.url == url)
        #expect(result.length == 5_000_000)
    }

    // MARK: - Audio Formats

    @Test("AIFF audio enclosure round-trips with audio/aiff")
    func aiffRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep.aiff")
        let enclosure = Enclosure(url: url, length: 40_000_000, mimeType: .aiff)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "audio/aiff")
        #expect(result.url == url)
        #expect(result.length == 40_000_000)
    }

    @Test("WebM audio enclosure round-trips with audio/webm")
    func webmAudioRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep-audio.webm")
        let enclosure = Enclosure(url: url, length: 15_000_000, mimeType: .webmAudio)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "audio/webm")
        #expect(result.url == url)
        #expect(result.length == 15_000_000)
    }

    @Test("Matroska audio enclosure round-trips with audio/x-matroska")
    func matroskaAudioRoundTrip() throws {
        let url = makeURL("https://cdn.example.com/ep.mka")
        let enclosure = Enclosure(url: url, length: 25_000_000, mimeType: .matroskaAudio)
        let feed = makeFeed(enclosure: enclosure)

        let result = try roundTrip(feed)
        #expect(result.type == "audio/x-matroska")
        #expect(result.url == url)
        #expect(result.length == 25_000_000)
    }

    // MARK: - Multi-Item Feed

    @Test("Feed with mixed audio and video enclosures round-trips all items")
    func mixedMediaFeedRoundTrip() throws {
        let linkURL = makeURL("https://example.com")
        let hlsURL = makeURL("https://cdn.example.com/stream.m3u8")
        let webmURL = makeURL("https://cdn.example.com/ep.webm")
        let aiffURL = makeURL("https://cdn.example.com/ep.aiff")

        var channel = Channel(title: "Mixed Show", link: linkURL, description: "Audio and video")
        var hlsItem = Item(title: "Live Stream", guid: GUID(value: "live", isPermaLink: false))
        hlsItem.enclosure = Enclosure(url: hlsURL, length: 0, mimeType: .hlsManifest)

        var videoItem = Item(title: "Video Episode", guid: GUID(value: "vid", isPermaLink: false))
        videoItem.enclosure = Enclosure(url: webmURL, length: 90_000_000, mimeType: .webm)

        var audioItem = Item(title: "Audio Episode", guid: GUID(value: "aud", isPermaLink: false))
        audioItem.enclosure = Enclosure(url: aiffURL, length: 40_000_000, mimeType: .aiff)

        channel.items = [hlsItem, videoItem, audioItem]
        let feed = PodcastFeed(version: "2.0", channel: channel)

        let xml = try generator.generate(feed)
        let parsed = try parser.parse(xml)
        let items = try #require(parsed.channel?.items)
        #expect(items.count == 3)

        let parsedHLS = try #require(items[0].enclosure)
        #expect(parsedHLS.type == "application/x-mpegURL")

        let parsedVideo = try #require(items[1].enclosure)
        #expect(parsedVideo.type == "video/webm")

        let parsedAudio = try #require(items[2].enclosure)
        #expect(parsedAudio.type == "audio/aiff")
    }
}
