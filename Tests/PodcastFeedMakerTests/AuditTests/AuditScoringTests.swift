import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Helpers

private func makeEmptyFeed() -> PodcastFeed { PodcastFeed() }

private func makeMinimalFeed() -> PodcastFeed {
    PodcastFeed(
        channel: Channel(
            title: "Minimal Podcast",
            link: makeURL("https://example.com"),
            description: "A minimal test podcast."
        ))
}

private func makeDynamicURL(_ string: String) -> URL {
    URL(string: string) ?? makeURL("https://example.com/fallback")
}

private func makeFullItem(index: Int) -> Item {
    Item(
        title: "Episode \(index)",
        description: String(repeating: "A", count: 250),
        enclosure: Enclosure(
            url: makeDynamicURL("https://example.com/ep\(index).mp3"),
            length: 12345, type: "audio/mpeg"
        ),
        guid: GUID(value: "guid-\(index)", isPermaLink: false),
        pubDate: Date(),
        itunesDuration: 1800,
        itunesImage: makeDynamicURL("https://example.com/ep\(index).jpg"),
        contentEncoded: ContentEncoded(value: "<p>Notes \(index)</p>"),
        transcripts: [
            Transcript(
                url: makeDynamicURL("https://example.com/ep\(index).vtt"),
                type: "text/vtt"
            )
        ],
        chaptersLink: ChaptersLink(
            url: makeDynamicURL("https://example.com/ep\(index)/ch.json")
        ),
        socialInteractions: [
            SocialInteract(
                uri: "https://mastodon.social/@host/\(index)",
                protocol: "activitypub"
            )
        ]
    )
}

private func makePerfectFeed() -> PodcastFeed {
    let items = (1...5).map { makeFullItem(index: $0) }
    return PodcastFeed(
        channel: Channel(
            title: "Perfect Podcast",
            link: makeURL("https://example.com"),
            description: String(repeating: "B", count: 200),
            language: "en",
            copyright: "2025 Perfect Podcast",
            items: items,
            itunesAuthor: "Jane Host",
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false,
            itunesImage: makeURL("https://example.com/artwork.jpg"),
            itunesOwner: ITunesOwner(name: "Jane Host", email: "jane@example.com"),
            itunesType: .episodic,
            atomLinks: [AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))],
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "jane@example.com"),
            funding: [Funding(url: makeURL("https://example.com/donate"), message: "Support us")],
            txtRecords: [PodcastTxt(value: "podcast keywords")],
            podroll: Podroll(remoteItems: [RemoteItem(feedGuid: "other-podcast-guid")]),
            updateFrequency: UpdateFrequency(label: "Weekly")
        ))
}

// MARK: - Metadata Scoring Tests

@Suite("AuditScoring Metadata Tests")
struct AuditScoringMetadataTests {

    @Test("Empty feed scores 0, maximum 25 for metadata")
    func emptyFeedMetadata() {
        let score = AuditScoring.evaluate(category: .metadata, feed: makeEmptyFeed())
        #expect(score.earned == 0)
        #expect(score.maximum == 25)
    }

    @Test("Minimal feed earns partial metadata points")
    func minimalFeedMetadata() {
        let score = AuditScoring.evaluate(category: .metadata, feed: makeMinimalFeed())
        #expect(score.earned > 0)
        #expect(score.earned < 25)
    }

    @Test("Perfect feed earns 25/25 metadata points")
    func perfectFeedMetadata() {
        let score = AuditScoring.evaluate(category: .metadata, feed: makePerfectFeed())
        #expect(score.earned == 25)
    }

    @Test("Metadata has 8 criteria")
    func metadataCriteriaCount() {
        let score = AuditScoring.evaluate(category: .metadata, feed: makeEmptyFeed())
        #expect(score.criteria.count == 8)
    }

    @Test("HTTPS artwork earns full 5 points")
    func httpsArtwork() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                itunesImage: makeURL("https://example.com/art.jpg")
            ))
        let result = AuditScoring.evaluate(category: .metadata, feed: feed)
            .criteria.first { $0.criterion.identifier == "metadata.artwork" }
        #expect(result?.pointsAwarded == 5)
        #expect(result?.passed == true)
    }

    @Test("Description 100-4000 chars earns full 4 points")
    func goodDescription() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"),
                description: String(repeating: "X", count: 150)
            ))
        let result = AuditScoring.evaluate(category: .metadata, feed: feed)
            .criteria.first { $0.criterion.identifier == "metadata.description" }
        #expect(result?.pointsAwarded == 4)
        #expect(result?.passed == true)
    }
}

