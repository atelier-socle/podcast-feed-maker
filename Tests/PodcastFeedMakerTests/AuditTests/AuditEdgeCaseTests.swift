import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Audit Edge Case Tests

@Suite("Audit Edge Cases")
struct AuditEdgeCaseTests {

    private let auditor = FeedAuditor()

    // MARK: - Helpers

    private func feedWithChannel(_ channel: Channel) -> PodcastFeed {
        PodcastFeed(channel: channel)
    }

    func richChannel() -> Channel {
        var channel = Channel(
            title: "Rich Show",
            link: makeURL("https://example.com"),
            description: String(repeating: "A", count: 150)
        )
        channel.language = "en"
        channel.copyright = "2026 Example"
        channel.itunesAuthor = "Host Name"
        channel.itunesOwner = ITunesOwner(name: "Host", email: "h@example.com")
        channel.itunesImage = makeURL("https://example.com/art.jpg")
        channel.itunesCategories = [ITunesCategory(text: "Technology")]
        channel.itunesExplicit = false
        channel.itunesType = .episodic
        channel.atomLinks = [
            AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))
        ]
        channel.locked = Locked(isLocked: true, owner: "h@example.com")
        channel.podcastGuid = PodcastGuid(
            value: "550e8400-e29b-41d4-a716-446655440000"
        )
        return channel
    }

    func makeItem(
        title: String,
        guidValue: String,
        description: String = "A decent episode description for scoring",
        duration: Int? = 3600
    ) -> Item {
        var item = Item()
        item.title = title
        item.description = description
        item.guid = GUID(value: guidValue, isPermaLink: false)
        item.enclosure = Enclosure(
            url: makeURL("https://example.com/ep.mp3"),
            length: 12345,
            type: "audio/mpeg"
        )
        item.itunesDuration = duration
        item.pubDate = Date()
        return item
    }

    // MARK: - Empty / No-Episodes Feed

    @Test("Empty feed with no channel — episodeCount 0, very low score, grade F")
    func emptyFeedNoChannel() {
        let feed = PodcastFeed(channel: nil)
        let report = auditor.audit(feed)

        #expect(report.episodeCount == 0)
        #expect(report.score <= 5)
        #expect(report.grade == .f)
    }

    @Test("Feed with 0 episodes — episodeCount 0, critical recommendation")
    func feedZeroEpisodes() {
        let channel = Channel(
            title: "No Episodes",
            link: makeURL("https://example.com"),
            description: "A podcast that has not published yet"
        )
        let feed = feedWithChannel(channel)
        let report = auditor.audit(feed)

        #expect(report.episodeCount == 0)
        let hasEpisodesRec = report.recommendations.contains {
            $0.criterionId == "episodes.hasEpisodes"
        }
        #expect(hasEpisodesRec)

        let criticalRec = report.recommendations.first {
            $0.criterionId == "episodes.hasEpisodes"
        }
        #expect(criticalRec?.priority == .critical)
    }

    // MARK: - Duplicate GUIDs

    @Test("Feed with duplicate GUIDs — uniqueGuids criterion fails")
    func duplicateGuids() {
        var channel = richChannel()
        var item1 = makeItem(title: "Episode 1", guidValue: "guid-a")
        var item2 = makeItem(title: "Episode 2", guidValue: "guid-a")
        var item3 = makeItem(title: "Episode 3", guidValue: "guid-b")
        item1.itunesImage = makeURL("https://example.com/ep1.jpg")
        item2.itunesImage = makeURL("https://example.com/ep2.jpg")
        item3.itunesImage = makeURL("https://example.com/ep3.jpg")
        channel.items = [item1, item2, item3]
        let feed = feedWithChannel(channel)
        let report = auditor.audit(feed)

        let guidResult = report.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "episodes.uniqueGuids" }
        #expect(guidResult != nil)
        if let guidResult {
            #expect(guidResult.passed == false)
            #expect(guidResult.pointsAwarded < guidResult.criterion.maxPoints)
        }
    }

    // MARK: - Empty Descriptions

    @Test("Feed with empty or short descriptions — descriptions criterion fails")
    func emptyDescriptions() {
        var channel = richChannel()
        var item1 = makeItem(title: "Ep1", guidValue: "g1", description: "")
        var item2 = makeItem(title: "Ep2", guidValue: "g2", description: "Short")
        item1.itunesImage = makeURL("https://example.com/ep1.jpg")
        item2.itunesImage = makeURL("https://example.com/ep2.jpg")
        channel.items = [item1, item2]
        let feed = feedWithChannel(channel)
        let report = auditor.audit(feed)

        let descResult = report.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "episodes.descriptions" }
        #expect(descResult != nil)
        if let descResult {
            #expect(descResult.passed == false)
        }
    }

    // MARK: - HTTPS vs HTTP Artwork

    @Test("HTTPS artwork gets full points, HTTP artwork gets partial")
    func artworkHTTPSvsHTTP() {
        var httpsChannel = richChannel()
        httpsChannel.itunesImage = makeURL("https://example.com/art.jpg")
        var httpsItem = makeItem(title: "Ep", guidValue: "g1")
        httpsItem.itunesImage = makeURL("https://example.com/ep.jpg")
        httpsChannel.items = [httpsItem]
        let httpsFeed = feedWithChannel(httpsChannel)
        let httpsReport = auditor.audit(httpsFeed)

        var httpChannel = richChannel()
        httpChannel.itunesImage = makeURL("http://example.com/art.jpg")
        var httpItem = makeItem(title: "Ep", guidValue: "g1")
        httpItem.itunesImage = makeURL("http://example.com/ep.jpg")
        httpChannel.items = [httpItem]
        let httpFeed = feedWithChannel(httpChannel)
        let httpReport = auditor.audit(httpFeed)

        let httpsArtwork = httpsReport.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "metadata.artwork" }
        let httpArtwork = httpReport.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "metadata.artwork" }

        #expect(httpsArtwork != nil)
        #expect(httpArtwork != nil)
        if let httpsArtwork, let httpArtwork {
            #expect(httpsArtwork.pointsAwarded > httpArtwork.pointsAwarded)
            #expect(httpsArtwork.passed == true)
            #expect(httpArtwork.passed == false)
        }
    }

    // MARK: - Grade Boundaries

    @Test("Grade boundaries — score 94 is A, 95 is A+, 59 is F, 60 is D")
    func gradeBoundaries() {
        #expect(AuditGrade.from(score: 94) == .a)
        #expect(AuditGrade.from(score: 95) == .aPlus)
        #expect(AuditGrade.from(score: 59) == .f)
        #expect(AuditGrade.from(score: 60) == .d)
        #expect(AuditGrade.from(score: 0) == .f)
        #expect(AuditGrade.from(score: 100) == .aPlus)
    }
}

