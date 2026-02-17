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

/// The `<textInput>` element from the RSS 2.0 specification.
///
/// Specifies a text input box that can be displayed with the channel.
/// The purpose of this element is to allow readers to submit queries
/// or feedback directly from the feed reader.
///
/// Example:
/// ```xml
/// <textInput>
///   <title>Search</title>
///   <description>Search this feed</description>
///   <name>query</name>
///   <link>https://example.com/search</link>
/// </textInput>
/// ```
///
/// - SeeAlso: [RSS 2.0 — textInput](https://www.rssboard.org/rss-specification#lttextinputgtSubelementOfLtchannelgt)
public struct RSSTextInput: Sendable, Hashable, Equatable, Codable {

    /// The label for the Submit button.
    public var title: String

    /// Explains the text input area.
    public var description: String

    /// The name of the text object in the form.
    public var name: String

    /// The URL of the CGI script that processes the request.
    public var link: URL

    /// Creates a new RSS text input element.
    ///
    /// - Parameters:
    ///   - title: The Submit button label.
    ///   - description: A description of the text input.
    ///   - name: The form field name.
    ///   - link: The URL for form submission.
    public init(title: String, description: String, name: String, link: URL) {
        self.title = title
        self.description = description
        self.name = name
        self.link = link
    }
}
