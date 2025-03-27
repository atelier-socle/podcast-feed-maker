import Foundation

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
///   - `DescriptionType.text`
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
    
        let replacements: [(Regex<Substring>, String)] = [
            // specifics first.
            (try! Regex(#"&copy;"#), "&#xA9;"),
            (try! Regex(#"©"#), "&#xA9;"),
            (try! Regex(#"℗"#), "&#x2117;"),
            (try! Regex(#"™"#), "&#x2122;"),

            // then XML standards chars.
            (try! Regex(#"<"#), "&lt;"),
            (try! Regex(#">"#), "&gt;"),
            (try! Regex(#"’"#), "&apos;"),
            (try! Regex(#"[“”]"#), "&quot;"),
            (try! Regex(#"""#), "&quot;"),

            // finally.
            (try! Regex(#"&(?!amp;|lt;|gt;|quot;|apos;|#x[a-fA-F0-9]+;)"#), "&amp;")
        ]

        for (pattern, replacement) in replacements {
            result = result.replacing(pattern, with: replacement)
        }

        return result
    }
}