// MARK: - Scoring & Codable Edge Cases

extension AuditEdgeCaseTests {

    @Test("Description length: 100 chars full points, 99 chars partial, empty 0")
    func descriptionLength() {
        let desc100 = String(repeating: "x", count: 100)
        var ch100 = Channel(
            title: "T",
            link: makeURL("https://example.com"),
            description: desc100
        )
        ch100.itunesImage = makeURL("https://example.com/art.jpg")
        let report100 = auditor.audit(PodcastFeed(channel: ch100))
        let result100 = report100.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "metadata.description" }

        let desc99 = String(repeating: "x", count: 99)
        var ch99 = Channel(
            title: "T",
            link: makeURL("https://example.com"),
            description: desc99
        )
        ch99.itunesImage = makeURL("https://example.com/art.jpg")
        let report99 = auditor.audit(PodcastFeed(channel: ch99))
        let result99 = report99.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "metadata.description" }

        var chEmpty = Channel(
            title: "T",
            link: makeURL("https://example.com"),
            description: ""
        )
        chEmpty.itunesImage = makeURL("https://example.com/art.jpg")
        let reportEmpty = auditor.audit(PodcastFeed(channel: chEmpty))
        let resultEmpty = reportEmpty.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "metadata.description" }

        #expect(result100 != nil)
        #expect(result99 != nil)
        #expect(resultEmpty != nil)

        if let result100 {
            #expect(result100.pointsAwarded == result100.criterion.maxPoints)
            #expect(result100.passed == true)
        }
        if let result99 {
            #expect(result99.pointsAwarded < result99.criterion.maxPoints)
            #expect(result99.passed == false)
        }
        if let resultEmpty {
            #expect(resultEmpty.pointsAwarded == 0)
            #expect(resultEmpty.passed == false)
        }
    }

    @Test("All Podcast NS 2.0 tags present yields high compliance score")
    func podcastNS20HighCompliance() {
        var channel = richChannel()
        channel.funding = [
            Funding(url: makeURL("https://example.com/donate"), message: "Support")
        ]
        channel.txtRecords = [PodcastTxt(value: "verify=abc123")]
        channel.podroll = Podroll(remoteItems: [RemoteItem(feedGuid: "abc-def")])
        channel.updateFrequency = UpdateFrequency(label: "weekly")

        var item = makeItem(title: "Ep1", guidValue: "g1")
        item.itunesImage = makeURL("https://example.com/ep.jpg")
        item.transcripts = [
            Transcript(url: makeURL("https://example.com/t.vtt"), type: "text/vtt")
        ]
        item.chaptersLink = ChaptersLink(
            url: makeURL("https://example.com/chapters.json")
        )
        item.contentEncoded = ContentEncoded(value: "<p>Rich content</p>")
        item.socialInteractions = [
            SocialInteract(
                uri: "https://social.example/post/1", protocol: "activitypub"
            )
        ]
        channel.items = [item]

        let report = auditor.audit(PodcastFeed(channel: channel))

        // Comparable on AuditGrade is inverted (aPlus < a < ... < f),
        // so "better or equal to B+" means grade <= .bPlus.
        #expect(report.score >= 85)
        #expect(report.grade <= .bPlus)
    }

    @Test("Only RSS 2.0 tags — low score but valid report")
    func rssOnlyFeed() {
        let channel = Channel(
            title: "RSS Only Show",
            link: makeURL("https://example.com"),
            description: String(repeating: "A", count: 120),
            items: [
                Item(
                    title: "Episode 1",
                    description: String(repeating: "B", count: 60),
                    enclosure: Enclosure(
                        url: makeURL("https://example.com/ep.mp3"),
                        length: 5000,
                        type: "audio/mpeg"
                    ),
                    guid: GUID(value: "e1", isPermaLink: false),
                    pubDate: Date()
                )
            ]
        )
        let report = auditor.audit(PodcastFeed(channel: channel))

        #expect(report.score < 60)
        #expect(report.grade == .f)
        #expect(report.episodeCount == 1)
        #expect(report.recommendations.count > 0)
    }

    @Test("Partial scoring — 7 of 10 episodes with duration gets proportional points")
    func partialScoringDuration() {
        var channel = richChannel()
        let epImage = makeURL("https://example.com/ep.jpg")
        var items: [Item] = []
        for i in 0..<10 {
            let duration: Int? = i < 7 ? 3600 : nil
            var item = makeItem(
                title: "Ep \(i)",
                guidValue: "g-\(i)",
                duration: duration
            )
            item.itunesImage = epImage
            items.append(item)
        }
        channel.items = items
        let report = auditor.audit(PodcastFeed(channel: channel))

        let durationResult = report.categoryScores
            .flatMap(\.criteria)
            .first { $0.criterion.identifier == "episodes.durations" }
        #expect(durationResult != nil)
        if let durationResult {
            #expect(durationResult.pointsAwarded > 0)
            #expect(durationResult.pointsAwarded < durationResult.criterion.maxPoints)
            #expect(durationResult.passed == false)
        }
    }

    @Test("Feed with all metadata but no episodes — high metadata, episodes 0")
    func allMetadataNoEpisodes() {
        let channel = richChannel()
        let report = auditor.audit(PodcastFeed(channel: channel))

        #expect(report.episodeCount == 0)

        let metaScore = report.categoryScores.first { $0.category == .metadata }
        let epScore = report.categoryScores.first { $0.category == .episodes }

        #expect(metaScore != nil)
        #expect(epScore != nil)
        if let metaScore, let epScore {
            #expect(metaScore.earned > epScore.earned)
            #expect(epScore.earned == 0)
        }
    }

    @Test("AuditReport encodes to JSON and decodes back")
    func auditReportCodable() throws {
        var channel = richChannel()
        var item = makeItem(title: "Ep", guidValue: "g1")
        item.itunesImage = makeURL("https://example.com/ep.jpg")
        channel.items = [item]
        let original = auditor.audit(PodcastFeed(channel: channel))

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AuditReport.self, from: data)

        #expect(decoded.score == original.score)
        #expect(decoded.grade == original.grade)
        #expect(decoded.episodeCount == original.episodeCount)
        #expect(decoded.feedTitle == original.feedTitle)
        #expect(decoded.categoryScores.count == original.categoryScores.count)
        #expect(decoded.recommendations.count == original.recommendations.count)
        #expect(decoded.compatibility.count == original.compatibility.count)
    }

    @Test("Grade boundary ranges cover full 0-100 spectrum")
    func gradeBoundaryFullSpectrum() {
        #expect(AuditGrade.from(score: 90) == .a)
        #expect(AuditGrade.from(score: 85) == .bPlus)
        #expect(AuditGrade.from(score: 89) == .bPlus)
        #expect(AuditGrade.from(score: 80) == .b)
        #expect(AuditGrade.from(score: 84) == .b)
        #expect(AuditGrade.from(score: 75) == .cPlus)
        #expect(AuditGrade.from(score: 79) == .cPlus)
        #expect(AuditGrade.from(score: 70) == .c)
        #expect(AuditGrade.from(score: 74) == .c)
        #expect(AuditGrade.from(score: 69) == .d)
    }

    @Test("Any feed score is between 0 and 100 inclusive")
    func scoreBounds() {
        let emptyReport = auditor.audit(PodcastFeed(channel: nil))
        #expect(emptyReport.score >= 0)
        #expect(emptyReport.score <= 100)

        var channel = richChannel()
        var item = makeItem(title: "Ep", guidValue: "g1")
        item.itunesImage = makeURL("https://example.com/ep.jpg")
        channel.items = [item]
        let richReport = auditor.audit(PodcastFeed(channel: channel))
        #expect(richReport.score >= 0)
        #expect(richReport.score <= 100)
    }
}
