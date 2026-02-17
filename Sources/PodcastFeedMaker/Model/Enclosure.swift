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

/// The `<enclosure>` element from the RSS 2.0 specification.
///
/// Describes a media object (audio, video, or document) attached to an RSS item.
/// In podcast feeds, this is the primary mechanism for referencing episode audio files.
///
/// - Important: Required by PSP-1 and Apple Podcasts for each `<item>`.
///
/// Example:
/// ```xml
/// <enclosure url="https://example.com/episode1.mp3"
///            length="12345678" type="audio/mpeg" />
/// ```
///
/// - SeeAlso: [RSS 2.0 — enclosure](https://www.rssboard.org/rss-specification#ltenclosuregtSubelementOfLtitemgt)
public struct Enclosure: Sendable, Hashable, Equatable, Codable {

    /// The URL of the media file.
    public var url: URL

    /// The file size in bytes.
    public var length: Int

    /// The MIME type of the media file (e.g., `"audio/mpeg"`, `"audio/m4a"`).
    public var type: String

    /// Creates a new enclosure.
    ///
    /// - Parameters:
    ///   - url: The URL of the media file.
    ///   - length: The file size in bytes.
    ///   - type: The MIME type string.
    public init(url: URL, length: Int, type: String) {
        self.url = url
        self.length = length
        self.type = type
    }

    /// Creates a new enclosure using a typed MIME value.
    ///
    /// - Parameters:
    ///   - url: The URL of the media file.
    ///   - length: The file size in bytes.
    ///   - mimeType: The MIME type as a ``MIMEType`` value.
    public init(url: URL, length: Int, mimeType: MIMEType) {
        self.url = url
        self.length = length
        self.type = mimeType.rawValue
    }
}

// MARK: - MIMEType

extension Enclosure {

    /// Common MIME types for podcast enclosures.
    public enum MIMEType: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        /// AAC audio (`audio/aac`).
        case aac = "audio/aac"
        /// M4A audio (`audio/m4a`).
        case m4a = "audio/m4a"
        /// MP3 audio (`audio/mpeg`).
        case mpeg = "audio/mpeg"
        /// Ogg Vorbis audio (`audio/ogg`).
        case ogg = "audio/ogg"
        /// Opus audio (`audio/opus`).
        case opus = "audio/opus"
        /// WAV audio (`audio/wav`).
        case wav = "audio/wav"
        /// FLAC audio (`audio/flac`).
        case flac = "audio/flac"
        /// QuickTime video (`video/quicktime`).
        case quicktime = "video/quicktime"
        /// MP4 video (`video/mp4`).
        case mp4 = "video/mp4"
        /// M4V video (`video/m4v`).
        case m4v = "video/m4v"
        /// PDF document (`application/pdf`).
        case pdf = "application/pdf"
    }
}
