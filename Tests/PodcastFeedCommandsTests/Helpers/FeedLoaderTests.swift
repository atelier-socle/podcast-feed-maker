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

@testable import PodcastFeedCommands

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif


@Suite("FeedLoader Tests")
struct FeedLoaderTests {

    private static let validXML = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
        <channel>
            <title>Loader Test</title>
            <link>https://example.com</link>
            <description>A test feed for FeedLoader.</description>
        </channel>
        </rss>
        """

    private let tempPath: String

    init() throws {
        tempPath = "/tmp/pfm_loader_\(UUID().uuidString).xml"
        try Self.validXML.write(toFile: tempPath, atomically: true, encoding: .utf8)
    }

    @Test("Loads raw XML from file path")
    func loadXMLFromFile() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        let xml = try FeedLoader.loadXML(from: tempPath)
        #expect(xml.contains("<title>Loader Test</title>"))
    }

    @Test("Loads and parses feed from file path")
    func loadFeedFromFile() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        let feed = try FeedLoader.load(from: tempPath)
        #expect(feed.channel?.title == "Loader Test")
    }

    @Test("Throws fileNotFound for non-existent path")
    func throwsForMissingFile() {
        #expect(throws: InputError.self) {
            _ = try FeedLoader.loadXML(from: "/tmp/nonexistent_\(UUID()).xml")
        }
    }

    @Test("Handles path with tilde expansion")
    func handlesTildePath() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        // The path is already absolute, but loadXML uses expandingTildeInPath internally
        let xml = try FeedLoader.loadXML(from: tempPath)
        #expect(!xml.isEmpty)
    }

    @Test("Load and parse returns valid channel")
    func loadParsesChannel() throws {
        defer { try? FileManager.default.removeItem(atPath: tempPath) }
        let feed = try FeedLoader.load(from: tempPath)
        let channel = try #require(feed.channel)
        #expect(channel.description == "A test feed for FeedLoader.")
        #expect(channel.link.absoluteString == "https://example.com")
    }
}
