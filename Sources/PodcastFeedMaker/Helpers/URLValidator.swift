import Foundation

/// Extension providing utilities for validating and encoding URLs used in RSS podcast feeds.
///
/// Ensures that URLs conform to the expected scheme, length, and safety constraints for use
/// in XML elements such as `<enclosure>`, `<itunes:image>`, `<podcast:chapters>`, etc.
///
/// - Important: Only `http` and `https` schemes are accepted.
/// - SeeAlso:
///   - [PSP-1 URL Requirements](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification)
///   - `RSSTag.Enclosure`, `Namespace.iTunes.Image`, `Namespace.Podcast.Chapters`
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
        absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? absoluteString
    }
}
