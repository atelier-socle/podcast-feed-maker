import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Audit Recommendations

@Suite("Audit Recommendations")
struct AuditRecommendationTests {

    private let auditor = FeedAuditor()

    // MARK: - Helpers

    /// A minimal feed that fails most audit criteria.
    private func minimalFeed() -> PodcastFeed {
        let url = makeURL("http://example.com")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short"
        )
        return PodcastFeed(channel: channel)
    }

    /// A feed with all metadata, compliance, accessibility, and discoverability
    /// fields filled in so that every criterion passes.
    private func fullyPassingFeed() -> PodcastFeed {
        let url = makeURL("https://example.com")
        let imageURL = makeURL("https://example.com/art.jpg")
        let feedURL = makeURL("https://example.com/feed.xml")
        let transcriptURL = makeURL("https://example.com/ep1.vtt")
        let chaptersURL = makeURL("https://example.com/ep1-chapters.json")
        let fundingURL = makeURL("https://example.com/donate")

        let longDescription = String(repeating: "A podcast about technology. ", count: 10)

        let item = Item(
            title: "Episode 1",
            description: String(repeating: "Episode about tech topics. ", count: 5),
            enclosure: Enclosure(
                url: makeURL("https://example.com/ep1.mp3"),
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 1800,
            itunesExplicit: false,
            itunesImage: imageURL,
            contentEncoded: ContentEncoded(value: "<p>Rich HTML description of the episode.</p>"),
            transcripts: [
                Transcript(url: transcriptURL, type: "text/vtt")
            ],
            chaptersLink: ChaptersLink(url: chaptersURL),
            socialInteractions: [
                SocialInteract(
                    uri: "https://social.example.com/post/1",
                    protocol: "activitypub"
                )
            ]
        )

        let channel = Channel(
            title: "Test Podcast",
            link: url,
            description: longDescription,
            language: "en",
            copyright: "2024 Test",
            items: [item],
            itunesAuthor: "Host Name",
            itunesCategories: [ITunesCategory(text: "Technology")],
            itunesExplicit: false,
            itunesImage: imageURL,
            itunesOwner: ITunesOwner(name: "Host", email: "host@example.com"),
            itunesType: .episodic,
            atomLinks: [
                AtomLink(href: feedURL, rel: "self", type: "application/rss+xml")
            ],
            podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
            locked: Locked(isLocked: true, owner: "host@example.com"),
            funding: [Funding(url: fundingURL, message: "Support us")],
            txtRecords: [PodcastTxt(value: "keywords=tech,swift")],
            podroll: Podroll(remoteItems: []),
            updateFrequency: UpdateFrequency(label: "weekly")
        )

        return PodcastFeed(channel: channel)
    }

    /// A feed with episodes that have enclosures but otherwise minimal metadata.
    private func feedWithEnclosures() -> PodcastFeed {
        let url = makeURL("http://example.com")
        let item = Item(
            title: "Episode 1",
            enclosure: Enclosure(
                url: makeURL("https://example.com/ep1.mp3"),
                length: 1024,
                type: "audio/mpeg"
            ),
            guid: GUID(value: "ep-1", isPermaLink: false),
            pubDate: Date(),
            itunesDuration: 600
        )
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short",
            items: [item]
        )
        return PodcastFeed(channel: channel)
    }

    // MARK: - 1. AuditRecommendation Model

    @Test("AuditRecommendation stores all fields")
    func modelFieldsStored() {
        let recommendation = AuditRecommendation(
            priority: .critical,
            category: .episodes,
            criterionId: "episodes.enclosures",
            message: "Fix enclosures",
            suggestion: "Add <enclosure> to every item",
            potentialPoints: 5
        )

        #expect(recommendation.priority == .critical)
        #expect(recommendation.category == .episodes)
        #expect(recommendation.criterionId == "episodes.enclosures")
        #expect(recommendation.message == "Fix enclosures")
        #expect(recommendation.suggestion == "Add <enclosure> to every item")
        #expect(recommendation.potentialPoints == 5)
    }

    // MARK: - 2. Priority Comparable

    @Test("Priority ordering: critical < recommended < niceToHave")
    func priorityComparable() {
        #expect(AuditRecommendation.Priority.critical < .recommended)
        #expect(AuditRecommendation.Priority.recommended < .niceToHave)
        #expect(AuditRecommendation.Priority.critical < .niceToHave)
    }

    // MARK: - 3. Priority CaseIterable

    @Test("Priority has exactly 3 cases")
    func priorityCaseIterable() {
        let cases = AuditRecommendation.Priority.allCases
        #expect(cases.count == 3)
        #expect(cases.contains(.critical))
        #expect(cases.contains(.recommended))
        #expect(cases.contains(.niceToHave))
    }

    // MARK: - 4. Missing Artwork

    @Test("Missing artwork produces recommended priority with itunes:image in message")
    func missingArtworkRecommendation() throws {
        let feed = feedWithEnclosures()
        let report = auditor.audit(feed)

        let rec = try #require(
            report.recommendations.first {
                $0.criterionId == "metadata.artwork"
            })

        #expect(rec.priority == .recommended)
        #expect(rec.message.contains("itunes:image"))
    }

    // MARK: - 5. Missing Enclosures

    @Test("Missing enclosures produces critical priority")
    func missingEnclosuresCritical() throws {
        let url = makeURL("http://example.com")
        let item = Item(title: "Episode 1")
        let channel = Channel(
            title: "Test",
            link: url,
            description: "Short",
            items: [item]
        )
        let feed = PodcastFeed(channel: channel)
        let report = auditor.audit(feed)

        let rec = try #require(
            report.recommendations.first {
                $0.criterionId == "episodes.enclosures"
            })

        #expect(rec.priority == .critical)
    }

    // MARK: - 6. Missing podcast:guid

    @Test("Missing podcast:guid produces recommended priority")
    func missingPodcastGuid() throws {
        let feed = feedWithEnclosures()
        let report = auditor.audit(feed)

        let rec = try #require(
            report.recommendations.first {
                $0.criterionId == "compliance.guid"
            })

        #expect(rec.priority == .recommended)
    }

    // MARK: - 7. Missing Funding

    @Test("Missing funding produces niceToHave priority")
    func missingFundingNiceToHave() throws {
        let feed = feedWithEnclosures()
        let report = auditor.audit(feed)

        let rec = try #require(
            report.recommendations.first {
                $0.criterionId == "discoverability.funding"
            })

        #expect(rec.priority == .niceToHave)
    }

    // MARK: - 8. potentialPoints Reflects Points Lost

    @Test("potentialPoints equals max points minus awarded points")
    func potentialPointsCorrect() throws {
        let feed = minimalFeed()
        let report = auditor.audit(feed)

        // A minimal feed with no episodes should fail episodes.hasEpisodes (5 max, 0 awarded)
        let rec = try #require(
            report.recommendations.first {
                $0.criterionId == "episodes.hasEpisodes"
            })

        #expect(rec.potentialPoints == 5)
    }

    // MARK: - 9. No Recommendations for Fully Passing Criteria

    @Test("Fully passing feed has no recommendations")
    func noRecommendationsForPassingFeed() {
        let feed = fullyPassingFeed()
        let report = auditor.audit(feed)

        #expect(report.recommendations.isEmpty)
    }

    // MARK: - 10. Recommendations Sorted by Priority Then Impact

    @Test("Recommendations sorted: critical with high impact first")
    func recommendationsSortedByPriorityThenImpact() throws {
        let feed = minimalFeed()
        let report = auditor.audit(feed)

        let recommendations = report.recommendations
        guard recommendations.count >= 2 else {
            #expect(Bool(false), "Expected at least 2 recommendations for minimal feed")
            return
        }

        // Verify sorted by priority first (critical < recommended < niceToHave)
        for index in 0..<(recommendations.count - 1) {
            let current = recommendations[index]
            let next = recommendations[index + 1]

            if current.priority == next.priority {
                // Within same priority, higher impact (potentialPoints) comes first
                #expect(current.potentialPoints >= next.potentialPoints)
            } else {
                // Lower priority value comes first (critical before recommended)
                #expect(current.priority < next.priority)
            }
        }

        // The first recommendation should be critical
        let first = try #require(recommendations.first)
        #expect(first.priority == .critical)
    }
}
