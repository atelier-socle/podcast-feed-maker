# Builder DSL

Build podcast feeds with a fluent, expressive Swift API.

## Overview

PodcastFeedMaker provides a result builder DSL and fluent modifier pattern for constructing podcast feeds entirely in Swift. Instead of assembling ``Channel`` and ``Item`` structs by hand, you declare your feed structure using ``PodcastFeedBuilder`` closures and chain modifiers for metadata. The result is concise, readable, and type-safe feed construction with zero string literals for tag names.

## Result Builder Syntax

The ``PodcastFeedBuilder`` result builder lets you declare a ``PodcastFeed`` by listing a ``Channel`` and any number of ``Item`` values inside a closure. Items declared in the closure are appended to the channel automatically.

```swift
let feed = PodcastFeed {
    Channel(
        title: "Builder Show",
        link: URL(string: "https://example.com")!,
        description: "Built with the DSL"
    )
    .author("Host Name")
    .explicit(false)
    .category(.technology)
    .image("https://cdn.example.com/artwork.jpg")

    Item(
        title: "Episode 1",
        enclosure: Enclosure.mp3(
            url: "https://cdn.example.com/episodes/ep001.mp3",
            length: 48_000_000
        )
    )
    .guid("ep-001", isPermaLink: false)
    .duration(1800)

    Item(
        title: "Episode 2",
        enclosure: Enclosure.mp3(
            url: "https://cdn.example.com/episodes/ep002.mp3",
            length: 55_000_000
        )
    )
    .guid("ep-002", isPermaLink: false)
    .duration(2400)
}
```

Both ``Channel`` and ``Item`` conform to the ``FeedComponent`` protocol, which is the marker protocol accepted by the builder. If a ``Channel`` already contains items in its `items` array, items declared in the builder closure are appended after the existing ones.

## Channel Modifiers

Every modifier returns a new copy of the ``Channel`` with the field set, so modifiers can be chained freely.

| Modifier | Description |
|----------|-------------|
| `.author(_:)` | Set `itunes:author` |
| `.language(_:)` | Set channel language (BCP 47) |
| `.copyright(_:)` | Set copyright notice |
| `.category(_:)` | Append an iTunes category |
| `.categories(_:)` | Replace all iTunes categories |
| `.explicit(_:)` | Set `itunes:explicit` flag |
| `.image(_:)` | Set `itunes:image` artwork URL (string) |
| `.type(_:)` | Set `itunes:type` (`"episodic"` or `"serial"`) |
| `.owner(name:email:)` | Set `itunes:owner` |
| `.locked(owner:)` | Set `podcast:locked` (always locks with owner) |
| `.guid(_:)` | Set `podcast:guid` |
| `.funding(url:text:)` | Append a `podcast:funding` link |
| `.atomLink(href:rel:)` | Append an `atom:link` |
| `.medium(_:)` | Set `podcast:medium` |
| `.publisher(feedGuid:feedUrl:)` | Set `podcast:publisher` with remote item |
| `.newFeedUrl(_:)` | Set `itunes:new-feed-url` |
| `.complete(_:)` | Set `itunes:complete` |
| `.location(name:geo:osm:rel:country:)` | Append a `podcast:location` |

All 18 modifiers can be chained in a single expression:

```swift
let channel = Channel(
    title: "Fluent Show",
    link: URL(string: "https://example.com")!,
    description: "Testing all modifiers"
)
.author("Jane Doe")
.language("en-us")
.copyright("(c) 2025")
.category(.technology)
.explicit(false)
.image("https://cdn.example.com/art.jpg")
.type("episodic")
.owner(name: "Jane", email: "jane@example.com")
.locked(owner: "jane@example.com")
.guid("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
.funding(url: "https://patreon.com/show", text: "Support us")
.atomLink(href: "https://example.com/feed.xml", rel: "self")
.medium(.podcast)
.publisher(feedGuid: "net-guid")
.newFeedUrl("https://new.example.com/feed.xml")
.complete(false)
.location(name: "San Francisco")
```

## Item Modifiers

``Item`` modifiers follow the same copy-on-write pattern as channel modifiers.

