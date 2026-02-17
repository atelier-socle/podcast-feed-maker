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

/// Represents the `<skipHours>` and `<skipDays>` elements from RSS 2.0.
///
/// These elements hint to aggregators about periods when the feed is not updated,
/// allowing them to skip polling during those times.
///
/// Example:
/// ```xml
/// <skipHours>
///   <hour>0</hour>
///   <hour>1</hour>
/// </skipHours>
/// <skipDays>
///   <day>Saturday</day>
///   <day>Sunday</day>
/// </skipDays>
/// ```
///
/// - SeeAlso: [RSS 2.0 — skipHours](https://www.rssboard.org/rss-specification#ltskiphoursgtSubelementOfLtchannelgt)
public struct SkipSchedule: Sendable, Hashable, Equatable, Codable {

    /// Hours (0-23) when aggregators can skip fetching.
    public var hours: Set<Int>

    /// Days of the week when aggregators can skip fetching.
    public var days: Set<Day>

    /// Creates a new skip schedule.
    ///
    /// - Parameters:
    ///   - hours: Set of hours (0-23) to skip.
    ///   - days: Set of days to skip.
    public init(hours: Set<Int> = [], days: Set<Day> = []) {
        self.hours = hours
        self.days = days
    }
}

// MARK: - Day

extension SkipSchedule {

    /// Days of the week for the `<skipDays>` element.
    public enum Day: String, CaseIterable, Hashable, Equatable, Sendable, Codable {
        case monday = "Monday"
        case tuesday = "Tuesday"
        case wednesday = "Wednesday"
        case thursday = "Thursday"
        case friday = "Friday"
        case saturday = "Saturday"
        case sunday = "Sunday"
    }
}
