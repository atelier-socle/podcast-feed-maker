// swiftlint:disable file_length
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

// MARK: - Template Factory Showcase

@Suite("Template Factory Showcase")
struct TemplateFactoryShowcase {

    @Test("PodcastFeed.basic creates feed using BasicTemplate namespaces")
    func basicFactory() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.basic(
            title: "Basic Show",
            link: link,
            description: "Minimal feed"
        )
        let channel = try #require(feed.channel)
        #expect(channel.title == "Basic Show")
        #expect(feed.namespaces.contains(.itunes))
        #expect(feed.namespaces.contains(.atom))
    }

    @Test("PodcastFeed.standard creates feed using StandardTemplate namespaces")
    func standardFactory() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.standard(
            title: "Standard Show",
            link: link,
            description: "PSP-1 feed"
        )
        #expect(feed.namespaces.contains(.podcast))
    }

    @Test("PodcastFeed.advanced creates feed using AdvancedTemplate namespaces")
    func advancedFactory() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.advanced(
            title: "Advanced Show",
            link: link,
            description: "Rich metadata feed"
        )
        #expect(feed.namespaces.contains(.content))
    }

    @Test("PodcastFeed.expert creates feed using ExpertTemplate namespaces")
    func expertFactory() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.expert(
            title: "Expert Show",
            link: link,
            description: "Full 7-namespace feed"
        )
        let standardNamespaces = Set(PodcastNamespace.allStandard)
        #expect(Set(feed.namespaces) == standardNamespaces)
    }

    @Test("PodcastFeed.template uses generic template")
    func genericTemplate() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.template(
            StandardTemplate(),
            title: "Generic Show",
            link: link,
            description: "Using generic API"
        )
        let channel = try #require(feed.channel)
        #expect(channel.title == "Generic Show")
    }

    @Test("Configure closure allows fluent channel modification")
    func configureClosure() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.basic(
            title: "Configured Show",
            link: link,
            description: "Using configure closure"
        ) { channel in
            channel
                .author("Jane Doe")
                .explicit(false)
                .category(.technology)
                .image("https://cdn.example.com/art.jpg")
        }

        let channel = try #require(feed.channel)
        #expect(channel.itunesAuthor == "Jane Doe")
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesCategories.count == 1)
        #expect(channel.itunesImage != nil)
    }

    @Test("Factory without configure closure returns plain channel")
    func noConfigureClosure() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feed = PodcastFeed.basic(
            title: "Plain Show",
            link: link,
            description: "No configuration"
        )
        let channel = try #require(feed.channel)
        #expect(channel.itunesAuthor == nil)
        #expect(channel.itunesExplicit == nil)
        #expect(channel.itunesCategories.isEmpty)
    }
}

// MARK: - Template Validator Showcase

@Suite("Template Validator Showcase")
struct TemplateValidatorShowcase {

    let templateValidator = TemplateValidator()

    @Test("Validate feed against BasicTemplate: missing required tags produce errors")
    func validateBasicMissing() throws {
        let channel = Channel(
            title: "",
            link: try #require(URL(string: "https://example.com")),
            description: ""
        )
        let feed = PodcastFeed(channel: channel)
        let report = templateValidator.validate(feed, against: BasicTemplate())

        #expect(!report.isCompliant)
        #expect(report.level == .basic)
        #expect(report.errors.contains { $0.tag == .title })
        #expect(report.errors.contains { $0.tag == .description })
        #expect(report.errors.contains { $0.tag == .itunesCategory })
        #expect(report.errors.contains { $0.tag == .itunesExplicit })
        #expect(report.errors.contains { $0.tag == .itunesImage })
    }

    @Test("Validate feed against BasicTemplate: missing recommended tags produce warnings")
    func validateBasicRecommended() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Description",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let report = templateValidator.validate(feed, against: BasicTemplate())

