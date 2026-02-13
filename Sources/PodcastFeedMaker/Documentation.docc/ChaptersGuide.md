# Chapters Guide

Add chapter markers to podcast episodes using JSON Chapters or Podlove Simple Chapters.

## Overview

Podcast chapters let listeners navigate to specific sections of an episode. PodcastFeedMaker
supports two chapter systems: Podcast Namespace JSON Chapters (linked externally via
``ChaptersLink``) and Podlove Simple Chapters (inline in the RSS feed via ``PodloveChapters``).
Both are fully modeled, generated, parsed, and round-tripped.

## JSON Chapters

### Structure

``JSONChapterList`` contains metadata about the episode and an array of ``JSONChapter`` entries.
Each chapter has a start time in seconds and optional fields for title, end time, URL, artwork,
table-of-contents inclusion, and location:

```swift
let list = JSONChapterList(
    version: "1.2.0",
    title: "Episode 42: The Answer",
    author: "Wlad",
    podcastName: "Swift Talk",
    chapters: [
        JSONChapter(startTime: 0.0, title: "Intro", endTime: 30.0),
        JSONChapter(
            startTime: 30.0,
            title: "Main Topic",
            endTime: 2700.0,
            url: URL(string: "https://example.com/topic")!,
            img: URL(string: "https://example.com/chapter1.jpg")!,
            toc: true,
            location: PodcastLocation(name: "San Francisco", country: "US")
        ),
        JSONChapter(startTime: 2700.0, title: "Ad Break", toc: false),
        JSONChapter(startTime: 2760.0, title: "Wrap-up")
    ]
)

// list.version == "1.2.0"
// list.title == "Episode 42: The Answer"
// list.author == "Wlad"
// list.podcastName == "Swift Talk"
// list.chapters.count == 4
// list.chapters[1].url == URL(string: "https://example.com/topic")!
// list.chapters[1].location?.name == "San Francisco"
// list.chapters[2].toc == false
```

A default-initialized ``JSONChapterList`` uses version `"1.2.0"` with no metadata and an empty
chapters array:

```swift
let empty = JSONChapterList()
// empty.version == "1.2.0"
// empty.title == nil
// empty.author == nil
// empty.podcastName == nil
// empty.chapters.isEmpty == true
```

A ``JSONChapter`` only requires `startTime`. All other fields are optional:

```swift
let minimal = JSONChapter(startTime: 120.5)
// minimal.startTime == 120.5
// minimal.title == nil
// minimal.endTime == nil
// minimal.url == nil
// minimal.img == nil
// minimal.toc == nil
// minimal.location == nil
```

### Chapter Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `startTime` | `Double` | Yes | Start time in seconds |
| `title` | `String?` | No | Chapter title |
| `endTime` | `Double?` | No | End time in seconds |
| `url` | `URL?` | No | Link for the chapter |
| `img` | `URL?` | No | Chapter artwork |
| `toc` | `Bool?` | No | Include in table of contents |
| `location` | ``PodcastLocation``? | No | Location metadata |

### Encoding and Decoding

``JSONChapterList`` conforms to `Codable`, so you can round-trip through JSON:

```swift
let original = JSONChapterList(
    version: "1.2.0",
    title: "Codable Test",
    author: "Tester",
    podcastName: "Test Pod",
    chapters: [
        JSONChapter(startTime: 0.0, title: "Start"),
        JSONChapter(startTime: 300.0, title: "Middle", toc: true),
        JSONChapter(startTime: 600.0, title: "End")
    ]
)

let encoder = JSONEncoder()
encoder.outputFormatting = .sortedKeys
let data = try encoder.encode(original)

let decoder = JSONDecoder()
let decoded = try decoder.decode(JSONChapterList.self, from: data)
// decoded == original
// decoded.version == "1.2.0"
// decoded.title == "Codable Test"
// decoded.chapters.count == 3
// decoded.chapters[1].toc == true
```

### Linking in the Feed

To reference an external JSON chapters file from an episode, set the ``Item/chaptersLink``
property with a ``ChaptersLink``. The default MIME type is `"application/json+chapters"`:

```swift
let chaptersURL = URL(string: "https://example.com/ep1/chapters.json")!

// Default type
let link = ChaptersLink(url: chaptersURL)
// link.type == "application/json+chapters"

// Explicit type override
let customLink = ChaptersLink(url: chaptersURL, type: "application/json")
// customLink.type == "application/json"
```

Set it on an ``Item``:

```swift
let episode = Item(
    title: "Episode with JSON Chapters",
    enclosure: Enclosure(
        url: URL(string: "https://example.com/ep1.mp3")!,
        length: 50_000_000,
        type: "audio/mpeg"
    ),
    chaptersLink: ChaptersLink(
        url: URL(string: "https://example.com/ep1/chapters.json")!
    )
)
```

