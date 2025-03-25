import Foundation

/// Extension for formatting `Date` into the RFC 822 date format.
///
/// This format is used in RSS feeds to represent publication dates
/// via the `<pubDate>` tag as per the [RSS 2.0 specification](https://validator.w3.org/feed/docs/rss2.html#pubdate).
///
/// - Important: The resulting string is always formatted in GMT (UTC+0).
package extension Date {

    /// The RFC 822-formatted string representation of the date.
    ///
    /// Used specifically for `<pubDate>` in podcast feeds.
    ///
    /// - Returns: A string in the format `"EEE, dd LLL yyyy HH:mm:ss ZZZ"`, e.g. `"Tue, 26 Mar 2024 16:20:00 +0000"`.
    ///
    /// - SeeAlso: [RFC 822 Date and Time Specification](https://www.rfc-editor.org/rfc/rfc822)
    var rcfPubDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss ZZZ"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .gmt
        return formatter.string(from: self)
    }
}