        #expect(report.isCompliant)
        #expect(report.warnings.contains { $0.tag == .language })
        #expect(report.warnings.contains { $0.tag == .itunesAuthor })
        #expect(report.warnings.contains { $0.tag == .itunesType })
    }

    @Test("Validate feed passes StandardTemplate when all PSP-1 fields present")
    func validateStandardPasses() throws {
        let link = try #require(URL(string: "https://example.com"))
        let enclosureURL = try #require(URL(string: "https://cdn.example.com/e.mp3"))
        let feedURL = try #require(URL(string: "https://example.com/feed.xml"))
        let channel = Channel(
            title: "Standard Show",
            link: link,
            description: "PSP-1 compliant",
            language: "en",
            items: [
                Item(
                    title: "Ep1",
                    enclosure: Enclosure(
                        url: enclosureURL,
                        length: 10_000_000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "ep-001", isPermaLink: false)
                )
            ],
            itunesAuthor: "Host",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg"),
            itunesOwner: ITunesOwner(name: "Host", email: "h@e.com"),
            atomLinks: [.selfLink(href: feedURL)],
            podcastGuid: PodcastGuid(value: "guid-123"),
            locked: Locked(isLocked: true, owner: "h@e.com")
        )
        let feed = PodcastFeed(channel: channel)
        let report = templateValidator.validate(feed, against: StandardTemplate())
        #expect(report.isCompliant, "Errors: \(report.errors)")
    }

    @Test("detectLevel identifies the highest matching level")
    func detectLevel() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Description",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg")
        )
        let feed = PodcastFeed(channel: channel)
        let level = templateValidator.detectLevel(feed)
        #expect(level == .basic)
    }

    @Test("detectLevel returns standard for PSP-1 compliant feed")
    func detectStandard() throws {
        let link = try #require(URL(string: "https://example.com"))
        let feedURL = try #require(URL(string: "https://example.com/f.xml"))
        let imageURL = try #require(URL(string: "https://cdn.example.com/a.jpg"))
        let enclosureURL = try #require(URL(string: "https://cdn.example.com/e.mp3"))
        let config = PSP1Configuration(
            title: "Show", link: link,
            description: "D", feedURL: feedURL,
            author: "A", ownerName: "O", ownerEmail: "o@e.com",
            category: .technology, explicit: false,
            imageURL: imageURL,
            podcastGUID: "guid-123"
        )
        var feed = PodcastFeed.psp1Compliant(config: config)
        feed.channel?.items = [
            Item(
                title: "Ep1",
                enclosure: Enclosure(
                    url: enclosureURL,
                    length: 10_000_000,
                    type: "audio/mpeg"
                ),
                guid: GUID(value: "ep-001", isPermaLink: false)
            )
        ]
        let level = templateValidator.detectLevel(feed)
        #expect(level >= .standard)
    }

    @Test("TemplateValidationReport errors, warnings, infos filter correctly")
    func reportFiltering() {
        let results = [
            TemplateValidationResult(severity: .error, tag: .title, message: "Missing"),
            TemplateValidationResult(severity: .warning, tag: .language, message: "Recommended"),
            TemplateValidationResult(
                severity: .info, tag: .podcastValue, message: "Upgrade",
                suggestedLevel: .expert
            )
        ]
        let report = TemplateValidationReport(level: .basic, results: results)

        #expect(report.errors.count == 1)
        #expect(report.warnings.count == 1)
        #expect(report.infos.count == 1)
        #expect(!report.isCompliant)
        #expect(report.infos[0].suggestedLevel == .expert)
    }

    @Test("TemplateValidationResult fields are accessible")
    func resultFields() {
        let result = TemplateValidationResult(
            severity: .error,
            tag: .itunesImage,
            message: "Required channel tag itunesImage is missing"
        )
        #expect(result.severity == .error)
        #expect(result.tag == .itunesImage)
        #expect(result.message.contains("itunesImage"))
        #expect(result.suggestedLevel == nil)
    }

    @Test("Level mismatch detection produces info with suggestedLevel")
    func levelMismatch() throws {
        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Description",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg"),
            podcastGuid: PodcastGuid(value: "guid-123"),
            locked: Locked(isLocked: true, owner: "o@e.com")
        )
        let feed = PodcastFeed(channel: channel)
        let report = templateValidator.validate(feed, against: BasicTemplate())
        let mismatches = report.infos.filter { $0.suggestedLevel != nil }
        #expect(!mismatches.isEmpty, "Feed with standard-level tags should trigger mismatch info")
    }
}

// MARK: - Template Composition Showcase

@Suite("Template Composition Showcase")
struct TemplateCompositionShowcase {

    @Test("Merge operator (+) unions required channel tags from two templates")
    func mergeOperator() {
        let combined = BasicTemplate() + AdvancedTemplate()
        #expect(combined.requiredChannelTags.isSuperset(of: BasicTemplate().requiredChannelTags))
        #expect(combined.requiredChannelTags.isSuperset(of: AdvancedTemplate().requiredChannelTags))
    }

    @Test("Merge operator uses max level")
    func mergeLevel() {
        let combined = BasicTemplate() + ExpertTemplate()
        #expect(combined.level == .expert)
    }

    @Test("Merge operator combines names")
    func mergeName() {
        let combined = BasicTemplate() + StandardTemplate()
        #expect(combined.name == "Basic + Standard")
    }

    @Test("Merge operator unions namespaces")
    func mergeNamespaces() {
        let combined = BasicTemplate() + ExpertTemplate()
        #expect(combined.namespaces == Set(PodcastNamespace.allStandard))
    }

    @Test("requiring adds required channel tags")
    func requiring() {
        let enhanced = BasicTemplate().requiring(.podcastLocked, .podcastGuid)
        #expect(enhanced.requiredChannelTags.contains(.podcastLocked))
        #expect(enhanced.requiredChannelTags.contains(.podcastGuid))
        #expect(enhanced.requiredChannelTags.isSuperset(of: BasicTemplate().requiredChannelTags))
    }

