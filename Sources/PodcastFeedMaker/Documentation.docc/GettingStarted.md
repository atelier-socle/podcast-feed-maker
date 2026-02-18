# Getting Started with PodcastFeedMaker

Learn how to add PodcastFeedMaker to your project and create your first podcast feed.

## Overview

PodcastFeedMaker is a bi-directional Swift library for generating, parsing, and validating podcast RSS feeds. It covers RSS 2.0, iTunes, Podcast Namespace 2.0, Atom, Dublin Core, Content, and Podlove Simple Chapters with zero third-party dependencies. It supports 24 MIME types across audio, video, HLS streaming, and document formats. You can build feeds from Swift structs, parse existing XML into the same model, validate against five major podcast platforms, and round-trip feeds with zero data loss.

## Adding the Dependency

Add PodcastFeedMaker to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/atelier-socle/podcast-feed-maker.git", from: "0.1.0")
]
```

And add it to your target:

```swift
.target(
    name: "MyApp",
    dependencies: ["PodcastFeedMaker"]
)
```

Then import the module in your Swift files:

```swift
import PodcastFeedMaker
```

## Creating Your First Feed

Build a podcast feed by creating a ``Channel`` with its required fields (title, link, description) and one or more ``Item`` instances. Use the ``PodcastFeed`` result builder DSL for a concise, declarative syntax:

```swift
let feed = PodcastFeed {
    Channel(
        title: "My Podcast",
        link: URL(string: "https://example.com")!,
        description: "A show about Swift development"
    )
    .author("Jane Host")
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
            length: 52_000_000
        )
    )
    .guid("ep-002", isPermaLink: false)
    .duration(2400)
}
```

The result builder collects the ``Channel`` and all ``Item`` components, merging items into the channel automatically. Each fluent modifier (`.author(_:)`, `.explicit(_:)`, `.category(_:)`, `.duration(_:)`) returns a modified copy, keeping the API chainable and the model immutable at the call site.

You can also construct the model manually when you need full control over every field:

```swift
let episode = Item(
    title: "Episode 1: Getting Started",
    description: "The very first episode.",
    enclosure: Enclosure(
        url: URL(string: "https://cdn.example.com/ep1.mp3")!,
        length: 48_000_000,
        type: "audio/mpeg"
    ),
    guid: GUID(value: "ep-001", isPermaLink: false),
    itunesDuration: 1800,
    itunesEpisodeType: .full,
    itunesExplicit: false
)

let channel = Channel(
    title: "The Showcase Podcast",
    link: URL(string: "https://example.com")!,
    description: "A podcast demonstrating PodcastFeedMaker.",
    language: "en-US",
    items: [episode],
    itunesAuthor: "Atelier Socle",
    itunesCategories: [.technology],
    itunesExplicit: false,
    itunesImage: URL(string: "https://cdn.example.com/artwork.jpg"),
    itunesOwner: ITunesOwner(name: "Wlad", email: "wlad@example.com"),
    itunesType: .episodic,
    atomLinks: [
        AtomLink.selfLink(href: URL(string: "https://example.com/feed.xml")!)
    ],
    podcastGuid: PodcastGuid(value: "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"),
    locked: Locked(isLocked: true, owner: "wlad@example.com")
)

let feed = PodcastFeed(
    version: "2.0",
    namespaces: PodcastNamespace.allStandard,
    channel: channel
)
```

## Generating XML

Use ``FeedGenerator`` to convert a ``PodcastFeed`` model into an RSS XML string:

```swift
let generator = FeedGenerator()
let xml = try generator.generate(feed)
// xml contains a complete RSS 2.0 document with all namespace declarations
```

By default the generator includes an XML declaration, uses UTF-8 encoding, pretty-prints with tab indentation, and automatically detects which namespaces to declare based on feed content. You can customize all of these options:

```swift
let generator = FeedGenerator(
    prettyPrint: false,
    includeXMLDeclaration: true,
    encoding: "UTF-8",
    namespaceMode: .auto
)
let minifiedXML = try generator.generate(feed)
```

## Parsing an Existing Feed

Use ``FeedParser`` to parse an XML string or `Data` into a ``PodcastFeed`` model:

```swift
let parser = FeedParser()
let feed = try parser.parse(xmlString)

let channel = feed.channel!
print(channel.title)           // "My Podcast"
print(channel.items.count)     // 2
print(channel.itunesAuthor)    // "Jane Host"
```

You can also parse from raw `Data`:

```swift
let data = xmlString.data(using: .utf8)!
let feed = try parser.parse(data: data)
```

The parser handles all seven supported namespaces, extracts every modeled attribute, and preserves unknown elements, XML comments, CDATA field tracking, and namespace prefixes for full round-trip fidelity.

## Validating Against Apple Podcasts

Use ``FeedValidator`` to check a feed against platform-specific requirements. Each platform has its own rules for required fields, URL schemes, artwork dimensions, and format support:

```swift
let validator = FeedValidator()
let report = validator.validate(feed, for: .apple)

if report.isValid {
    print("Feed passes Apple Podcasts validation")
} else {
    for error in report.errors {
        print("ERROR [\(error.field)]: \(error.message)")
    }
    for warning in report.warnings {
        print("WARNING [\(warning.field)]: \(warning.message)")
    }
}
```

Five platforms are supported via the ``ValidationPlatform`` enum: `.apple`, `.spotify`, `.amazon`, `.podcastIndex`, and `.psp1`.

## Using the High-Level Engine

``PodcastFeedEngine`` is a facade that combines generation, parsing, validation, normalization, equivalence checking, and diffing into a single entry point:

```swift
let engine = PodcastFeedEngine()

// Generate
let xml = try engine.generate(feed)
let minified = try engine.generate(feed, prettyPrint: false)

// Parse
let parsed = try engine.parse(xml)
let fromData = try engine.parse(data: Data(xml.utf8))

// Validate against one platform
let report = engine.validate(parsed, for: .apple)

// Validate against all platforms at once
let reports = engine.validateAll(parsed)
for r in reports {
    print("\(r.platform): \(r.isValid ? "PASS" : "FAIL")")
}

// Normalize messy XML into consistently formatted output
let normalized = try engine.normalize(xml)

// Check if two XML strings represent equivalent feeds
let equivalent = try engine.isEquivalent(xml, minified)
// true — formatting differences do not affect equivalence

// Stream generation for large catalogs
let stream = engine.generateStream(feed)
for try await chunk in stream {
    // Process each chunk (header, per-item, footer)
}
```

## Next Steps

- <doc:GeneratingFeeds>
- <doc:ParsingFeeds>
- <doc:ValidatingFeeds>
- <doc:BuilderDSL>
- <doc:TemplatesAndPresets>
- <doc:ChaptersGuide>
- <doc:RoundTripAndDiff>
- <doc:CLIReference>
