import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("Template Composition Scenarios")
struct TemplateCompositionTests {

    // MARK: - Helpers

    private static func makeTestURL() throws -> URL {
        try #require(URL(string: "https://example.com"))
    }

    private static func makeImageURL() throws -> URL {
        try #require(URL(string: "https://example.com/art.jpg"))
    }

    private static func makeFeedURL() throws -> URL {
        try #require(URL(string: "https://example.com/feed.xml"))
    }

    // MARK: - Real-World Composition Scenarios

    @Test("Radio France use case: expert + requiring + targeting")
    func radioFrance() {
        let template = ExpertTemplate()
            .requiring(.podcastPerson, .podcastTranscript, .podcastChapters)
            .targeting(.apple, .spotify, .podcastIndex)
            .named("Radio France")
        #expect(template.name == "Radio France")
        #expect(template.level == .expert)
        #expect(template.requiredChannelTags.contains(.podcastPerson))
        // podcastTranscript is item-level -- requiring() adds it to channel,
        // but it's present in the overall allTags
        #expect(template.allTags.contains(.podcastChapters))
        #expect(template.platformPreset.platforms == Set([.apple, .spotify, .podcastIndex]))
    }

    @Test("Network template: standard + requiring + targeting + named")
    func networkTemplate() {
        let template = StandardTemplate()
            .requiring(.podcastFunding)
            .targeting(.universal)
            .named("Network Standard")
        #expect(template.name == "Network Standard")
        #expect(template.level == .standard)
        #expect(template.requiredChannelTags.contains(.podcastFunding))
        #expect(template.platformPreset == .universal)
    }

    @Test("Standard + Advanced merge is superset of both")
    func mergeSuperset() {
        let basic = StandardTemplate()
        let advanced = AdvancedTemplate()
        let combined = basic + advanced
        #expect(
            combined.requiredChannelTags.isSuperset(of: basic.requiredChannelTags))
        #expect(
            combined.requiredChannelTags.isSuperset(of: advanced.requiredChannelTags))
        #expect(
            combined.requiredItemTags.isSuperset(of: basic.requiredItemTags))
        #expect(
            combined.requiredItemTags.isSuperset(of: advanced.requiredItemTags))
    }

    // MARK: - Validation with Composed Templates

    @Test("Composed template validates correctly")
    func composedValidation() throws {
        let testURL = try Self.makeTestURL()
        let imageURL = try Self.makeImageURL()
        let template = BasicTemplate()
            .requiring(.podcastGuid)

        let feed = PodcastFeed.basic(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.category(.technology).explicit(false).image(imageURL.absoluteString)
        }

        let report = TemplateValidator().validate(feed, against: template)
        // podcastGuid is required but not present -> error
        let guidError = report.errors.first { $0.tag == .podcastGuid }
        #expect(guidError != nil)
    }

    @Test("Composed template factory: PodcastFeed.template() works")
    func composedFactory() throws {
        let testURL = try Self.makeTestURL()
        let template = StandardTemplate().named("Custom")
        let feed = PodcastFeed.template(
            template,
            title: "Custom Show",
            link: testURL,
            description: "Test"
        )
        #expect(feed.channel?.title == "Custom Show")
        // Namespaces from standard template
        #expect(feed.namespaces.contains(.podcast))
    }

    @Test("detectLevel works on feed built from composed template")
    func detectLevelComposed() throws {
        let testURL = try Self.makeTestURL()
        let feedURL = try Self.makeFeedURL()
        let imageURL = try Self.makeImageURL()
        let feed = PodcastFeed.standard(
            title: "Show", link: testURL, description: "About"
        ) { ch in
            ch.author("Host")
                .explicit(false)
                .category(.technology)
                .owner(name: "Host", email: "h@example.com")
                .locked(owner: "h@example.com")
                .guid("aaaa-bbbb-cccc")
                .atomLink(href: feedURL.absoluteString, rel: "self")
                .image(imageURL.absoluteString)
                .language("en")
        }
        let level = TemplateValidator().detectLevel(feed)
        #expect(level >= .standard)
    }

    // MARK: - Composed + Composed

    @Test("Composing two composed templates works")
    func composedPlusComposed() {
        let left = BasicTemplate().requiring(.podcastFunding)
        let right = StandardTemplate().requiring(.podcastPerson)
        let combined = left + right
        #expect(combined.requiredChannelTags.contains(.podcastFunding))
        #expect(combined.requiredChannelTags.contains(.podcastPerson))
        #expect(combined.level == .standard)
    }

    @Test("Fluent chain on merged template")
    func fluentOnMerged() {
        let merged = (BasicTemplate() + AdvancedTemplate())
            .requiring(.podcastFunding)
            .named("Enhanced Network")
        #expect(merged.name == "Enhanced Network")
        #expect(merged.requiredChannelTags.contains(.podcastFunding))
        #expect(merged.level == .advanced)
    }

    // MARK: - allTags Includes Composed Requirements

    @Test("allTags includes added required tags")
    func allTagsIncludesAdded() {
        let template = BasicTemplate()
            .requiring(.podcastGuid)
            .recommendingItems(.podcastChapters)
        #expect(template.allTags.contains(.podcastGuid))
        #expect(template.allTags.contains(.podcastChapters))
    }
}
