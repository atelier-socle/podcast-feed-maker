import Foundation

/// Multi-format date parser for podcast feeds.
///
/// Podcast feeds use inconsistent date formats. `DateParser` tries
/// multiple known formats in order of likelihood: RFC 2822 first,
/// then ISO 8601, then common non-standard formats.
///
/// Uses manual parsing for Linux compatibility (avoids `DateFormatter`
/// locale issues on swift-corelibs-foundation).
public struct DateParser: Sendable {

    // MARK: - Public API

    /// Attempts to parse a date string using multiple known formats.
    ///
    /// - Parameter string: The date string to parse.
    /// - Returns: A `Date` if parsing succeeded, or `nil`.
    public static func parse(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        return parseRFC2822(trimmed)
            ?? parseISO8601(trimmed)
            ?? parseCommonFormats(trimmed)
    }

    // MARK: - RFC 2822

    /// Parses an RFC 2822 date string.
    ///
    /// Handles variants: with/without day name, 2/4-digit year,
    /// timezone abbreviations and numeric offsets.
    ///
    /// - Parameter string: The date string.
    /// - Returns: A `Date` if parsing succeeded.
    static func parseRFC2822(_ string: String) -> Date? {
        // Strip optional day name: "Tue, 18 Mar 2025 ..." → "18 Mar 2025 ..."
        var s = string
        if let commaRange = s.range(of: ",") {
            s = String(s[commaRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        }

        let parts = s.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        // Expected: "18 Mar 2025 19:20:15 +0000" → 5 parts
        guard parts.count >= 4 else { return nil }

        guard let day = Int(parts[0]) else { return nil }
        guard let month = monthNumber(parts[1]) else { return nil }

        var year = 0
        if let y = Int(parts[2]) {
            year = y < 100 ? (y < 50 ? 2000 + y : 1900 + y) : y
        } else {
            return nil
        }

        let timeParts = parts[3].split(separator: ":").compactMap { Int($0) }
        guard timeParts.count >= 2 else { return nil }
        let hour = timeParts[0]
        let minute = timeParts[1]
        let second = timeParts.count >= 3 ? timeParts[2] : 0

        let tzOffset: Int
        if parts.count >= 5 {
            tzOffset = parseTimezoneOffset(parts[4])
        } else {
            tzOffset = 0
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second

        guard let date = calendar.date(from: components) else { return nil }
        return date.addingTimeInterval(TimeInterval(-tzOffset))
    }

    // MARK: - ISO 8601

    /// Parses an ISO 8601 date string.
    ///
    /// Handles variants: with Z suffix, with offset (+01:00 or +0100),
    /// with/without milliseconds, with/without T separator.
    ///
    /// - Parameter string: The date string.
    /// - Returns: A `Date` if parsing succeeded.
    static func parseISO8601(_ string: String) -> Date? {
        // Must contain at least a date portion: yyyy-MM-dd
        guard string.count >= 10, string.contains("-") else { return nil }

        let (stripped, tzOffset) = stripISO8601Timezone(string)
        let s = stripped.replacingOccurrences(of: "T", with: " ")

        let mainParts = s.split(separator: " ", maxSplits: 1).map(String.init)
        guard let datePart = mainParts.first else { return nil }

        let datePieces = datePart.split(separator: "-").compactMap { Int($0) }
        guard datePieces.count == 3 else { return nil }

        let time =
            mainParts.count >= 2
            ? parseTimePart(mainParts[1])
            : TimeParts(hour: 0, minute: 0, second: 0)

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        var components = DateComponents()
        components.year = datePieces[0]
        components.month = datePieces[1]
        components.day = datePieces[2]
        components.hour = time.hour
        components.minute = time.minute
        components.second = time.second

        guard let date = calendar.date(from: components) else { return nil }
        return date.addingTimeInterval(TimeInterval(-tzOffset))
    }

    /// Strips the timezone suffix from an ISO 8601 string, returning
    /// the stripped string and the timezone offset in seconds.
    private static func stripISO8601Timezone(
        _ string: String
    ) -> (String, Int) {
        var s = string
        if s.hasSuffix("Z") {
            return (String(s.dropLast()), 0)
        }
        let searchStart =
            s.index(
                s.startIndex, offsetBy: 10, limitedBy: s.endIndex
            ) ?? s.endIndex
        if let plusRange = s.range(
            of: "+", options: .backwards,
            range: searchStart..<s.endIndex
        ) {
            let tzStr = String(s[plusRange.upperBound...])
            let offset = parseISO8601Offset(tzStr)
            s = String(s[..<plusRange.lowerBound])
            return (s, offset)
        }
        if let minusIdx = findISO8601MinusTimezone(s) {
            let tzStr = String(s[s.index(after: minusIdx)...])
            let offset = -parseISO8601Offset(tzStr)
            s = String(s[..<minusIdx])
            return (s, offset)
        }
        return (s, 0)
    }

    private struct TimeParts {
        let hour: Int
        let minute: Int
        let second: Int
    }

    /// Parses a time string like "14:30:00" or "14:30:00.123".
    private static func parseTimePart(
        _ string: String
    ) -> TimeParts {
        var timePart = string
        if let dotIdx = timePart.firstIndex(of: ".") {
            timePart = String(timePart[..<dotIdx])
        }
        let pieces = timePart.split(separator: ":").compactMap { Int($0) }
        return TimeParts(
            hour: pieces.count >= 1 ? pieces[0] : 0,
            minute: pieces.count >= 2 ? pieces[1] : 0,
            second: pieces.count >= 3 ? pieces[2] : 0
        )
    }

    // MARK: - Common Non-Standard Formats

    /// Attempts to parse common non-standard date formats.
    ///
    /// - Parameter string: The date string.
    /// - Returns: A `Date` if parsing succeeded.
    static func parseCommonFormats(_ string: String) -> Date? {
        // "February 12, 2026"
        if let date = parseLongMonthFormat(string) { return date }

        // "2026/02/12"
        if let date = parseSlashFormat(string) { return date }

        // "12 Feb 2026"
        if let date = parseDayMonthYear(string) { return date }

        return nil
    }

    // MARK: - Private Helpers

    private static let monthNames: [String: Int] = [
        "jan": 1, "feb": 2, "mar": 3, "apr": 4, "may": 5, "jun": 6,
        "jul": 7, "aug": 8, "sep": 9, "oct": 10, "nov": 11, "dec": 12,
        "january": 1, "february": 2, "march": 3, "april": 4,
        "june": 6, "july": 7, "august": 8, "september": 9,
        "october": 10, "november": 11, "december": 12
    ]

    private static func monthNumber(_ string: String) -> Int? {
        monthNames[string.lowercased()]
    }

    private static let timezoneAbbreviations: [String: Int] = [
        "GMT": 0, "UTC": 0, "UT": 0, "Z": 0,
        "EST": -5 * 3600, "EDT": -4 * 3600,
        "CST": -6 * 3600, "CDT": -5 * 3600,
        "MST": -7 * 3600, "MDT": -6 * 3600,
        "PST": -8 * 3600, "PDT": -7 * 3600,
        "CET": 1 * 3600, "CEST": 2 * 3600,
        "JST": 9 * 3600, "KST": 9 * 3600,
        "IST": 5 * 3600 + 1800, "AEST": 10 * 3600
    ]

    private static func parseTimezoneOffset(_ string: String) -> Int {
        // Numeric offset: "+0000", "-0500", "+01:00"
        let clean = string.replacingOccurrences(of: ":", with: "")
        if let numeric = Int(clean), clean.count >= 4 {
            let hours = numeric / 100
            let minutes = numeric % 100
            return hours * 3600 + minutes * 60
        }
        // Named timezone: "EST", "PST", "GMT"
        return timezoneAbbreviations[string.uppercased()] ?? 0
    }

    private static func parseISO8601Offset(_ string: String) -> Int {
        let clean = string.replacingOccurrences(of: ":", with: "")
        let digits = clean.prefix(4)
        guard digits.count >= 2 else { return 0 }
        let hours = Int(digits.prefix(2)) ?? 0
        let minutes = digits.count >= 4 ? (Int(digits.suffix(2)) ?? 0) : 0
        return hours * 3600 + minutes * 60
    }

    /// Finds the minus sign that starts a timezone offset (not part of the date).
    private static func findISO8601MinusTimezone(_ string: String) -> String.Index? {
        // The timezone minus must be after the time portion (after index 16+)
        guard string.count >= 16 else { return nil }
        let searchStart =
            string.index(string.startIndex, offsetBy: 16, limitedBy: string.endIndex)
            ?? string.endIndex
        return string.range(of: "-", range: searchStart..<string.endIndex)?.lowerBound
    }

    private static func parseLongMonthFormat(_ string: String) -> Date? {
        // "February 12, 2026" or "February 12 2026"
        let parts =
            string
            .replacingOccurrences(of: ",", with: "")
            .split(separator: " ", omittingEmptySubsequences: true)
            .map(String.init)
        guard parts.count >= 3,
            let month = monthNumber(parts[0]),
            let day = Int(parts[1]),
            let year = Int(parts[2])
        else { return nil }

        return makeDate(year: year, month: month, day: day)
    }

    private static func parseSlashFormat(_ string: String) -> Date? {
        // "2026/02/12"
        let parts = string.split(separator: "/").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        return makeDate(year: parts[0], month: parts[1], day: parts[2])
    }

    private static func parseDayMonthYear(_ string: String) -> Date? {
        // "12 Feb 2026"
        let parts = string.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard parts.count >= 3,
            let day = Int(parts[0]),
            let month = monthNumber(parts[1]),
            let year = Int(parts[2])
        else { return nil }
        return makeDate(year: year, month: month, day: day)
    }

    private static func makeDate(year: Int, month: Int, day: Int) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return calendar.date(from: components)
    }
}
