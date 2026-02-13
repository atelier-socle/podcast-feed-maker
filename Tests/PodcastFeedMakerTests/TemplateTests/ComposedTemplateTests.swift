import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("ComposedTemplate")
struct ComposedTemplateTests {

    // MARK: - Merge Operator

    @Test("+ operator unions required channel tags")
    func mergeRequiredChannel() {
        let combined = BasicTemplate() + StandardTemplate()
        #expect(combined.requiredChannelTags.isSuperset(of: BasicTemplate().requiredChannelTags))
        #expect(combined.requiredChannelTags.isSuperset(of: StandardTemplate().requiredChannelTags))
    }

    @Test("+ operator unions required item tags")
    func mergeRequiredItem() {
        let combined = BasicTemplate() + AdvancedTemplate()
        #expect(combined.requiredItemTags.isSuperset(of: BasicTemplate().requiredItemTags))
        #expect(combined.requiredItemTags.isSuperset(of: AdvancedTemplate().requiredItemTags))
    }

    @Test("+ operator takes max level")
    func mergeMaxLevel() {
        let combined = BasicTemplate() + ExpertTemplate()
        #expect(combined.level == .expert)
    }

    @Test("+ operator unions namespaces")
    func mergeNamespaces() {
        let combined = BasicTemplate() + ExpertTemplate()
        for ns in ExpertTemplate().namespaces {
            #expect(combined.namespaces.contains(ns))
        }
    }

    @Test("+ operator unions platforms")
    func mergePlatforms() {
        let left = BasicTemplate().targeting(.apple)
        let right = StandardTemplate().targeting(.spotify)
        let combined = left + right
        #expect(combined.platformPreset.platforms.contains(.apple))
        #expect(combined.platformPreset.platforms.contains(.spotify))
    }

    @Test("+ operator concatenates names")
    func mergeNames() {
        let combined = BasicTemplate() + StandardTemplate()
        #expect(combined.name == "Basic + Standard")
    }

    @Test("+ operator unions recommended channel tags")
    func mergeRecommendedChannel() {
        let combined = BasicTemplate() + AdvancedTemplate()
        #expect(
            combined.recommendedChannelTags.isSuperset(of: BasicTemplate().recommendedChannelTags))
        #expect(
            combined.recommendedChannelTags.isSuperset(
                of: AdvancedTemplate().recommendedChannelTags))
    }

    @Test("+ operator unions recommended item tags")
    func mergeRecommendedItem() {
        let combined = BasicTemplate() + AdvancedTemplate()
        #expect(combined.recommendedItemTags.isSuperset(of: BasicTemplate().recommendedItemTags))
        #expect(
            combined.recommendedItemTags.isSuperset(of: AdvancedTemplate().recommendedItemTags))
    }

    // MARK: - Fluent Builder Methods

    @Test(".requiring() adds to required channel tags")
    func requiring() {
        let template = BasicTemplate().requiring(.podcastTranscript)
        #expect(template.requiredChannelTags.contains(.podcastTranscript))
        // Original tags preserved
        #expect(template.requiredChannelTags.contains(.title))
    }

    @Test(".recommending() adds to recommended channel tags")
    func recommending() {
        let template = BasicTemplate().recommending(.podcastFunding)
        #expect(template.recommendedChannelTags.contains(.podcastFunding))
    }

    @Test(".requiringItems() adds to required item tags")
    func requiringItems() {
        let template = BasicTemplate().requiringItems(.itemGuid, .itemPubDate)
        #expect(template.requiredItemTags.contains(.itemGuid))
        #expect(template.requiredItemTags.contains(.itemPubDate))
    }

    @Test(".recommendingItems() adds to recommended item tags")
    func recommendingItems() {
        let template = BasicTemplate().recommendingItems(.podcastChapters)
        #expect(template.recommendedItemTags.contains(.podcastChapters))
    }

    @Test(".targeting(PlatformPreset) overrides platforms")
    func targetingPreset() {
        let template = ExpertTemplate().targeting(.universal)
        #expect(template.platformPreset == .universal)
    }

    @Test(".targeting(ValidationPlatform...) overrides platforms")
    func targetingPlatforms() {
        let template = BasicTemplate().targeting(.apple, .spotify)
        #expect(template.platformPreset.platforms == Set([.apple, .spotify]))
    }

    @Test(".named() overrides name")
    func named() {
        let template = StandardTemplate().named("Radio France")
        #expect(template.name == "Radio France")
        // Level preserved
        #expect(template.level == .standard)
    }

    @Test("chaining multiple fluent methods")
    func chaining() {
        let template = StandardTemplate()
            .requiring(.podcastTranscript, .podcastPerson)
            .targeting(.universal)
            .named("Network Standard")
        #expect(template.name == "Network Standard")
        #expect(template.platformPreset == .universal)
        #expect(template.requiredChannelTags.contains(.podcastTranscript))
        #expect(template.requiredChannelTags.contains(.podcastPerson))
        // Original standard required tags preserved
        #expect(template.requiredChannelTags.contains(.podcastGuid))
    }

    // MARK: - Conformances

    @Test("ComposedTemplate conforms to FeedTemplate")
    func feedTemplateConformance() {
        let template = BasicTemplate().named("Custom")
        let report = TemplateValidator().validate(PodcastFeed(), against: template)
        #expect(!report.isCompliant)
    }

    @Test("ComposedTemplate is Sendable and Hashable")
    func sendableHashable() {
        let a = BasicTemplate().named("A")
        let b = BasicTemplate().named("B")
        let set: Set<ComposedTemplate> = [a, b]
        #expect(set.count == 2)
    }

    // MARK: - PlatformPreset.resolveNamed

    @Test("resolveNamed returns .all for all 5 platforms")
    func resolveNamedAll() {
        let all = Set(ValidationPlatform.allCases)
        #expect(PlatformPreset.resolveNamed(all) == .all)
    }

    @Test("resolveNamed returns .universal for 4 platforms")
    func resolveNamedUniversal() {
        let universal: Set<ValidationPlatform> = [.apple, .spotify, .amazon, .podcastIndex]
        #expect(PlatformPreset.resolveNamed(universal) == .universal)
    }

    @Test("resolveNamed returns .majorPlatforms for 3 platforms")
    func resolveNamedMajor() {
        let major: Set<ValidationPlatform> = [.apple, .spotify, .amazon]
        #expect(PlatformPreset.resolveNamed(major) == .majorPlatforms)
    }

    @Test("resolveNamed returns .openEcosystem for podcastIndex + psp1")
    func resolveNamedOpen() {
        let open: Set<ValidationPlatform> = [.podcastIndex, .psp1]
        #expect(PlatformPreset.resolveNamed(open) == .openEcosystem)
    }

    @Test("resolveNamed returns .custom for non-standard combination")
    func resolveNamedCustom() {
        let custom: Set<ValidationPlatform> = [.apple, .psp1]
        let resolved = PlatformPreset.resolveNamed(custom)
        #expect(resolved.platforms == custom)
    }

    @Test("resolveNamed returns single-case preset for single platform")
    func resolveNamedSingle() {
        #expect(PlatformPreset.resolveNamed([.apple]) == .apple)
        #expect(PlatformPreset.resolveNamed([.spotify]) == .spotify)
    }
}
