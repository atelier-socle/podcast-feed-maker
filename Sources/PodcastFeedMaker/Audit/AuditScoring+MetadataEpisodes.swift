import Foundation

// MARK: - Metadata & Episodes Evaluation

extension AuditScoring {

    // MARK: Metadata

    static func evaluateMetadata(_ feed: PodcastFeed) -> [AuditCriterionResult] {
        guard let channel = feed.channel else {
            return allMetadataCriteria.map {
                AuditCriterionResult(criterion: $0, pointsAwarded: 0, passed: false)
            }
        }
        return [
            evaluateArtwork(channel),
            evaluateDescription(channel),
            evaluateCategory(channel),
            evaluateLanguage(channel),
            evaluateAuthor(channel),
            evaluateOwner(channel),
            evaluateLink(channel),
            evaluateCopyright(channel)
        ]
    }

    private static var allMetadataCriteria: [AuditCriterion] {
        [
            metadataArtwork, metadataDescription, metadataCategory,
            metadataLanguage, metadataAuthor, metadataOwner,
            metadataLink, metadataCopyright
        ]
    }

    private static func evaluateArtwork(_ channel: Channel) -> AuditCriterionResult {
        guard let imageURL = channel.itunesImage else {
            return AuditCriterionResult(
                criterion: metadataArtwork, pointsAwarded: 0, passed: false,
                detail: "No itunes:image found"
            )
        }
        let isHTTPS = imageURL.scheme?.lowercased() == "https"
        if isHTTPS {
            return AuditCriterionResult(
                criterion: metadataArtwork, pointsAwarded: 5, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataArtwork, pointsAwarded: 3, passed: false,
            detail: "Artwork URL uses HTTP instead of HTTPS"
        )
    }

    private static func evaluateDescription(_ channel: Channel) -> AuditCriterionResult {
        let desc = channel.description
        if desc.count >= 100 && desc.count <= 4000 {
            return AuditCriterionResult(
                criterion: metadataDescription, pointsAwarded: 4, passed: true
            )
        }
        if desc.count > 4000 {
            return AuditCriterionResult(
                criterion: metadataDescription, pointsAwarded: 2, passed: false,
                detail: "Description exceeds 4000 characters (\(desc.count))"
            )
        }
        if desc.isEmpty {
            return AuditCriterionResult(
                criterion: metadataDescription, pointsAwarded: 0, passed: false,
                detail: "Description is empty"
            )
        }
        return AuditCriterionResult(
            criterion: metadataDescription, pointsAwarded: 2, passed: false,
            detail: "Description is only \(desc.count) characters (recommend ≥100)"
        )
    }

    private static func evaluateCategory(_ channel: Channel) -> AuditCriterionResult {
        if !channel.itunesCategories.isEmpty {
            return AuditCriterionResult(
                criterion: metadataCategory, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataCategory, pointsAwarded: 0, passed: false,
            detail: "No itunes:category found"
        )
    }

    private static func evaluateLanguage(_ channel: Channel) -> AuditCriterionResult {
        if let lang = channel.language, !lang.isEmpty {
            return AuditCriterionResult(
                criterion: metadataLanguage, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataLanguage, pointsAwarded: 0, passed: false,
            detail: "No language tag defined"
        )
    }

    private static func evaluateAuthor(_ channel: Channel) -> AuditCriterionResult {
        if let author = channel.itunesAuthor, !author.isEmpty {
            return AuditCriterionResult(
                criterion: metadataAuthor, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataAuthor, pointsAwarded: 0, passed: false,
            detail: "No itunes:author defined"
        )
    }

    private static func evaluateOwner(_ channel: Channel) -> AuditCriterionResult {
        if let owner = channel.itunesOwner,
            !owner.name.isEmpty, !owner.email.isEmpty
        {
            return AuditCriterionResult(
                criterion: metadataOwner, pointsAwarded: 3, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataOwner, pointsAwarded: 0, passed: false,
            detail: "Missing itunes:owner with name and email"
        )
    }

    private static func evaluateLink(_ channel: Channel) -> AuditCriterionResult {
        let isHTTPS = channel.link.scheme?.lowercased() == "https"
        if isHTTPS {
            return AuditCriterionResult(
                criterion: metadataLink, pointsAwarded: 2, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataLink, pointsAwarded: 1, passed: false,
            detail: "Site link uses HTTP instead of HTTPS"
        )
    }

    private static func evaluateCopyright(_ channel: Channel) -> AuditCriterionResult {
        if let cr = channel.copyright, !cr.isEmpty {
            return AuditCriterionResult(
                criterion: metadataCopyright, pointsAwarded: 2, passed: true
            )
        }
        return AuditCriterionResult(
            criterion: metadataCopyright, pointsAwarded: 0, passed: false,
            detail: "No copyright notice defined"
        )
    }

    // MARK: Episodes

    static func evaluateEpisodes(_ feed: PodcastFeed) -> [AuditCriterionResult] {
        let items = feed.channel?.items ?? []
        return [
            evaluateHasEpisodes(items),
            evaluateEnclosures(items),
            evaluateDurations(items),
            evaluateUniqueGuids(items),
            evaluateEpisodeDescriptions(items),
            evaluatePubDates(items)
        ]
    }

    private static func evaluateHasEpisodes(_ items: [Item]) -> AuditCriterionResult {
        if !items.isEmpty {
            return AuditCriterionResult(
                criterion: episodesHasEpisodes, pointsAwarded: 5, passed: true,
                detail: "\(items.count) episode(s)"
            )
        }
        return AuditCriterionResult(
            criterion: episodesHasEpisodes, pointsAwarded: 0, passed: false,
            detail: "Feed has no episodes"
        )
    }

    private static func evaluateEnclosures(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: episodesEnclosures, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let missing = items.filter { $0.enclosure == nil }.count
        if missing == 0 {
            return AuditCriterionResult(
                criterion: episodesEnclosures, pointsAwarded: 5, passed: true
            )
        }
        let ratio = Double(items.count - missing) / Double(items.count)
        let points = Int((ratio * 5).rounded())
        return AuditCriterionResult(
            criterion: episodesEnclosures, pointsAwarded: points, passed: false,
            detail: "\(missing) of \(items.count) episodes missing enclosure"
        )
    }

    private static func evaluateDurations(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: episodesDurations, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let missing = items.filter { $0.itunesDuration == nil }.count
        if missing == 0 {
            return AuditCriterionResult(
                criterion: episodesDurations, pointsAwarded: 4, passed: true
            )
        }
        let ratio = Double(items.count - missing) / Double(items.count)
        let points = Int((ratio * 4).rounded())
        return AuditCriterionResult(
            criterion: episodesDurations, pointsAwarded: points, passed: false,
            detail: "\(missing) of \(items.count) episodes missing duration"
        )
    }

    private static func evaluateUniqueGuids(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: episodesUniqueGuids, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let guids = items.compactMap { $0.guid?.value }
        let uniqueGuids = Set(guids)
        let duplicateCount = guids.count - uniqueGuids.count
        let missingCount = items.count - guids.count

        if duplicateCount == 0 && missingCount == 0 {
            return AuditCriterionResult(
                criterion: episodesUniqueGuids, pointsAwarded: 4, passed: true
            )
        }
        var details: [String] = []
        if duplicateCount > 0 {
            details.append("\(duplicateCount) duplicate GUID(s)")
        }
        if missingCount > 0 {
            details.append("\(missingCount) episode(s) missing GUID")
        }
        let ratio = Double(uniqueGuids.count) / Double(items.count)
        let points = Int((ratio * 4).rounded())
        return AuditCriterionResult(
            criterion: episodesUniqueGuids, pointsAwarded: points, passed: false,
            detail: details.joined(separator: ", ")
        )
    }

    private static func evaluateEpisodeDescriptions(
        _ items: [Item]
    ) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: episodesDescriptions, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let short = items.filter { ($0.description?.count ?? 0) < 50 }.count
        if short == 0 {
            return AuditCriterionResult(
                criterion: episodesDescriptions, pointsAwarded: 4, passed: true
            )
        }
        let ratio = Double(items.count - short) / Double(items.count)
        let points = Int((ratio * 4).rounded())
        return AuditCriterionResult(
            criterion: episodesDescriptions, pointsAwarded: points, passed: false,
            detail: "\(short) of \(items.count) episodes have descriptions < 50 chars"
        )
    }

    private static func evaluatePubDates(_ items: [Item]) -> AuditCriterionResult {
        guard !items.isEmpty else {
            return AuditCriterionResult(
                criterion: episodesPubDates, pointsAwarded: 0, passed: false,
                detail: "No episodes to evaluate"
            )
        }
        let missing = items.filter { $0.pubDate == nil }.count
        if missing == 0 {
            return AuditCriterionResult(
                criterion: episodesPubDates, pointsAwarded: 3, passed: true
            )
        }
        let ratio = Double(items.count - missing) / Double(items.count)
        let points = Int((ratio * 3).rounded())
        return AuditCriterionResult(
            criterion: episodesPubDates, pointsAwarded: points, passed: false,
            detail: "\(missing) of \(items.count) episodes missing pubDate"
        )
    }
}
