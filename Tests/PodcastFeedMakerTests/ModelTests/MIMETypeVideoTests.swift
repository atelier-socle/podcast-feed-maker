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

// MARK: - MIMEType Raw Values

@Suite("MIMEType Raw Values")
struct MIMETypeRawValueTests {

    @Test("AAC raw value") func aac() { #expect(Enclosure.MIMEType.aac.rawValue == "audio/aac") }
    @Test("AIFF raw value") func aiff() { #expect(Enclosure.MIMEType.aiff.rawValue == "audio/aiff") }
    @Test("FLAC raw value") func flac() { #expect(Enclosure.MIMEType.flac.rawValue == "audio/flac") }
    @Test("M4A raw value") func m4a() { #expect(Enclosure.MIMEType.m4a.rawValue == "audio/m4a") }
    @Test("MPEG raw value") func mpeg() { #expect(Enclosure.MIMEType.mpeg.rawValue == "audio/mpeg") }
    @Test("OGG raw value") func ogg() { #expect(Enclosure.MIMEType.ogg.rawValue == "audio/ogg") }
    @Test("Opus raw value") func opus() { #expect(Enclosure.MIMEType.opus.rawValue == "audio/opus") }
    @Test("WAV raw value") func wav() { #expect(Enclosure.MIMEType.wav.rawValue == "audio/wav") }
    @Test("WebM audio raw value") func webmAudio() { #expect(Enclosure.MIMEType.webmAudio.rawValue == "audio/webm") }
    @Test("Matroska audio raw value") func mka() { #expect(Enclosure.MIMEType.matroskaAudio.rawValue == "audio/x-matroska") }
    @Test("WMA raw value") func wma() { #expect(Enclosure.MIMEType.wma.rawValue == "audio/x-ms-wma") }
    @Test("AVI raw value") func avi() { #expect(Enclosure.MIMEType.avi.rawValue == "video/x-msvideo") }
    @Test("Matroska video raw value") func mkv() { #expect(Enclosure.MIMEType.matroska.rawValue == "video/x-matroska") }
    @Test("MP4 raw value") func mp4() { #expect(Enclosure.MIMEType.mp4.rawValue == "video/mp4") }
    @Test("MPEG-TS raw value") func mpegTS() { #expect(Enclosure.MIMEType.mpegTS.rawValue == "video/MP2T") }
    @Test("M4V raw value") func m4v() { #expect(Enclosure.MIMEType.m4v.rawValue == "video/m4v") }
    @Test("QuickTime raw value") func quicktime() { #expect(Enclosure.MIMEType.quicktime.rawValue == "video/quicktime") }
    @Test("WebM video raw value") func webm() { #expect(Enclosure.MIMEType.webm.rawValue == "video/webm") }
    @Test("WMV raw value") func wmv() { #expect(Enclosure.MIMEType.wmv.rawValue == "video/x-ms-wmv") }
    @Test("3GP raw value") func threeGP() { #expect(Enclosure.MIMEType.threeGP.rawValue == "video/3gpp") }
    @Test("3GP2 raw value") func threeGP2() { #expect(Enclosure.MIMEType.threeGP2.rawValue == "video/3gpp2") }
    @Test("HLS manifest raw value") func hls() { #expect(Enclosure.MIMEType.hlsManifest.rawValue == "application/x-mpegURL") }
    @Test("HLS audio manifest raw value") func hlsAudio() { #expect(Enclosure.MIMEType.hlsAudioManifest.rawValue == "audio/mpegurl") }
    @Test("PDF raw value") func pdf() { #expect(Enclosure.MIMEType.pdf.rawValue == "application/pdf") }

    @Test("Total case count is 24") func caseCount() {
        #expect(Enclosure.MIMEType.allCases.count == 24)
    }
}

// MARK: - MIMEType Classification

@Suite("MIMEType Classification")
struct MIMETypeClassificationTests {

    // MARK: - isVideo

    private static let videoCases: [Enclosure.MIMEType] = [
        .avi, .matroska, .mp4, .mpegTS, .m4v, .quicktime, .webm, .wmv, .threeGP, .threeGP2
    ]

    @Test("isVideo returns true for all video cases", arguments: videoCases)
    func isVideoTrue(mime: Enclosure.MIMEType) {
        #expect(mime.isVideo)
    }

    @Test("isVideo returns false for all non-video cases")
    func isVideoFalse() {
        let nonVideo = Enclosure.MIMEType.allCases.filter { !Self.videoCases.contains($0) }
        for mime in nonVideo {
            #expect(!mime.isVideo, "Expected isVideo == false for \(mime)")
        }
    }

    // MARK: - isAudio

    private static let audioCases: [Enclosure.MIMEType] = [
        .aac, .aiff, .flac, .m4a, .mpeg, .ogg, .opus, .wav, .webmAudio, .matroskaAudio, .wma, .hlsAudioManifest
    ]

    @Test("isAudio returns true for all audio cases", arguments: audioCases)
    func isAudioTrue(mime: Enclosure.MIMEType) {
        #expect(mime.isAudio)
    }

    @Test("isAudio returns false for all non-audio cases")
    func isAudioFalse() {
        let nonAudio = Enclosure.MIMEType.allCases.filter { !Self.audioCases.contains($0) }
        for mime in nonAudio {
            #expect(!mime.isAudio, "Expected isAudio == false for \(mime)")
        }
    }

    // MARK: - isHLS

    private static let hlsCases: [Enclosure.MIMEType] = [.hlsManifest, .hlsAudioManifest]

    @Test("isHLS returns true for HLS types", arguments: hlsCases)
    func isHLSTrue(mime: Enclosure.MIMEType) {
        #expect(mime.isHLS)
    }

    @Test("isHLS returns false for all non-HLS cases")
    func isHLSFalse() {
        let nonHLS = Enclosure.MIMEType.allCases.filter { !Self.hlsCases.contains($0) }
        for mime in nonHLS {
            #expect(!mime.isHLS, "Expected isHLS == false for \(mime)")
        }
    }

    // MARK: - isStreaming

    private static let streamingCases: [Enclosure.MIMEType] = [.hlsManifest, .hlsAudioManifest, .mpegTS]

    @Test("isStreaming returns true for streaming types", arguments: streamingCases)
    func isStreamingTrue(mime: Enclosure.MIMEType) {
        #expect(mime.isStreaming)
    }

    @Test("isStreaming returns false for all non-streaming cases")
    func isStreamingFalse() {
        let nonStreaming = Enclosure.MIMEType.allCases.filter { !Self.streamingCases.contains($0) }
        for mime in nonStreaming {
            #expect(!mime.isStreaming, "Expected isStreaming == false for \(mime)")
        }
    }
}

// MARK: - Enclosure Video Factories

@Suite("Enclosure Video Factories")
struct EnclosureVideoFactoryTests {

    private let validURL = "https://example.com/video.mp4"
    private let invalidURL = ""

    @Test("mov factory creates QuickTime enclosure") func movValid() throws {
        let enc = try #require(Enclosure.mov(url: validURL, length: 500_000))
        #expect(enc.type == Enclosure.MIMEType.quicktime.rawValue)
        #expect(enc.length == 500_000)
    }

    @Test("mov factory returns nil for invalid URL") func movInvalid() {
        #expect(Enclosure.mov(url: invalidURL, length: 1) == nil)
    }

    @Test("m4v factory creates M4V enclosure") func m4vValid() throws {
        let enc = try #require(Enclosure.m4v(url: validURL, length: 600_000))
        #expect(enc.type == Enclosure.MIMEType.m4v.rawValue)
        #expect(enc.length == 600_000)
    }

    @Test("m4v factory returns nil for invalid URL") func m4vInvalid() {
        #expect(Enclosure.m4v(url: invalidURL, length: 1) == nil)
    }

    @Test("webm factory creates WebM video enclosure") func webmValid() throws {
        let enc = try #require(Enclosure.webm(url: validURL, length: 700_000))
        #expect(enc.type == Enclosure.MIMEType.webm.rawValue)
        #expect(enc.length == 700_000)
    }

    @Test("webm factory returns nil for invalid URL") func webmInvalid() {
        #expect(Enclosure.webm(url: invalidURL, length: 1) == nil)
    }
}

// MARK: - Enclosure Audio Factories

@Suite("Enclosure Audio Factories")
struct EnclosureAudioFactoryTests {

    private let validURL = "https://example.com/audio.mp3"
    private let invalidURL = ""

    @Test("aac factory creates AAC enclosure") func aacValid() throws {
        let enc = try #require(Enclosure.aac(url: validURL, length: 100_000))
        #expect(enc.type == Enclosure.MIMEType.aac.rawValue)
    }

    @Test("aac factory returns nil for invalid URL") func aacInvalid() {
        #expect(Enclosure.aac(url: invalidURL, length: 1) == nil)
    }

    @Test("ogg factory creates OGG enclosure") func oggValid() throws {
        let enc = try #require(Enclosure.ogg(url: validURL, length: 200_000))
        #expect(enc.type == Enclosure.MIMEType.ogg.rawValue)
    }

    @Test("ogg factory returns nil for invalid URL") func oggInvalid() {
        #expect(Enclosure.ogg(url: invalidURL, length: 1) == nil)
    }

    @Test("opus factory creates Opus enclosure") func opusValid() throws {
        let enc = try #require(Enclosure.opus(url: validURL, length: 300_000))
        #expect(enc.type == Enclosure.MIMEType.opus.rawValue)
    }

    @Test("opus factory returns nil for invalid URL") func opusInvalid() {
        #expect(Enclosure.opus(url: invalidURL, length: 1) == nil)
    }

    @Test("wav factory creates WAV enclosure") func wavValid() throws {
        let enc = try #require(Enclosure.wav(url: validURL, length: 400_000))
        #expect(enc.type == Enclosure.MIMEType.wav.rawValue)
    }

    @Test("wav factory returns nil for invalid URL") func wavInvalid() {
        #expect(Enclosure.wav(url: invalidURL, length: 1) == nil)
    }

    @Test("flac factory creates FLAC enclosure") func flacValid() throws {
        let enc = try #require(Enclosure.flac(url: validURL, length: 500_000))
        #expect(enc.type == Enclosure.MIMEType.flac.rawValue)
    }

    @Test("flac factory returns nil for invalid URL") func flacInvalid() {
        #expect(Enclosure.flac(url: invalidURL, length: 1) == nil)
    }

    @Test("aiff factory creates AIFF enclosure") func aiffValid() throws {
        let enc = try #require(Enclosure.aiff(url: validURL, length: 600_000))
        #expect(enc.type == Enclosure.MIMEType.aiff.rawValue)
    }

    @Test("aiff factory returns nil for invalid URL") func aiffInvalid() {
        #expect(Enclosure.aiff(url: invalidURL, length: 1) == nil)
    }

    @Test("webmAudio factory creates WebM audio enclosure") func webmAudioValid() throws {
        let enc = try #require(Enclosure.webmAudio(url: validURL, length: 700_000))
        #expect(enc.type == Enclosure.MIMEType.webmAudio.rawValue)
    }

    @Test("webmAudio factory returns nil for invalid URL") func webmAudioInvalid() {
        #expect(Enclosure.webmAudio(url: invalidURL, length: 1) == nil)
    }
}

// MARK: - Enclosure HLS Factories

@Suite("Enclosure HLS Factories")
struct EnclosureHLSFactoryTests {

    private let validURL = "https://example.com/stream/master.m3u8"
    private let invalidURL = ""

    @Test("hls factory creates HLS manifest enclosure with length 0") func hlsValid() throws {
        let enc = try #require(Enclosure.hls(url: validURL, length: 0))
        #expect(enc.type == Enclosure.MIMEType.hlsManifest.rawValue)
        #expect(enc.length == 0)
    }

    @Test("hls factory returns nil for invalid URL") func hlsInvalid() {
        #expect(Enclosure.hls(url: invalidURL, length: 0) == nil)
    }

    @Test("hlsAudio factory creates HLS audio manifest enclosure with length 0") func hlsAudioValid() throws {
        let enc = try #require(Enclosure.hlsAudio(url: validURL, length: 0))
        #expect(enc.type == Enclosure.MIMEType.hlsAudioManifest.rawValue)
        #expect(enc.length == 0)
    }

    @Test("hlsAudio factory returns nil for invalid URL") func hlsAudioInvalid() {
        #expect(Enclosure.hlsAudio(url: invalidURL, length: 0) == nil)
    }
}

// MARK: - MIMEType Round-Trip

@Suite("MIMEType Round-Trip")
struct MIMETypeRoundTripTests {

    @Test("Enclosure created with MIMEType has matching type string", arguments: Enclosure.MIMEType.allCases)
    func enclosureTypeString(mime: Enclosure.MIMEType) {
        let url = makeURL("https://example.com/file")
        let enclosure = Enclosure(url: url, length: 42, mimeType: mime)
        #expect(enclosure.type == mime.rawValue)
    }

    @Test("MIMEType round-trips through rawValue", arguments: Enclosure.MIMEType.allCases)
    func rawValueRoundTrip(mime: Enclosure.MIMEType) throws {
        let reconstructed = try #require(Enclosure.MIMEType(rawValue: mime.rawValue))
        #expect(reconstructed == mime)
    }

    @Test("MIMEType returns nil for unknown raw value") func unknownRawValue() {
        #expect(Enclosure.MIMEType(rawValue: "application/octet-stream") == nil)
    }
}
