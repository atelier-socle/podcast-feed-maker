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

struct PodcastFeedMakerTests {

    @Test
    func test_xmlRepresentation_generatesValidFeed() throws {
        let channelLink = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/image.jpg")
        let channel = Channel(
            title: "My Podcast",
            link: channelLink,
            description: "Welcome to the show!",
            itunesAuthor: "Jane Doe",
            itunesCategories: [ITunesCategory(.technology)],
            itunesExplicit: false,
            itunesImage: imageURL
        )

        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)

        let xml = try maker.generate()

        #expect(xml.contains("<rss version=\"2.0\""))
        #expect(xml.contains("<channel>"))
        #expect(xml.contains("<title>My Podcast</title>"))
        #expect(xml.contains("<link>https://example.com</link>"))
        #expect(xml.contains("<description>Welcome to the show!</description>"))
        #expect(xml.contains("<itunes:author>Jane Doe</itunes:author>"))
    }

    @Test
    func test_xmlRepresentation_throwsIfChannelIsNil() {
        let feed = PodcastFeed(channel: nil)
        let maker = PodcastFeedMaker(feed)

        #expect(throws: GeneratorError.self) {
            _ = try maker.generate()
        }
    }

    @Test("generateStream yields chunks")
    func generateStreamYieldsChunks() async throws {
        let streamLink = makeURL("https://example.com")
        let channel = Channel(
            title: "Stream Test",
            link: streamLink,
            description: "Testing stream"
        )
        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)
        var chunks: [String] = []
        for try await chunk in maker.generateStream() {
            chunks.append(chunk)
        }
        #expect(chunks.count == 2)
        #expect(chunks.first?.contains("<channel>") == true)
    }

    @Test("generateStream with prettyPrint false")
    func generateStreamMinified() async throws {
        let minLink = makeURL("https://example.com")
        let channel = Channel(
            title: "Stream Test",
            link: minLink,
            description: "Testing stream"
        )
        let feed = PodcastFeed(channel: channel)
        let maker = PodcastFeedMaker(feed)
        var chunks: [String] = []
        for try await chunk in maker.generateStream(prettyPrint: false) {
            chunks.append(chunk)
        }
        #expect(chunks.count == 2)
    }
}
