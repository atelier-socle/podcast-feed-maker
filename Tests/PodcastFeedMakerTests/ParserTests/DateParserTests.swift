import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("DateParser Tests")
struct DateParserTests {

    // MARK: - RFC 2822

    @Test("Parses RFC 2822 date with day name")
    func rfc2822WithDayName() {
        let date = DateParser.parse(
            "Thu, 12 Feb 2026 14:30:00 +0000"
        )
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date ?? Date()
        )
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 12)
        #expect(components.hour == 14)
        #expect(components.minute == 30)
    }

    @Test("Parses RFC 2822 date without day name")
    func rfc2822WithoutDayName() {
        let date = DateParser.parse("12 Feb 2026 14:30:00 +0000")
        #expect(date != nil)
    }

    @Test("Parses RFC 2822 date with timezone abbreviation")
    func rfc2822WithTimezoneAbbrev() {
        let date = DateParser.parse(
            "Mon, 10 Feb 2025 10:00:00 EST"
        )
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.hour], from: date ?? Date()
        )
        #expect(components.hour == 15) // EST = -5h → 10:00 + 5 = 15:00 UTC
    }

    @Test("Parses RFC 2822 date with negative offset")
    func rfc2822NegativeOffset() {
        let date = DateParser.parse(
            "Mon, 01 Jan 2025 00:00:00 -0500"
        )
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.hour], from: date ?? Date()
        )
        #expect(components.hour == 5) // -0500 → 00:00 + 5 = 05:00 UTC
    }

    @Test("Parses RFC 2822 date with 2-digit year")
    func rfc2822TwoDigitYear() {
        let date = DateParser.parseRFC2822("12 Feb 25 14:30:00 GMT")
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.year], from: date ?? Date()
        )
        #expect(components.year == 2025)
    }

    // MARK: - ISO 8601

    @Test("Parses ISO 8601 with Z suffix")
    func iso8601WithZ() {
        let date = DateParser.parse("2026-02-12T20:00:00Z")
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour],
            from: date ?? Date()
        )
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 12)
        #expect(components.hour == 20)
    }

    @Test("Parses ISO 8601 with positive offset")
    func iso8601PositiveOffset() {
        let date = DateParser.parse("2026-02-12T20:00:00+01:00")
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.hour], from: date ?? Date()
        )
        #expect(components.hour == 19) // +01:00 → 20:00 - 1 = 19:00 UTC
    }

    @Test("Parses ISO 8601 with milliseconds")
    func iso8601WithMilliseconds() {
        let date = DateParser.parse("2026-02-12T20:00:00.000Z")
        #expect(date != nil)
    }

    @Test("Parses ISO 8601 date only")
    func iso8601DateOnly() {
        let date = DateParser.parse("2025-01-01")
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.year, .month, .day], from: date ?? Date()
        )
        #expect(components.year == 2025)
        #expect(components.month == 1)
        #expect(components.day == 1)
    }

    // MARK: - Common Formats

    @Test("Parses long month format")
    func longMonthFormat() {
        let date = DateParser.parse("February 12, 2026")
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.year, .month, .day], from: date ?? Date()
        )
        #expect(components.year == 2026)
        #expect(components.month == 2)
        #expect(components.day == 12)
    }

    @Test("Parses slash format")
    func slashFormat() {
        let date = DateParser.parse("2026/02/12")
        #expect(date != nil)
        let components = calendar.dateComponents(
            [.year, .month, .day], from: date ?? Date()
        )
        #expect(components.year == 2026)
        #expect(components.month == 2)
    }

    @Test("Parses day month year format")
    func dayMonthYear() {
        let date = DateParser.parse("12 Feb 2026")
        #expect(date != nil)
    }

    // MARK: - Edge Cases

    @Test("Returns nil for empty string")
    func emptyString() {
        #expect(DateParser.parse("") == nil)
    }

    @Test("Returns nil for whitespace only")
    func whitespaceOnly() {
        #expect(DateParser.parse("   ") == nil)
    }

    @Test("Returns nil for garbage input")
    func garbageInput() {
        #expect(DateParser.parse("not a date") == nil)
    }

    @Test("Trims whitespace before parsing")
    func trimsWhitespace() {
        let date = DateParser.parse(
            "  2026-02-12T20:00:00Z  "
        )
        #expect(date != nil)
    }

    // MARK: - Helpers

    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return cal
    }
}
