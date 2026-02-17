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

/// Errors that can occur during podcast feed parsing.
///
/// `ParserError` covers XML parsing failures, missing required elements,
/// encoding issues, and network errors for URL-based parsing.
public enum ParserError: Error, LocalizedError, Equatable, Sendable {

    /// The XML data could not be parsed.
    case invalidXML(String)

    /// The root `<rss>` element was not found.
    case missingRSSElement

    /// The `<channel>` element was not found inside `<rss>`.
    case missingChannel

    /// The data could not be decoded with the expected encoding.
    case encodingError(String)

    /// A network error occurred while fetching a remote feed.
    case networkError(String)

    public var errorDescription: String? {
        switch self {
        case .invalidXML(let detail):
            return "Invalid XML: \(detail)"
        case .missingRSSElement:
            return "Missing <rss> root element"
        case .missingChannel:
            return "Missing <channel> element"
        case .encodingError(let detail):
            return "Encoding error: \(detail)"
        case .networkError(let detail):
            return "Network error: \(detail)"
        }
    }
}