    @Test("recommending adds recommended channel tags")
    func recommending() {
        let enhanced = BasicTemplate().recommending(.podcastFunding)
        #expect(enhanced.recommendedChannelTags.contains(.podcastFunding))
    }

    @Test("requiringItems adds required item tags")
    func requiringItems() {
        let enhanced = BasicTemplate().requiringItems(.itemGuid, .itemPubDate)
        #expect(enhanced.requiredItemTags.contains(.itemGuid))
        #expect(enhanced.requiredItemTags.contains(.itemPubDate))
    }

    @Test("recommendingItems adds recommended item tags")
    func recommendingItems() {
        let enhanced = BasicTemplate().recommendingItems(.podcastSoundbite)
        #expect(enhanced.recommendedItemTags.contains(.podcastSoundbite))
    }

    @Test("targeting overrides platform preset with named preset")
    func targetingPreset() {
        let targeted = StandardTemplate().targeting(.universal)
        #expect(targeted.platformPreset == .universal)
    }

    @Test("targeting overrides platform preset with individual platforms")
    func targetingPlatforms() {
        let targeted = StandardTemplate().targeting(.apple, .spotify, .podcastIndex)
        #expect(targeted.platformPreset.platforms == [.apple, .spotify, .podcastIndex])
    }

    @Test("named overrides the template name")
    func named() {
        let renamed = StandardTemplate().named("Network Standard")
        #expect(renamed.name == "Network Standard")
        #expect(renamed.level == .standard)
    }

    @Test("Fluent methods can be chained together")
    func chainingFluentMethods() {
        let template = StandardTemplate()
            .requiring(.podcastTranscript, .podcastPerson)
            .recommending(.podcastValue)
            .requiringItems(.podcastTranscript)
            .recommendingItems(.podcastSoundbite)
            .targeting(.universal)
            .named("Network Standard v2")

        #expect(template.name == "Network Standard v2")
        #expect(template.level == .standard)
        #expect(template.platformPreset == .universal)
        #expect(template.requiredChannelTags.contains(.podcastTranscript))
        #expect(template.requiredChannelTags.contains(.podcastPerson))
        #expect(template.recommendedChannelTags.contains(.podcastValue))
        #expect(template.requiredItemTags.contains(.podcastTranscript))
        #expect(template.recommendedItemTags.contains(.podcastSoundbite))
    }

    @Test("ComposedTemplate conforms to FeedTemplate protocol")
    func composedTemplateConformance() {
        let composed = ComposedTemplate(
            name: "Custom",
            level: .standard,
            platformPreset: .apple,
            requiredChannelTags: [.title, .description],
            recommendedChannelTags: [.language],
            requiredItemTags: [.itemTitle],
            recommendedItemTags: [.itemGuid],
            namespaces: [.itunes]
        )
        #expect(composed.name == "Custom")
        #expect(composed.level == .standard)
        #expect(composed.platformPreset == .apple)
        #expect(composed.requiredChannelTags.contains(.title))
        #expect(composed.namespaces.contains(.itunes))
    }

    @Test("ComposedTemplate is Hashable")
    func composedHashable() {
        let a = BasicTemplate().requiring(.podcastLocked)
        let b = BasicTemplate().requiring(.podcastLocked)
        #expect(a == b)

        var set = Set<ComposedTemplate>()
        set.insert(a)
        set.insert(b)
        #expect(set.count == 1)
    }

    @Test("ComposedTemplate can be validated by TemplateValidator")
    func composedValidation() throws {
        let template = BasicTemplate()
            .requiring(.podcastLocked, .podcastGuid)
            .named("Locked Basic")

        let channel = Channel(
            title: "Show",
            link: try #require(URL(string: "https://example.com")),
            description: "Description",
            itunesCategories: [.technology],
            itunesExplicit: false,
            itunesImage: URL(string: "https://cdn.example.com/art.jpg"),
            podcastGuid: PodcastGuid(value: "guid-123"),
            locked: Locked(isLocked: true, owner: "o@e.com")
        )
        let feed = PodcastFeed(channel: channel)

        let validator = TemplateValidator()
        let report = validator.validate(feed, against: template)
        #expect(report.isCompliant)
    }

    @Test("PlatformPreset.resolveNamed returns named presets when matching")
    func resolveNamed() {
        let allPlatforms = Set(ValidationPlatform.allCases)
        #expect(PlatformPreset.resolveNamed(allPlatforms) == .all)

        let major: Set<ValidationPlatform> = [.apple, .spotify, .amazon]
        #expect(PlatformPreset.resolveNamed(major) == .majorPlatforms)

        let custom: Set<ValidationPlatform> = [.apple, .psp1]
        if case .custom(let platforms) = PlatformPreset.resolveNamed(custom) {
            #expect(platforms == custom)
        } else {
            Issue.record("Expected .custom preset")
        }
    }
}
