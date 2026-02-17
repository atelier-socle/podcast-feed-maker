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

struct PodcastTranscriptTests {

    // MARK: - Initialization

    @Test
    func initWithRequiredParameters() {
        let url = makeURL("https://example.com/transcript.vtt")
        let transcript = Transcript(url: url, type: "text/vtt")

        #expect(transcript.url == url)
        #expect(transcript.type == "text/vtt")
        #expect(transcript.language == nil)
        #expect(transcript.rel == nil)
    }

    @Test
    func initWithAllParameters() {
        let url = makeURL("https://example.com/transcript.vtt")
        let transcript = Transcript(
            url: url,
            type: "text/vtt",
            language: "en",
            rel: "captions"
        )

        #expect(transcript.url == url)
        #expect(transcript.type == "text/vtt")
        #expect(transcript.language == "en")
        #expect(transcript.rel == "captions")
    }

    // MARK: - TranscriptType Cases

    @Test
    func transcriptTypeVttRawValue() {
        #expect(Transcript.TranscriptType.vtt.rawValue == "text/vtt")
    }

    @Test
    func transcriptTypeSrtRawValue() {
        #expect(Transcript.TranscriptType.srt.rawValue == "application/srt")
    }

    @Test
    func transcriptTypeSubripRawValue() {
        #expect(Transcript.TranscriptType.subrip.rawValue == "application/x-subrip")
    }

    @Test
    func transcriptTypeHtmlRawValue() {
        #expect(Transcript.TranscriptType.html.rawValue == "text/html")
    }

    @Test
    func transcriptTypeJsonRawValue() {
        #expect(Transcript.TranscriptType.json.rawValue == "application/json")
    }

    @Test
    func transcriptTypeHasFiveCases() {
        #expect(Transcript.TranscriptType.allCases.count == 5)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let url1 = makeURL("https://example.com/a.vtt")
        let url2 = makeURL("https://example.com/b.srt")

        let a = Transcript(url: url1, type: "text/vtt")
        let b = Transcript(url: url1, type: "text/vtt")
        let c = Transcript(url: url2, type: "application/srt")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let url1 = makeURL("https://example.com/a.vtt")
        let url2 = makeURL("https://example.com/b.srt")

        let a = Transcript(url: url1, type: "text/vtt")
        let b = Transcript(url: url1, type: "text/vtt")
        let c = Transcript(url: url2, type: "application/srt")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithUrlAndType() {
        let transcriptURL = makeURL("https://example.com/subs.srt")
        let transcript = Transcript(
            url: transcriptURL,
            type: "application/srt"
        )

        var attrs: [(String, String)] = [("url", XMLBuilder.encodeURL(transcript.url)), ("type", transcript.type)]
        if let language = transcript.language { attrs.append(("language", language)) }
        if let rel = transcript.rel { attrs.append(("rel", rel)) }
        let xml = XMLBuilder().selfClosingElement("podcast:transcript", attributes: attrs)

        #expect(xml.contains("podcast:transcript"))
        #expect(xml.contains(#"url="https://example.com/subs.srt""#))
        #expect(xml.contains(#"type="application/srt""#))
    }

    @Test
    func xmlRepresentationWithLanguageAndRel() {
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let transcript = Transcript(
            url: transcriptURL,
            type: "text/vtt",
            language: "en",
            rel: "captions"
        )

        var attrs: [(String, String)] = [("url", XMLBuilder.encodeURL(transcript.url)), ("type", transcript.type)]
        if let language = transcript.language { attrs.append(("language", language)) }
        if let rel = transcript.rel { attrs.append(("rel", rel)) }
        let xml = XMLBuilder().selfClosingElement("podcast:transcript", attributes: attrs)

        #expect(xml.contains("podcast:transcript"))
        #expect(xml.contains(#"language="en""#))
        #expect(xml.contains(#"rel="captions""#))
    }

    @Test
    func xmlRepresentationIsSelfClosingTag() {
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let transcript = Transcript(
            url: transcriptURL,
            type: "text/vtt"
        )

        var attrs: [(String, String)] = [("url", XMLBuilder.encodeURL(transcript.url)), ("type", transcript.type)]
        if let language = transcript.language { attrs.append(("language", language)) }
        if let rel = transcript.rel { attrs.append(("rel", rel)) }
        let xml = XMLBuilder().selfClosingElement("podcast:transcript", attributes: attrs)

        #expect(xml.contains("/>"))
    }

    @Test
    func xmlRepresentationWithoutOptionalAttributes() {
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let transcript = Transcript(
            url: transcriptURL,
            type: "text/vtt"
        )

        var attrs: [(String, String)] = [("url", XMLBuilder.encodeURL(transcript.url)), ("type", transcript.type)]
        if let language = transcript.language { attrs.append(("language", language)) }
        if let rel = transcript.rel { attrs.append(("rel", rel)) }
        let xml = XMLBuilder().selfClosingElement("podcast:transcript", attributes: attrs)

        #expect(!xml.contains("language="))
        #expect(!xml.contains("rel="))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Transcript.self)
    }
}
