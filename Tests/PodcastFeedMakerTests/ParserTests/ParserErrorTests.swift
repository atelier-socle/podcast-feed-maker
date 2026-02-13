import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("ParserError Tests")
struct ParserErrorTests {

    @Test("invalidXML errorDescription includes detail")
    func invalidXMLDescription() {
        let error = ParserError.invalidXML("unexpected token")
        #expect(error.errorDescription == "Invalid XML: unexpected token")
    }

    @Test("missingRSSElement errorDescription")
    func missingRSSElementDescription() {
        let error = ParserError.missingRSSElement
        #expect(error.errorDescription == "Missing <rss> root element")
    }

    @Test("missingChannel errorDescription")
    func missingChannelDescription() {
        let error = ParserError.missingChannel
        #expect(error.errorDescription == "Missing <channel> element")
    }

    @Test("encodingError errorDescription includes detail")
    func encodingErrorDescription() {
        let error = ParserError.encodingError("Invalid UTF-8")
        #expect(error.errorDescription == "Encoding error: Invalid UTF-8")
    }

    @Test("networkError errorDescription includes detail")
    func networkErrorDescription() {
        let error = ParserError.networkError("Connection refused")
        #expect(error.errorDescription == "Network error: Connection refused")
    }

    @Test("ParserError conforms to Equatable")
    func equatable() {
        #expect(ParserError.missingChannel == ParserError.missingChannel)
        #expect(ParserError.invalidXML("a") != ParserError.invalidXML("b"))
        #expect(ParserError.missingChannel != ParserError.missingRSSElement)
    }
}
