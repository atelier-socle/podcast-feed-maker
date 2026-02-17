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

struct ITunesEpisodeTests {

    // MARK: - Item

    @Test
    func test_item_itunesEpisode_withPositiveValue() {
        let item = Item(itunesEpisode: 3)
        #expect(item.itunesEpisode == 3)
    }

    @Test
    func test_item_itunesEpisode_withZero() {
        let item = Item(itunesEpisode: 0)
        #expect(item.itunesEpisode == 0)
    }

    @Test
    func test_item_itunesEpisode_withLargeValue() {
        let item = Item(itunesEpisode: 999_999)
        #expect(item.itunesEpisode == 999_999)
    }

    @Test
    func test_item_itunesEpisode_defaultsToNil() {
        let item = Item()
        #expect(item.itunesEpisode == nil)
    }

    // MARK: - Equatable

    @Test
    func test_item_equatable_sameEpisode() {
        let itemA = Item(itunesEpisode: 1)
        let itemB = Item(itunesEpisode: 1)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentEpisode() {
        let itemA = Item(itunesEpisode: 1)
        let itemB = Item(itunesEpisode: 2)
        #expect(itemA != itemB)
    }

    // MARK: - Hashable

    @Test
    func test_item_hashable() {
        let itemA = Item(itunesEpisode: 1)
        let itemB = Item(itunesEpisode: 1)
        let itemC = Item(itunesEpisode: 2)
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
