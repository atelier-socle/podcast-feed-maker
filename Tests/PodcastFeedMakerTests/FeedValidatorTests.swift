import Foundation
@testable import PodcastFeedMaker
import Testing

struct FeedValidatorTests {

    @Test
    func testAppleValidationFailsWhenMissingRequiredTags() async throws {
        let feed = Feed(channel: .init(
            title: .init("My Podcast"),
            link: .init(.init(string: "https://example.com")!),
            description: .init("This is a description"),
            author: .init(name: "John Doe"),
            explicit: .init(.clean),
            image: .init(url: .init(string: "https://example.com/image.png")!),
            categories: .init(categories: []),
            items: [],
            language: nil,
            summary: nil,
            owner: nil,
            type: nil,
            atomSelfLink: nil,
            additionalTags: []
        ))

        let issues = FeedValidator.validate(feed, for: [.apple])
        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item" || $0.tag == "itunes:owner") })
    }

    @Test
    func testPodcastIndexValidationSucceedsWhenTagsPresent() async throws {
        let feed = Feed(channel: .init(
            title: .init("Podcast"),
            link: .init(URL(string: "https://podcast.exemple.com")!),
            description: .init("desc"),
            author: .init(name: "John"),
            explicit: .init(.no),
            image: .init(url: URL(string: "https://podcast.exemple.com/image.jpg")!),
            categories: .init(categories: []),
            items: [],
            language: nil,
            summary: nil,
            owner: nil,
            type: nil,
            atomSelfLink: .init(url: URL(string: "https://podcast.exemple.com")!),
            additionalTags: [
                Namespace.Podcast.Guid(value: "some-guid")
            ]
        ))

        let issues = FeedValidator.validate(feed, for: [.podcastIndex])
        #expect(issues.isEmpty)
    }

    @Test
    func testValidationFailsOnMissingRequiredChannelTags() async throws {
        let channel = RSSTag.Channel(tags: [], items: [], categories: .init(categories: []))
        let feed = Feed(channel: channel)
        let issues = FeedValidator.validate(feed, for: [.google])
        #expect(!issues.isEmpty)
        #expect(issues.contains(where: { $0.tag == "title" }))
        #expect(issues.contains(where: { $0.tag == "link" }))
        #expect(issues.contains(where: { $0.tag == "description" }))
    }

    @Test
    func testValidationFailsOnMissingItems() async throws {
        let feed = Feed(channel: .init(
            title: .init("Show"),
            link: .init(URL(string: "https://example.com")!),
            description: .init("desc"),
            author: .init(name: "John"),
            explicit: .init(.no),
            image: .init(url: URL(string: "https://podcast.exemple.com/image.jpg")!),
            categories: .init(categories: []),
            items: [],
            language: nil,
            summary: nil,
            owner: nil,
            type: nil,
            atomSelfLink: .init(url: URL(string: "https://podcast.exemple.com")!),
            additionalTags: []
        ))

        let issues = FeedValidator.validate(feed, for: [.apple])
        #expect(issues.contains(where: { $0.tag == "item" }))
    }

    @Test
    func testStrictValidationFailsOnMissingTags() async throws {
        let feed = Feed(channel: .init(
            title: .init("Show"),
            link: .init(URL(string: "https://example.com")!),
            description: .init("desc"),
            author: .init(name: "John"),
            explicit: .init(.no),
            image: .init(url: URL(string: "https://podcast.exemple.com/image.jpg")!),
            categories: .init(categories: []),
            items: [],
            language: nil,
            summary: nil,
            owner: nil,
            type: nil,
            atomSelfLink: .init(url: URL(string: "https://podcast.exemple.com")!),
            additionalTags: []
        ))

        #expect(throws: FeedValidator.ValidationError.self) {
            try FeedValidator.strictValidate(feed)
        }
    }

    @Test
    func testStrictValidationFailsOnMissingChannelTag() async throws {
        let feed = Feed(channel: nil)

        #expect(throws: FeedValidator.ValidationError.self) {
            try FeedValidator.strictValidate(feed)
        }
        
        #expect(performing: {
            try FeedValidator.strictValidate(feed)
        }, throws: { error in
            let expected = (error as? FeedValidator.ValidationError)
            return expected?.errorDescription?.isEmpty == false && expected?.localizedDescription.isEmpty == false
        })
    }

    @Test
    func testStrictValidationSucceedsWhenTagsPresent() async throws {
        let feed = Feed(channel: .init(
            title: .init("Podcast"),
            link: .init(URL(string: "https://podcast.exemple.com")!),
            description: .init("desc"),
            author: .init(name: "John"),
            explicit: .init(.no),
            image: .init(url: URL(string: "https://podcast.exemple.com/image.jpg")!),
            categories: .init(categories: []),
            items: [],
            language: nil,
            summary: nil,
            owner: nil,
            type: nil,
            atomSelfLink: .init(url: URL(string: "https://podcast.exemple.com")!),
            additionalTags: [
                Namespace.Podcast.Guid(value: "some-guid")
            ]
        ))

        let issues = FeedValidator.validate(feed, for: [.podcastIndex])
        #expect(issues.isEmpty)
        #expect(try FeedValidator.strictValidate(feed, for: [.podcastIndex]))
    }

    @Test
    func testAppleValidationFailsWhenMissingItemRequiredTags() async throws {
        let items: [RSSTag.Item] = [
            .init(tags: [Namespace.iTunes.Episode.init(value: 0)]),
            .init(tags: [Namespace.iTunes.Episode.init(value: 1)])
        ]

        let feed = Feed(channel: .init(
            title: .init("My Podcast"),
            link: .init(.init(string: "https://example.com")!),
            description: .init("This is a description"),
            author: .init(name: "John Doe"),
            explicit: .init(.clean),
            image: .init(url: .init(string: "https://example.com/image.png")!),
            categories: .init(categories: []),
            items: items,
            language: nil,
            summary: nil,
            owner: .init(name: "john doe", mail: "john@example.com"),
            type: nil,
            atomSelfLink: nil,
            additionalTags: []
        ))

        let issues = FeedValidator.validate(feed, for: [.apple])

        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/title" || $0.tag == "item[1]/title" ) })
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/enclosure" || $0.tag == "item[1]/enclosure" ) })
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/guid" || $0.tag == "item[1]/guid" ) })
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/pubDate" || $0.tag == "item[1]/pubDate" ) })
    }
}
