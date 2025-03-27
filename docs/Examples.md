# 🧪 PodcastFeedMaker Examples

---

## 1️⃣ Minimal Example (Valid PSP-1 Feed)

```swift
let feed = Feed(channel: .init(
    title: .init("My Podcast"),
    link: .init(URL(string: "https://podcast.example.com/feed.xml")!),
    description: .init("A simple podcast feed."),
    author: .init(name: "John Doe"),
    explicit: .init(.no),
    image: .init(url: URL(string: "https://podcast.example.com/image.jpg")!),
    categories: .init(categories: [.arts([])]),
    items: [],
    language: .init(value: "en_US"),
    atomSelfLink: .init(url: URL(string: "https://podcast.example.com/feed.xml")!)
))
```

---

## 2️⃣ Recommended Feed (Validator Compliant)

```swift
let recommendedFeed = Feed(channel: .init(
    title: .init("CHANNEL TITLE"),
    link: .init(URL(string: "https://podcast.example.com/feed.xml")!),
    description: .init("CHANNEL DESCRIPTION CONTENT"),
    author: .init(name: "CHANNEL AUTHOR NAME"),
    explicit: .init(.clean),
    image: .init(url: URL(string: "https://podcast.example.com/cover.jpg")!),
    categories: .init(categories: [.music([]), .news([.techNews])]),
    items: [],
    language: .init(value: "en_US"),
    summary: .init(content: "A summary of your podcast."),
    owner: .init(name: "Owner Name", mail: "owner@example.com"),
    type: .init(type: .episodic),
    atomSelfLink: .init(url: URL(string: "https://podcast.example.com/feed.xml")!),
    additionalTags: [
        Namespace.Podcast.Guid(value: UUID().uuidString),
        Namespace.Podcast.Locked(value: false),
        RSSTag.TimeToLive(60),
        RSSTag.PubDate(.now),
        RSSTag.LastBuildDate(.now),
        RSSTag.Generator("PodcastFeedMaker"),
        RSSTag.Copyright("© 2025 Podcast Inc."),
        Namespace.iTunes.Subtitle(text: "Podcast subtitle here"),
        Namespace.iTunes.Title(text: "CHANNEL TITLE"),
        Namespace.iTunes.Keywords(keywords: ["swift", "rss", "podcast"]),
        Namespace.iTunes.Block(value: false),
        Namespace.iTunes.Complete(value: false)
    ]
))
```

---

## 3️⃣ Advanced Episode Item

```swift
let item = RSSTag.Item(
    title: .init("EP.1 TITLE"),
    enclosure: .init(
        url: URL(string: "https://podcast.example.com/audio/ep1.m4a")!,
        length: 12345678,
        type: .m4a
    ),
    guid: .init(value: UUID().uuidString),
    pubDate: .init(.now),
    additionalTags: [
        Namespace.iTunes.Image(url: URL(string: "https://podcast.example.com/images/ep1.jpg")!),
        Namespace.iTunes.Duration(duration: 3600),
        Namespace.iTunes.Episode(value: 1),
        Namespace.iTunes.EpisodeType(type: .full),
        Namespace.iTunes.Explicit(.no),
        Namespace.iTunes.Title(text: "EP.1 ITUNES TITLE"),
        Namespace.iTunes.Summary(content: "EP.1 Summary", type: .html),
        RSSTag.Description("EP.1 Description", type: .html),
        Namespace.Podcast.Chapters(url: URL(string: "https://podcast.example.com/chapters/ep1.json")!, type: .json),
        Namespace.Podcast.Transcript(url: URL(string: "https://podcast.example.com/transcript/ep1.vtt")!, type: .vtt)
    ]
)
```

---

## 4️⃣ Advanced Custom Feed

```swift
import PodcastFeedMaker

let customTags: [any XmlRepresentable] = [
    RSSTag.Title("My Podcast Show"),
    RSSTag.Link(URL(string: "https://podcast.example.com/feed.xml")!),
    RSSTag.Description("A podcast about stories that matter."),
    RSSTag.Language(value: "en_US"),
    Namespace.iTunes.Author(name: "Podcast Author"),
    Namespace.iTunes.Image(url: URL(string: "https://podcast.example.com/assets/cover.jpg")!),
    Namespace.iTunes.Explicit(.clean),
    Namespace.Podcast.Guid(value: UUID().uuidString),
    Namespace.Atom.Link(url: URL(string: "https://podcast.example.com/feed.xml")!),
    RSSTag.PubDate(.now),
    RSSTag.LastBuildDate(.now)
]

let item = RSSTag.Item(
    title: .init("Episode 1"),
    enclosure: .init(
        url: URL(string: "https://podcast.example.com/episodes/ep1.m4a")!,
        length: 12345678,
        type: .m4a
    ),
    guid: .init(value: UUID().uuidString),
    pubDate: .init(.now),
    description: .init("Episode 1 description", type: .html),
    itunesTitle: .init(text: "Episode 1 – Special Guest"),
    itunesImage: .init(url: URL(string: "https://podcast.example.com/assets/ep1.jpg")!),
    itunesExplicit: .init(.no),
    itunesDuration: .init(duration: 1482),
    itunesEpisodeType: .init(type: .full),
    additionalTags: [
        Namespace.Podcast.Transcript(
            url: URL(string: "https://podcast.example.com/episodes/ep1.vtt")!,
            type: .vtt
        )
    ]
)

let categories = Namespace.iTunes.Category(
    categories: [
        .societyAndCulture([.philosophy]),
        .technology
    ]
)

let channel = RSSTag.Channel(
    tags: customTags,
    items: [item],
    categories: categories
)

let feed = Feed(channel: channel)

do {
    let xml = try PodcastFeedMaker(feed).xmlRepresentation()
    print(xml)
} catch {
    print("❌ XML generation failed: \(error.localizedDescription)")
}
```
