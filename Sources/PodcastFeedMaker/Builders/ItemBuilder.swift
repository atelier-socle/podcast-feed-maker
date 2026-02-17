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

// MARK: - Item Fluent Modifiers

extension Item {

    /// Sets the item description.
    ///
    /// - Parameter text: The description text.
    /// - Returns: A modified copy of the item.
    public func description(_ text: String) -> Item {
        var copy = self
        copy.description = text
        return copy
    }

    /// Sets the item GUID.
    ///
    /// - Parameters:
    ///   - value: The unique identifier string.
    ///   - isPermaLink: Whether the GUID is a permanent URL.
    /// - Returns: A modified copy of the item.
    public func guid(_ value: String, isPermaLink: Bool) -> Item {
        var copy = self
        copy.guid = GUID(value: value, isPermaLink: isPermaLink)
        return copy
    }

    /// Sets the publication date.
    ///
    /// - Parameter date: The publication date.
    /// - Returns: A modified copy of the item.
    public func pubDate(_ date: Date) -> Item {
        var copy = self
        copy.pubDate = date
        return copy
    }

    /// Sets the episode duration in seconds (`itunes:duration`).
    ///
    /// - Parameter seconds: The duration in seconds.
    /// - Returns: A modified copy of the item.
    public func duration(_ seconds: Int) -> Item {
        var copy = self
        copy.itunesDuration = seconds
        return copy
    }

    /// Sets the explicit content flag (`itunes:explicit`).
    ///
    /// - Parameter value: Whether the episode contains explicit content.
    /// - Returns: A modified copy of the item.
    public func explicit(_ value: Bool) -> Item {
        var copy = self
        copy.itunesExplicit = value
        return copy
    }

    /// Sets the episode artwork URL (`itunes:image`).
    ///
    /// - Parameter urlString: The image URL as a string.
    /// - Returns: A modified copy of the item. If the URL is invalid, the image is not set.
    public func image(_ urlString: String) -> Item {
        var copy = self
        copy.itunesImage = URL(string: urlString)
        return copy
    }

    /// Sets the season number (`itunes:season`).
    ///
    /// - Parameter number: The season number.
    /// - Returns: A modified copy of the item.
    public func season(_ number: Int) -> Item {
        var copy = self
        copy.itunesSeason = number
        return copy
    }

    /// Sets the episode number (`itunes:episode`).
    ///
    /// - Parameter number: The episode number.
    /// - Returns: A modified copy of the item.
    public func episode(_ number: Int) -> Item {
        var copy = self
        copy.itunesEpisode = number
        return copy
    }

    /// Sets the episode type (`itunes:episodeType`).
    ///
    /// - Parameter type: Either `"full"`, `"trailer"`, or `"bonus"`.
    /// - Returns: A modified copy of the item.
    public func episodeType(_ type: String) -> Item {
        var copy = self
        copy.itunesEpisodeType = ITunesEpisodeType(rawValue: type)
        return copy
    }

    /// Appends a person (`podcast:person`).
    ///
    /// - Parameters:
    ///   - name: The person's name.
    ///   - role: The role using ``PodcastPerson/Role``.
    /// - Returns: A modified copy of the item.
    public func person(_ name: String, role: PodcastPerson.Role) -> Item {
        var copy = self
        copy.persons.append(PodcastPerson(name: name, role: role.rawValue))
        return copy
    }

    /// Appends a transcript (`podcast:transcript`).
    ///
    /// - Parameters:
    ///   - url: The transcript file URL as a string.
    ///   - type: The transcript type using ``Transcript/TranscriptType``.
    /// - Returns: A modified copy of the item. If the URL is invalid, no transcript is added.
    public func transcript(url: String, type: Transcript.TranscriptType) -> Item {
        var copy = self
        if let transcriptURL = URL(string: url) {
            copy.transcripts.append(Transcript(url: transcriptURL, type: type.rawValue))
        }
        return copy
    }

    /// Sets the chapters link (`podcast:chapters`).
    ///
    /// - Parameter url: The JSON chapters file URL as a string.
    /// - Returns: A modified copy of the item. If the URL is invalid, the chapters link is not set.
    public func chapters(url: String) -> Item {
        var copy = self
        if let chaptersURL = URL(string: url) {
            copy.chaptersLink = ChaptersLink(url: chaptersURL, type: "application/json+chapters")
        }
        return copy
    }

    /// Appends a soundbite (`podcast:soundbite`).
    ///
    /// - Parameters:
    ///   - start: The start time in seconds.
    ///   - duration: The duration in seconds.
    ///   - title: Optional title for the soundbite.
    /// - Returns: A modified copy of the item.
    public func soundbite(start: Double, duration: Double, title: String? = nil) -> Item {
        var copy = self
        copy.soundbites.append(Soundbite(startTime: start, duration: duration, title: title))
        return copy
    }

    /// Sets the rich HTML content (`content:encoded`).
    ///
    /// - Parameter html: The HTML content.
    /// - Returns: A modified copy of the item.
    public func contentEncoded(_ html: String) -> Item {
        var copy = self
        copy.contentEncoded = ContentEncoded(value: html)
        return copy
    }
}

// MARK: - Enclosure Convenience Factories

extension Enclosure {

    /// Creates an MP3 enclosure (`audio/mpeg`).
    ///
    /// - Parameters:
    ///   - url: The MP3 file URL as a string.
    ///   - length: The file size in bytes.
    /// - Returns: An `Enclosure` configured for MP3, or `nil` if the URL is invalid.
    public static func mp3(url: String, length: Int) -> Enclosure? {
        guard let parsed = URL(string: url) else { return nil }
        return Enclosure(url: parsed, length: length, mimeType: .mpeg)
    }

    /// Creates an M4A enclosure (`audio/m4a`).
    ///
    /// - Parameters:
    ///   - url: The M4A file URL as a string.
    ///   - length: The file size in bytes.
    /// - Returns: An `Enclosure` configured for M4A, or `nil` if the URL is invalid.
    public static func m4a(url: String, length: Int) -> Enclosure? {
        guard let parsed = URL(string: url) else { return nil }
        return Enclosure(url: parsed, length: length, mimeType: .m4a)
    }

    /// Creates an MP4 video enclosure (`video/mp4`).
    ///
    /// - Parameters:
    ///   - url: The MP4 file URL as a string.
    ///   - length: The file size in bytes.
    /// - Returns: An `Enclosure` configured for MP4 video, or `nil` if the URL is invalid.
    public static func mp4(url: String, length: Int) -> Enclosure? {
        guard let parsed = URL(string: url) else { return nil }
        return Enclosure(url: parsed, length: length, mimeType: .mp4)
    }
}

// MARK: - PodcastPerson.Role

extension PodcastPerson {

    /// Common roles for podcast people per the Podcast Taxonomy.
    ///
    /// - SeeAlso: [Podcast Taxonomy](https://podcasttaxonomy.com)
    public enum Role: String, CaseIterable, Sendable, Hashable, Equatable {

        /// The main host of the show.
        case host

        /// A guest appearing on the show.
        case guest

        /// The audio or content editor.
        case editor

        /// The show's producer.
        case producer

        /// A writer for the show.
        case writer

        /// The visual/graphic designer.
        case designer

        /// The music composer.
        case composer

        /// The narrator or voice actor.
        case narrator
    }
}
