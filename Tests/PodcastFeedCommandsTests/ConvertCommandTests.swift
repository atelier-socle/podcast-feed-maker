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

import ArgumentParser
import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("ConvertCommand Tests")
struct ConvertCommandTests {

    @Test("Parses input and to option")
    func parsesInputAndTo() throws {
        let command = try ConvertCommand.parse(["feed.xml", "--to", "json"])
        #expect(command.input == "feed.xml")
        #expect(command.to == "json")
        #expect(command.output == nil)
    }

    @Test("Parses output option")
    func parsesOutput() throws {
        let command = try ConvertCommand.parse([
            "feed.xml", "--to", "json", "-o", "feed.json"
        ])
        #expect(command.output == "feed.json")
    }

    @Test("Parses PSC format")
    func parsesPSC() throws {
        let command = try ConvertCommand.parse(["chapters.json", "--to", "psc"])
        #expect(command.to == "psc")
    }

    // MARK: - Invalid UTF-8 input

    @Test("Convert with invalid UTF-8 input throws error")
    func convertInvalidUTF8Throws() throws {
        let path = "/tmp/pfm_invalid_utf8_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Write bytes that are not valid UTF-8
        let invalidBytes: [UInt8] = [0xFF, 0xFE, 0x80, 0x81, 0xC0, 0xC1]
        let data = Data(invalidBytes)
        try data.write(to: URL(fileURLWithPath: path))

        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([path, "--to", "json"])
            try command.run()
        }
    }

    // MARK: - Malformed standalone PSC content

    @Test("Convert malformed standalone PSC throws error")
    func convertMalformedPSCThrows() throws {
        // Content that triggers isStandalonePSC (contains podlove.org/simple-chapters
        // but not <rss>/<channel>), but the wrapping causes the parsed item to have
        // no podloveChapters because the XML is not valid PSC structure.
        let path = "/tmp/pfm_bad_psc_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        // This references podlove.org/simple-chapters in a comment (triggering
        // isStandalonePSC) but contains no actual psc:chapter elements to parse.
        // The parser will fail to produce chapters from nested arbitrary XML.
        let badContent = """
            <!-- xmlns:psc="http://podlove.org/simple-chapters" -->
            <invalid>not real chapters</invalid>
            """
        try badContent.write(toFile: path, atomically: true, encoding: .utf8)

        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([path, "--to", "json"])
            try command.run()
        }
    }

    // MARK: - PSC to JSON with diverse timestamp formats

    @Test("Convert PSC to JSON handles MM:SS and seconds-only timestamps")
    func convertPSCDiverseTimestamps() throws {
        let path = "/tmp/pfm_psc_timestamps_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        // PSC XML with three timestamp formats: HH:MM:SS, MM:SS, and seconds-only.
        // No XML declaration — it will be wrapped in an RSS envelope by ConvertCommand.
        let pscContent = """
            <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
              <psc:chapter start="00:00:00" title="Intro" />
              <psc:chapter start="05:30" title="Topic One" />
              <psc:chapter start="120" title="Topic Two" />
            </psc:chapters>
            """
        try pscContent.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try ConvertCommand.parse([path, "--to", "json"])
        try command.run()
    }

    // MARK: - PSC with 4-part timestamp (default branch in parseNPTToSeconds)

    @Test("Convert PSC with 4-part timestamp falls back to zero seconds")
    func convertPSCFourPartTimestamp() throws {
        let path = "/tmp/pfm_psc_4part_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        // A 4-part timestamp like "1:2:3:4" has parts.count == 4,
        // which hits the `default: return 0` branch at line 190.
        let pscContent = """
            <psc:chapters version="1.2" xmlns:psc="http://podlove.org/simple-chapters">
              <psc:chapter start="1:2:3:4" title="Four Part Timestamp" />
              <psc:chapter start="00:05:00" title="Valid Chapter" />
            </psc:chapters>
            """
        try pscContent.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try ConvertCommand.parse([path, "--to", "json"])
        try command.run()
    }

    // MARK: - Unsupported conversion format

    @Test("Convert with unsupported target format throws error")
    func convertUnsupportedFormat() throws {
        let path = "/tmp/pfm_unsupported_\(UUID()).txt"
        defer { try? FileManager.default.removeItem(atPath: path) }

        try "some content".write(toFile: path, atomically: true, encoding: .utf8)

        #expect(throws: (any Error).self) {
            var command = try ConvertCommand.parse([path, "--to", "yaml"])
            try command.run()
        }
    }
}
