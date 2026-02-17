// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// Generates a podcast RSS feed as a stream of XML chunks.
///
/// `StreamingFeedGenerator` yields N+2 chunks for a feed with N items:
/// 1. XML declaration + `<rss>` + `<channel>` metadata (one chunk)
/// 2. Each `<item>` as a separate chunk (N chunks)
/// 3. `</channel>` + `</rss>` (one chunk)
///
/// Memory usage per chunk is proportional to a single episode, making this
/// suitable for large catalogs (10,000+ episodes).
///
/// Example:
/// ```swift
/// let streaming = StreamingFeedGenerator()
/// for try await chunk in streaming.generate(feed) {
///     fileHandle.write(chunk.data(using: .utf8)!)
/// }
/// ```
///
/// - SeeAlso: ``FeedGenerator``, ``XMLBuilder``
public struct StreamingFeedGenerator: Sendable {

    /// Whether to format the output with indentation. Defaults to `true`.
    public let prettyPrint: Bool

    /// Whether to include the XML declaration. Defaults to `true`.
    public let includeXMLDeclaration: Bool

    /// The XML encoding declaration. Defaults to `"UTF-8"`.
    public let encoding: String

    /// How namespace declarations are determined. Defaults to `.feedDefined`.
    public let namespaceMode: FeedGenerator.NamespaceMode

    /// Creates a new streaming feed generator.
    ///
    /// - Parameters:
    ///   - prettyPrint: Whether to indent the output.
    ///   - includeXMLDeclaration: Whether to include `<?xml ... ?>`.
    ///   - encoding: The encoding declaration string.
    ///   - namespaceMode: How to determine namespace declarations.
    public init(
        prettyPrint: Bool = true,
        includeXMLDeclaration: Bool = true,
        encoding: String = "UTF-8",
        namespaceMode: FeedGenerator.NamespaceMode = .feedDefined
    ) {
        self.prettyPrint = prettyPrint
        self.includeXMLDeclaration = includeXMLDeclaration
        self.encoding = encoding
        self.namespaceMode = namespaceMode
    }

    /// Generates the feed as an async stream of XML chunks.
    ///
    /// - Parameter feed: The feed model.
    /// - Returns: An `AsyncThrowingStream` yielding XML string chunks.
    public func generate(_ feed: PodcastFeed) -> AsyncThrowingStream<String, Error> {
        let prettyPrint = self.prettyPrint
        let includeXMLDeclaration = self.includeXMLDeclaration
        let encoding = self.encoding
        let namespaceMode = self.namespaceMode

        return AsyncThrowingStream { continuation in
            do {
                guard let channel = feed.channel else {
                    throw GeneratorError.missingChannel
                }

                let gen = FeedGenerator(
                    prettyPrint: prettyPrint,
                    includeXMLDeclaration: includeXMLDeclaration,
                    encoding: encoding,
                    namespaceMode: namespaceMode
                )

                // Chunk 1: header + channel metadata (no items)
                var headerChannel = channel
                headerChannel.items = []
                let headerFeed = PodcastFeed(
                    version: feed.version,
                    namespaces: feed.namespaces,
                    channel: headerChannel
                )
                let fullHeader = try gen.generate(headerFeed)

                // Strip closing tags to leave channel open
                let indentStr = prettyPrint ? "\t" : ""
                let sep = prettyPrint ? "\n" : ""
                let closing = "\(sep)\(indentStr)</channel>\(sep)</rss>"
                if let range = fullHeader.range(of: closing, options: .backwards) {
                    continuation.yield(String(fullHeader[..<range.lowerBound]))
                } else {
                    continuation.yield(fullHeader)
                }

                // Chunks 2..N+1: one per item
                let itemBuilder = XMLBuilder(indentString: indentStr, depth: 2)
                for item in channel.items {
                    let lines = gen.generateItem(item, builder: itemBuilder)
                    continuation.yield(sep + lines.joined(separator: sep))
                }

                // Chunk N+2: footer
                continuation.yield("\(sep)\(indentStr)</channel>\(sep)</rss>")

                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}
