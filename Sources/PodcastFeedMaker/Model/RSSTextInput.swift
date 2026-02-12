import Foundation

/// The `<textInput>` element from the RSS 2.0 specification.
///
/// Specifies a text input box that can be displayed with the channel.
/// The purpose of this element is to allow readers to submit queries
/// or feedback directly from the feed reader.
///
/// Example:
/// ```xml
/// <textInput>
///   <title>Search</title>
///   <description>Search this feed</description>
///   <name>query</name>
///   <link>https://example.com/search</link>
/// </textInput>
/// ```
///
/// - SeeAlso: [RSS 2.0 — textInput](https://www.rssboard.org/rss-specification#lttextinputgtSubelementOfLtchannelgt)
public struct RSSTextInput: Sendable, Hashable, Equatable, Codable {

    /// The label for the Submit button.
    public var title: String

    /// Explains the text input area.
    public var description: String

    /// The name of the text object in the form.
    public var name: String

    /// The URL of the CGI script that processes the request.
    public var link: URL

    /// Creates a new RSS text input element.
    ///
    /// - Parameters:
    ///   - title: The Submit button label.
    ///   - description: A description of the text input.
    ///   - name: The form field name.
    ///   - link: The URL for form submission.
    public init(title: String, description: String, name: String, link: URL) {
        self.title = title
        self.description = description
        self.name = name
        self.link = link
    }
}
