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

    /// A predefined list of unsafe characters and their corresponding XML-safe entity codes.
    ///
    /// Includes common special characters like `&`, `<`, `>`, `©`, `™`, etc.
    private var patternsAndReplacements: [(String, String)] {
        [
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("’", "&apos;"),
            ("“", "&quot;"),
            ("”", "&quot;"),
            ("©", "&#xA9;"),
            ("&copy;", "&#xA9;"),
            ("℗", "&#x2117;"),
            ("™", "&#x2122;")
        ]
    }

    /// Escapes special characters in the string to ensure it is safe for XML rendering.
    ///
    /// This is particularly important when using `.text` type descriptions that are not wrapped in CDATA.
    ///
    /// - Returns: A sanitized version of the original string with all replacements applied.
    ///
    /// ### Example
    /// ```swift
    /// let input = "My “email” is test@example.com & copyright ©"
    /// let safeXML = input.cleanSpecialChars()
    /// print(safeXML)
    /// // Output: My &quot;email&quot; is test@example.com &amp; copyright &#xA9;
    /// ```
    func cleanSpecialChars() -> String {
        var original = self

        for (pattern, replacement) in patternsAndReplacements {
            original = original.replacingOccurrences(
                of: pattern,
                with: replacement,
                options: .regularExpression
            )
        }

        return original
    }
}