This generates the `<podcast:chapters>` element in the RSS feed:

```xml
<podcast:chapters url="https://example.com/ep1/chapters.json"
                  type="application/json+chapters" />
```

## Podlove Simple Chapters

### Structure

``PodloveChapters`` wraps an array of ``PodloveChapter`` entries with a version string. Each
chapter has a start time in Normal Play Time format and a title, with optional href and image:

```swift
let chapters = PodloveChapters(
    version: "1.2",
    chapters: [
        PodloveChapter(start: "00:00:00.000", title: "Intro"),
        PodloveChapter(
            start: "00:05:30.000",
            title: "Main Topic",
            href: URL(string: "https://example.com/topic")!,
            image: URL(string: "https://example.com/chapter-img.jpg")!
        ),
        PodloveChapter(start: "00:45:00.000", title: "Wrap-up and Outro")
    ]
)

// chapters.version == "1.2"
// chapters.chapters.count == 3
// chapters.chapters[0].start == "00:00:00.000"
// chapters.chapters[0].title == "Intro"
// chapters.chapters[0].href == nil
// chapters.chapters[0].image == nil
// chapters.chapters[1].href == URL(string: "https://example.com/topic")!
// chapters.chapters[1].image == URL(string: "https://example.com/chapter-img.jpg")!
```

A default-initialized ``PodloveChapters`` uses version `"1.2"` with an empty array:

```swift
let empty = PodloveChapters()
// empty.version == "1.2"
// empty.chapters.isEmpty == true
```

A ``PodloveChapter`` requires `start` and `title`. The `href` and `image` properties are optional:

```swift
let chapter = PodloveChapter(
    start: "01:23:45.678",
    title: "Swift Evolution Deep Dive",
    href: URL(string: "https://swift.org")!,
    image: URL(string: "https://example.com/swift-logo.png")!
)

// chapter.start == "01:23:45.678"
// chapter.title == "Swift Evolution Deep Dive"
// chapter.href == URL(string: "https://swift.org")!
// chapter.image == URL(string: "https://example.com/swift-logo.png")!
```

### Time Formats

Podlove uses Normal Play Time (NPT) format:

| Format | Example | Meaning |
|--------|---------|---------|
| `HH:MM:SS.mmm` | `00:02:30.500` | 2 minutes, 30.5 seconds |
| `HH:MM:SS` | `01:23:45` | 1 hour, 23 minutes, 45 seconds |
| `MM:SS` | `5:30` | 5 minutes, 30 seconds |

### Inline in the Feed

Set the ``Item/podloveChapters`` property to embed chapters directly in the RSS feed:

```swift
let episode = Item(
    title: "Episode with Podlove Chapters",
    enclosure: Enclosure(
        url: URL(string: "https://example.com/ep1.mp3")!,
        length: 50_000_000,
        type: "audio/mpeg"
    ),
    podloveChapters: PodloveChapters(
        version: "1.2",
        chapters: [
            PodloveChapter(start: "00:00:00.000", title: "Intro"),
            PodloveChapter(start: "00:05:30.000", title: "Main Topic"),
            PodloveChapter(start: "00:25:00.000", title: "Outro")
        ]
    )
)
```

This generates inline `<psc:chapters>` XML:

```xml
<psc:chapters version="1.2">
    <psc:chapter start="00:00:00.000" title="Intro"/>
    <psc:chapter start="00:05:30.000" title="Main Topic"/>
    <psc:chapter start="00:25:00.000" title="Outro"/>
</psc:chapters>
```

Podlove chapters survive the full round-trip. When parsed and regenerated, the chapter count,
start times, titles, links, and images are all preserved exactly.

## Using Both Systems

An episode can use both chapter systems simultaneously. ``ChaptersLink`` references an external
JSON file for rich chapter data (images, locations, URLs), while ``PodloveChapters`` provides
inline chapter markers for players that support the Podlove format:

```swift
let episode = Item(
    title: "Episode with Both Chapter Types",
    enclosure: Enclosure(
        url: URL(string: "https://example.com/ep1.mp3")!,
        length: 50_000_000,
        type: "audio/mpeg"
    ),
    chaptersLink: ChaptersLink(
        url: URL(string: "https://example.com/ep1/chapters.json")!
    ),
    podloveChapters: PodloveChapters(
        version: "1.2",
        chapters: [
            PodloveChapter(start: "00:00:00.000", title: "Intro"),
            PodloveChapter(start: "00:10:00.000", title: "Discussion")
        ]
    )
)
```

## Next Steps

- <doc:GeneratingFeeds>
- <doc:ParsingFeeds>
- <doc:BuilderDSL>
