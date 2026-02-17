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

@Suite("TemplateFeedFactory")
struct TemplateFeedFactoryTests {

    // MARK: - Helpers

    private static func makeTestURL() -> URL {
        makeURL("https://example.com")
    }

    @Test("basic factory creates feed with correct namespaces")
    func basicNamespaces() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        )
        let namespaces = Set(feed.namespaces)
        #expect(namespaces.contains(.itunes))
        #expect(namespaces.contains(.atom))
    }

    @Test("basic factory sets channel title, link, description")
    func basicChannelFields() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.basic(
            title: "My Podcast", link: testURL, description: "A great show"
        )
        #expect(feed.channel?.title == "My Podcast")
        #expect(feed.channel?.link == testURL)
        #expect(feed.channel?.description == "A great show")
    }

    @Test("basic factory applies configure closure")
    func basicConfigureClosure() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { channel in
            channel.author("Host").explicit(false).category(.technology)
        }
        #expect(feed.channel?.itunesAuthor == "Host")
        #expect(feed.channel?.itunesExplicit == false)
        #expect(feed.channel?.itunesCategories.count == 1)
    }

    @Test("standard factory includes podcast namespace")
    func standardNamespaces() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.standard(
            title: "Show", link: testURL, description: "About"
        )
        let namespaces = Set(feed.namespaces)
        #expect(namespaces.contains(.podcast))
        #expect(namespaces.contains(.itunes))
        #expect(namespaces.contains(.atom))
    }

    @Test("advanced factory includes content namespace")
    func advancedNamespaces() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.advanced(
            title: "Show", link: testURL, description: "About"
        )
        let namespaces = Set(feed.namespaces)
        #expect(namespaces.contains(.content))
    }

    @Test("expert factory includes all 6 standard namespaces")
    func expertNamespaces() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.expert(
            title: "Show", link: testURL, description: "About"
        )
        for ns in PodcastNamespace.allStandard {
            #expect(feed.namespaces.contains(ns))
        }
    }

    @Test("template factory with generic parameter works")
    func genericFactory() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.template(
            BasicTemplate(),
            title: "Generic", link: testURL, description: "Test"
        )
        #expect(feed.channel?.title == "Generic")
    }

    @Test("configure closure can chain fluent modifiers")
    func fluentChaining() {
        let testURL = Self.makeTestURL()
        let imageURL = makeURL("https://example.com/art.jpg")
        let feed = PodcastFeed.standard(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: "https://example.com/feed.xml", rel: "self")
                .image(imageURL.absoluteString)
                .language("en")
        }
        #expect(feed.channel?.itunesAuthor == "Host")
        #expect(feed.channel?.itunesOwner?.name == "Host")
        #expect(feed.channel?.locked?.isLocked == true)
        #expect(feed.channel?.podcastGuid?.value == "aaaa-bbbb-cccc")
        #expect(feed.channel?.atomLinks.count == 1)
        #expect(feed.channel?.itunesImage == imageURL)
        #expect(feed.channel?.language == "en")
    }

    @Test("factory without configure closure uses identity")
    func noConfigureClosure() {
        let testURL = Self.makeTestURL()
        let feed = PodcastFeed.basic(
            title: "Minimal", link: testURL, description: "Test"
        )
        // Channel should have only the fields set by the Channel init
        #expect(feed.channel?.itunesAuthor == nil)
        #expect(feed.channel?.itunesExplicit == nil)
        #expect(feed.channel?.items.isEmpty == true)
    }
}
