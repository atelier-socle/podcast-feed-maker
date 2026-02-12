import Foundation
@testable import PodcastFeedMaker

enum MockFeed {

    static let applePodcasts = PodcastFeed(channel: Channel(
        title: "CHANNEL TITLE",
        link: URL(string: "https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml")!,
        description: "CHANNEL DESCRIPTION CONTENT",
        language: "en_US",
        copyright: "Copyright 2025 Atelier Socle",
        pubDate: .now,
        lastBuildDate: .now,
        generator: "Atelier Socle Music Studios",
        ttl: 60,
        image: RSSImage(
            url: URL(string: "https://atelier-socle.com/podcasts/files/PodFeed-3000x3000.jpg")!,
            title: "CHANNEL TITLE",
            link: URL(string: "https://atelier-socle.com")!
        ),
        items: defaultItems,
        itunesAuthor: "CHANNEL AUTHOR NAME",
        itunesBlock: false,
        itunesCategories: [.music(), .news(.techNews)],
        itunesComplete: false,
        itunesExplicit: false,
        itunesImage: URL(string: "https://atelier-socle.com/podcasts/files/PodFeed-3000x3000.jpg")!,
        itunesKeywords: ["music", "sounds", "better", "with", "you"],
        itunesOwner: ITunesOwner(name: "CHANNEL OWNER NAME", email: "CHANNEL_OWNER@EMAIL"),
        itunesSubtitle: "CHANNEL SUBTITLE",
        itunesTitle: "CHANNEL TITLE",
        itunesType: .episodic,
        atomLinks: [.selfLink(href: URL(string: "https://atelier-socle.com/podcasts/feed-1742426334.0261931.xml")!)],
        podcastGuid: PodcastGuid(value: UUID().uuidString),
        locked: Locked(isLocked: false)
    ))

    static let defaultItems: [Item] = [
        Item(
            title: "EP.0 TITLE 0",
            link: URL(string: "https://atelier-socle.com")!,
            description: "EP.0 - My description 0, Listen on <a href=\"https://atelier-socle.com\">Apple Podcasts</a>.",
            enclosure: Enclosure(
                url: URL(string: "https://atelier-socle.com/podcasts/files/TronikShow899-Avicii.m4a")!,
                length: 27867798,
                mimeType: .m4a
            ),
            guid: GUID(value: UUID().uuidString),
            pubDate: .now,
            itunesDuration: 3349,
            itunesEpisodeType: .trailer,
            itunesExplicit: true,
            itunesImage: URL(string: "https://atelier-socle.com/podcasts/files/EP0-3000x3000.jpg")!,
            itunesSummary: "EP.0 - My description 0, Listen on <a href=\"https://atelier-socle.com\">Apple Podcasts</a>.",
            itunesTitle: "ITUNES EP.0 TITLE 0",
            transcripts: [
                Transcript(url: URL(string: "https://www.buzzsprout.com/1/10167133/transcript.vtt")!, type: "text/vtt")
            ],
            chaptersLink: ChaptersLink(
                url: URL(string: "https://atelier-socle.com/podcasts/files/chapter-00.json")!,
                type: "application/json+chapters"
            )
        ),
        Item(
            title: "EP.1 TITLE 1",
            link: URL(string: "https://atelier-socle.com")!,
            description: "EP.1 - My description 1, Listen on <a href=\"https://www.apple.com/itunes/podcasts/\">Apple Podcasts</a>.",
            enclosure: Enclosure(
                url: URL(string: "https://atelier-socle.com/podcasts/files/TronikShow885-Avicii.m4a")!,
                length: 31009618,
                mimeType: .m4a
            ),
            guid: GUID(value: UUID().uuidString),
            pubDate: .now,
            itunesBlock: false,
            itunesDuration: 3775,
            itunesEpisode: 1,
            itunesEpisodeType: .full,
            itunesExplicit: false,
            itunesImage: URL(string: "https://atelier-socle.com/podcasts/files/EP1-3000x3000.jpg")!,
            itunesSeason: 2,
            itunesSummary: "EP.1 - My description 1, Listen on <a href=\"https://www.apple.com/itunes/podcasts/\">Apple Podcasts</a>.",
            itunesTitle: "EP.1 - ITUNES TITLE 1",
            chaptersLink: ChaptersLink(
                url: URL(string: "https://atelier-socle.com/podcasts/files/chapter-01.json")!,
                type: "application/json+chapters"
            )
        )
    ]
}
