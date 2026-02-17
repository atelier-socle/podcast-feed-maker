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

/// Errors thrown during feed XML generation.
///
/// `GeneratorError` covers all conditions that prevent the ``FeedGenerator``
/// or ``StreamingFeedGenerator`` from producing valid XML output.
///
/// - SeeAlso: ``FeedGenerator``, ``StreamingFeedGenerator``
public enum GeneratorError: Error, LocalizedError, Equatable, Sendable {

    /// The feed has no channel set.
    case missingChannel

    /// A URL failed validation.
    ///
    /// - Parameters:
    ///   - context: The element or attribute where the invalid URL was found.
    ///   - url: The invalid URL string.
    case invalidURL(String, String)

    /// An encoding or serialization error occurred.
    ///
    /// - Parameter message: A description of the encoding failure.
    case encodingError(String)

    public var errorDescription: String? {
        switch self {
        case .missingChannel:
            "Missing channel — a PodcastFeed must have a channel to generate XML."
        case let .invalidURL(context, url):
            "Invalid URL in \(context): \(url)"
        case let .encodingError(message):
            "Encoding error: \(message)"
        }
    }
}
