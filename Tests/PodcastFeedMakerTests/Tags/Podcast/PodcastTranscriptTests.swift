import Foundation
@testable import PodcastFeedMaker
import Testing

struct PodcastTranscriptTests {

    @Test
    func test_init_withTranscriptType_setsCorrectType() {
        let url = URL(string: "https://example.com/transcript.vtt")!
        let transcript = Namespace.Podcast.Transcript(url: url, type: .vtt)

        #expect(transcript.url == url)
        #expect(transcript.type == "text/vtt")
    }

    @Test
    func test_xmlRepresentation_generatesExpectedXML() throws {
        let url = URL(string: "https://example.com/subs.srt")!
        let transcript = Namespace.Podcast.Transcript(url: url, type: .srt)

        let xml = try transcript.xmlRepresentation()
        #expect(xml.contains(#"<podcast:transcript url="https://example.com/subs.srt" type="application/srt""#))
    }

    @Test
    func test_xmlRepresentation_throwsIfURLInvalid() {
        let url = URL(string: "file:///Users/local.srt")!
        let transcript = Namespace.Podcast.Transcript(url: url, type: .vtt)

        #expect(throws: URL.URLValidatorError.self) {
            try transcript.xmlRepresentation()
        }
    }

    @Test
    func test_xmlRepresentation_throwsIfTypeInvalid() {
        let url = URL(string: "https://example.com/subs.txt")!
        let transcript = Namespace.Podcast.Transcript(url: url, type: "text/plain")

        #expect(throws: Namespace.Podcast.Transcript.TranscriptTypeError.self) {
            try transcript.xmlRepresentation()
        }
    }

    @Test
    func test_transcriptTypeRawValues_areCorrect() {
        #expect(Namespace.Podcast.Transcript.TranscriptType.vtt.rawValue == "text/vtt")
        #expect(Namespace.Podcast.Transcript.TranscriptType.srt.rawValue == "application/srt")
        #expect(Namespace.Podcast.Transcript.TranscriptType.subrip.rawValue == "application/x-subrip")
    }

    @Test
    func test_transcriptTypeErrorDescription() {
        let error = Namespace.Podcast.Transcript.TranscriptTypeError.invalidType
        #expect(error.localizedDescription == "Invalid transcript type")
    }
}
