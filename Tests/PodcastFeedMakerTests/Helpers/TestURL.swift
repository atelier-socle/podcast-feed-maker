import Foundation

/// Creates a URL from a compile-time string literal.
///
/// Using `StaticString` ensures only string literals are passed,
/// making the `preconditionFailure` unreachable in practice since
/// `URL(string:)` succeeds for all well-formed literal URLs.
func makeURL(_ string: StaticString) -> URL {
    guard let url = URL(string: "\(string)") else {
        preconditionFailure("Invalid URL string: \(string)")
    }
    return url
}
