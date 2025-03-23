import Foundation

package extension URL {

    enum URLValidatorError: Swift.Error, LocalizedError {
        case invalidScheme
        case schemeNotFound
        case isFileURL
        case maxLength

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

    var encodeURLQueryAllowed: String {
        absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? absoluteString
    }
}
