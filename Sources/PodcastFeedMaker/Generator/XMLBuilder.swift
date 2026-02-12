import Foundation

/// Low-level XML construction engine for building well-formed XML fragments.
///
/// `XMLBuilder` is a pure value type with no Model layer dependencies.
/// It provides indentation-aware element building and static utility methods
/// for escaping, date formatting, boolean conversion, and URL encoding.
///
/// Example:
/// ```swift
/// let builder = XMLBuilder()
/// let xml = builder.element("title", content: "My Podcast")
/// // → "<title>My Podcast</title>"
///
/// let nested = builder.indented()
/// let child = nested.element("name", content: "Host")
/// // → "\t<name>Host</name>"
/// ```
///
/// - SeeAlso: ``FeedGenerator``, ``StreamingFeedGenerator``
public struct XMLBuilder: Sendable {

    // MARK: - Configuration

    /// The string used for a single level of indentation (default: `"\t"`).
    public let indentString: String

    /// The current nesting depth.
    public private(set) var depth: Int

    /// Creates a new XML builder.
    ///
    /// - Parameters:
    ///   - indentString: The indentation character(s). Defaults to `"\t"`.
    ///   - depth: The initial nesting depth. Defaults to `0`.
    public init(indentString: String = "\t", depth: Int = 0) {
        self.indentString = indentString
        self.depth = depth
    }

    // MARK: - Indentation

    /// The indentation prefix for the current depth.
    public var indent: String {
        String(repeating: indentString, count: depth)
    }

    /// Returns a copy of this builder with `depth + 1`.
    public func indented() -> XMLBuilder {
        XMLBuilder(indentString: indentString, depth: depth + 1)
    }

    // MARK: - Element Building

    /// Builds an element with text content and optional attributes.
    ///
    /// - Parameters:
    ///   - name: The element name.
    ///   - content: The text content (will be XML-escaped).
    ///   - attributes: Optional attributes.
    /// - Returns: The formatted XML element string.
    public func element(_ name: String, content: String, attributes: [(String, String)] = []) -> String {
        let attrs = Self.formatAttributes(attributes)
        return "\(indent)<\(name)\(attrs)>\(Self.escape(content))</\(name)>"
    }

    /// Builds an element with a pre-formatted body and optional attributes.
    ///
    /// - Parameters:
    ///   - name: The element name.
    ///   - attributes: Optional attributes.
    ///   - body: The pre-formatted inner XML (not escaped).
    /// - Returns: The formatted XML element string.
    public func element(_ name: String, attributes: [(String, String)] = [], body: String) -> String {
        let attrs = Self.formatAttributes(attributes)
        return "\(indent)<\(name)\(attrs)>\n\(body)\n\(indent)</\(name)>"
    }

    /// Builds a self-closing element with attributes.
    ///
    /// - Parameters:
    ///   - name: The element name.
    ///   - attributes: The attributes.
    /// - Returns: The formatted self-closing XML element string.
    public func selfClosingElement(_ name: String, attributes: [(String, String)]) -> String {
        let attrs = Self.formatAttributes(attributes)
        return "\(indent)<\(name)\(attrs) />"
    }

    /// Builds an opening tag with optional attributes.
    ///
    /// - Parameters:
    ///   - name: The element name.
    ///   - attributes: Optional attributes.
    /// - Returns: The formatted opening tag string.
    public func openTag(_ name: String, attributes: [(String, String)] = []) -> String {
        let attrs = Self.formatAttributes(attributes)
        return "\(indent)<\(name)\(attrs)>"
    }

    /// Builds a closing tag.
    ///
    /// - Parameter name: The element name.
    /// - Returns: The formatted closing tag string.
    public func closeTag(_ name: String) -> String {
        "\(indent)</\(name)>"
    }

    /// Builds an element with CDATA-wrapped content.
    ///
    /// - Parameters:
    ///   - name: The element name.
    ///   - content: The raw content to wrap in CDATA.
    /// - Returns: The formatted XML element with CDATA.
    public func cdataElement(_ name: String, content: String) -> String {
        "\(indent)<\(name)><![CDATA[\(content)]]></\(name)>"
    }

