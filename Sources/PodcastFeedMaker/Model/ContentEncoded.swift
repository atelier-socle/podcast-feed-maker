import Foundation

/// The `<content:encoded>` element from the Content Module namespace.
///
/// Contains the full HTML content of a feed item, typically used to
/// provide rich show notes or episode descriptions with formatting.
///
/// - Important: Item-level only. Content is typically wrapped in `CDATA`.
///
/// Example:
/// ```xml
/// <content:encoded><![CDATA[<p>Full show notes with <strong>HTML</strong>.</p>]]></content:encoded>
/// ```
///
/// - SeeAlso: [Content Module Specification](http://web.resource.org/rss/1.0/modules/content/)
public struct ContentEncoded: Sendable, Hashable, Equatable, Codable {

    /// The HTML content string.
    public var value: String

    /// Creates a new content:encoded element.
    ///
    /// - Parameter value: The HTML content.
    public init(value: String) {
        self.value = value
    }
}
