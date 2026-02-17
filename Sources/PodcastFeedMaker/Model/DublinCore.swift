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

/// Dublin Core metadata elements from the `dc:` namespace.
///
/// A collection of optional Dublin Core terms that can be applied at
/// either the channel or item level. The Dublin Core Metadata Element Set
/// provides a standard vocabulary for describing resources.
///
/// Example:
/// ```xml
/// <dc:creator>John Doe</dc:creator>
/// <dc:language>en</dc:language>
/// <dc:rights>Copyright 2024 Example Corp</dc:rights>
/// ```
///
/// - SeeAlso: [Dublin Core Elements](https://www.dublincore.org/specifications/dublin-core/dcmi-terms/)
public struct DublinCore: Sendable, Hashable, Equatable, Codable {

    /// The primary creator of the resource (`dc:creator`).
    public var creator: String?

    /// A contributor to the resource (`dc:contributor`).
    public var contributor: String?

    /// The date of the resource (`dc:date`), typically in W3CDTF format.
    public var date: String?

    /// A description of the resource (`dc:description`).
    public var description: String?

    /// The format of the resource (`dc:format`), e.g., MIME type.
    public var format: String?

    /// A unique identifier for the resource (`dc:identifier`).
    public var identifier: String?

    /// The language of the resource (`dc:language`), BCP 47.
    public var language: String?

    /// The publisher of the resource (`dc:publisher`).
    public var publisher: String?

    /// A related resource (`dc:relation`).
    public var relation: String?

    /// Rights information (`dc:rights`).
    public var rights: String?

    /// A resource from which this resource is derived (`dc:source`).
    public var source: String?

    /// The topic of the resource (`dc:subject`).
    public var subject: String?

    /// The name of the resource (`dc:title`).
    public var title: String?

    /// The nature or genre of the resource (`dc:type`).
    public var type: String?

    /// The spatial or temporal coverage (`dc:coverage`).
    public var coverage: String?

    /// Creates a new Dublin Core metadata set.
    ///
    /// All parameters are optional — only include the elements you need.
    public init(
        creator: String? = nil,
        contributor: String? = nil,
        date: String? = nil,
        description: String? = nil,
        format: String? = nil,
        identifier: String? = nil,
        language: String? = nil,
        publisher: String? = nil,
        relation: String? = nil,
        rights: String? = nil,
        source: String? = nil,
        subject: String? = nil,
        title: String? = nil,
        type: String? = nil,
        coverage: String? = nil
    ) {
        self.creator = creator
        self.contributor = contributor
        self.date = date
        self.description = description
        self.format = format
        self.identifier = identifier
        self.language = language
        self.publisher = publisher
        self.relation = relation
        self.rights = rights
        self.source = source
        self.subject = subject
        self.title = title
        self.type = type
        self.coverage = coverage
    }
}
