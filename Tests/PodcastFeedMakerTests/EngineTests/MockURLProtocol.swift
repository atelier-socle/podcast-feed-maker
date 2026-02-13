import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

// MARK: - MockResponse

/// A mock HTTP response for use with ``MockURLProtocol``.
struct MockResponse: Sendable {

    /// The response body data.
    let data: Data

    /// The HTTP status code.
    let statusCode: Int

    /// The HTTP response headers.
    let headers: [String: String]

    init(
        data: Data,
        statusCode: Int,
        headers: [String: String] = [:]
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
    }
}

// MARK: - MockResponseStore

/// Thread-safe store for mock responses, used by ``MockURLProtocol``.
final class MockResponseStore: @unchecked Sendable {

    /// Shared singleton instance.
    static let shared = MockResponseStore()

    private let lock = NSLock()
    private var responses: [String: MockResponse] = [:]

    private init() {}

    /// Sets a mock response for the given URL string.
    func set(_ response: MockResponse, for urlString: String) {
        lock.lock()
        defer { lock.unlock() }
        responses[urlString] = response
    }

    /// Returns the mock response for the given URL string, if any.
    func response(for urlString: String) -> MockResponse? {
        lock.lock()
        defer { lock.unlock() }
        return responses[urlString]
    }

    /// Removes all registered mock responses.
    func reset() {
        lock.lock()
        defer { lock.unlock() }
        responses = [:]
    }
}

// MARK: - MockURLProtocol

/// A `URLProtocol` subclass that intercepts requests and returns mock responses.
///
/// Use this in tests to avoid real network calls. Register mock responses
/// via ``MockResponseStore``, then create a session with ``makeMockSession()``.
///
/// ## Usage
///
/// ```swift
/// MockResponseStore.shared.set(
///     MockResponse(data: Data([0x49, 0x44, 0x33]), statusCode: 206),
///     for: "https://example.com/file.mp3"
/// )
/// let session = makeMockSession()
/// ```
final class MockURLProtocol: URLProtocol {

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let urlString = request.url?.absoluteString,
            let mock = MockResponseStore.shared.response(for: urlString)
        else {
            client?.urlProtocol(
                self, didFailWithError: URLError(.fileDoesNotExist))
            return
        }

        guard let requestURL = request.url,
            let response = HTTPURLResponse(
                url: requestURL,
                statusCode: mock.statusCode,
                httpVersion: "HTTP/1.1",
                headerFields: mock.headers
            )
        else {
            client?.urlProtocol(
                self, didFailWithError: URLError(.badServerResponse))
            return
        }

        client?.urlProtocol(
            self, didReceive: response,
            cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: mock.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

// MARK: - Helper

/// Creates a `URLSession` configured to use ``MockURLProtocol``.
///
/// All requests made through this session will be intercepted by the
/// mock protocol and return pre-registered responses.
///
/// - Returns: An ephemeral URL session using `MockURLProtocol`.
func makeMockSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSession(configuration: config)
}
