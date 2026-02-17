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

@Suite("FeedTag")
struct FeedTagTests {

    @Test("CaseIterable includes all expected cases")
    func allCasesCount() {
        // Verify we have a substantial number of tags
        #expect(FeedTag.allCases.count >= 50)
    }

    @Test("RSS channel tags have no namespace")
    func rssChannelNamespace() {
        #expect(FeedTag.title.namespace == nil)
        #expect(FeedTag.link.namespace == nil)
        #expect(FeedTag.description.namespace == nil)
        #expect(FeedTag.language.namespace == nil)
        #expect(FeedTag.copyright.namespace == nil)
        #expect(FeedTag.pubDate.namespace == nil)
        #expect(FeedTag.lastBuildDate.namespace == nil)
    }

    @Test("RSS item tags have no namespace")
    func rssItemNamespace() {
        #expect(FeedTag.itemTitle.namespace == nil)
        #expect(FeedTag.itemEnclosure.namespace == nil)
        #expect(FeedTag.itemGuid.namespace == nil)
        #expect(FeedTag.itemPubDate.namespace == nil)
    }

    @Test("iTunes tags have itunes namespace")
    func itunesNamespace() {
        #expect(FeedTag.itunesCategory.namespace == .itunes)
        #expect(FeedTag.itunesExplicit.namespace == .itunes)
        #expect(FeedTag.itunesImage.namespace == .itunes)
        #expect(FeedTag.itunesAuthor.namespace == .itunes)
        #expect(FeedTag.itunesOwner.namespace == .itunes)
        #expect(FeedTag.itunesDuration.namespace == .itunes)
    }

    @Test("Atom tags have atom namespace")
    func atomNamespace() {
        #expect(FeedTag.atomLink.namespace == .atom)
    }

    @Test("Podcast NS 2.0 tags have podcast namespace")
    func podcastNamespace() {
        #expect(FeedTag.podcastLocked.namespace == .podcast)
        #expect(FeedTag.podcastGuid.namespace == .podcast)
        #expect(FeedTag.podcastFunding.namespace == .podcast)
        #expect(FeedTag.podcastTranscript.namespace == .podcast)
        #expect(FeedTag.podcastValue.namespace == .podcast)
    }

    @Test("Content module tags have content namespace")
    func contentNamespace() {
        #expect(FeedTag.contentEncoded.namespace == .content)
    }

    @Test("Dublin Core tag has dublinCore namespace")
    func dublinCoreNamespace() {
        #expect(FeedTag.dublinCore.namespace == .dublinCore)
    }

    @Test("Podlove chapters tag has podloveSimpleChapters namespace")
    func podloveNamespace() {
        #expect(FeedTag.podloveChapters.namespace == .podloveSimpleChapters)
    }

    @Test("minimumLevel for basic tags")
    func basicMinimumLevel() {
        #expect(FeedTag.title.minimumLevel == .basic)
        #expect(FeedTag.link.minimumLevel == .basic)
        #expect(FeedTag.itunesCategory.minimumLevel == .basic)
        #expect(FeedTag.itunesExplicit.minimumLevel == .basic)
        #expect(FeedTag.itemTitle.minimumLevel == .basic)
        #expect(FeedTag.itemEnclosure.minimumLevel == .basic)
    }

    @Test("minimumLevel for standard tags")
    func standardMinimumLevel() {
        #expect(FeedTag.podcastLocked.minimumLevel == .standard)
        #expect(FeedTag.podcastGuid.minimumLevel == .standard)
        #expect(FeedTag.atomLink.minimumLevel == .standard)
        #expect(FeedTag.itunesOwner.minimumLevel == .standard)
    }

    @Test("minimumLevel for standard-recommended tags")
    func standardRecommendedMinimumLevel() {
        // podcastMedium is recommended at standard level
        #expect(FeedTag.podcastMedium.minimumLevel == .standard)
    }

    @Test("minimumLevel for advanced tags")
    func advancedMinimumLevel() {
        #expect(FeedTag.podcastTranscript.minimumLevel == .advanced)
        #expect(FeedTag.podcastChapters.minimumLevel == .advanced)
        #expect(FeedTag.podcastSoundbite.minimumLevel == .advanced)
        #expect(FeedTag.podcastAlternateEnclosure.minimumLevel == .advanced)
    }

    @Test("minimumLevel for expert tags")
    func expertMinimumLevel() {
        #expect(FeedTag.podcastValue.minimumLevel == .expert)
        #expect(FeedTag.podcastBlock.minimumLevel == .expert)
        #expect(FeedTag.podcastPodroll.minimumLevel == .expert)
        #expect(FeedTag.podloveChapters.minimumLevel == .expert)
        #expect(FeedTag.dublinCore.minimumLevel == .expert)
    }

    @Test("Hashable — all cases are distinct")
    func hashable() {
        let set = Set(FeedTag.allCases)
        #expect(set.count == FeedTag.allCases.count)
    }
}
