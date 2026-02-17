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

struct ITunesEpisodeTypeTests {

    // MARK: - Enum Cases and Raw Values

    @Test
    func test_full_rawValue() {
        #expect(ITunesEpisodeType.full.rawValue == "full")
    }

    @Test
    func test_trailer_rawValue() {
        #expect(ITunesEpisodeType.trailer.rawValue == "trailer")
    }

    @Test
    func test_bonus_rawValue() {
        #expect(ITunesEpisodeType.bonus.rawValue == "bonus")
    }

    @Test
    func test_initFromRawValue_full() {
        let episodeType = ITunesEpisodeType(rawValue: "full")
        #expect(episodeType == .full)
    }

    @Test
    func test_initFromRawValue_trailer() {
        let episodeType = ITunesEpisodeType(rawValue: "trailer")
        #expect(episodeType == .trailer)
    }

    @Test
    func test_initFromRawValue_bonus() {
        let episodeType = ITunesEpisodeType(rawValue: "bonus")
        #expect(episodeType == .bonus)
    }

    @Test
    func test_initFromRawValue_invalid() {
        let episodeType = ITunesEpisodeType(rawValue: "unknown")
        #expect(episodeType == nil)
    }

    // MARK: - CaseIterable

    @Test
    func test_allCases_containsThreeCases() {
        #expect(ITunesEpisodeType.allCases.count == 3)
        #expect(ITunesEpisodeType.allCases.contains(.full))
        #expect(ITunesEpisodeType.allCases.contains(.trailer))
        #expect(ITunesEpisodeType.allCases.contains(.bonus))
    }

    // MARK: - Item Integration

    @Test
    func test_item_itunesEpisodeType_full() {
        let item = Item(itunesEpisodeType: .full)
        #expect(item.itunesEpisodeType == .full)
    }

    @Test
    func test_item_itunesEpisodeType_trailer() {
        let item = Item(itunesEpisodeType: .trailer)
        #expect(item.itunesEpisodeType == .trailer)
    }

    @Test
    func test_item_itunesEpisodeType_bonus() {
        let item = Item(itunesEpisodeType: .bonus)
        #expect(item.itunesEpisodeType == .bonus)
    }

    @Test
    func test_item_itunesEpisodeType_defaultsToNil() {
        let item = Item()
        #expect(item.itunesEpisodeType == nil)
    }

    // MARK: - Equatable and Hashable

    @Test
    func test_equatable() {
        #expect(ITunesEpisodeType.bonus == ITunesEpisodeType.bonus)
        #expect(ITunesEpisodeType.bonus != ITunesEpisodeType.trailer)
    }

    @Test
    func test_hashable() {
        let set: Set<ITunesEpisodeType> = [.full, .trailer, .bonus, .bonus]
        #expect(set.count == 3)
    }

    // MARK: - Sendable and Codable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(ITunesEpisodeType.self)
    }

    @Test
    func test_codableConformance() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(ITunesEpisodeType.bonus)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ITunesEpisodeType.self, from: data)
        #expect(decoded == .bonus)
    }
}
