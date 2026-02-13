import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("ColorOutput Tests")
struct ColorOutputTests {

    @Test("Error wraps in red when enabled")
    func errorRed() {
        // ColorOutput.isEnabled depends on env/args, test the function directly
        let text = "test error"
        let result = ColorOutput.error(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[31m"))
            #expect(result.contains(text))
            #expect(result.contains("\u{001B}[0m"))
        } else {
            #expect(result == text)
        }
    }

    @Test("Warning wraps in yellow when enabled")
    func warningYellow() {
        let text = "test warning"
        let result = ColorOutput.warning(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[33m"))
            #expect(result.contains(text))
        } else {
            #expect(result == text)
        }
    }

    @Test("Success wraps in green when enabled")
    func successGreen() {
        let text = "all good"
        let result = ColorOutput.success(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[32m"))
            #expect(result.contains(text))
        } else {
            #expect(result == text)
        }
    }

    @Test("Bold wraps in bold when enabled")
    func boldWraps() {
        let text = "important"
        let result = ColorOutput.bold(text)
        if ColorOutput.isEnabled {
            #expect(result.contains("\u{001B}[1m"))
        } else {
            #expect(result == text)
        }
    }
}
