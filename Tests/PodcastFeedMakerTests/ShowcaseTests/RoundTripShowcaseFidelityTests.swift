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
import PodcastFeedMaker
import Testing

// MARK: - Round-Trip Fidelity Features

@Suite("Round-Trip Fidelity Showcase")
struct RoundTripFidelityShowcase {

    // MARK: - Round-Trip Fidelity Features

    @Test("Unknown elements are preserved through round-trip")
    func unknownElementsRoundTrip() throws {
        // Use non-namespaced custom elements to avoid XMLParser namespace issues.
        // The parser captures any unrecognized elements as UnknownElement.
        let xmlWithCustom = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" \
            xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
            \t<title>Custom Elements Show</title>
            \t<link>https://example.com</link>
            \t<description>Has custom elements.</description>
            \t<myrating>5 stars</myrating>
            \t<item>
            \t\t<title>Episode with Custom</title>
            \t\t<enclosure url="https://example.com/ep.mp3" length="1000" type="audio/mpeg"/>
            \t\t<guid>ep-custom</guid>
            \t\t<mysponsor>ACME Corp</mysponsor>
            \t</item>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        // Parse — unknown elements should be captured
        let feed1 = try parser.parse(xmlWithCustom)
        let ch1 = try #require(feed1.channel)
        #expect(!ch1.unknownElements.isEmpty, "Channel should capture unknown elements")

        let channelUnknown = ch1.unknownElements.first { $0.name == "myrating" }
        #expect(channelUnknown?.textContent == "5 stars")

        let item1 = try #require(ch1.items.first)
        let itemUnknown = item1.unknownElements.first { $0.name == "mysponsor" }
        #expect(itemUnknown?.textContent == "ACME Corp")

        // Generate and re-parse
        let xml = try generator.generate(feed1)
        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)

        // Verify unknown elements survived
        let roundTrippedChannel = ch2.unknownElements.first { $0.name == "myrating" }
        #expect(roundTrippedChannel?.textContent == "5 stars")

        let item2 = try #require(ch2.items.first)
        let roundTrippedItem = item2.unknownElements.first { $0.name == "mysponsor" }
        #expect(roundTrippedItem?.textContent == "ACME Corp")
    }

    @Test("CDATA sections are preserved through round-trip")
    func cdataSectionsRoundTrip() throws {
        let xmlWithCDATA = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" \
            xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" \
            xmlns:content="http://purl.org/rss/1.0/modules/content/">
            <channel>
            \t<title>CDATA Show</title>
            \t<link>https://example.com</link>
            \t<description><![CDATA[A show with <em>HTML</em> in CDATA.]]></description>
            \t<item>
            \t\t<title>CDATA Episode</title>
            \t\t<description><![CDATA[Episode with <strong>bold</strong> text.]]></description>
            \t\t<enclosure url="https://example.com/ep.mp3" length="5000" type="audio/mpeg"/>
            \t\t<guid>ep-cdata</guid>
            \t\t<content:encoded><![CDATA[<h1>Full HTML</h1><p>Paragraph.</p>]]></content:encoded>
            \t</item>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        let feed1 = try parser.parse(xmlWithCDATA)
        let ch1 = try #require(feed1.channel)

        // Verify CDATA fields are tracked
        #expect(ch1.cdataFields.contains("description"))

        let item1 = try #require(ch1.items.first)
        #expect(item1.cdataFields.contains("description"))
        #expect(item1.contentEncoded?.value == "<h1>Full HTML</h1><p>Paragraph.</p>")

        // Generate and re-parse
        let xml = try generator.generate(feed1)
        #expect(xml.contains("CDATA"), "Generated XML should contain CDATA sections")

        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)
        let item2 = try #require(ch2.items.first)

        // Content survives — CDATA is transparent to the parser
        #expect(ch2.description.contains("HTML"))
        #expect(item2.description?.contains("bold") == true)
        #expect(item2.contentEncoded?.value == "<h1>Full HTML</h1><p>Paragraph.</p>")
    }

    @Test("XML comments are preserved through round-trip")
    func xmlCommentsRoundTrip() throws {
        let xmlWithComments = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
            \t<title>Comments Show</title>
            \t<link>https://example.com</link>
            \t<description>Has XML comments.</description>
            \t<!-- Channel-level comment -->
            \t<item>
            \t\t<title>Commented Episode</title>
            \t\t<enclosure url="https://example.com/ep.mp3" length="1000" type="audio/mpeg"/>
            \t\t<guid>ep-comment</guid>
            \t\t<!-- Item-level comment -->
            \t</item>
            </channel>
            </rss>
            """

        let parser = FeedParser()
        let generator = FeedGenerator(namespaceMode: .auto)

        let feed1 = try parser.parse(xmlWithComments)
        let ch1 = try #require(feed1.channel)
        #expect(!ch1.xmlComments.isEmpty, "Channel should capture XML comments")

        let item1 = try #require(ch1.items.first)
        #expect(!item1.xmlComments.isEmpty, "Item should capture XML comments")

        // Generate and re-parse
        let xml = try generator.generate(feed1)
        #expect(xml.contains("<!--"), "Generated XML should preserve comments")

        let feed2 = try parser.parse(xml)
        let ch2 = try #require(feed2.channel)
        #expect(ch1.xmlComments == ch2.xmlComments)

        let item2 = try #require(ch2.items.first)
        #expect(item1.xmlComments == item2.xmlComments)
    }
}
