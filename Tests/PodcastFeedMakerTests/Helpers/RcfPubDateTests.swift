import Foundation
@testable import PodcastFeedMaker
import Testing

struct RcfPubDateTests {

    @Test
    func test_rfc2822Date_returnsCorrectFormat() {
        // Fixed reference date: 1 January 2024 at 15:30:45 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1
        components.hour = 15
        components.minute = 30
        components.second = 45
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar(identifier: .gregorian)
        let date = calendar.date(from: components)!

        let expected = "Mon, 01 Jan 2024 15:30:45 +0000"
        #expect(XMLBuilder.rfc2822Date(date) == expected)
    }

    @Test
    func test_rfc2822Date_respectsEnglishLocale() {
        // We check that even on non-English devices, the weekday and month are in English
        let date = ISO8601DateFormatter().date(from: "2025-03-26T18:00:00Z")!
        let result = XMLBuilder.rfc2822Date(date)

        // Expected starts with English weekday and month
        #expect(result.starts(with: "Wed, 26 Mar 2025"))
    }
}
