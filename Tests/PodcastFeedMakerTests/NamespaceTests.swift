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

import Testing

@testable import PodcastFeedMaker

struct NamespaceTests {

    @Test
    func test_allStandard_containsExpectedNamespaces() {
        let standard = PodcastNamespace.allStandard
        #expect(standard.count == 6)
        #expect(standard.contains(.itunes))
        #expect(standard.contains(.podcast))
        #expect(standard.contains(.atom))
        #expect(standard.contains(.dublinCore))
        #expect(standard.contains(.content))
        #expect(standard.contains(.podloveSimpleChapters))
    }

    @Test
    func test_xmlnsDeclaration_returnsCorrectStrings() {
        let cases: [(PodcastNamespace, String)] = [
            (.itunes, #"xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd""#),
            (.podcast, #"xmlns:podcast="https://podcastindex.org/namespace/1.0""#),
            (.atom, #"xmlns:atom="http://www.w3.org/2005/Atom""#),
            (.dublinCore, #"xmlns:dc="http://purl.org/dc/elements/1.1/""#),
            (.content, #"xmlns:content="http://purl.org/rss/1.0/modules/content/""#),
            (.podloveSimpleChapters, #"xmlns:psc="http://podlove.org/simple-chapters""#)
        ]

        for (namespace, expected) in cases {
            #expect(namespace.xmlnsDeclaration == expected)
        }
    }

    @Test
    func test_prefix_returnsCorrectValues() {
        #expect(PodcastNamespace.itunes.prefix == "itunes")
        #expect(PodcastNamespace.podcast.prefix == "podcast")
        #expect(PodcastNamespace.atom.prefix == "atom")
        #expect(PodcastNamespace.dublinCore.prefix == "dc")
        #expect(PodcastNamespace.content.prefix == "content")
        #expect(PodcastNamespace.podloveSimpleChapters.prefix == "psc")
    }

    @Test
    func test_equatable() {
        #expect(PodcastNamespace.atom == .atom)
        #expect(PodcastNamespace.atom != .itunes)
        #expect(PodcastNamespace.custom("xmlns:x=\"http://example.com\"") == .custom("xmlns:x=\"http://example.com\""))
        #expect(PodcastNamespace.custom("a") != .custom("b"))
    }

    @Test
    func test_hashable() {
        let set: Set<PodcastNamespace> = [.itunes, .atom, .podcast, .dublinCore]
        #expect(set.contains(.itunes))
        #expect(set.contains(.atom))
        #expect(!set.contains(.content))
    }

    @Test
    func test_customNamespace() {
        let custom = PodcastNamespace.custom(#"xmlns:my="http://example.com/ns""#)
        #expect(custom.prefix == "")
        #expect(custom.uri == #"xmlns:my="http://example.com/ns""#)
        #expect(custom.xmlnsDeclaration == #"xmlns:my="http://example.com/ns""#)
    }
}