// MARK: - Episodes Scoring Tests

@Suite("AuditScoring Episodes Tests")
struct AuditScoringEpisodesTests {

    @Test("No items scores 0/25 for episodes")
    func noItemsEpisodes() {
        let score = AuditScoring.evaluate(category: .episodes, feed: makeMinimalFeed())
        #expect(score.earned == 0)
        #expect(score.maximum == 25)
    }

    @Test("Full items score 25/25 for episodes")
    func fullItemsEpisodes() {
        let score = AuditScoring.evaluate(category: .episodes, feed: makePerfectFeed())
        #expect(score.earned == 25)
    }

    @Test("Episodes has 6 criteria")
    func episodesCriteriaCount() {
        let score = AuditScoring.evaluate(category: .episodes, feed: makeMinimalFeed())
        #expect(score.criteria.count == 6)
    }

    @Test("7 of 10 items with duration yields proportional points")
    func partialDurations() {
        let baseURL = makeURL("https://example.com/ep.mp3")
        let items: [Item] = (1...10).map { index in
            Item(
                title: "Ep \(index)",
                description: String(repeating: "Z", count: 60),
                enclosure: Enclosure(url: baseURL, length: 1000, type: "audio/mpeg"),
                guid: GUID(value: "g-\(index)", isPermaLink: false),
                pubDate: Date(),
                itunesDuration: index <= 7 ? 600 : nil
            )
        }
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                items: items
            ))
        let result = AuditScoring.evaluate(category: .episodes, feed: feed)
            .criteria.first { $0.criterion.identifier == "episodes.durations" }
        #expect(result?.pointsAwarded == 3)
        #expect(result?.passed == false)
    }

    @Test("1 of 2 items without enclosure yields partial score")
    func missingEnclosures() {
        let items = [
            Item(title: "Ep1"),
            Item(
                title: "Ep2",
                enclosure: Enclosure(
                    url: makeURL("https://example.com/ep2.mp3"),
                    length: 1000, type: "audio/mpeg"
                ))
        ]
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                items: items
            ))
        let result = AuditScoring.evaluate(category: .episodes, feed: feed)
            .criteria.first { $0.criterion.identifier == "episodes.enclosures" }
        #expect(result?.pointsAwarded == 3)
        #expect(result?.passed == false)
    }
}

// MARK: - Compliance Scoring Tests

@Suite("AuditScoring Compliance Tests")
struct AuditScoringComplianceTests {

    @Test("Empty feed scores 0/20 for compliance")
    func emptyFeedCompliance() {
        let score = AuditScoring.evaluate(category: .compliance, feed: makeEmptyFeed())
        #expect(score.earned == 0)
        #expect(score.maximum == 20)
    }

    @Test("Perfect feed earns 20/20 compliance points")
    func perfectFeedCompliance() {
        let score = AuditScoring.evaluate(category: .compliance, feed: makePerfectFeed())
        #expect(score.earned == 20)
    }

    @Test("Compliance has 6 criteria")
    func complianceCriteriaCount() {
        let score = AuditScoring.evaluate(category: .compliance, feed: makeEmptyFeed())
        #expect(score.criteria.count == 6)
    }

    @Test("Locked element earns 4 points")
    func lockedPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                locked: Locked(isLocked: true, owner: "owner@example.com")
            ))
        let result = AuditScoring.evaluate(category: .compliance, feed: feed)
            .criteria.first { $0.criterion.identifier == "compliance.locked" }
        #expect(result?.pointsAwarded == 4)
        #expect(result?.passed == true)
    }

    @Test("Podcast GUID earns 4 points")
    func guidPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                podcastGuid: PodcastGuid(value: "some-uuid-value")
            ))
        let result = AuditScoring.evaluate(category: .compliance, feed: feed)
            .criteria.first { $0.criterion.identifier == "compliance.guid" }
        #expect(result?.pointsAwarded == 4)
        #expect(result?.passed == true)
    }

    @Test("Atom self link earns 3 points")
    func atomSelfPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                atomLinks: [AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))]
            ))
        let result = AuditScoring.evaluate(category: .compliance, feed: feed)
            .criteria.first { $0.criterion.identifier == "compliance.atomSelf" }
        #expect(result?.pointsAwarded == 3)
        #expect(result?.passed == true)
    }
}

