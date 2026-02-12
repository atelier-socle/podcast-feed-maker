import Foundation

// MARK: - Legacy Helpers
//
// This file preserves the helper utilities extracted from the original
// Helpers/ directory. Each extension provides formatting, escaping, or
// validation logic used by the legacy XML generation layer.
//
// When the full FeedGenerator is implemented (sync + streaming),
// this file should be replaced by proper Generator-layer code.

// MARK: - Boolean Formatter

/// Extension converting a `Bool` value to a string representation expected in podcast RSS tags.
///
/// Certain RSS tags, particularly in the iTunes and Podcast namespaces,
/// expect `yes` or `no` string values rather than `true` or `false`.
///
/// - Examples:
///     - `<itunes:explicit>yes</itunes:explicit>`
///     - `<itunes:block>no</itunes:block>`
package extension Bool {

    /// A `String` representation of the boolean, as `"yes"` or `"no"`.
    ///
    /// - Returns: `"yes"` if `true`, otherwise `"no"`.
    var stringValue: String {
        self ? "yes" : "no"
    }
}

// MARK: - RFC 822 Pub Date

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

// MARK: - Special Characters Escaping

/// Extension to sanitize strings for XML output in RSS feeds.
///
/// This utility replaces problematic or non-XML-safe characters (such as `&`, `<`, `©`, `™`, etc.)
/// with their corresponding XML entity codes to ensure the resulting feed remains valid.
///
/// - Important: Use this before embedding user-facing content (titles, descriptions, summaries)
///   into XML tags that do **not** support CDATA.
///
/// - SeeAlso:
///   - [`RSS 2.0 XML Encoding`](https://validator.w3.org/feed/docs/rss2.html#ltgtProblem)
///   - `cleanSpecialChars()`
package extension String {

    /// Escapes special characters in the string to ensure it is safe for XML rendering.
    ///
    /// Prevents re-escaping valid XML entities like `&amp;`, `&quot;`, etc.
    ///
    /// This is particularly important when using `.text` type descriptions that are not wrapped in CDATA.
    ///
    /// - Returns: A sanitized version of the original string with all replacements applied.
    func cleanSpecialChars() -> String {
        var result = self

        // swiftlint:disable force_try
        let replacements: [(Regex<Substring>, String)] = [
            // specifics first.
            (try! Regex(#"&copy;"#), "&#xA9;"),
            (try! Regex(#"©"#), "&#xA9;"),
            (try! Regex(#"℗"#), "&#x2117;"),
            (try! Regex(#"™"#), "&#x2122;"),

            // then XML standards chars.
            (try! Regex(#"<"#), "&lt;"),
            (try! Regex(#">"#), "&gt;"),
            (try! Regex(#"\u{2019}"#), "&apos;"),
            (try! Regex(#"[\u{201C}\u{201D}]"#), "&quot;"),
            (try! Regex(#"\u{0022}"#), "&quot;"),

            // finally.
            (try! Regex(#"&(?!amp;|lt;|gt;|quot;|apos;|#x[a-fA-F0-9]+;)"#), "&amp;")
        ]
        // swiftlint:enable force_try

        for (pattern, replacement) in replacements {
            result = result.replacing(pattern, with: replacement)
        }

        return result
    }
}

// MARK: - String Tags Representation

/// Extension on `[String]` to assist with proper XML indentation when rendering RSS tags.
///
/// These utilities are commonly used to format arrays of XML strings
/// (e.g., multiple `<item>` or `<itunes:category>` tags) with consistent tab-based indentation.
///
/// - Important: This is purely for visual clarity in the resulting XML feed;
/// RSS parsers do not require indentation.
package extension [String] {

    /// Formats each string in the array with a single tab of indentation (`\t`).
    ///
    /// Typically used when rendering nested XML elements (e.g., `<channel>`-level tags).
    ///
    /// - Returns: A string with each line prefixed by one tab and separated by line breaks.
    ///
    /// ### Example:
    /// ```swift
    /// ["<title>Podcast</title>", "<link>https://example.com</link>"]
    ///     .indentedTagsRepresentation
    ///
    /// // → "\t<title>Podcast</title>\n\t<link>https://example.com</link>"
    /// ```
    var indentedTagsRepresentation: String {
        map { "\t\($0)" }.joined(separator: "\n")
    }

    /// Formats each string in the array with **two** tabs of indentation (`\t\t`).
    ///
    /// Useful for deeply nested XML elements, such as `<itunes:owner>` sub-tags or `<item>` content.
    ///
    /// - Returns: A string with each line prefixed by two tabs and separated by line breaks.
    ///
    /// ### Example:
    /// ```swift
    /// ["<itunes:name>John Doe</itunes:name>", "<itunes:email>john@example.com</itunes:email>"]
    ///     .doubleIndentedTagsRepresentation
    ///
    /// // → "\t\t<itunes:name>John Doe</itunes:name>\n\t\t<itunes:email>john@example.com</itunes:email>"
    /// ```
    var doubleIndentedTagsRepresentation: String {
        map { "\t\t\($0)" }.joined(separator: "\n")
    }
}

// MARK: - URL Validator

/// Extension providing utilities for validating and encoding URLs used in RSS podcast feeds.
///
/// Ensures that URLs conform to the expected scheme, length, and safety constraints for use
/// in XML elements such as `<enclosure>`, `<itunes:image>`, `<podcast:chapters>`, etc.
///
/// - Important: Only `http` and `https` schemes are accepted.
/// - SeeAlso:
///   - [PSP-1 URL Requirements](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification)
package extension URL {

    /// Validation errors for podcast-safe URLs.
    enum URLValidatorError: Swift.Error, LocalizedError {

        /// The URL has a scheme other than `http` or `https`.
        case invalidScheme

        /// The scheme is missing from the URL.
        case schemeNotFound

        /// The URL uses the `file://` scheme, which is not allowed in RSS feeds.
        case isFileURL

        /// The encoded URL exceeds the allowed length (255 characters).
        case maxLength

        /// The URL has invalid host.
        case invalidHost

        /// Localized description of each validation error.
        package var errorDescription: String? {
            switch self {
            case .invalidScheme:
                "Scheme must be either `http` or `https`."
            case .schemeNotFound:
                "Scheme not found."
            case .isFileURL:
                "URL is `file://`."
            case .maxLength:
                "URL is too long, max length is 255 characters."
            case .invalidHost:
                "Invalid host."
            }
        }
    }

    /// Validates that the current URL is safe and allowed in an RSS context.
    ///
    /// This includes checking:
    /// - The scheme is present and is `http` or `https`
    /// - The URL is not a `file://` reference
    /// - The encoded length does not exceed 255 characters
    ///
    /// - Returns: `true` if valid
    /// - Throws: A `URLValidatorError` if validation fails
    ///
    /// ### Example:
    /// ```swift
    /// let url = URL(string: "https://example.com/image.jpg")!
    /// try url.isValid() // returns true or throws
    /// ```
    @discardableResult
    func isValid() throws -> Bool {
        guard let scheme else {
            throw URLValidatorError.schemeNotFound
        }

        guard isFileURL == false else {
            throw URLValidatorError.isFileURL
        }

        guard ["http", "https"].contains(scheme) else {
            throw URLValidatorError.invalidScheme
        }

        guard let host, !host.isEmpty else {
            throw URLValidatorError.invalidHost
        }

        guard encodeURLQueryAllowed.count <= 255 else {
            throw URLValidatorError.maxLength
        }

        return true
    }

    /// A safely encoded URL string using `urlQueryAllowed` characters.
    ///
    /// This encoding ensures that special characters are correctly escaped
    /// for use within XML attributes (e.g. in `href`, `url`, etc).
    ///
    /// - Returns: A percent-encoded URL string, or the original if encoding fails.
    ///
    /// ### Example:
    /// ```swift
    /// let url = URL(string: "https://example.com/audio file.mp3")!
    /// print(url.encodeURLQueryAllowed)
    /// // → "https://example.com/audio%20file.mp3"
    /// ```
    var encodeURLQueryAllowed: String {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return absoluteString
        }

        var newComponents = components
        newComponents.percentEncodedQuery = components.percentEncodedQuery

        return newComponents.string ?? absoluteString
    }

}
