import Foundation
@testable import PodcastFeedMaker
import Testing

struct PubDateTests {
    
    @Test
    func test_xmlRepresentation_shouldFormatRFC822Correctly() throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let date = formatter.date(from: "2025-03-24 18:30:00")!
        let tag = RSSTag.PubDate(date)
        
        let result = try tag.xmlRepresentation()
        let expected = "\t<pubDate>Mon, 24 Mar 2025 18:30:00 +0000</pubDate>"

        #expect(result == expected)
        // RFC 822 string may vary slightly in timezone ("+0000" vs "-0000"), accept both
        #expect(result.contains("Mon, 24 Mar 2025 18:30:00"))
        #expect(result.contains("<pubDate>"))
        #expect(result.contains("</pubDate>"))
    }

    @Test
    func test_equatable_conformance() {
        let date1 = Date(timeIntervalSince1970: 100)
        let date2 = Date(timeIntervalSince1970: 200)

        let tag1 = RSSTag.PubDate(date1)
        let tag2 = RSSTag.PubDate(date1)
        let tag3 = RSSTag.PubDate(date2)

        #expect(tag1 == tag2)
        #expect(tag1 != tag3)
    }

    @Test
    func test_hashable_conformance() {
        let date = Date(timeIntervalSince1970: 100)
        let tag = RSSTag.PubDate(date)
        let set: Set = [tag]

        #expect(set.contains(tag))
    }
}
