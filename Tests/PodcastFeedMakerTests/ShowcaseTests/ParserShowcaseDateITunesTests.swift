import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Date Parser Showcase

@Suite("Date Parser Showcase")
struct DateParserShowcase {

    @Test("DateParser — RFC 2822 full format with day name")
    func parseRFC2822Full() throws {
        let date = DateParser.parse("Mon, 10 Feb 2025 12:00:00 +0000")
        #expect(date != nil)

        // Verify the parsed date is 2025-02-10 12:00:00 UTC
        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            #expect(components.year == 2025)
            #expect(components.month == 2)
            #expect(components.day == 10)
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — RFC 2822 without day name")
    func parseRFC2822NoDayName() {
        let date = DateParser.parse("10 Feb 2025 12:00:00 +0000")
        #expect(date != nil)
    }

    @Test("DateParser — RFC 2822 with timezone abbreviation")
    func parseRFC2822Timezone() throws {
        // PST is UTC-8
        let date = DateParser.parse("Mon, 10 Feb 2025 04:00:00 PST")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.hour], from: date)
            // 04:00 PST = 12:00 UTC
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — RFC 2822 with negative offset")
    func parseRFC2822NegativeOffset() throws {
        let date = DateParser.parse("Tue, 11 Mar 2025 09:30:00 -0500")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.hour, .minute], from: date)
            // 09:30 -0500 = 14:30 UTC
            #expect(components.hour == 14)
            #expect(components.minute == 30)
        }
    }

    @Test("DateParser — RFC 2822 with two-digit year")
    func parseRFC2822TwoDigitYear() throws {
        // Two-digit year: < 50 maps to 2000s
        let date = DateParser.parse("10 Feb 25 12:00:00 GMT")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year], from: date)
            #expect(components.year == 2025)
        }
    }

    @Test("DateParser — ISO 8601 with Z suffix")
    func parseISO8601Z() throws {
        let date = DateParser.parse("2025-02-10T12:00:00Z")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
            #expect(components.year == 2025)
            #expect(components.month == 2)
            #expect(components.day == 10)
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — ISO 8601 with positive offset")
    func parseISO8601Offset() throws {
        let date = DateParser.parse("2025-02-10T14:00:00+02:00")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.hour], from: date)
            // 14:00 +0200 = 12:00 UTC
            #expect(components.hour == 12)
        }
    }

    @Test("DateParser — ISO 8601 date only (no time)")
    func parseISO8601DateOnly() throws {
        let date = DateParser.parse("2025-02-10")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == 2025)
            #expect(components.month == 2)
            #expect(components.day == 10)
        }
    }

    @Test("DateParser — ISO 8601 with milliseconds")
    func parseISO8601Millis() {
        let date = DateParser.parse("2025-02-10T12:00:00.123Z")
        #expect(date != nil)
    }

    @Test("DateParser — common format: long month name")
    func parseLongMonth() throws {
        let date = DateParser.parse("February 12, 2026")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == 2026)
            #expect(components.month == 2)
            #expect(components.day == 12)
        }
    }

    @Test("DateParser — common format: slash-separated date")
    func parseSlashFormat() throws {
        let date = DateParser.parse("2026/02/12")
        #expect(date != nil)

        if let date {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = try #require(TimeZone(secondsFromGMT: 0))
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            #expect(components.year == 2026)
            #expect(components.month == 2)
            #expect(components.day == 12)
        }
    }

    @Test("DateParser — common format: day month year")
    func parseDayMonthYear() {
        let date = DateParser.parse("12 Feb 2026")
        #expect(date != nil)
    }

    @Test("DateParser — returns nil for empty string")
    func parseEmpty() {
        #expect(DateParser.parse("") == nil)
        #expect(DateParser.parse("   ") == nil)
    }

    @Test("DateParser — returns nil for gibberish")
    func parseGibberish() {
        #expect(DateParser.parse("not a date") == nil)
        #expect(DateParser.parse("yesterday") == nil)
    }

    @Test("DateParser — generator and parser roundtrip for RFC 2822 dates")
    func rfc2822Roundtrip() {
        let original = Date(timeIntervalSince1970: 1_739_404_800)
        let formatted = XMLBuilder.rfc2822Date(original)
        let parsed = DateParser.parse(formatted)

        #expect(parsed != nil)
        if let parsed {
            // Allow 1-second tolerance for rounding
            #expect(abs(parsed.timeIntervalSince(original)) < 1.0)
        }
    }
}