    /// Builds an element that uses CDATA if the content contains HTML, otherwise XML-escapes.
    ///
    /// - Parameters:
    ///   - name: The element name.
    ///   - content: The text content.
    ///   - attributes: Optional attributes.
    /// - Returns: The formatted XML element string.
    public func smartElement(_ name: String, content: String, attributes: [(String, String)] = []) -> String {
        if Self.containsHTML(content) {
            let attrs = Self.formatAttributes(attributes)
            return "\(indent)<\(name)\(attrs)><![CDATA[\(content)]]></\(name)>"
        }
        return element(name, content: content, attributes: attributes)
    }

    // MARK: - Static Formatting Utilities

    /// Escapes a string for safe inclusion in XML text content.
    ///
    /// Handles: `&` (entity-aware), `<`, `>`, `"`, `'` (right single quote),
    /// `©`, `℗`, `™`, and smart quotes. Does not double-escape existing entities.
    ///
    /// - Parameter string: The raw string.
    /// - Returns: The XML-safe escaped string.
    public static func escape(_ string: String) -> String {
        var result = ""
        result.reserveCapacity(string.count)

        var index = string.startIndex
        while index < string.endIndex {
            let char = string[index]

            switch char {
            case "&":
                index = escapeAmpersand(string, at: index, into: &result)
                continue

            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            case "\"", "\u{201C}", "\u{201D}": result.append("&quot;")
            case "\u{2019}": result.append("&apos;")
            case "\u{00A9}": result.append("&#xA9;")
            case "\u{2117}": result.append("&#x2117;")
            case "\u{2122}": result.append("&#x2122;")
            default: result.append(char)
            }

            index = string.index(after: index)
        }

        return result
    }