// MARK: - Accessibility Scoring Tests

@Suite("AuditScoring Accessibility Tests")
struct AuditScoringAccessibilityTests {

    @Test("No items: altText default gives 3/15 points")
    func noItemsAccessibility() {
        let score = AuditScoring.evaluate(category: .accessibility, feed: makeMinimalFeed())
        #expect(score.earned == 3)
        #expect(score.maximum == 15)
    }

    @Test("Perfect feed earns 15/15 accessibility points")
    func perfectFeedAccessibility() {
        let score = AuditScoring.evaluate(category: .accessibility, feed: makePerfectFeed())
        #expect(score.earned == 15)
    }

    @Test("Accessibility has 4 criteria")
    func accessibilityCriteriaCount() {
        let score = AuditScoring.evaluate(category: .accessibility, feed: makeMinimalFeed())
        #expect(score.criteria.count == 4)
    }

    @Test("Alt text awarded by default even for empty feed")
    func altTextDefault() {
        let result = AuditScoring.evaluate(category: .accessibility, feed: makeEmptyFeed())
            .criteria.first { $0.criterion.identifier == "accessibility.altText" }
        #expect(result?.pointsAwarded == 3)
        #expect(result?.passed == true)
    }

    @Test("Transcripts on all episodes earns full 5 points")
    func transcriptsPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                items: (1...4).map { makeFullItem(index: $0) }
            ))
        let result = AuditScoring.evaluate(category: .accessibility, feed: feed)
            .criteria.first { $0.criterion.identifier == "accessibility.transcripts" }
        #expect(result?.pointsAwarded == 5)
        #expect(result?.passed == true)
    }

    @Test("Chapters on 50% of episodes earns full 4 points")
    func chaptersPresent() {
        let chURL = makeURL("https://example.com/ch.json")
        let items: [Item] = (1...4).map { index in
            index <= 2
                ? Item(title: "Ep \(index)", chaptersLink: ChaptersLink(url: chURL))
                : Item(title: "Ep \(index)")
        }
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                items: items
            ))
        let result = AuditScoring.evaluate(category: .accessibility, feed: feed)
            .criteria.first { $0.criterion.identifier == "accessibility.chapters" }
        #expect(result?.pointsAwarded == 4)
        #expect(result?.passed == true)
    }
}

// MARK: - Discoverability Scoring Tests

@Suite("AuditScoring Discoverability Tests")
struct AuditScoringDiscoverabilityTests {

    @Test("Empty feed scores 0/15 for discoverability")
    func emptyFeedDiscoverability() {
        let score = AuditScoring.evaluate(category: .discoverability, feed: makeEmptyFeed())
        #expect(score.earned == 0)
        #expect(score.maximum == 15)
    }

    @Test("Perfect feed earns 15/15 discoverability points")
    func perfectFeedDiscoverability() {
        let score = AuditScoring.evaluate(category: .discoverability, feed: makePerfectFeed())
        #expect(score.earned == 15)
    }

    @Test("Discoverability has 5 criteria")
    func discoverabilityCriteriaCount() {
        let score = AuditScoring.evaluate(category: .discoverability, feed: makeEmptyFeed())
        #expect(score.criteria.count == 5)
    }

