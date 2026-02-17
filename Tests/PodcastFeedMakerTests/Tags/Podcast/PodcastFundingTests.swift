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

struct PodcastFundingTests {

    // MARK: - Initialization

    @Test
    func initSetsPropertiesCorrectly() {
        let url = makeURL("https://patreon.com/myshow")
        let funding = Funding(url: url, message: "Support us on Patreon")

        #expect(funding.url == url)
        #expect(funding.message == "Support us on Patreon")
    }

    // MARK: - Equatable & Hashable

    @Test
    func equatableConformance() {
        let urlA = makeURL("https://a.com")
        let urlB = makeURL("https://b.com")

        let a = Funding(url: urlA, message: "A")
        let b = Funding(url: urlA, message: "A")
        let c = Funding(url: urlB, message: "B")

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func hashableConformance() {
        let urlA = makeURL("https://a.com")
        let urlB = makeURL("https://b.com")

        let a = Funding(url: urlA, message: "A")
        let b = Funding(url: urlA, message: "A")
        let c = Funding(url: urlB, message: "B")

        let set: Set = [a, b, c]
        #expect(set.count == 2)
        #expect(set.contains(a))
    }

    // MARK: - XML Representation

    @Test
    func xmlRepresentationContainsUrlAndMessage() {
        let fundingURL = makeURL("https://patreon.com/myshow")
        let funding = Funding(
            url: fundingURL,
            message: "Support us on Patreon"
        )

        let xml = XMLBuilder().element(
            "podcast:funding",
            content: funding.message,
            attributes: [("url", XMLBuilder.encodeURL(funding.url))]
        )

        #expect(xml.contains("podcast:funding"))
        #expect(xml.contains(#"url="https://patreon.com/myshow""#))
        #expect(xml.contains("Support us on Patreon"))
    }

    @Test
    func xmlRepresentationWrapsMessageAsElementContent() {
        let donateURL = makeURL("https://example.com/donate")
        let funding = Funding(
            url: donateURL,
            message: "Donate here"
        )

        let xml = XMLBuilder().element(
            "podcast:funding",
            content: funding.message,
            attributes: [("url", XMLBuilder.encodeURL(funding.url))]
        )

        #expect(xml.contains(">Donate here</podcast:funding>"))
    }

    // MARK: - Sendable

    @Test
    func sendableConformance() {
        func requiresSendable<T: Sendable>(_: T.Type) {}
        requiresSendable(Funding.self)
    }
}
