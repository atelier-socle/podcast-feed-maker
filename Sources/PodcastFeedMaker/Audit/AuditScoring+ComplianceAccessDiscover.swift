import Foundation

// MARK: - Compliance, Accessibility & Discoverability Evaluation

extension AuditScoring {

    // MARK: Compliance

    static func evaluateCompliance(_ feed: PodcastFeed) -> [AuditCriterionResult] {
        let channel = feed.channel
        let items = channel?.items ?? []
        return [
            evaluateLocked(channel),
            evaluatePodcastGuid(channel),
            evaluateAtomSelf(channel),
            evaluateExplicit(channel),
            evaluateItunesType(channel),
            evaluateEpisodeArtwork(items)
        ]
    }

    private static func evaluateLocked(_ channel: Channel?) -> AuditCriterionResult {
        if channel?.locked != nil {
            return AuditCriterionResult(
                criterion: complianceLocked, pointsAwarded: 4, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: complianceLocked, pointsAwarded: 0, passed: false,
            detail: "No podcast:locked element found"
        )
    }

    private static func evaluatePodcastGuid(_ channel: Channel?) -> AuditCriterionResult {
        if channel?.podcastGuid != nil {
            return AuditCriterionResult(
                criterion: complianceGuid, pointsAwarded: 4, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: complianceGuid, pointsAwarded: 0, passed: false,
            detail: "No podcast:guid element found"
        )
    }

    private static func evaluateAtomSelf(_ channel: Channel?) -> AuditCriterionResult {
        let hasSelf = channel?.atomLinks.contains { $0.rel == "self" } ?? false
        if hasSelf {
            return AuditCriterionResult(
                criterion: complianceAtomSelf, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: complianceAtomSelf, pointsAwarded: 0, passed: false,
            detail: "No atom:link rel=\"self\" found"
        )
    }

    private static func evaluateExplicit(_ channel: Channel?) -> AuditCriterionResult {
        if channel?.itunesExplicit != nil {
            return AuditCriterionResult(
                criterion: complianceExplicit, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: complianceExplicit, pointsAwarded: 0, passed: false,
            detail: "itunes:explicit not set"
        )
    }

    private static func evaluateItunesType(_ channel: Channel?) -> AuditCriterionResult {
        if channel?.itunesType != nil {
            return AuditCriterionResult(
                criterion: complianceType, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: complianceType, pointsAwarded: 0, passed: false,
            detail: "itunes:type not set"
        )
    }

    private static func evaluateEpisodeArtwork(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: complianceEpisodeArtwork, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let withArtwork = items.filter { $0.itunesImage != nil }.count
        let ratio = Double(withArtwork) / Double(items.count)
        if ratio >= 0.5 {
            return AuditCriterionResult(
                criterion: complianceEpisodeArtwork, pointsAwarded: 3, passed: true,
                detail: "\(withArtwork) of \(items.count) episodes have artwork"
            )
        }
        let points = Int((ratio * 2 * 3).rounded())
        return AuditCriterionResult(
            criterion: complianceEpisodeArtwork, pointsAwarded: min(points, 2),
            passed: false,
            detail: "Only \(withArtwork) of \(items.count) episodes have artwork (need ≥50%)"
        )
    }

    // MARK: Accessibility

    static func evaluateAccessibility(_ feed: PodcastFeed) -> [AuditCriterionResult] {
        let items = feed.channel?.items ?? []
        return [
            evaluateTranscripts(items),
            evaluateChapters(items),
            evaluateRichDescriptions(items),
            evaluateAltText()
        ]
    }

    private static func evaluateTranscripts(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: accessibilityTranscripts, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let withTranscripts = items.filter { !$0.transcripts.isEmpty }.count
        let ratio = Double(withTranscripts) / Double(items.count)
        if ratio >= 0.5 {
            return AuditCriterionResult(
                criterion: accessibilityTranscripts, pointsAwarded: 5, passed: true,
                detail: "\(withTranscripts) of \(items.count) episodes have transcripts"
            )
        }
        let points = Int((ratio * 2 * 5).rounded())
        return AuditCriterionResult(
            criterion: accessibilityTranscripts, pointsAwarded: min(points, 4),
            passed: false,
            detail: "Only \(withTranscripts) of \(items.count) episodes have transcripts (need ≥50%)"
        )
    }

    private static func evaluateChapters(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: accessibilityChapters, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let withChapters = items.filter {
            $0.chaptersLink != nil || $0.podloveChapters != nil
        }.count
        let ratio = Double(withChapters) / Double(items.count)
        if ratio >= 0.25 {
            return AuditCriterionResult(
                criterion: accessibilityChapters, pointsAwarded: 4, passed: true,
                detail: "\(withChapters) of \(items.count) episodes have chapters"
            )
        }
        let points = Int((ratio * 4 * 4).rounded())
        return AuditCriterionResult(
            criterion: accessibilityChapters, pointsAwarded: min(points, 3),
            passed: false,
            detail: "Only \(withChapters) of \(items.count) episodes have chapters (need ≥25%)"
        )
    }

    private static func evaluateRichDescriptions(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: accessibilityRichDescriptions, pointsAwarded: 0,
                passed: false, detail: "No episodes to evaluate"
            )
        }
        let rich = items.filter {
            $0.contentEncoded != nil || ($0.description?.count ?? 0) > 200
        }.count
        let ratio = Double(rich) / Double(items.count)
        if ratio >= 0.5 {
            return AuditCriterionResult(
                criterion: accessibilityRichDescriptions, pointsAwarded: 3,
                passed: true,
                detail: "\(rich) of \(items.count) episodes have rich descriptions"
            )
        }
        let points = Int((ratio * 2 * 3).rounded())
        return AuditCriterionResult(
            criterion: accessibilityRichDescriptions, pointsAwarded: min(points, 2),
            passed: false,
            detail: "Only \(rich) of \(items.count) episodes have rich descriptions (need ≥50%)"
        )
    }

    /// Alt text artwork — awarded 3 points by default.
    /// No spec currently supports alt text on podcast artwork.
    /// This will become a real check when specs support it.
    private static func evaluateAltText() -> AuditCriterionResult {
        AuditCriterionResult(
            criterion: accessibilityAltText, pointsAwarded: 3, passed: true,
            detail: "Awarded by default — no spec currently supports artwork alt text"
        )
    }

    // MARK: Discoverability

    static func evaluateDiscoverability(_ feed: PodcastFeed) -> [AuditCriterionResult] {
        let channel = feed.channel
        return [
            evaluateKeywords(channel),
            evaluateFunding(channel),
            evaluateSocial(channel?.items ?? []),
            evaluatePodroll(channel),
            evaluateUpdateFrequency(channel)
        ]
    }

    private static func evaluateKeywords(_ channel: Channel?) -> AuditCriterionResult {
        let hasTxt = !(channel?.txtRecords.isEmpty ?? true)
        let hasKeywords = !(channel?.itunesKeywords.isEmpty ?? true)
        if hasTxt || hasKeywords {
            return AuditCriterionResult(
                criterion: discoverabilityKeywords, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: discoverabilityKeywords, pointsAwarded: 0, passed: false,
            detail: "No podcast:txt or itunes:keywords found"
        )
    }

    private static func evaluateFunding(_ channel: Channel?) -> AuditCriterionResult {
        if !(channel?.funding.isEmpty ?? true) {
            return AuditCriterionResult(
                criterion: discoverabilityFunding, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: discoverabilityFunding, pointsAwarded: 0, passed: false,
            detail: "No podcast:funding element found"
        )
    }

    private static func evaluateSocial(_ items: [Item]) -> AuditCriterionResult {
        let hasSocial = items.contains { !$0.socialInteractions.isEmpty }
        if hasSocial {
            return AuditCriterionResult(
                criterion: discoverabilitySocial, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: discoverabilitySocial, pointsAwarded: 0, passed: false,
            detail: "No podcast:socialInteract elements found"
        )
    }

    private static func evaluatePodroll(_ channel: Channel?) -> AuditCriterionResult {
        if channel?.podroll != nil {
            return AuditCriterionResult(
                criterion: discoverabilityPodroll, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: discoverabilityPodroll, pointsAwarded: 0, passed: false,
            detail: "No podcast:podroll element found"
        )
    }

    private static func evaluateUpdateFrequency(
        _ channel: Channel?
    ) -> AuditCriterionResult {
        if channel?.updateFrequency != nil {
            return AuditCriterionResult(
                criterion: discoverabilityUpdateFrequency, pointsAwarded: 3,
                passed: true
            )
        }
        return AuditCriterionResult(
            criterion: discoverabilityUpdateFrequency, pointsAwarded: 0,
            passed: false, detail: "No podcast:updateFrequency element found"
        )
    }
}
