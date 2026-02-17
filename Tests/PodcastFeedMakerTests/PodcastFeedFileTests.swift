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

struct PodcastFeedFileTests {

    @Test
    func test_writeFeedToTemporaryFile_andDeleteAfter() throws {
        let maker = try PodcastFeedMaker(MockFeed.applePodcasts())
        let xml = try maker.generate()

        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp-feed.xml")

        try xml.write(to: fileURL, atomically: true, encoding: .utf8)

        #expect(fileManager.fileExists(atPath: fileURL.path))

        let read = try String(contentsOf: fileURL, encoding: .utf8)
        #expect(read.contains("<rss version=\"2.0\""))

        try fileManager.removeItem(at: fileURL)
        #expect(!fileManager.fileExists(atPath: fileURL.path))
    }

    @Test
    func test_writeAndCleanTemporaryFeedFile() throws {
        let maker = try PodcastFeedMaker(MockFeed.applePodcasts())
        let xml = try maker.generate()

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("temp-feed-\(UUID().uuidString).xml")

        defer {
            try? FileManager.default.removeItem(at: fileURL)
        }

        try xml.write(to: fileURL, atomically: true, encoding: .utf8)

        #expect(FileManager.default.fileExists(atPath: fileURL.path))

        let contents = try String(contentsOf: fileURL)
        #expect(contents.contains("<rss version=\"2.0\""))
    }
}