// MARK: - iTunes Parsing Showcase

@Suite("iTunes Parsing Showcase")
struct ITunesParsingShowcase {

    @Test("FeedParser — iTunes explicit true/false values")
    func parseExplicitTrueFalse() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:explicit>true</itunes:explicit>
                    <item>
                        <title>Ep</title>
                        <itunes:explicit>false</itunes:explicit>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesExplicit == true)
        #expect(channel.items[0].itunesExplicit == false)
    }

    @Test("FeedParser — iTunes explicit yes/no legacy values")
    func parseExplicitYesNo() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:explicit>yes</itunes:explicit>
                    <item>
                        <title>Ep</title>
                        <itunes:explicit>no</itunes:explicit>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesExplicit == true)
        #expect(channel.items[0].itunesExplicit == false)
    }

    @Test("FeedParser — iTunes duration as integer seconds")
    func parseDurationSeconds() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Ep</title>
                        <itunes:duration>3600</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        #expect(item.itunesDuration == 3600)
    }

    @Test("FeedParser — iTunes duration in HH:MM:SS format")
    func parseDurationHHMMSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Ep</title>
                        <itunes:duration>01:30:15</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        // 1*3600 + 30*60 + 15 = 5415
        #expect(item.itunesDuration == 5415)
    }

    @Test("FeedParser — iTunes duration in MM:SS format")
    func parseDurationMMSS() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Ep</title>
                        <itunes:duration>45:30</itunes:duration>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let item = try #require(feed.channel?.items.first)
        // 45*60 + 30 = 2730
        #expect(item.itunesDuration == 2730)
    }

    @Test("FeedParser — iTunes block yes/no values")
    func parseITunesBlock() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:block>yes</itunes:block>
                    <item>
                        <title>Ep</title>
                        <itunes:block>no</itunes:block>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesBlock == true)
        #expect(channel.items[0].itunesBlock == false)
    }

    @Test("FeedParser — iTunes category with subcategory")
    func parseITunesCategory() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:category text="Technology">
                        <itunes:category text="Podcasting" />
                    </itunes:category>
                    <itunes:category text="Comedy" />
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesCategories.count == 2)
        #expect(channel.itunesCategories[0].text == "Technology")
        #expect(channel.itunesCategories[0].subcategories.count == 1)
        #expect(channel.itunesCategories[0].subcategories[0].text == "Podcasting")
        #expect(channel.itunesCategories[1].text == "Comedy")
    }

    @Test("FeedParser — iTunes owner with name and email")
    func parseITunesOwner() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:owner>
                        <itunes:name>Jane Doe</itunes:name>
                        <itunes:email>jane@example.com</itunes:email>
                    </itunes:owner>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.itunesOwner?.name == "Jane Doe")
        #expect(channel.itunesOwner?.email == "jane@example.com")
    }

    @Test("FeedParser — iTunes show type")
    func parseITunesType() throws {
        let serialXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <itunes:type>serial</itunes:type>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(serialXML)
        #expect(feed.channel?.itunesType == .serial)
    }

    @Test("FeedParser — iTunes episode type")
    func parseITunesEpisodeType() throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
                <channel>
                    <title>Show</title>
                    <link>https://example.com</link>
                    <description>Test.</description>
                    <item>
                        <title>Trailer</title>
                        <itunes:episodeType>trailer</itunes:episodeType>
                    </item>
                    <item>
                        <title>Bonus</title>
                        <itunes:episodeType>bonus</itunes:episodeType>
                    </item>
                    <item>
                        <title>Full</title>
                        <itunes:episodeType>full</itunes:episodeType>
                    </item>
                </channel>
            </rss>
            """
        let feed = try FeedParser().parse(xml)
        let items = try #require(feed.channel?.items)
        #expect(items.count == 3)
        #expect(items[0].itunesEpisodeType == .trailer)
        #expect(items[1].itunesEpisodeType == .bonus)
        #expect(items[2].itunesEpisodeType == .full)
    }
}
