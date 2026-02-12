import Foundation

/// Errors thrown during feed XML generation.
///
/// `GeneratorError` covers all conditions that prevent the ``FeedGenerator``
/// or ``StreamingFeedGenerator`` from producing valid XML output.
///
/// - SeeAlso: ``FeedGenerator``, ``StreamingFeedGenerator``
public enum GeneratorError: Error, LocalizedError, Equatable, Sendable {

    /// The feed has no channel set.
    case missingChannel

    /// A URL failed validation.
    ///
    /// - Parameters:
    ///   - context: The element or attribute where the invalid URL was found.
    ///   - url: The invalid URL string.
    case invalidURL(String, String)

    /// An encoding or serialization error occurred.
    ///
    /// - Parameter message: A description of the encoding failure.
    case encodingError(String)

    public var errorDescription: String? {
        switch self {
        case .missingChannel:
            "Missing channel — a PodcastFeed must have a channel to generate XML."
        case let .invalidURL(context, url):
            "Invalid URL in \(context): \(url)"
        case let .encodingError(message):
            "Encoding error: \(message)"
        }
    }
}
