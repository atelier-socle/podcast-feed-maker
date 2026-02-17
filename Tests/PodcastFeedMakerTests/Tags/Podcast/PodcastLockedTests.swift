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

struct PodcastLockedTests {

    // MARK: - Initialization

    @Test
    func initWithIsLockedOnly() {
        let locked = Locked(isLocked: true)

        #expect(locked.isLocked == true)
        #expect(locked.owner == nil)
    }

    @Test
    func initWithIsLockedAndOwner() {
        let locked = Locked(isLocked: true, owner: "john@example.com")

        #expect(locked.isLocked == true)
        #expect(locked.owner == "john@example.com")
    }

    @Test
    func initWithUnlockedState() {
        let locked = Locked(isLocked: false)

        #expect(locked.isLocked == false)
        #expect(locked.owner == nil)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = Locked(isLocked: true, owner: "a@example.com")
        let b = Locked(isLocked: true, owner: "a@example.com")
        let c = Locked(isLocked: false)

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let lockedTrue = Locked(isLocked: true)
        let lockedFalse = Locked(isLocked: false)

        let set: Set = [lockedTrue, lockedFalse]
        #expect(set.count == 2)
        #expect(set.contains(Locked(isLocked: true)))
        #expect(set.contains(Locked(isLocked: false)))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWhenLocked() {
        let locked = Locked(isLocked: true)

        var attrs: [(String, String)] = []
        if let owner = locked.owner { attrs.append(("owner", owner)) }
        let xml = XMLBuilder().element("podcast:locked", content: XMLBuilder.boolYesNo(locked.isLocked), attributes: attrs)

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains(">yes</podcast:locked>"))
    }

    @Test
    func xmlRepresentationWhenUnlocked() {
        let locked = Locked(isLocked: false)

        var attrs: [(String, String)] = []
        if let owner = locked.owner { attrs.append(("owner", owner)) }
        let xml = XMLBuilder().element("podcast:locked", content: XMLBuilder.boolYesNo(locked.isLocked), attributes: attrs)

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains(">no</podcast:locked>"))
    }

    @Test
    func xmlRepresentationWithOwner() {
        let locked = Locked(isLocked: true, owner: "john@example.com")

        var attrs: [(String, String)] = []
        if let owner = locked.owner { attrs.append(("owner", owner)) }
        let xml = XMLBuilder().element("podcast:locked", content: XMLBuilder.boolYesNo(locked.isLocked), attributes: attrs)

        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains(#"owner="john@example.com""#))
        #expect(xml.contains(">yes</podcast:locked>"))
    }

    @Test
    func xmlRepresentationWithoutOwner() {
        let locked = Locked(isLocked: true)

        var attrs: [(String, String)] = []
        if let owner = locked.owner { attrs.append(("owner", owner)) }
        let xml = XMLBuilder().element("podcast:locked", content: XMLBuilder.boolYesNo(locked.isLocked), attributes: attrs)

        #expect(!xml.contains("owner="))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Locked.self)
    }
}
