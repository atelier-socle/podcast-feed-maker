import Foundation
@testable import PodcastFeedMaker
import Testing

struct LastBuildDateTests {

    @Test
    func test_xmlRepresentation_shouldFormatDateAsRFC822() throws {
        // Fixed date: 26 March 2024 at 20:30:00 UTC
        let components = DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2024, month: 3, day: 26,
            hour: 20, minute: 30, second: 0
        )

        let date = components.date!
        let tag = RSSTag.LastBuildDate(date)

        let expected = "\t<lastBuildDate>Tue, 26 Mar 2024 20:30:00 +0000</lastBuildDate>"
        let result = try tag.xmlRepresentation()

        #expect(result == expected)
    }
}
