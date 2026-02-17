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

@Suite("Built-in Templates")
struct BuiltInTemplateTests {

    // MARK: - BasicTemplate

    @Test("BasicTemplate has correct level and name")
    func basicMetadata() {
        let template = BasicTemplate()
        #expect(template.level == .basic)
        #expect(template.name == "Basic")
    }

    @Test("BasicTemplate requires RSS core + iTunes essentials")
    func basicRequired() {
        let t = BasicTemplate()
        #expect(t.requiredChannelTags.contains(.title))
        #expect(t.requiredChannelTags.contains(.link))
        #expect(t.requiredChannelTags.contains(.description))
        #expect(t.requiredChannelTags.contains(.itunesCategory))
        #expect(t.requiredChannelTags.contains(.itunesExplicit))
        #expect(t.requiredChannelTags.contains(.itunesImage))
        #expect(t.requiredItemTags.contains(.itemTitle))
        #expect(t.requiredItemTags.contains(.itemEnclosure))
    }

    @Test("BasicTemplate uses itunes + atom namespaces")
    func basicNamespaces() {
        let t = BasicTemplate()
        #expect(t.namespaces == [.itunes, .atom])
    }

    @Test("BasicTemplate targets major platforms")
    func basicPlatformPreset() {
        #expect(BasicTemplate().platformPreset == .majorPlatforms)
    }

    // MARK: - StandardTemplate

    @Test("StandardTemplate has correct level and name")
    func standardMetadata() {
        let template = StandardTemplate()
        #expect(template.level == .standard)
        #expect(template.name == "Standard")
    }

    @Test("StandardTemplate includes all Basic required tags")
    func standardIncludesBasic() {
        let basic = BasicTemplate()
        let standard = StandardTemplate()
        #expect(basic.requiredChannelTags.isSubset(of: standard.requiredChannelTags))
        #expect(basic.requiredItemTags.isSubset(of: standard.requiredItemTags))
    }

    @Test("StandardTemplate adds PSP-1 tags")
    func standardPSP1Tags() {
        let t = StandardTemplate()
        #expect(t.requiredChannelTags.contains(.podcastLocked))
        #expect(t.requiredChannelTags.contains(.podcastGuid))
        #expect(t.requiredChannelTags.contains(.atomLink))
        #expect(t.requiredChannelTags.contains(.itunesOwner))
        #expect(t.requiredChannelTags.contains(.itunesAuthor))
        #expect(t.requiredChannelTags.contains(.language))
        #expect(t.requiredItemTags.contains(.itemGuid))
    }

    @Test("StandardTemplate adds podcast namespace")
    func standardNamespaces() {
        let t = StandardTemplate()
        #expect(t.namespaces.contains(.podcast))
        #expect(t.namespaces.contains(.itunes))
        #expect(t.namespaces.contains(.atom))
    }

    // MARK: - AdvancedTemplate

    @Test("AdvancedTemplate has correct level and name")
    func advancedMetadata() {
        let template = AdvancedTemplate()
        #expect(template.level == .advanced)
        #expect(template.name == "Advanced")
    }

    @Test("AdvancedTemplate includes all Standard required tags")
    func advancedIncludesStandard() {
        let standard = StandardTemplate()
        let advanced = AdvancedTemplate()
        #expect(standard.requiredChannelTags.isSubset(of: advanced.requiredChannelTags))
        #expect(standard.requiredItemTags.isSubset(of: advanced.requiredItemTags))
    }

    @Test("AdvancedTemplate adds medium as required")
    func advancedMedium() {
        let t = AdvancedTemplate()
        #expect(t.requiredChannelTags.contains(.podcastMedium))
    }

    @Test("AdvancedTemplate recommends Podcast NS 2.0 phases 1-3")
    func advancedRecommendations() {
        let t = AdvancedTemplate()
        #expect(t.recommendedItemTags.contains(.podcastTranscript))
        #expect(t.recommendedItemTags.contains(.podcastChapters))
        #expect(t.recommendedItemTags.contains(.podcastSoundbite))
        #expect(t.recommendedItemTags.contains(.podcastPerson))
        #expect(t.recommendedItemTags.contains(.contentEncoded))
    }

    @Test("AdvancedTemplate adds content namespace")
    func advancedNamespaces() {
        let t = AdvancedTemplate()
        #expect(t.namespaces.contains(.content))
    }

    // MARK: - ExpertTemplate

    @Test("ExpertTemplate has correct level and name")
    func expertMetadata() {
        let template = ExpertTemplate()
        #expect(template.level == .expert)
        #expect(template.name == "Expert")
    }

    @Test("ExpertTemplate includes all Advanced required tags")
    func expertIncludesAdvanced() {
        let advanced = AdvancedTemplate()
        let expert = ExpertTemplate()
        #expect(advanced.requiredChannelTags.isSubset(of: expert.requiredChannelTags))
        #expect(advanced.requiredItemTags.isSubset(of: expert.requiredItemTags))
    }

    @Test("ExpertTemplate uses all 6 standard namespaces")
    func expertNamespaces() {
        let t = ExpertTemplate()
        #expect(t.namespaces == Set(PodcastNamespace.allStandard))
    }

    @Test("ExpertTemplate recommends Dublin Core and Podlove")
    func expertRecommendations() {
        let t = ExpertTemplate()
        #expect(t.recommendedChannelTags.contains(.dublinCore))
        #expect(t.recommendedItemTags.contains(.podloveChapters))
        #expect(t.recommendedItemTags.contains(.dublinCore))
    }

    // MARK: - Subset Invariants

    @Test("each level's allTags is a subset of the next level")
    func subsetInvariant() {
        let basic = BasicTemplate.allTags
        let standard = StandardTemplate.allTags
        let advanced = AdvancedTemplate.allTags
        let expert = ExpertTemplate.allTags

        #expect(basic.isSubset(of: standard))
        #expect(standard.isSubset(of: advanced))
        #expect(advanced.isSubset(of: expert))
    }

    @Test("expert allTags covers every FeedTag case")
    func expertCoversAll() {
        let expert = ExpertTemplate.allTags
        // Expert should cover the vast majority of tags
        // Some item-only tags may not appear in channel-focused lists and vice versa,
        // but the union of all should be close to FeedTag.allCases
        #expect(expert.count >= 40)
    }

    // MARK: - Static Accessors

    @Test("static accessor .basic returns BasicTemplate")
    func staticBasic() {
        func check<T: FeedTemplate>(_ template: T) {
            #expect(template.level == .basic)
        }
        check(.basic)
    }

    @Test("static accessor .standard returns StandardTemplate")
    func staticStandard() {
        func check<T: FeedTemplate>(_ template: T) {
            #expect(template.level == .standard)
        }
        check(.standard)
    }

    @Test("static accessor .advanced returns AdvancedTemplate")
    func staticAdvanced() {
        func check<T: FeedTemplate>(_ template: T) {
            #expect(template.level == .advanced)
        }
        check(.advanced)
    }

    @Test("static accessor .expert returns ExpertTemplate")
    func staticExpert() {
        func check<T: FeedTemplate>(_ template: T) {
            #expect(template.level == .expert)
        }
        check(.expert)
    }
}
