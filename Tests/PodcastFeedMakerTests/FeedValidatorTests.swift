import Foundation
@testable import PodcastFeedMaker
import Testing

struct FeedValidatorTests {

    @Test
    func testAppleValidationFailsWhenMissingRequiredTags() {
        let feed = PodcastFeed(channel: Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "This is a description",
            itunesAuthor: "John Doe",
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/image.png")!
            // Missing: itunesOwner, items
        ))

        let issues = FeedValidator.validate(feed, for: [.apple])
        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item" || $0.tag == "itunes:owner") })
    }

    @Test
    func testPodcastIndexValidationSucceedsWhenTagsPresent() {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://podcast.exemple.com")!,
            description: "desc",
            atomLinks: [.selfLink(href: URL(string: "https://podcast.exemple.com")!)],
            podcastGuid: PodcastGuid(value: "some-guid")
        ))

        let issues = FeedValidator.validate(feed, for: [.podcastIndex])
        #expect(issues.isEmpty)
    }

    @Test
    func testPodcastIndexValidationFailsWhenGuidMissing() {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://podcast.exemple.com")!,
            description: "desc"
        ))

        let issues = FeedValidator.validate(feed, for: [.podcastIndex])
        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.tag == "podcast:guid" })
    }

    @Test
    func testValidationFailsOnMissingItems() {
        let feed = PodcastFeed(channel: Channel(
            title: "Show",
            link: URL(string: "https://example.com")!,
            description: "desc",
            itunesAuthor: "John",
            itunesExplicit: false,
            itunesImage: URL(string: "https://podcast.exemple.com/image.jpg")!,
            itunesOwner: ITunesOwner(name: "John", email: "john@example.com"),
            atomLinks: [.selfLink(href: URL(string: "https://podcast.exemple.com")!)]
        ))

        let issues = FeedValidator.validate(feed, for: [.apple])
        #expect(issues.contains { $0.tag == "item" })
    }

    @Test
    func testStrictValidationThrowsOnIssues() {
        let feed = PodcastFeed(channel: Channel(
            title: "Show",
            link: URL(string: "https://example.com")!,
            description: "desc"
        ))

        #expect(throws: FeedValidator.ValidationError.self) {
            try FeedValidator.strictValidate(feed)
        }
    }

    @Test
    func testStrictValidationFailsOnMissingChannel() {
        let feed = PodcastFeed(channel: nil)

        #expect(throws: FeedValidator.ValidationError.self) {
            try FeedValidator.strictValidate(feed)
        }

        let issues = FeedValidator.validate(feed)
        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.tag == "channel" })
    }

    @Test
    func testStrictValidationSucceedsForPodcastIndex() throws {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://podcast.exemple.com")!,
            description: "desc",
            atomLinks: [.selfLink(href: URL(string: "https://podcast.exemple.com")!)],
            podcastGuid: PodcastGuid(value: "some-guid")
        ))

        let issues = FeedValidator.validate(feed, for: [.podcastIndex])
        #expect(issues.isEmpty)
        #expect(try FeedValidator.strictValidate(feed, for: [.podcastIndex]))
    }

    @Test
    func testAppleValidationFailsWhenItemsMissingRequiredTags() {
        let items: [Item] = [
            Item(itunesEpisode: 0),
            Item(itunesEpisode: 1)
        ]

        let feed = PodcastFeed(channel: Channel(
            title: "My Podcast",
            link: URL(string: "https://example.com")!,
            description: "This is a description",
            items: items,
            itunesAuthor: "John Doe",
            itunesExplicit: false,
            itunesImage: URL(string: "https://example.com/image.png")!,
            itunesOwner: ITunesOwner(name: "john doe", email: "john@example.com")
        ))

        let issues = FeedValidator.validate(feed, for: [.apple])

        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/title" || $0.tag == "item[1]/title") })
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/enclosure" || $0.tag == "item[1]/enclosure") })
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/guid" || $0.tag == "item[1]/guid") })
        #expect(issues.contains { $0.platform == .apple && ($0.tag == "item[0]/pubDate" || $0.tag == "item[1]/pubDate") })
    }

    @Test
    func testPSP1ValidationChecks() {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc",
            atomLinks: [.selfLink(href: URL(string: "https://example.com/feed.xml")!)],
            podcastGuid: PodcastGuid(value: "guid-123"),
            locked: Locked(isLocked: false)
        ))

        let issues = FeedValidator.validate(feed, for: [.psp1])
        #expect(issues.isEmpty)
    }

    @Test
    func testPSP1ValidationFailsWhenMissing() {
        let feed = PodcastFeed(channel: Channel(
            title: "Podcast",
            link: URL(string: "https://example.com")!,
            description: "desc"
        ))

        let issues = FeedValidator.validate(feed, for: [.psp1])
        #expect(!issues.isEmpty)
        #expect(issues.contains { $0.tag == "podcast:guid" })
        #expect(issues.contains { $0.tag == "podcast:locked" })
        #expect(issues.contains { $0.tag == "atom:link[rel=self]" })
    }

    @Test
    func testValidationErrorDescription() {
        let issues = [
            FeedValidator.ValidationIssue(tag: "title", message: "Required", platform: .apple)
        ]
        let error = FeedValidator.ValidationError.issuesFound(issues)
        #expect(error.errorDescription?.contains("apple") == true)
        #expect(error.errorDescription?.contains("title") == true)
    }
}
