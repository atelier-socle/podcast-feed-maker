import Foundation
import Testing

@testable import PodcastFeedMaker

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
