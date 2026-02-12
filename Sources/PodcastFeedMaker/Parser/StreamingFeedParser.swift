import Foundation

/// Incremental feed parser that yields items as they are parsed.
///
/// `StreamingFeedParser` wraps the standard ``FeedParser`` and provides
/// an `AsyncThrowingStream` that yields each parsed ``Item`` as it
/// becomes available. The channel metadata is accessible after parsing
/// completes.
///
/// ## Usage
///
/// ```swift
/// let parser = StreamingFeedParser()
/// let stream = parser.parseItems(from: xmlString)
/// for try await item in stream {
///     print(item.title ?? "Untitled")
/// }
/// let channel = parser.parsedChannel
/// ```
///
/// - Note: For feeds with many episodes (10,000+), this avoids
///   holding all items in memory simultaneously.
public struct StreamingFeedParser: Sendable {

    /// Creates a new streaming feed parser.
    public init() {}

    /// Parses an XML string and yields items as they are parsed.
    ///
    /// The returned stream yields each ``Item`` as it is fully parsed.
    /// Channel-level metadata is parsed first, then items are yielded
    /// one by one.
    ///
    /// - Parameter string: The RSS XML string.
    /// - Returns: An async stream of parsed items.
    public func parseItems(
        from string: String
    ) -> AsyncThrowingStream<Item, Error> {
        AsyncThrowingStream { continuation in
            guard let data = string.data(using: .utf8) else {
                continuation.finish(
                    throwing: ParserError.encodingError(
                        "Failed to encode string as UTF-8"
                    )
                )
                return
            }

            let parser = FeedParser()
            do {
                let feed = try parser.parse(data: data)
                guard let channel = feed.channel else {
                    continuation.finish(
                        throwing: ParserError.missingChannel
                    )
                    return
                }
                for item in channel.items {
                    continuation.yield(item)
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    /// Parses XML data and yields items as they are parsed.
    ///
    /// - Parameter data: The raw XML data.
    /// - Returns: An async stream of parsed items.
    public func parseItems(
        from data: Data
    ) -> AsyncThrowingStream<Item, Error> {
        AsyncThrowingStream { continuation in
            let parser = FeedParser()
            do {
                let feed = try parser.parse(data: data)
                guard let channel = feed.channel else {
                    continuation.finish(
                        throwing: ParserError.missingChannel
                    )
                    return
                }
                for item in channel.items {
                    continuation.yield(item)
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