    @Test("Funding earns 3 points")
    func fundingPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                funding: [Funding(url: makeURL("https://example.com/donate"), message: "Support")]
            ))
        let result = AuditScoring.evaluate(category: .discoverability, feed: feed)
            .criteria.first { $0.criterion.identifier == "discoverability.funding" }
        #expect(result?.pointsAwarded == 3)
    }

    @Test("Podroll earns 3 points")
    func podrollPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                podroll: Podroll(remoteItems: [RemoteItem(feedGuid: "abc-123")])
            ))
        let result = AuditScoring.evaluate(category: .discoverability, feed: feed)
            .criteria.first { $0.criterion.identifier == "discoverability.podroll" }
        #expect(result?.pointsAwarded == 3)
    }

    @Test("UpdateFrequency earns 3 points")
    func updateFrequencyPresent() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                updateFrequency: UpdateFrequency(label: "Weekly")
            ))
        let result = AuditScoring.evaluate(category: .discoverability, feed: feed)
            .criteria.first { $0.criterion.identifier == "discoverability.updateFrequency" }
        #expect(result?.pointsAwarded == 3)
    }

    @Test("Txt records satisfy keywords criterion")
    func txtRecordsSatisfyKeywords() {
        let feed = PodcastFeed(
            channel: Channel(
                title: "T", link: makeURL("https://example.com"), description: "D",
                txtRecords: [PodcastTxt(value: "some keywords")]
            ))
        let result = AuditScoring.evaluate(category: .discoverability, feed: feed)
            .criteria.first { $0.criterion.identifier == "discoverability.keywords" }
        #expect(result?.pointsAwarded == 3)
    }
}

// MARK: - Global Score Tests

@Suite("AuditScoring Global Score Tests")
struct AuditScoringGlobalScoreTests {

    @Test("Perfect feed yields global score of 100")
    func perfectGlobalScore() {
        let scores = AuditCategory.allCases.map {
            AuditScoring.evaluate(category: $0, feed: makePerfectFeed())
        }
        #expect(AuditScoring.globalScore(from: scores) == 100)
    }

    @Test("Empty feed yields low global score")
    func emptyGlobalScore() {
        let scores = AuditCategory.allCases.map {
            AuditScoring.evaluate(category: $0, feed: makeEmptyFeed())
        }
        #expect(AuditScoring.globalScore(from: scores) <= 5)
    }

    @Test("Only-metadata-perfect yields 25 globally")
    func weightDistribution() {
        let metadataScore = AuditCategoryScore(
            category: .metadata, earned: 25, maximum: 25,
            weightedScore: 25.0, criteria: []
        )
        let zero: (AuditCategory) -> AuditCategoryScore = { cat in
            AuditCategoryScore(
                category: cat, earned: 0, maximum: cat.maxPoints,
                weightedScore: 0.0, criteria: []
            )
        }
        let scores = [
            metadataScore,
            zero(.episodes), zero(.compliance),
            zero(.accessibility), zero(.discoverability)
        ]
        #expect(AuditScoring.globalScore(from: scores) == 25)
    }

    @Test("Known partial scores yield correct global")
    func knownCategoryScores() {
        let scores = [
            AuditCategoryScore(
                category: .metadata, earned: 20, maximum: 25,
                weightedScore: (20.0 / 25.0) * 0.25 * 100, criteria: []),
            AuditCategoryScore(
                category: .episodes, earned: 15, maximum: 25,
                weightedScore: (15.0 / 25.0) * 0.25 * 100, criteria: []),
            AuditCategoryScore(
                category: .compliance, earned: 10, maximum: 20,
                weightedScore: (10.0 / 20.0) * 0.20 * 100, criteria: []),
            AuditCategoryScore(
                category: .accessibility, earned: 12, maximum: 15,
                weightedScore: (12.0 / 15.0) * 0.15 * 100, criteria: []),
            AuditCategoryScore(
                category: .discoverability, earned: 9, maximum: 15,
                weightedScore: (9.0 / 15.0) * 0.15 * 100, criteria: [])
        ]
        #expect(AuditScoring.globalScore(from: scores) == 66)
    }

    @Test("Empty scores array yields 0")
    func emptyCategoryScoresYieldsZero() {
        #expect(AuditScoring.globalScore(from: []) == 0)
    }

    @Test("Percentage: 20/25 = 80%")
    func categoryPercentage() {
        let score = AuditCategoryScore(
            category: .metadata, earned: 20, maximum: 25,
            weightedScore: 20.0, criteria: []
        )
        #expect(score.percentage == 80)
    }

    @Test("Percentage with zero max returns 0")
    func categoryPercentageZeroMax() {
        let score = AuditCategoryScore(
            category: .metadata, earned: 0, maximum: 0,
            weightedScore: 0.0, criteria: []
        )
        #expect(score.percentage == 0)
    }
}
