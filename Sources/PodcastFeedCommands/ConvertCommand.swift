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
import PodcastFeedMaker

/// Converts between feed/chapter formats.
struct ConvertCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "convert",
        abstract: "Convert between feed and chapter formats."
    )

    @Argument(help: "Input file path.")
    var input: String

    @Option(name: .long, help: "Target format: json, xml, psc.")
    var to: String

    @Option(name: .shortAndLong, help: "Output file path (stdout if omitted).")
    var output: String?

    @Flag(help: "Pretty-print output (default: true).")
    var pretty: Bool = false

    @Flag(name: .long, help: "Disable colored output.")
    var noColor: Bool = false

    mutating func run() throws {
        let expandedPath = NSString(string: input).expandingTildeInPath
        let inputURL = URL(fileURLWithPath: expandedPath)
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw InputError.fileNotFound(input)
        }

        let data = try Data(contentsOf: inputURL)
        let ext = (input as NSString).pathExtension.lowercased()

        let result: String

        switch (ext, to) {
        case ("xml", "json"):
            if isStandalonePSC(data) {
                result = try convertPSCToJSONChapters(data)
            } else {
                result = try convertFeedXMLToJSON(data)
            }
        case ("json", "xml"):
            result = try convertFeedJSONToXML(data)
        case ("json", "psc"):
            result = try convertJSONChaptersToPSC(data)
        default:
            if to == "json" {
                // Try as feed XML
                result = try convertFeedXMLToJSON(data)
            } else if to == "xml" {
                // Try as feed JSON
                result = try convertFeedJSONToXML(data)
            } else if to == "psc" {
                result = try convertJSONChaptersToPSC(data)
            } else {
                throw ValidationError(
                    "Unsupported conversion: .\(ext) -> .\(to). "
                        + "Supported: xml->json, json->xml, json->psc"
                )
            }
        }

        if let outputPath = output {
            try result.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("Converted output written to \(outputPath)")
        } else {
            print(result)
        }
    }

    // MARK: - Feed Conversions

    private func convertFeedXMLToJSON(_ data: Data) throws -> String {
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw ValidationError("Cannot read input as UTF-8 text.")
        }
        let feed = try FeedParser().parse(xmlString)
        return try OutputFormatter.jsonString(feed)
    }

    private func convertFeedJSONToXML(_ data: Data) throws -> String {
        let feed = try JSONDecoder().decode(PodcastFeed.self, from: data)
        let generator = FeedGenerator(prettyPrint: true)
        return try generator.generate(feed)
    }

    // MARK: - Chapter Conversions

    private func convertJSONChaptersToPSC(_ data: Data) throws -> String {
        let chapters = try JSONDecoder().decode(JSONChapterList.self, from: data)
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<psc:chapters version=\"1.2\""
        xml += " xmlns:psc=\"http://podlove.org/simple-chapters\">\n"
        for chapter in chapters.chapters {
            let start = formatTime(chapter.startTime)
            xml += "  <psc:chapter start=\"\(start)\""
            if let title = chapter.title {
                xml += " title=\"\(escapeXML(title))\""
            }
            if let url = chapter.url {
                xml += " href=\"\(escapeXML(url.absoluteString))\""
            }
            if let img = chapter.img {
                xml += " image=\"\(escapeXML(img.absoluteString))\""
            }
            xml += " />\n"
        }
        xml += "</psc:chapters>"
        return xml
    }

    private func convertPSCToJSONChapters(_ data: Data) throws -> String {
        guard let xmlString = String(data: data, encoding: .utf8) else {
            throw ValidationError("Cannot read input as UTF-8 text.")
        }
        // Parse as a feed wrapping the PSC, or extract chapters from XML
        // For simplicity, wrap in minimal RSS and parse
        let wrappedXML = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:psc="http://podlove.org/simple-chapters">
              <channel>
                <title>temp</title>
                <link>https://example.com</link>
                <description>temp</description>
                <item>
                  <title>temp</title>
                  \(xmlString)
                </item>
              </channel>
            </rss>
            """
        let feed = try FeedParser().parse(wrappedXML)
        if let chapters = feed.channel?.items.first?.podloveChapters {
            let jsonChapters = JSONChapterList(
                chapters: chapters.chapters.map { chapter in
                    JSONChapter(
                        startTime: parseNPTToSeconds(chapter.start),
                        title: chapter.title,
                        url: chapter.href,
                        img: chapter.image
                    )
                }
            )
            return try OutputFormatter.jsonString(jsonChapters)
        }
        throw ValidationError("No Podlove chapters found in input.")
    }

    private func isStandalonePSC(_ data: Data) -> Bool {
        guard let str = String(data: data, encoding: .utf8) else { return false }
        let hasPSC = str.contains("psc:chapters") || str.contains("podlove.org/simple-chapters")
        let isFeed = str.contains("<rss") || str.contains("<channel")
        return hasPSC && !isFeed
    }

    // MARK: - Helpers

    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        let millis = Int((seconds - Double(totalSeconds)) * 1000)
        if millis > 0 {
            return String(format: "%02d:%02d:%02d.%03d", hours, minutes, secs, millis)
        }
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    private func parseNPTToSeconds(_ npt: String) -> Double {
        let parts = npt.split(separator: ":")
        switch parts.count {
        case 3:
            let hours = Double(parts[0]) ?? 0
            let minutes = Double(parts[1]) ?? 0
            let seconds = Double(parts[2]) ?? 0
            return hours * 3600 + minutes * 60 + seconds
        case 2:
            let minutes = Double(parts[0]) ?? 0
            let seconds = Double(parts[1]) ?? 0
            return minutes * 60 + seconds
        case 1:
            return Double(parts[0]) ?? 0
        default:
            return 0
        }
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
