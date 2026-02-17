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

/// A JSON Chapters document as defined by the Podcast Namespace.
///
/// This is the JSON-based chapter format referenced by the ``ChaptersLink``
/// element. Each chapter includes a start time, title, and optional metadata.
///
/// Example JSON:
/// ```json
/// {
///   "version": "1.2.0",
///   "chapters": [
///     { "startTime": 0, "title": "Intro" },
///     { "startTime": 300, "title": "Main Topic", "url": "https://example.com" }
///   ]
/// }
/// ```
///
/// - SeeAlso: [JSON Chapters Format](https://github.com/Podcastindex-org/podcast-namespace/blob/main/chapters/jsonChapters.md)
public struct JSONChapterList: Sendable, Hashable, Equatable, Codable {

    /// The JSON Chapters format version (e.g., `"1.2.0"`).
    public var version: String

    /// The title of the podcast episode this chapter list belongs to.
    public var title: String?

    /// The name of the author of the podcast episode.
    public var author: String?

    /// The name of the podcast this episode belongs to.
    public var podcastName: String?

    /// The chapter entries.
    public var chapters: [JSONChapter]

    /// Creates a new JSON chapter list.
    ///
    /// - Parameters:
    ///   - version: The format version. Defaults to `"1.2.0"`.
    ///   - title: Optional episode title.
    ///   - author: Optional episode author.
    ///   - podcastName: Optional podcast name.
    ///   - chapters: The chapter entries.
    public init(
        version: String = "1.2.0",
        title: String? = nil,
        author: String? = nil,
        podcastName: String? = nil,
        chapters: [JSONChapter] = []
    ) {
        self.version = version
        self.title = title
        self.author = author
        self.podcastName = podcastName
        self.chapters = chapters
    }
}

// MARK: - JSONChapter

/// A single chapter in a JSON Chapters document.
///
/// - SeeAlso: [JSON Chapters Format](https://github.com/Podcastindex-org/podcast-namespace/blob/main/chapters/jsonChapters.md)
public struct JSONChapter: Sendable, Hashable, Equatable, Codable {

    /// The start time of the chapter in seconds.
    public var startTime: Double

    /// The title of the chapter.
    public var title: String?

    /// An optional end time in seconds (if the chapter has a defined duration).
    public var endTime: Double?

    /// An optional URL associated with the chapter.
    public var url: URL?

    /// An optional image URL for the chapter.
    public var img: URL?

    /// Whether this chapter should be hidden from the user (e.g., ad markers).
    public var toc: Bool?

    /// Optional location data for this chapter.
    public var location: PodcastLocation?

    /// Creates a new JSON chapter.
    ///
    /// - Parameters:
    ///   - startTime: The start time in seconds.
    ///   - title: Optional chapter title.
    ///   - endTime: Optional end time in seconds.
    ///   - url: Optional associated URL.
    ///   - img: Optional image URL.
    ///   - toc: Optional table-of-contents visibility flag.
    ///   - location: Optional location data.
    public init(
        startTime: Double,
        title: String? = nil,
        endTime: Double? = nil,
        url: URL? = nil,
        img: URL? = nil,
        toc: Bool? = nil,
        location: PodcastLocation? = nil
    ) {
        self.startTime = startTime
        self.title = title
        self.endTime = endTime
        self.url = url
        self.img = img
        self.toc = toc
        self.location = location
    }
}
