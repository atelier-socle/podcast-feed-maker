import Foundation

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
