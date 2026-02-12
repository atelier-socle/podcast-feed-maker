import Foundation

/// Errors that can occur during podcast feed parsing.
///
/// `ParserError` covers XML parsing failures, missing required elements,
/// encoding issues, and network errors for URL-based parsing.
public enum ParserError: Error, LocalizedError, Equatable, Sendable {

    /// The XML data could not be parsed.
    case invalidXML(String)

    /// The root `<rss>` element was not found.
    case missingRSSElement

    /// The `<channel>` element was not found inside `<rss>`.
    case missingChannel

    /// The data could not be decoded with the expected encoding.
    case encodingError(String)

    /// A network error occurred while fetching a remote feed.
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidXML(let detail):
            return "Invalid XML: \(detail)"
        case .missingRSSElement:
            return "Missing <rss> root element"
        case .missingChannel:
            return "Missing <channel> element"
        case .encodingError(let detail):
            return "Encoding error: \(detail)"
        case .networkError(let detail):
            return "Network error: \(detail)"
        }
    }
}
