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

@Suite("InputResolver Tests")
struct InputResolverTests {

    @Test("Resolves HTTPS URL")
    func resolvesHTTPS() throws {
        let result = try InputResolver.resolve("https://example.com/feed.xml")
        if case .url(let url) = result {
            #expect(url.absoluteString == "https://example.com/feed.xml")
        } else {
            Issue.record("Expected .url, got .file")
        }
    }

    @Test("Resolves HTTP URL")
    func resolvesHTTP() throws {
        let result = try InputResolver.resolve("http://example.com/feed.xml")
        if case .url(let url) = result {
            #expect(url.absoluteString == "http://example.com/feed.xml")
        } else {
            Issue.record("Expected .url, got .file")
        }
    }

    @Test("Resolves file path")
    func resolvesFile() throws {
        let result = try InputResolver.resolve("/tmp/feed.xml")
        if case .file(let path) = result {
            #expect(path == "/tmp/feed.xml")
        } else {
            Issue.record("Expected .file, got .url")
        }
    }

    @Test("Resolves relative file path")
    func resolvesRelative() throws {
        let result = try InputResolver.resolve("feed.xml")
        if case .file(let path) = result {
            #expect(path == "feed.xml")
        } else {
            Issue.record("Expected .file, got .url")
        }
    }

    @Test("Trims whitespace from source")
    func trimsWhitespace() throws {
        let result = try InputResolver.resolve("  /tmp/feed.xml  ")
        if case .file(let path) = result {
            #expect(path == "/tmp/feed.xml")
        } else {
            Issue.record("Expected .file, got .url")
        }
    }

    @Test("Resolves file:// URL")
    func resolvesFileURL() throws {
        let result = try InputResolver.resolve("file:///tmp/feed.xml")
        if case .url(let url) = result {
            #expect(url.scheme == "file")
            #expect(url.path == "/tmp/feed.xml")
        } else {
            Issue.record("Expected .url, got .file")
        }
    }

    @Test("InputError descriptions are meaningful")
    func errorDescriptions() {
        let invalidURL = InputError.invalidURL("bad://url")
        #expect(invalidURL.description.contains("Invalid URL"))

        let notFound = InputError.fileNotFound("/missing.xml")
        #expect(notFound.description.contains("File not found"))

        let readError = InputError.fileReadError(
            "/fail.xml",
            NSError(domain: "test", code: -1, userInfo: nil)
        )
        #expect(readError.description.contains("Cannot read file"))
    }

    // MARK: - Invalid URL throws InputError.invalidURL

    @Test("InputResolver throws invalidURL for URL-like string that is not a valid URL")
    func resolveInvalidURL() {
        // "http://[invalid" starts with "http://" so it enters the URL branch,
        // but URL(string:) returns nil for this malformed string, triggering
        // the throw at InputResolver line 26.
        #expect(throws: InputError.self) {
            _ = try InputResolver.resolve("http://[invalid")
        }
    }

    @Test("InputResolver throws invalidURL for HTTPS malformed URL")
    func resolveInvalidHTTPSURL() {
        #expect(throws: InputError.self) {
            _ = try InputResolver.resolve("https://[also invalid")
        }
    }

    @Test("InputResolver throws invalidURL for file:// malformed URL")
    func resolveInvalidFileURL() {
        // file:// with invalid characters that URL(string:) rejects
        #expect(throws: InputError.self) {
            _ = try InputResolver.resolve("file://[bad path")
        }
    }
}
