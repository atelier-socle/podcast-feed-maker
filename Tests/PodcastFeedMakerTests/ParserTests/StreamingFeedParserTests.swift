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

@Suite("StreamingFeedParser Tests")
struct StreamingFeedParserTests {

    @Test("Streams items from minimal feed")
    func minimalStream() async throws {
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: minimalXML)
        var items: [Item] = []
        for try await item in stream {
            items.append(item)
        }
        #expect(items.isEmpty)
    }

    @Test("Streams correct item count from maximal feed")
    func maximalStreamCount() async throws {
        let parser = StreamingFeedParser()
        let xml = try maximalFixture()
        let stream = parser.parseItems(from: xml)
        var count = 0
        for try await _ in stream {
            count += 1
        }
        #expect(count == 2)
    }

    @Test("Streamed items match parsed items")
    func streamMatchesParse() async throws {
        let feedParser = FeedParser()
        let xml = try maximalFixture()
        let feed = try feedParser.parse(xml)
        let expected = feed.channel?.items ?? []

        let streamParser = StreamingFeedParser()
        let stream = streamParser.parseItems(from: xml)
        var streamed: [Item] = []
        for try await item in stream {
            streamed.append(item)
        }

        #expect(streamed.count == expected.count)
        for (idx, item) in streamed.enumerated() {
            #expect(item.title == expected[idx].title)
            #expect(item.guid == expected[idx].guid)
        }
    }

    @Test("Streams from Data")
    func streamFromData() async throws {
        let data = minimalXML.data(using: .utf8)
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: data ?? Data())
        var items: [Item] = []
        for try await item in stream {
            items.append(item)
        }
        #expect(items.isEmpty)
    }

    @Test("Throws for missing channel in stream")
    func streamMissingChannel() async {
        let parser = StreamingFeedParser()
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        let stream = parser.parseItems(from: xml)
        do {
            for try await _ in stream {
                // Should not reach here
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is ParserError)
        }
    }

    @Test("Streams items with all metadata intact")
    func streamedItemMetadata() async throws {
        let parser = StreamingFeedParser()
        let xml = try maximalFixture()
        let stream = parser.parseItems(from: xml)
        var items: [Item] = []
        for try await item in stream {
            items.append(item)
        }

        let first = try #require(items.first)
        #expect(first.title == "Episode 1: Getting Started")
        #expect(first.enclosure != nil)
        #expect(first.itunesEpisode == 1)
        #expect(first.transcripts.count == 2)
    }

    @Test("Throws for invalid XML in stream")
    func streamInvalidXML() async {
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: "<<<not xml>>>")
        do {
            for try await _ in stream {
                Issue.record("Expected error to be thrown")
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is ParserError)
        }
    }

    @Test("Streams from Data with items")
    func streamFromDataWithItems() async throws {
        let xml = try maximalFixture()
        let data = xml.data(using: .utf8) ?? Data()
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: data)
        var count = 0
        for try await _ in stream {
            count += 1
        }
        #expect(count == 2)
    }

    @Test("Streams from Data with missing channel throws")
    func streamFromDataMissingChannel() async {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        let data = xml.data(using: .utf8) ?? Data()
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: data)
        do {
            for try await _ in stream {
                Issue.record("Expected error")
            }
            Issue.record("Expected error")
        } catch {
            #expect(error is ParserError)
        }
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

    // MARK: - Missing Channel Error Specifics

    @Test("String variant missing channel throws ParserError.missingChannel specifically")
    func stringVariantMissingChannelSpecificError() async {
        let parser = StreamingFeedParser()
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        let stream = parser.parseItems(from: xml)
        do {
            for try await _ in stream {
                Issue.record("Expected error to be thrown")
            }
            Issue.record("Expected error to be thrown")
        } catch let parserError as ParserError {
            #expect(parserError == .missingChannel)
        } catch {
            Issue.record("Expected ParserError.missingChannel, got \(error)")
        }
    }

    @Test("Data variant missing channel throws ParserError.missingChannel specifically")
    func dataVariantMissingChannelSpecificError() async {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        let data = xml.data(using: .utf8) ?? Data()
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: data)
        do {
            for try await _ in stream {
                Issue.record("Expected error to be thrown")
            }
            Issue.record("Expected error to be thrown")
        } catch let parserError as ParserError {
            #expect(parserError == .missingChannel)
        } catch {
            Issue.record("Expected ParserError.missingChannel, got \(error)")
        }
    }

    @Test("String variant with RSS element but no channel yields no items and throws")
    func stringVariantRssNoChannelNoItems() async {
        let parser = StreamingFeedParser()
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            </rss>
            """
        let stream = parser.parseItems(from: xml)
        var itemCount = 0
        do {
            for try await _ in stream {
                itemCount += 1
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(itemCount == 0)
            #expect(error is ParserError)
        }
    }

    @Test("Data variant invalid XML throws ParserError")
    func dataVariantInvalidXML() async {
        let data = Data("<<<not xml>>>".utf8)
        let parser = StreamingFeedParser()
        let stream = parser.parseItems(from: data)
        do {
            for try await _ in stream {
                Issue.record("Expected error to be thrown")
            }
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is ParserError)
        }
    }

    // MARK: - Missing Channel Guard Path

    @Test("parseItems from string with no channel throws missingChannel")
    func parseItemsStringNoChannel() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        let parser = StreamingFeedParser()
        var thrownError: (any Error)?
        do {
            for try await _ in parser.parseItems(from: xml) {
                Issue.record("Should not yield items")
            }
        } catch {
            thrownError = error
        }
        #expect(thrownError is ParserError)
    }

    @Test("parseItems from data with no channel throws missingChannel")
    func parseItemsDataNoChannel() async throws {
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0"></rss>
            """
        let data = Data(xml.utf8)
        let parser = StreamingFeedParser()
        var thrownError: (any Error)?
        do {
            for try await _ in parser.parseItems(from: data) {
                Issue.record("Should not yield items")
            }
        } catch {
            thrownError = error
        }
        #expect(thrownError is ParserError)
    }
}
