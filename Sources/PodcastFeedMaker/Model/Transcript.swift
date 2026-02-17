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

/// The `<podcast:transcript>` element from Podcast Namespace 2.0.
///
/// Links to a transcript file for an episode. Multiple transcripts in
/// different formats or languages may be provided.
///
/// - Important: Item-level only.
///
/// Example:
/// ```xml
/// <podcast:transcript url="https://example.com/ep1.vtt"
///                     type="text/vtt" language="en" rel="captions" />
/// ```
///
/// - SeeAlso: [Podcast NS — transcript](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#transcript)
public struct Transcript: Sendable, Hashable, Equatable, Codable {

    /// The URL of the transcript file.
    public var url: URL

    /// The MIME type of the transcript (e.g., `"text/vtt"`, `"application/srt"`, `"text/html"`).
    public var type: String

    /// The BCP 47 language code for the transcript (e.g., `"en"`, `"fr"`).
    public var language: String?

    /// The relationship of the transcript to the media.
    ///
    /// Common values: `"captions"` for closed captions.
    public var rel: String?

    /// Creates a new transcript.
    ///
    /// - Parameters:
    ///   - url: The transcript file URL.
    ///   - type: The MIME type string.
    ///   - language: Optional BCP 47 language code.
    ///   - rel: Optional relationship (e.g., `"captions"`).
    public init(url: URL, type: String, language: String? = nil, rel: String? = nil) {
        self.url = url
        self.type = type
        self.language = language
        self.rel = rel
    }
}

// MARK: - Known Transcript Types

extension Transcript {

    /// Common transcript MIME types.
    public enum TranscriptType: String, CaseIterable, Sendable {
        /// WebVTT format.
        case vtt = "text/vtt"
        /// SRT (SubRip) format.
        case srt = "application/srt"
        /// SubRip alternative MIME type.
        case subrip = "application/x-subrip"
        /// HTML format.
        case html = "text/html"
        /// JSON format.
        case json = "application/json"
    }
}
