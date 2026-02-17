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

@Suite("Round-Trip Tests")
struct RoundTripTests {

    let feedParser = FeedParser()

    // MARK: - Minimal Round Trip

    @Test("Minimal feed survives round-trip")
    func minimalRoundTrip() throws {
        let original = try feedParser.parse(minimalXML)
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        #expect(original.channel?.title == reparsed.channel?.title)
        #expect(original.channel?.link == reparsed.channel?.link)
        #expect(original.channel?.description == reparsed.channel?.description)
    }

    // MARK: - Full Feed Round Trip

    @Test("Full feed channel metadata survives round-trip")
    func fullChannelRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origCh = try #require(original.channel)
        let reCh = try #require(reparsed.channel)

        #expect(origCh.title == reCh.title)
        #expect(origCh.link == reCh.link)
        #expect(origCh.description == reCh.description)
        #expect(origCh.language == reCh.language)
        #expect(origCh.copyright == reCh.copyright)
        #expect(origCh.managingEditor == reCh.managingEditor)
        #expect(origCh.generator == reCh.generator)
        #expect(origCh.ttl == reCh.ttl)
    }

    @Test("iTunes metadata survives round-trip")
    func itunesRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origCh = try #require(original.channel)
        let reCh = try #require(reparsed.channel)

        #expect(origCh.itunesAuthor == reCh.itunesAuthor)
        #expect(origCh.itunesBlock == reCh.itunesBlock)
        #expect(origCh.itunesComplete == reCh.itunesComplete)
        #expect(origCh.itunesExplicit == reCh.itunesExplicit)
        #expect(origCh.itunesImage == reCh.itunesImage)
        #expect(origCh.itunesSubtitle == reCh.itunesSubtitle)
        #expect(origCh.itunesTitle == reCh.itunesTitle)
        #expect(origCh.itunesType == reCh.itunesType)
        #expect(origCh.itunesOwner == reCh.itunesOwner)
    }

    @Test("Podcast NS metadata survives round-trip")
    func podcastNSRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origCh = try #require(original.channel)
        let reCh = try #require(reparsed.channel)

        #expect(origCh.podcastGuid == reCh.podcastGuid)
        #expect(origCh.locked == reCh.locked)
        #expect(origCh.medium == reCh.medium)
        #expect(origCh.podpingEnabled == reCh.podpingEnabled)
        #expect(origCh.funding == reCh.funding)
        #expect(origCh.persons == reCh.persons)
        #expect(origCh.location == reCh.location)
        #expect(origCh.license == reCh.license)
        #expect(origCh.podcastBlocks == reCh.podcastBlocks)
        #expect(origCh.txtRecords == reCh.txtRecords)
    }

    @Test("Item count preserved in round-trip")
    func itemCountRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        #expect(original.channel?.items.count == reparsed.channel?.items.count)
    }

    @Test("Item core elements survive round-trip")
    func itemCoreRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origItem = try #require(original.channel?.items.first)
        let reItem = try #require(reparsed.channel?.items.first)

        #expect(origItem.title == reItem.title)
        #expect(origItem.link == reItem.link)
        #expect(origItem.author == reItem.author)
        #expect(origItem.enclosure == reItem.enclosure)
        #expect(origItem.guid == reItem.guid)
    }

    @Test("Item iTunes elements survive round-trip")
    func itemITunesRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origItem = try #require(original.channel?.items.first)
        let reItem = try #require(reparsed.channel?.items.first)

        #expect(origItem.itunesAuthor == reItem.itunesAuthor)
        #expect(origItem.itunesDuration == reItem.itunesDuration)
        #expect(origItem.itunesEpisode == reItem.itunesEpisode)
        #expect(origItem.itunesEpisodeType == reItem.itunesEpisodeType)
        #expect(origItem.itunesExplicit == reItem.itunesExplicit)
        #expect(origItem.itunesSeason == reItem.itunesSeason)
    }

    @Test("Item podcast elements survive round-trip")
    func itemPodcastRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origItem = try #require(original.channel?.items.first)
        let reItem = try #require(reparsed.channel?.items.first)

        #expect(origItem.transcripts == reItem.transcripts)
        #expect(origItem.chaptersLink == reItem.chaptersLink)
        #expect(origItem.soundbites == reItem.soundbites)
        #expect(origItem.persons == reItem.persons)
        #expect(origItem.location == reItem.location)
        #expect(origItem.license == reItem.license)
        #expect(origItem.socialInteractions == reItem.socialInteractions)
        #expect(origItem.txtRecords == reItem.txtRecords)
        #expect(origItem.podcastSeason == reItem.podcastSeason)
        #expect(origItem.podcastEpisode == reItem.podcastEpisode)
    }

    @Test("Podlove chapters survive round-trip")
    func podloveRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origChapters = try #require(
            original.channel?.items.first?.podloveChapters
        )
        let reChapters = try #require(
            reparsed.channel?.items.first?.podloveChapters
        )
        #expect(origChapters == reChapters)
    }

    @Test("Dublin Core survives round-trip")
    func dublinCoreRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origDC = try #require(original.channel?.dublinCore)
        let reDC = try #require(reparsed.channel?.dublinCore)
        #expect(origDC == reDC)
    }

    @Test("Value with time splits survives round-trip")
    func valueTimeSplitsRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origVal = try #require(original.channel?.value)
        let reVal = try #require(reparsed.channel?.value)
        #expect(origVal.type == reVal.type)
        #expect(origVal.method == reVal.method)
        #expect(origVal.recipients == reVal.recipients)
        #expect(origVal.timeSplits.count == reVal.timeSplits.count)
    }

    @Test("AlternateEnclosure survives round-trip")
    func alternateEnclosureRoundTrip() throws {
        let original = try feedParser.parse(maximalFixture())
        let generator = FeedGenerator()
        let xml = try generator.generate(original)
        let reparsed = try feedParser.parse(xml)

        let origEnc = try #require(
            original.channel?.items.first?.alternateEnclosures.first
        )
        let reEnc = try #require(
            reparsed.channel?.items.first?.alternateEnclosures.first
        )
        #expect(origEnc.type == reEnc.type)
        #expect(origEnc.sources.count == reEnc.sources.count)
        #expect(origEnc.integrity == reEnc.integrity)
    }

    // MARK: - Helpers

    private var minimalXML: String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
          <channel>
            <title>Minimal Podcast</title>
            <link>https://example.com</link>
            <description>A minimal podcast feed</description>
          </channel>
        </rss>
        """
    }

    private func maximalFixture() throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: "maximal", withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture maximal.xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
