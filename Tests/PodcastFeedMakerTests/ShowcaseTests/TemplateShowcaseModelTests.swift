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

// MARK: - Expertise Level Showcase

@Suite("Expertise Level Showcase")
struct ExpertiseLevelShowcase {

    @Test("ExpertiseLevel is Comparable: basic < standard < advanced < expert")
    func comparableOrdering() {
        #expect(ExpertiseLevel.basic < .standard)
        #expect(ExpertiseLevel.standard < .advanced)
        #expect(ExpertiseLevel.advanced < .expert)
        #expect(ExpertiseLevel.basic < .expert)
    }

    @Test("ExpertiseLevel is CaseIterable with 4 levels")
    func caseIterable() {
        let allLevels = ExpertiseLevel.allCases
        #expect(allLevels.count == 4)
        #expect(allLevels == [.basic, .standard, .advanced, .expert])
    }

    @Test("ExpertiseLevel rawValue maps to integers 0-3")
    func rawValues() {
        #expect(ExpertiseLevel.basic.rawValue == 0)
        #expect(ExpertiseLevel.standard.rawValue == 1)
        #expect(ExpertiseLevel.advanced.rawValue == 2)
        #expect(ExpertiseLevel.expert.rawValue == 3)
    }

    @Test("ExpertiseLevel is Codable for JSON round-trip")
    func codableRoundTrip() throws {
        let original = ExpertiseLevel.advanced
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ExpertiseLevel.self, from: data)
        #expect(decoded == original)
    }

    @Test("ExpertiseLevel is Hashable and can be used as dictionary key")
    func hashable() {
        var labels: [ExpertiseLevel: String] = [:]
        labels[.basic] = "Beginner"
        labels[.expert] = "Pro"
        #expect(labels[.basic] == "Beginner")
        #expect(labels[.expert] == "Pro")
    }

    @Test("ExpertiseLevel description matches level name")
    func customStringConvertible() {
        #expect(ExpertiseLevel.basic.description == "basic")
        #expect(ExpertiseLevel.standard.description == "standard")
        #expect(ExpertiseLevel.advanced.description == "advanced")
        #expect(ExpertiseLevel.expert.description == "expert")
    }
}

// MARK: - Platform Preset Showcase

@Suite("Platform Preset Showcase")
struct PlatformPresetShowcase {

    @Test("Single-platform presets map to one platform each")
    func singlePlatformPresets() {
        #expect(PlatformPreset.apple.platforms == [.apple])
        #expect(PlatformPreset.spotify.platforms == [.spotify])
        #expect(PlatformPreset.amazon.platforms == [.amazon])
        #expect(PlatformPreset.podcastIndex.platforms == [.podcastIndex])
        #expect(PlatformPreset.psp1.platforms == [.psp1])
    }

    @Test("majorPlatforms includes Apple, Spotify, and Amazon")
    func majorPlatforms() {
        let expected: Set<ValidationPlatform> = [.apple, .spotify, .amazon]
        #expect(PlatformPreset.majorPlatforms.platforms == expected)
    }

    @Test("openEcosystem includes Podcast Index and PSP-1")
    func openEcosystem() {
        let expected: Set<ValidationPlatform> = [.podcastIndex, .psp1]
        #expect(PlatformPreset.openEcosystem.platforms == expected)
    }

    @Test("universal includes 4 platforms: Apple + Spotify + Amazon + Podcast Index")
    func universal() {
        let expected: Set<ValidationPlatform> = [.apple, .spotify, .amazon, .podcastIndex]
        #expect(PlatformPreset.universal.platforms == expected)
    }

    @Test("all includes all 5 platforms")
    func all() {
        #expect(PlatformPreset.all.platforms == Set(ValidationPlatform.allCases))
        #expect(PlatformPreset.all.platforms.count == 5)
    }

    @Test("custom preset accepts arbitrary platform sets")
    func customPreset() {
        let custom = PlatformPreset.custom([.apple, .podcastIndex])
        #expect(custom.platforms == [.apple, .podcastIndex])
    }

    @Test("PlatformPreset is Hashable")
    func hashable() {
        let set: Set<PlatformPreset> = [.apple, .spotify, .apple]
        #expect(set.count == 2)
    }
}

// MARK: - FeedTag Showcase

@Suite("FeedTag Showcase")
struct FeedTagShowcase {

    @Test("FeedTag covers RSS 2.0 channel and item tags")
    func rssCoreTags() {
        let rssTags: [FeedTag] = [
            .title, .link, .description, .language, .copyright,
            .pubDate, .lastBuildDate,
            .itemTitle, .itemLink, .itemDescription, .itemEnclosure,
            .itemGuid, .itemPubDate, .itemAuthor
        ]
        for tag in rssTags {
            #expect(tag.namespace == nil, "RSS core tag \(tag) should have nil namespace")
        }
    }

    @Test("FeedTag covers iTunes namespace tags")
    func itunesTags() {
        let itunesTags: [FeedTag] = [
            .itunesCategory, .itunesExplicit, .itunesImage, .itunesAuthor,
            .itunesOwner, .itunesType, .itunesDuration, .itunesEpisode,
            .itunesSeason, .itunesEpisodeType
        ]
        for tag in itunesTags {
            #expect(tag.namespace == .itunes, "iTunes tag \(tag) should have .itunes namespace")
        }
    }

