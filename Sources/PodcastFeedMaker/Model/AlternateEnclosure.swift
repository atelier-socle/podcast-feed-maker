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

/// The `<podcast:alternateEnclosure>` element from Podcast Namespace 2.0.
///
/// Provides alternative media files for an episode, allowing different
/// formats, bitrates, or codecs (e.g., Opus alongside MP3).
///
/// - Important: Item-level only. Must contain at least one ``PodcastSource``.
///
/// Example:
/// ```xml
/// <podcast:alternateEnclosure type="audio/opus" length="12345" bitrate="128000"
///                              height="0" lang="en" title="High Quality"
///                              default="true">
///   <podcast:source uri="https://example.com/ep1.opus" />
///   <podcast:integrity type="sri" value="sha256-..." />
/// </podcast:alternateEnclosure>
/// ```
///
/// - SeeAlso: [Podcast NS — alternateEnclosure](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#alternate-enclosure)
public struct AlternateEnclosure: Sendable, Hashable, Equatable, Codable {

    /// The MIME type of the media (e.g., `"audio/opus"`, `"audio/mpeg"`).
    public var type: String

    /// The file size in bytes.
    public var length: Int?

    /// The encoding bitrate in bits per second.
    public var bitrate: Int?

    /// The height of the media in pixels (for video). Use `0` for audio.
    public var height: Int?

    /// The BCP 47 language code.
    public var language: String?

    /// A human-readable title for this alternate enclosure.
    public var title: String?

    /// Whether this is the default enclosure.
    public var isDefault: Bool?

    /// The media sources for this enclosure.
    public var sources: [PodcastSource]

    /// Optional integrity check for the media.
    public var integrity: PodcastIntegrity?

    /// Creates a new alternate enclosure.
    ///
    /// - Parameters:
    ///   - type: The MIME type.
    ///   - length: Optional file size in bytes.
    ///   - bitrate: Optional bitrate in bps.
    ///   - height: Optional height in pixels.
    ///   - language: Optional BCP 47 language code.
    ///   - title: Optional display title.
    ///   - isDefault: Whether this is the default enclosure.
    ///   - sources: The media source URIs.
    ///   - integrity: Optional integrity verification.
    public init(
        type: String,
        length: Int? = nil,
        bitrate: Int? = nil,
        height: Int? = nil,
        language: String? = nil,
        title: String? = nil,
        isDefault: Bool? = nil,
        sources: [PodcastSource] = [],
        integrity: PodcastIntegrity? = nil
    ) {
        self.type = type
        self.length = length
        self.bitrate = bitrate
        self.height = height
        self.language = language
        self.title = title
        self.isDefault = isDefault
        self.sources = sources
        self.integrity = integrity
    }
}
