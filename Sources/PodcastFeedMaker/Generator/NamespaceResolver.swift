import Foundation

/// Auto-detects which XML namespaces are actually used in a ``PodcastFeed``.
///
/// Rather than always declaring all 6 standard namespaces, `NamespaceResolver`
/// scans the channel and all items to determine which namespace declarations
/// are required. This produces cleaner XML output.
///
/// - SeeAlso: ``FeedGenerator/NamespaceMode``
public struct NamespaceResolver: Sendable {

    /// Resolves which namespaces are used in the given feed.
    ///
    /// Scans the channel, all items, trailers, and live items.
    ///
    /// - Parameter feed: The feed to analyze.
    /// - Returns: An array of namespaces that are actually referenced.
    public static func resolve(_ feed: PodcastFeed) -> [PodcastNamespace] {
        guard let channel = feed.channel else { return [] }

        var namespaces: [PodcastNamespace] = []

        if usesITunes(channel: channel) {
            namespaces.append(.itunes)
        }

        if usesAtom(channel: channel) {
            namespaces.append(.atom)
        }

        if usesPodcast(channel: channel) {
            namespaces.append(.podcast)
        }

        if usesDublinCore(channel: channel) {
            namespaces.append(.dublinCore)
        }

        if usesContent(channel: channel) {
            namespaces.append(.content)
        }

        if usesPodlove(channel: channel) {
            namespaces.append(.podloveSimpleChapters)
        }

        // Preserve any custom namespaces from the feed
        for ns in feed.namespaces {
            if case .custom = ns {
                namespaces.append(ns)
            }
        }

        return namespaces
    }

    // MARK: - Namespace Detection

    private static func usesITunes(channel: Channel) -> Bool {
        channel.itunesAuthor != nil
            || channel.itunesBlock != nil
            || !channel.itunesCategories.isEmpty
            || channel.itunesComplete != nil
            || channel.itunesExplicit != nil
            || channel.itunesImage != nil
            || !channel.itunesKeywords.isEmpty
            || channel.itunesNewFeedUrl != nil
            || channel.itunesOwner != nil
            || channel.itunesSubtitle != nil
            || channel.itunesSummary != nil
            || channel.itunesTitle != nil
            || channel.itunesType != nil
            || channel.itunesVerify != nil
            || channel.items.contains(where: { usesITunesItem($0) })
    }

    private static func usesITunesItem(_ item: Item) -> Bool {
        item.itunesAuthor != nil
            || item.itunesBlock != nil
            || item.itunesDuration != nil
            || item.itunesEpisode != nil
            || item.itunesEpisodeType != nil
            || item.itunesExplicit != nil
            || item.itunesImage != nil
            || !item.itunesKeywords.isEmpty
            || item.itunesSeason != nil
            || item.itunesSubtitle != nil
            || item.itunesSummary != nil
            || item.itunesTitle != nil
    }

    private static func usesAtom(channel: Channel) -> Bool {
        !channel.atomLinks.isEmpty
            || channel.items.contains(where: { !$0.atomLinks.isEmpty })
    }

    private static func usesPodcast(channel: Channel) -> Bool {
        channel.podcastGuid != nil
            || channel.locked != nil
            || !channel.funding.isEmpty
            || !channel.persons.isEmpty
            || !channel.locations.isEmpty
            || channel.license != nil
            || channel.value != nil
            || channel.medium != nil
            || !channel.podcastBlocks.isEmpty
            || !channel.txtRecords.isEmpty
            || channel.podroll != nil
            || channel.updateFrequency != nil
            || channel.podpingEnabled != nil
            || !channel.trailers.isEmpty
            || !channel.liveItems.isEmpty
            || channel.publisher != nil
            || !channel.podcastImages.isEmpty
            || channel.podcastImagesSrcset != nil
            || channel.chat != nil
            || channel.items.contains(where: { usesPodcastItem($0) })
    }

    private static func usesPodcastItem(_ item: Item) -> Bool {
        !item.transcripts.isEmpty
            || item.chaptersLink != nil
            || !item.soundbites.isEmpty
            || !item.persons.isEmpty
            || !item.locations.isEmpty
            || item.license != nil
            || !item.alternateEnclosures.isEmpty
            || item.value != nil
            || !item.socialInteractions.isEmpty
            || !item.txtRecords.isEmpty
            || item.podcastSeason != nil
            || item.podcastEpisode != nil
            || !item.podcastImages.isEmpty
            || item.podcastImagesSrcset != nil
    }

    private static func usesDublinCore(channel: Channel) -> Bool {
        channel.dublinCore != nil
            || channel.items.contains(where: { $0.dublinCore != nil })
    }

    private static func usesContent(channel: Channel) -> Bool {
        channel.items.contains(where: { $0.contentEncoded != nil })
    }

    private static func usesPodlove(channel: Channel) -> Bool {
        channel.items.contains(where: { $0.podloveChapters != nil })
    }
}
