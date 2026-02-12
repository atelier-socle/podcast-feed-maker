import Foundation
@testable import PodcastFeedMaker
import Testing

@Suite("GeneratorError Tests")
struct GeneratorErrorTests {

    @Test("missingChannel errorDescription")
    func missingChannelDescription() {
        let error = GeneratorError.missingChannel
        #expect(error.errorDescription?.contains("Missing channel") == true)
    }

    @Test("invalidURL errorDescription includes context and URL")
    func invalidURLDescription() {
        let error = GeneratorError.invalidURL("enclosure", "not-a-url")
        #expect(error.errorDescription?.contains("enclosure") == true)
        #expect(error.errorDescription?.contains("not-a-url") == true)
    }

    @Test("encodingError errorDescription includes message")
    func encodingErrorDescription() {
        let error = GeneratorError.encodingError("UTF-8 failure")
        #expect(error.errorDescription?.contains("UTF-8 failure") == true)
    }

    @Test("GeneratorError conforms to Equatable")
    func equatable() {
        #expect(GeneratorError.missingChannel == GeneratorError.missingChannel)
        #expect(
            GeneratorError.invalidURL("a", "b") == GeneratorError.invalidURL("a", "b")
        )
        #expect(
            GeneratorError.invalidURL("a", "b") != GeneratorError.invalidURL("c", "d")
        )
    }
}
