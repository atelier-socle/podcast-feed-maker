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
import Testing

@testable import PodcastFeedMaker

struct RcfPubDateTests {

    @Test
    func test_rfc2822Date_returnsCorrectFormat() throws {
        // Fixed reference date: 1 January 2024 at 15:30:45 UTC
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 1
        components.hour = 15
        components.minute = 30
        components.second = 45
        components.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar(identifier: .gregorian)
        let date = try #require(calendar.date(from: components))

        let expected = "Mon, 01 Jan 2024 15:30:45 +0000"
        #expect(XMLBuilder.rfc2822Date(date) == expected)
    }

    @Test
    func test_rfc2822Date_respectsEnglishLocale() throws {
        // We check that even on non-English devices, the weekday and month are in English
        let date = try #require(ISO8601DateFormatter().date(from: "2025-03-26T18:00:00Z"))
        let result = XMLBuilder.rfc2822Date(date)

        // Expected starts with English weekday and month
        #expect(result.starts(with: "Wed, 26 Mar 2025"))
    }
}
