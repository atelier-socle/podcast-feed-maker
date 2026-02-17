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

struct ITunesDurationTests {

    // MARK: - Item

    @Test
    func test_item_itunesDuration_withTypicalValue() {
        let item = Item(itunesDuration: 3681)
        #expect(item.itunesDuration == 3681)
    }

    @Test
    func test_item_itunesDuration_withZero() {
        let item = Item(itunesDuration: 0)
        #expect(item.itunesDuration == 0)
    }

    @Test
    func test_item_itunesDuration_withLargeValue() {
        let item = Item(itunesDuration: 999_999)
        #expect(item.itunesDuration == 999_999)
    }

    @Test
    func test_item_itunesDuration_defaultsToNil() {
        let item = Item()
        #expect(item.itunesDuration == nil)
    }

    @Test
    func test_item_itunesDuration_isInt() {
        let item = Item(itunesDuration: 42)
        let duration: Int? = item.itunesDuration
        #expect(duration == 42)
    }

    // MARK: - Equatable

    @Test
    func test_item_equatable_sameDuration() {
        let itemA = Item(itunesDuration: 42)
        let itemB = Item(itunesDuration: 42)
        #expect(itemA == itemB)
    }

    @Test
    func test_item_equatable_differentDuration() {
        let itemA = Item(itunesDuration: 42)
        let itemB = Item(itunesDuration: 99)
        #expect(itemA != itemB)
    }

    // MARK: - Hashable

    @Test
    func test_item_hashable() {
        let itemA = Item(itunesDuration: 42)
        let itemB = Item(itunesDuration: 42)
        let itemC = Item(itunesDuration: 99)
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