    /// Formats a `Date` as an RFC 2822 string in UTC.
    ///
    /// Uses hardcoded English weekday/month names for Linux compatibility.
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A string like `"Tue, 18 Mar 2025 19:20:15 +0000"`.
    public static func rfc2822Date(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .weekday],
            from: date
        )

        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let months = [
            "Jan", "Feb", "Mar", "Apr", "May", "Jun",
            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
        ]

        let weekday = weekdays[(components.weekday ?? 1) - 1]
        let month = months[(components.month ?? 1) - 1]
        let day = components.day ?? 1
        let year = components.year ?? 2000
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        return String(
            format: "%@, %02d %@ %04d %02d:%02d:%02d +0000",
            weekday, day, month, year, hour, minute, second
        )
    }

    /// Formats a `Date` as an ISO 8601 string in UTC.
    ///
    /// - Parameter date: The date to format.
    /// - Returns: A string like `"2021-09-26T07:30:00Z"`.
    public static func iso8601Date(_ date: Date) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )

        let year = components.year ?? 2000
        let month = components.month ?? 1
        let day = components.day ?? 1
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let second = components.second ?? 0

        return String(
            format: "%04d-%02d-%02dT%02d:%02d:%02dZ",
            year, month, day, hour, minute, second
        )
    }

    /// Converts a boolean to `"yes"` or `"no"`.
    ///
    /// Used for `itunes:block`, `itunes:complete`, `podcast:locked`, `podcast:block`.
    ///
    /// - Parameter value: The boolean value.
    /// - Returns: `"yes"` if `true`, `"no"` if `false`.
    public static func boolYesNo(_ value: Bool) -> String {
        value ? "yes" : "no"
    }

    /// Converts a boolean to `"true"` or `"false"`.
    ///
    /// Used for `itunes:explicit`, `podcast:podping`.
    ///
    /// - Parameter value: The boolean value.
    /// - Returns: `"true"` if `true`, `"false"` if `false`.
    public static func boolTrueFalse(_ value: Bool) -> String {
        value ? "true" : "false"
    }

    /// Safely encodes a URL for inclusion in XML attributes.
    ///
    /// - Parameter url: The URL to encode.
    /// - Returns: A percent-encoded URL string.
    public static func encodeURL(_ url: URL) -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url.absoluteString
        }

        var newComponents = components
        newComponents.percentEncodedQuery = components.percentEncodedQuery

        return newComponents.string ?? url.absoluteString
    }

    /// Validates that a URL is safe for use in an RSS feed.
    ///
    /// - Parameter url: The URL to validate.
    /// - Throws: ``GeneratorError/invalidURL(_:_:)`` if the URL is invalid.
    public static func validateURL(_ url: URL, context: String = "") throws {
        guard let scheme = url.scheme else {
            throw GeneratorError.invalidURL(context, url.absoluteString)
        }

        guard !url.isFileURL else {
            throw GeneratorError.invalidURL(context, url.absoluteString)
        }

        guard ["http", "https"].contains(scheme) else {
            throw GeneratorError.invalidURL(context, url.absoluteString)
        }

        guard let host = url.host, !host.isEmpty else {
            throw GeneratorError.invalidURL(context, url.absoluteString)
        }
    }

    /// Detects whether a string contains HTML-like markup.
    ///
    /// - Parameter string: The string to check.
    /// - Returns: `true` if the string contains `<` or `>`.
    public static func containsHTML(_ string: String) -> Bool {
        string.contains("<") || string.contains(">")
    }

    /// Formats an array of attribute name-value pairs into an XML attribute string.
    ///
    /// - Parameter attrs: An array of `(name, value)` tuples.
    /// - Returns: A string like ` key1="value1" key2="value2"`, or empty if no attributes.
    public static func formatAttributes(_ attrs: [(String, String)]) -> String {
        guard !attrs.isEmpty else { return "" }
        let pairs = attrs.map { " \($0.0)=\"\($0.1)\"" }
        return pairs.joined()
    }

    // MARK: - Private Helpers

    /// Handles `&` during escaping: converts HTML entities, preserves XML entities, or escapes.
    ///
    /// - Returns: The index to continue scanning from (after the processed entity or character).
    private static func escapeAmpersand(
        _ string: String,
        at index: String.Index,
        into result: inout String
    ) -> String.Index {
        // Known HTML entity → convert to numeric equivalent
        if let (replacement, entityEnd) = convertHTMLEntity(string, at: index) {
            result.append(replacement)
            return string.index(after: entityEnd)
        }
        // Already a standard XML / numeric entity → preserve as-is
        if isExistingEntity(string, at: index) {
            let entityEnd = findEntityEnd(string, from: index)
            result.append(contentsOf: string[index...entityEnd])
            return string.index(after: entityEnd)
        }
        // Bare ampersand → escape
        result.append("&amp;")
        return string.index(after: index)
    }

    /// HTML named entities that should be converted to their XML numeric equivalents.
    private static let htmlEntityMap: [String: String] = [
        "&copy;": "&#xA9;",
        "&trade;": "&#x2122;",
        "&reg;": "&#xAE;"
    ]

    /// Checks if the `&` at the given index starts a known HTML named entity
    /// and returns its XML numeric replacement.
    private static func convertHTMLEntity(
        _ string: String,
        at index: String.Index
    ) -> (replacement: String, entityEnd: String.Index)? {
        let remaining = string[index...]
        guard let match = htmlEntityMap.first(where: { remaining.hasPrefix($0.key) }) else {
            return nil
        }
        let endIndex = string.index(index, offsetBy: match.key.count - 1)
        return (match.value, endIndex)
    }

    /// Checks if the `&` at the given index is the start of an existing XML entity
    /// that should be preserved (standard XML entities and numeric character references only).
    private static func isExistingEntity(_ string: String, at index: String.Index) -> Bool {
        let remaining = string[index...]

        // Only preserve the 5 standard XML named entities
        let standardEntities = ["&amp;", "&lt;", "&gt;", "&quot;", "&apos;"]
        if standardEntities.contains(where: { remaining.hasPrefix($0) }) {
            return true
        }

        // Numeric character references: &#xHHHH; or &#DDDD;
        if remaining.hasPrefix("&#") {
            var searchIdx = string.index(index, offsetBy: 2, limitedBy: string.endIndex) ?? string.endIndex
            while searchIdx < string.endIndex {
                let ch = string[searchIdx]
                if ch == ";" { return true }
                if !(ch.isHexDigit || ch == "x") { return false }
                searchIdx = string.index(after: searchIdx)
            }
        }

        return false
    }

    /// Finds the end of an XML entity starting at the given `&` index.
    private static func findEntityEnd(_ string: String, from start: String.Index) -> String.Index {
        var idx = string.index(after: start)
        while idx < string.endIndex {
            if string[idx] == ";" { return idx }
            idx = string.index(after: idx)
        }
        return start
    }
}