    @Test("FeedTag covers Podcast NS 2.0 tags")
    func podcastTags() {
        let podcastTags: [FeedTag] = [
            .podcastLocked, .podcastGuid, .podcastFunding, .podcastPerson,
            .podcastTranscript, .podcastChapters, .podcastSoundbite,
            .podcastValue, .podcastMedium, .podcastBlock, .podcastTxt,
            .podcastPodroll, .podcastUpdateFrequency, .podcastLiveItem,
            .podcastSocialInteract, .podcastPublisher, .podcastTrailer,
            .podcastLocation, .podcastLicense, .podcastAlternateEnclosure,
            .podcastChat, .podcastPodping, .podcastImages, .podcastImage,
            .podcastSeason, .podcastEpisode, .podcastIntegrity,
            .podcastValueTimeSplit, .podcastRemoteItem, .podcastContentLink
        ]
        for tag in podcastTags {
            #expect(tag.namespace == .podcast, "Podcast tag \(tag) should have .podcast namespace")
        }
    }

    @Test("FeedTag atomLink has atom namespace")
    func atomTag() {
        #expect(FeedTag.atomLink.namespace == .atom)
    }

    @Test("FeedTag contentEncoded has content namespace")
    func contentTag() {
        #expect(FeedTag.contentEncoded.namespace == .content)
    }

    @Test("FeedTag dublinCore has dublinCore namespace")
    func dublinCoreTag() {
        #expect(FeedTag.dublinCore.namespace == .dublinCore)
    }

    @Test("FeedTag podloveChapters has podloveSimpleChapters namespace")
    func podloveTag() {
        #expect(FeedTag.podloveChapters.namespace == .podloveSimpleChapters)
    }

    @Test("minimumLevel returns correct level for each tag tier")
    func minimumLevel() {
        #expect(FeedTag.title.minimumLevel == .basic)
        #expect(FeedTag.itunesCategory.minimumLevel == .basic)
        #expect(FeedTag.podcastLocked.minimumLevel == .standard)
        #expect(FeedTag.podcastGuid.minimumLevel == .standard)
        #expect(FeedTag.podcastTranscript.minimumLevel == .advanced)
        #expect(FeedTag.podcastChapters.minimumLevel == .advanced)
        #expect(FeedTag.podcastValue.minimumLevel == .expert)
        #expect(FeedTag.podloveChapters.minimumLevel == .expert)
        #expect(FeedTag.dublinCore.minimumLevel == .expert)
    }

    @Test("FeedTag is CaseIterable with comprehensive coverage")
    func caseIterable() {
        let allTags = FeedTag.allCases
        #expect(allTags.count > 50, "FeedTag should cover 50+ tags across all namespaces")
    }
}

// MARK: - Built-in Template Showcase

@Suite("Built-in Template Showcase")
struct BuiltInTemplateShowcase {

    @Test("BasicTemplate has correct level and name")
    func basicTemplate() {
        let template = BasicTemplate()
        #expect(template.level == .basic)
        #expect(template.name == "Basic")
        #expect(template.platformPreset == .majorPlatforms)
        #expect(template.namespaces == [.itunes, .atom])
    }

    @Test("StandardTemplate has correct level and name")
    func standardTemplate() {
        let template = StandardTemplate()
        #expect(template.level == .standard)
        #expect(template.name == "Standard")
        #expect(template.platformPreset == .all)
        #expect(template.namespaces.contains(.podcast))
    }

    @Test("AdvancedTemplate has correct level and name")
    func advancedTemplate() {
        let template = AdvancedTemplate()
        #expect(template.level == .advanced)
        #expect(template.name == "Advanced")
        #expect(template.namespaces.contains(.content))
        #expect(template.requiredChannelTags.contains(.podcastMedium))
    }

    @Test("ExpertTemplate has correct level and name")
    func expertTemplate() {
        let template = ExpertTemplate()
        #expect(template.level == .expert)
        #expect(template.name == "Expert")
        #expect(template.namespaces == Set(PodcastNamespace.allStandard))
        #expect(template.requiredItemTags.contains(.podcastTranscript))
    }

    @Test("Each higher template is a superset of the lower template's required tags")
    func subsetInvariant() {
        let basic = BasicTemplate()
        let standard = StandardTemplate()
        let advanced = AdvancedTemplate()
        let expert = ExpertTemplate()

        #expect(basic.requiredChannelTags.isSubset(of: standard.requiredChannelTags))
        #expect(standard.requiredChannelTags.isSubset(of: advanced.requiredChannelTags))
        #expect(advanced.requiredChannelTags.isSubset(of: expert.requiredChannelTags))

        #expect(basic.requiredItemTags.isSubset(of: standard.requiredItemTags))
        #expect(standard.requiredItemTags.isSubset(of: advanced.requiredItemTags))
        #expect(advanced.requiredItemTags.isSubset(of: expert.requiredItemTags))
    }

    @Test("allTags computed property returns union of all tag sets")
    func allTagsProperty() {
        let template = BasicTemplate()
        let allTags = template.allTags
        #expect(allTags.isSuperset(of: template.requiredChannelTags))
        #expect(allTags.isSuperset(of: template.recommendedChannelTags))
        #expect(allTags.isSuperset(of: template.requiredItemTags))
        #expect(allTags.isSuperset(of: template.recommendedItemTags))
    }

    @Test("Static template accessors return correct concrete types")
    func staticAccessors() {
        func useBasic(_ t: some FeedTemplate) -> ExpertiseLevel { t.level }
        func useStandard(_ t: some FeedTemplate) -> ExpertiseLevel { t.level }
        func useAdvanced(_ t: some FeedTemplate) -> ExpertiseLevel { t.level }
        func useExpert(_ t: some FeedTemplate) -> ExpertiseLevel { t.level }

        #expect(useBasic(.basic) == .basic)
        #expect(useStandard(.standard) == .standard)
        #expect(useAdvanced(.advanced) == .advanced)
        #expect(useExpert(.expert) == .expert)
    }
}
