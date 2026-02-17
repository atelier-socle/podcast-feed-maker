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

/// The `<podcast:updateFrequency>` element from Podcast Namespace 2.0.
///
/// Provides a hint to podcast aggregators about how often to poll for
/// new episodes. More informative than RSS 2.0's `<ttl>` element.
///
/// - Important: Channel-level only.
///
/// Example:
/// ```xml
/// <podcast:updateFrequency rrule="FREQ=WEEKLY;BYDAY=FR"
///                          dtstart="2021-01-01T05:00:00.000-05:00">
///   Weekly on Fridays
/// </podcast:updateFrequency>
/// ```
///
/// - SeeAlso: [Podcast NS — updateFrequency](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md#update-frequency)
public struct UpdateFrequency: Sendable, Hashable, Equatable, Codable {

    /// A human-readable description of the update schedule.
    public var label: String?

    /// An iCalendar RRULE string (RFC 5545) defining the recurrence pattern.
    public var rrule: String?

    /// The date/time when the recurrence pattern starts (ISO 8601).
    public var dtstart: String?

    /// Whether the feed is complete and no more episodes will be added.
    public var complete: Bool?

    /// Creates a new update frequency.
    ///
    /// - Parameters:
    ///   - label: Optional human-readable description.
    ///   - rrule: Optional iCalendar RRULE.
    ///   - dtstart: Optional start date (ISO 8601 string).
    ///   - complete: Optional completion flag.
    public init(
        label: String? = nil,
        rrule: String? = nil,
        dtstart: String? = nil,
        complete: Bool? = nil
    ) {
        self.label = label
        self.rrule = rrule
        self.dtstart = dtstart
        self.complete = complete
    }
}
