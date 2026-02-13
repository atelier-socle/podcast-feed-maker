import Foundation

/// Resolves a user-provided source string into a URL or file path.
enum InputResolver {

    /// The resolved input type.
    enum ResolvedInput {
        /// A URL (http, https, or file).
        case url(URL)
        /// A local file path.
        case file(String)
    }

    /// Resolves a source string to either a URL or file path.
    ///
    /// - Parameter source: A file path or URL string from the user.
    /// - Returns: The resolved input type.
    /// - Throws: If the source is a URL with an invalid format.
    static func resolve(_ source: String) throws -> ResolvedInput {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
            || trimmed.hasPrefix("file://")
        {
            guard let url = URL(string: trimmed) else {
                throw InputError.invalidURL(trimmed)
            }
            return .url(url)
        }

        return .file(trimmed)
    }
}

/// Errors related to input resolution.
enum InputError: Error, CustomStringConvertible {

    /// The provided URL string could not be parsed.
    case invalidURL(String)

    /// The file was not found at the specified path.
    case fileNotFound(String)

    /// The file could not be read.
    case fileReadError(String, Error)

    var description: String {
        switch self {
        case .invalidURL(let url):
            "Invalid URL: \(url)"
        case .fileNotFound(let path):
            "File not found: \(path)"
        case .fileReadError(let path, let error):
            "Cannot read file '\(path)': \(error.localizedDescription)"
        }
    }
}
