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

struct ITunesSeasonTests {

    // MARK: - Item

    @Test
    func test_item_itunesSeason_shouldStoreValue() {
        let item = Item(itunesSeason: 2)
        #expect(item.itunesSeason == 2)
    }

    @Test
    func test_item_itunesSeason_withSeasonOne() {
        let item = Item(itunesSeason: 1)
        #expect(item.itunesSeason == 1)
    }

    @Test
    func test_item_itunesSeason_withZero() {
        let item = Item(itunesSeason: 0)
        #expect(item.itunesSeason == 0)
    }

    @Test
    func test_item_itunesSeason_withLargeValue() {
        let item = Item(itunesSeason: 100)
        #expect(item.itunesSeason == 100)
    }

    @Test
    func test_item_itunesSeason_defaultsToNil() {
        let item = Item()
        #expect(item.itunesSeason == nil)
    }

    // MARK: - Equatable

    @Test
    func test_item_equatable_sameSeason() {
        let itemA = Item(itunesSeason: 1)
        let itemB = Item(itunesSeason: 1)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentSeason() {
        let itemA = Item(itunesSeason: 1)
        let itemB = Item(itunesSeason: 3)
        #expect(itemA != itemB)
    }

    // MARK: - Hashable

    @Test
    func test_item_hashable() {
        let itemA = Item(itunesSeason: 1)
        let itemB = Item(itunesSeason: 1)
        let itemC = Item(itunesSeason: 3)
        let set: Set = [itemA, itemB, itemC]
        #expect(set.count == 2)
    }

    // MARK: - Sendable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(Item.self)
    }
}