| Modifier | Description |
|----------|-------------|
| `.description(_:)` | Set item description |
| `.guid(_:isPermaLink:)` | Set item GUID |
| `.pubDate(_:)` | Set publication date |
| `.duration(_:)` | Set `itunes:duration` in seconds |
| `.explicit(_:)` | Set `itunes:explicit` |
| `.image(_:)` | Set `itunes:image` (string) |
| `.season(_:)` | Set `itunes:season` number |
| `.episode(_:)` | Set `itunes:episode` number |
| `.episodeType(_:)` | Set `itunes:episodeType` (`"full"`, `"trailer"`, `"bonus"`) |
| `.person(_:role:)` | Append a `podcast:person` with ``PodcastPerson/Role`` |
| `.transcript(url:type:)` | Append a `podcast:transcript` |
| `.chapters(url:)` | Set `podcast:chapters` link (JSON chapters) |
| `.soundbite(start:duration:title:)` | Append a `podcast:soundbite` |
| `.contentEncoded(_:)` | Set `content:encoded` HTML |

Here is an item using every modifier:

```swift
let item = Item(
    title: "Test Episode",
    enclosure: Enclosure.mp3(
        url: "https://cdn.example.com/episodes/test-ep.mp3",
        length: 38_000_000
    )
)
    .description("Full episode description")
    .guid("ep-001", isPermaLink: false)
    .pubDate(Date(timeIntervalSince1970: 1_700_000_000))
    .duration(2700)
    .explicit(false)
    .image("https://cdn.example.com/ep.jpg")
    .season(1)
    .episode(3)
    .episodeType("full")
    .person("Host", role: .host)
    .transcript(url: "https://example.com/ep.vtt", type: .vtt)
    .chapters(url: "https://example.com/chapters.json")
    .soundbite(start: 60.0, duration: 15.0)
    .contentEncoded("<p>Episode notes</p>")
```

The `.person(_:role:)` modifier accepts a ``PodcastPerson/Role`` value. The role enum covers eight common podcast taxonomy roles:

- ``PodcastPerson/Role/host``
- ``PodcastPerson/Role/guest``
- ``PodcastPerson/Role/editor``
- ``PodcastPerson/Role/producer``
- ``PodcastPerson/Role/writer``
- ``PodcastPerson/Role/designer``
- ``PodcastPerson/Role/composer``
- ``PodcastPerson/Role/narrator``

The `.transcript(url:type:)` modifier accepts a ``Transcript/TranscriptType`` value (for example `.vtt`).

## Enclosure Factories

``Enclosure`` provides 15 static factory methods that create enclosures with the correct MIME type. Each factory returns an optional because it validates the URL string.

### Audio Factories

```swift
let mp3 = Enclosure.mp3(url: "https://cdn.example.com/ep.mp3", length: 10_000_000)
// type == "audio/mpeg"

let m4a = Enclosure.m4a(url: "https://cdn.example.com/ep.m4a", length: 8_000_000)
// type == "audio/m4a"

let aac = Enclosure.aac(url: "https://cdn.example.com/ep.aac", length: 7_000_000)
// type == "audio/aac"

let ogg = Enclosure.ogg(url: "https://cdn.example.com/ep.ogg", length: 6_000_000)
// type == "audio/ogg"

let opus = Enclosure.opus(url: "https://cdn.example.com/ep.opus", length: 5_000_000)
// type == "audio/opus"

let wav = Enclosure.wav(url: "https://cdn.example.com/ep.wav", length: 50_000_000)
// type == "audio/wav"

let flac = Enclosure.flac(url: "https://cdn.example.com/ep.flac", length: 30_000_000)
// type == "audio/flac"

let aiff = Enclosure.aiff(url: "https://cdn.example.com/ep.aiff", length: 40_000_000)
// type == "audio/aiff"

let webmAudio = Enclosure.webmAudio(url: "https://cdn.example.com/ep-audio.webm", length: 4_000_000)
// type == "audio/webm"
```

### Video Factories

```swift
let mp4 = Enclosure.mp4(url: "https://cdn.example.com/ep.mp4", length: 150_000_000)
// type == "video/mp4"

let mov = Enclosure.mov(url: "https://cdn.example.com/ep.mov", length: 200_000_000)
// type == "video/quicktime"

let m4v = Enclosure.m4v(url: "https://cdn.example.com/ep.m4v", length: 120_000_000)
// type == "video/m4v"

let webm = Enclosure.webm(url: "https://cdn.example.com/ep.webm", length: 100_000_000)
// type == "video/webm"
```

### HLS Factories

```swift
let hls = Enclosure.hls(url: "https://cdn.example.com/ep/master.m3u8", length: 0)
// type == "application/x-mpegURL"

let hlsAudio = Enclosure.hlsAudio(url: "https://cdn.example.com/ep/audio.m3u8", length: 0)
// type == "audio/mpegurl"
```

For additional formats not covered by factories, use the ``Enclosure/MIMEType`` enum with the standard initializer:

