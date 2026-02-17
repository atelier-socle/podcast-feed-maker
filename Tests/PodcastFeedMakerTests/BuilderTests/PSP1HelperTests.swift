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

// MARK: - PSP-1 Compliance Helper Tests

@Suite("PSP-1 Compliance Helper")
struct PSP1HelperTests {

    private func makePSP1Feed() -> PodcastFeed {
        let url = makeURL("https://example.com")
        let feedURL = makeURL("https://example.com/feed.xml")
        let imageURL = makeURL("https://example.com/artwork.jpg")
        let config = PSP1Configuration(
            title: "PSP-1 Podcast",
            link: url,
            description: "A PSP-1 compliant podcast",
            feedURL: feedURL,
            author: "Host Name",
            ownerName: "Owner Name",
            ownerEmail: "owner@example.com",
            category: .technology,
            explicit: false,
            imageURL: imageURL,
            podcastGUID: "ead4c236-bf58-58c6-a2c6-a6b28d128cb6"
        )
        return PodcastFeed.psp1Compliant(config: config)
    }

    @Test("sets channel title")
    func setsTitle() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.title == "PSP-1 Podcast")
    }

    @Test("sets channel link")
    func setsLink() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.link.absoluteString == "https://example.com")
    }

    @Test("sets channel description")
    func setsDescription() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.description == "A PSP-1 compliant podcast")
    }

    @Test("sets itunesAuthor")
    func setsAuthor() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesAuthor == "Host Name")
    }

    @Test("sets itunesOwner with name and email")
    func setsOwner() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesOwner?.name == "Owner Name")
        #expect(feed.channel?.itunesOwner?.email == "owner@example.com")
    }

    @Test("sets itunesCategory")
    func setsCategory() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesCategories.count == 1)
        #expect(feed.channel?.itunesCategories[0].text == "Technology")
    }

    @Test("sets itunesExplicit")
    func setsExplicit() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesExplicit == false)
    }

    @Test("sets itunesImage")
    func setsImage() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.itunesImage?.absoluteString == "https://example.com/artwork.jpg")
    }

    @Test("sets atom:link with rel=self")
    func setsAtomLink() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.atomLinks.count == 1)
        #expect(feed.channel?.atomLinks[0].rel == "self")
        #expect(feed.channel?.atomLinks[0].href.absoluteString == "https://example.com/feed.xml")
        #expect(feed.channel?.atomLinks[0].type == "application/rss+xml")
    }

    @Test("sets podcast:guid")
    func setsGuid() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.podcastGuid?.value == "ead4c236-bf58-58c6-a2c6-a6b28d128cb6")
    }

    @Test("sets podcast:locked with owner email")
    func setsLocked() {
        let feed = makePSP1Feed()
        #expect(feed.channel?.locked?.isLocked == true)
        #expect(feed.channel?.locked?.owner == "owner@example.com")
    }

    @Test("uses allStandard namespaces")
    func usesAllStandardNamespaces() {
        let feed = makePSP1Feed()
        #expect(feed.namespaces == PodcastNamespace.allStandard)
    }

    @Test("passes PSP-1 validation with zero errors")
    func passesPSP1Validation() {
        let feed = makePSP1Feed()
        let report = FeedValidator().validate(feed, for: .psp1)
        #expect(report.isValid)
        #expect(report.errors.isEmpty)
    }

    @Test("generates valid XML")
    func generatesValidXML() throws {
        let feed = makePSP1Feed()
        let xml = try FeedGenerator().generate(feed)
        #expect(xml.contains("PSP-1 Podcast"))
        #expect(xml.contains("podcast:guid"))
        #expect(xml.contains("podcast:locked"))
        #expect(xml.contains("atom:link"))
    }
}
