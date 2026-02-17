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

/// A utility for creating podcast feeds in XML format.
///
/// `PodcastFeedMaker` is a lightweight wrapper around a ``PodcastFeed``
/// that provides both synchronous and streaming XML generation.
///
/// - Important: The ``PodcastFeed`` instance passed must be properly configured with required tags.
/// - SeeAlso: ``PodcastFeed``, ``Channel``, ``FeedGenerator``, ``StreamingFeedGenerator``
public struct PodcastFeedMaker: Sendable {

    /// The underlying ``PodcastFeed`` instance used to generate XML.
    private let feed: PodcastFeed

    /// Initializes a new podcast feed maker.
    ///
    /// - Parameter feed: A ``PodcastFeed`` instance representing the complete podcast structure.
    ///
    /// ### Example:
    /// ```swift
    /// let feed = PodcastFeed(channel: myChannel)
    /// let maker = PodcastFeedMaker(feed)
    /// let xml = try maker.generate()
    /// ```
    public init(_ feed: PodcastFeed) {
        self.feed = feed
    }

    /// Generates the complete RSS feed XML string.
    ///
    /// - Parameter prettyPrint: Whether to indent the output. Defaults to `true`.
    /// - Returns: A fully-formed RSS 2.0 feed string.
    /// - Throws: ``GeneratorError`` if the feed is invalid.
    public func generate(prettyPrint: Bool = true) throws -> String {
        try FeedGenerator(prettyPrint: prettyPrint).generate(feed)
    }

    /// Generates the RSS feed as an async stream of XML chunks.
    ///
    /// Suitable for large feeds with many episodes. Yields N+2 chunks
    /// for a feed with N items.
    ///
    /// - Parameter prettyPrint: Whether to indent the output. Defaults to `true`.
    /// - Returns: An `AsyncThrowingStream` yielding XML string chunks.
    public func generateStream(prettyPrint: Bool = true) -> AsyncThrowingStream<String, Error> {
        StreamingFeedGenerator(prettyPrint: prettyPrint).generate(feed)
    }
}