```swift
let enc = Enclosure(
    url: URL(string: "https://cdn.example.com/ep.mkv")!,
    length: 300_000_000,
    mimeType: .matroska
)
// type == "video/x-matroska"
```

``Enclosure/MIMEType`` covers 24 podcast and streaming formats: audio (`.mpeg`, `.m4a`, `.aac`, `.ogg`, `.opus`, `.wav`, `.flac`, `.aiff`, `.wma`, `.webmAudio`, `.matroskaAudio`, `.hlsAudioManifest`), video (`.mp4`, `.quicktime`, `.m4v`, `.webm`, `.threeGP`, `.threeGP2`, `.avi`, `.matroska`, `.wmv`, `.mpegTS`), streaming (`.hlsManifest`, `.hlsAudioManifest`), and document (`.pdf`).

The enum also provides classification properties: ``Enclosure/MIMEType/isVideo``, ``Enclosure/MIMEType/isAudio``, ``Enclosure/MIMEType/isHLS``, and ``Enclosure/MIMEType/isStreaming``.

## PSP-1 Compliance Helper

``PSP1Configuration`` groups every field required by the Podcast Standard Project v1 (PSP-1) specification into a single struct. Pass it to ``PodcastFeed/psp1Compliant(config:)`` to get a feed that is ready for PSP-1 validation with zero errors.

```swift
let config = PSP1Configuration(
    title: "PSP-1 Show",
    link: URL(string: "https://example.com")!,
    description: "A PSP-1 compliant podcast",
    feedURL: URL(string: "https://example.com/feed.xml")!,
    author: "Jane Doe",
    ownerName: "Jane Doe",
    ownerEmail: "jane@example.com",
    category: .technology,
    explicit: false,
    imageURL: URL(string: "https://cdn.example.com/art.jpg")!,
    podcastGUID: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
)

let feed = PodcastFeed.psp1Compliant(config: config)
```

The returned feed includes all seven standard namespaces, an `atom:link` with `rel="self"`, `podcast:locked` set to true with the owner email, and `podcast:guid`. The `language` parameter defaults to `"en"` but can be overridden.

The PSP-1 compliant feed also passes Apple Podcasts validation, making it a safe default for cross-platform distribution.

## Building a Complete Feed

Combining the result builder, channel modifiers, item modifiers, and enclosure factories produces a production-ready feed:

```swift
let feed = PodcastFeed {
    Channel(
        title: "The Swift Podcast",
        link: URL(string: "https://swiftpodcast.example.com")!,
        description: "Weekly conversations about Swift development"
    )
    .author("Jane Doe")
    .language("en-us")
    .copyright("(c) 2025 Swift Podcast")
    .category(.technology)
    .explicit(false)
    .image("https://cdn.example.com/artwork.jpg")
    .type("episodic")
    .owner(name: "Jane Doe", email: "jane@swiftpodcast.example.com")
    .locked(owner: "jane@swiftpodcast.example.com")
    .guid("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
    .funding(url: "https://patreon.com/swiftpodcast", text: "Support on Patreon")
    .atomLink(href: "https://swiftpodcast.example.com/feed.xml", rel: "self")
    .medium(.podcast)

    Item(
        title: "S1E1: Getting Started with Swift 6",
        enclosure: Enclosure.mp3(
            url: "https://cdn.example.com/s1e1.mp3",
            length: 45_000_000
        )
    )
    .description("Everything you need to know about Swift 6 concurrency.")
    .guid("s1e1-swift6", isPermaLink: false)
    .pubDate(Date())
    .duration(2700)
    .explicit(false)
    .season(1)
    .episode(1)
    .episodeType("full")
    .person("Jane Doe", role: .host)
    .person("Tim Guest", role: .guest)
    .transcript(url: "https://cdn.example.com/s1e1.vtt", type: .vtt)
    .chapters(url: "https://cdn.example.com/s1e1-chapters.json")
    .soundbite(start: 120.0, duration: 30.0, title: "The key insight")
    .contentEncoded("<p><strong>Episode notes</strong> with rich formatting.</p>")
}
```

## Topics

### Builder Types
- ``PodcastFeedBuilder``
- ``FeedComponent``

### Fluent Modifiers
- ``Channel``
- ``Item``

### Enclosure Helpers
- ``Enclosure``
- ``Enclosure/MIMEType``

### Person Roles
- ``PodcastPerson``
- ``PodcastPerson/Role``

### PSP-1 Compliance
- ``PSP1Configuration``
- ``PodcastFeed/psp1Compliant(config:)``

## See Also

- <doc:TemplatesAndPresets>
