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

/// Resolves a user-provided source string into a URL or file path.
enum InputResolver {

    /// The resolved input type.
    enum ResolvedInput {
        /// A URL (http, https, or file).
        case url(URL)
        /// A local file path.
        case file(String)
    }

    /// Resolves a source string to either a URL or file path.
    ///
    /// - Parameter source: A file path or URL string from the user.
    /// - Returns: The resolved input type.
    /// - Throws: If the source is a URL with an invalid format.
    static func resolve(_ source: String) throws -> ResolvedInput {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
            || trimmed.hasPrefix("file://")
        {
            guard let url = URL(string: trimmed) else {
                throw InputError.invalidURL(trimmed)
            }
            return .url(url)
        }

        return .file(trimmed)
    }
}

/// Errors related to input resolution.
enum InputError: Error, CustomStringConvertible {

    /// The provided URL string could not be parsed.
    case invalidURL(String)

    /// The file was not found at the specified path.
    case fileNotFound(String)

    /// The file could not be read.
    case fileReadError(String, Error)

    var description: String {
        switch self {
        case .invalidURL(let url):
            "Invalid URL: \(url)"
        case .fileNotFound(let path):
            "File not found: \(path)"
        case .fileReadError(let path, let error):
            "Cannot read file '\(path)': \(error.localizedDescription)"
        }
    }
}
