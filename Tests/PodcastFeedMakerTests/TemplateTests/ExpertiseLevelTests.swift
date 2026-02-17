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

@Suite("ExpertiseLevel")
struct ExpertiseLevelTests {

    @Test("raw values are 0-3")
    func rawValues() {
        #expect(ExpertiseLevel.basic.rawValue == 0)
        #expect(ExpertiseLevel.standard.rawValue == 1)
        #expect(ExpertiseLevel.advanced.rawValue == 2)
        #expect(ExpertiseLevel.expert.rawValue == 3)
    }

    @Test("Comparable ordering")
    func comparableOrdering() {
        #expect(ExpertiseLevel.basic < .standard)
        #expect(ExpertiseLevel.standard < .advanced)
        #expect(ExpertiseLevel.advanced < .expert)
        #expect(!(ExpertiseLevel.expert < .basic))
    }

    @Test("CaseIterable has 4 cases")
    func caseIterable() {
        #expect(ExpertiseLevel.allCases.count == 4)
        #expect(ExpertiseLevel.allCases == [.basic, .standard, .advanced, .expert])
    }

    @Test("description matches case names")
    func descriptions() {
        #expect(ExpertiseLevel.basic.description == "basic")
        #expect(ExpertiseLevel.standard.description == "standard")
        #expect(ExpertiseLevel.advanced.description == "advanced")
        #expect(ExpertiseLevel.expert.description == "expert")
    }

    @Test("Hashable — distinct hash values")
    func hashable() {
        let set: Set<ExpertiseLevel> = [.basic, .standard, .advanced, .expert]
        #expect(set.count == 4)
    }

    @Test("Equatable — same and different values")
    func equatable() {
        #expect(ExpertiseLevel.basic == .basic)
        #expect(ExpertiseLevel.basic != .standard)
    }

    @Test("Codable round-trip preserves all levels")
    func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        for level in ExpertiseLevel.allCases {
            let data = try encoder.encode(level)
            let decoded = try decoder.decode(ExpertiseLevel.self, from: data)
            #expect(decoded == level)
        }
    }
}
