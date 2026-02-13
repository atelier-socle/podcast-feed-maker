import Foundation
import Testing

@testable import PodcastFeedMaker

struct PodcastTranscriptTests {

    // MARK: - Initialization

    @Test
    func initWithRequiredParameters() throws {
        let url = try #require(URL(string: "https://example.com/transcript.vtt"))
        let transcript = Transcript(url: url, type: "text/vtt")

        #expect(transcript.url == url)
        #expect(transcript.type == "text/vtt")
        #expect(transcript.language == nil)
        #expect(transcript.rel == nil)
    }

    @Test
    func initWithAllParameters() throws {
        let url = try #require(URL(string: "https://example.com/transcript.vtt"))
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
    func equatableConformance() throws {
        let url1 = try #require(URL(string: "https://example.com/a.vtt"))
        let url2 = try #require(URL(string: "https://example.com/b.srt"))

        let a = Transcript(url: url1, type: "text/vtt")
        let b = Transcript(url: url1, type: "text/vtt")
        let c = Transcript(url: url2, type: "application/srt")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() throws {
        let url1 = try #require(URL(string: "https://example.com/a.vtt"))
        let url2 = try #require(URL(string: "https://example.com/b.srt"))

        let a = Transcript(url: url1, type: "text/vtt")
        let b = Transcript(url: url1, type: "text/vtt")
        let c = Transcript(url: url2, type: "application/srt")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithUrlAndType() throws {
        let transcriptURL = try #require(URL(string: "https://example.com/subs.srt"))
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
    func xmlRepresentationWithLanguageAndRel() throws {
        let transcriptURL = try #require(URL(string: "https://example.com/ep1.vtt"))
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
    func xmlRepresentationIsSelfClosingTag() throws {
        let transcriptURL = try #require(URL(string: "https://example.com/ep1.vtt"))
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
    func xmlRepresentationWithoutOptionalAttributes() throws {
        let transcriptURL = try #require(URL(string: "https://example.com/ep1.vtt"))
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
