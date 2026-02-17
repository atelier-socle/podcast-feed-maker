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

struct PodcastTextFieldTests {

    // MARK: - Initialization

    @Test
    func initWithValueAndPurpose() {
        let txt = PodcastTxt(value: "S6lpp-7ZCn8-VZNOk", purpose: "verify")

        #expect(txt.value == "S6lpp-7ZCn8-VZNOk")
        #expect(txt.purpose == "verify")
    }

    @Test
    func initWithValueOnly() {
        let txt = PodcastTxt(value: "Some generic text")

        #expect(txt.value == "Some generic text")
        #expect(txt.purpose == nil)
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let a = PodcastTxt(value: "abc", purpose: "verify")
        let b = PodcastTxt(value: "abc", purpose: "verify")
        let c = PodcastTxt(value: "xyz")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let a = PodcastTxt(value: "abc", purpose: "verify")
        let b = PodcastTxt(value: "abc", purpose: "verify")
        let c = PodcastTxt(value: "xyz")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
        #expect(set.contains(a))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationWithPurpose() {
        let txt = PodcastTxt(value: "1234567890", purpose: "verify")

        var attrs: [(String, String)] = []
        if let purpose = txt.purpose { attrs.append(("purpose", purpose)) }
        let xml = XMLBuilder().element("podcast:txt", content: txt.value, attributes: attrs)

        #expect(xml.contains("podcast:txt"))
        #expect(xml.contains(#"purpose="verify""#))
        #expect(xml.contains(">1234567890</podcast:txt>"))
    }

    @Test
    func xmlRepresentationWithoutPurpose() {
        let txt = PodcastTxt(value: "Some generic text")

        var attrs: [(String, String)] = []
        if let purpose = txt.purpose { attrs.append(("purpose", purpose)) }
        let xml = XMLBuilder().element("podcast:txt", content: txt.value, attributes: attrs)

        #expect(xml.contains("podcast:txt"))
        #expect(xml.contains(">Some generic text</podcast:txt>"))
        #expect(!xml.contains("purpose="))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(PodcastTxt.self)
    }
}
