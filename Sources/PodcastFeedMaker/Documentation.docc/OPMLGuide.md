# OPML Import & Export

Exchange podcast subscription lists using the OPML standard.

## Overview

OPML (Outline Processor Markup Language) is the universal format for sharing
podcast subscription lists between apps. PodcastFeedMaker provides a complete
OPML toolkit: parse, generate, validate, and convert between OPML and
``PodcastFeed`` models.

## Parsing an OPML File

Use ``OPMLParser`` to convert OPML XML into an ``OPMLDocument``.

```swift
let parser = OPMLParser()
let document = try parser.parse(opmlString)

print(document.title ?? "Untitled")
print("\(document.podcastFeeds.count) subscriptions")

for feed in document.podcastFeeds {
    print("- \(feed.text): \(feed.xmlUrl?.absoluteString ?? "")")
}
```

## Generating an OPML File

Use ``OPMLGenerator`` to convert an ``OPMLDocument`` back to XML.

```swift
let document = OPMLDocument(
    head: OPMLHead(title: "My Podcasts"),
    outlines: [
        OPMLOutline(
            text: "Accidental Tech Podcast",
            type: "rss",
            xmlUrl: URL(string: "https://atp.fm/episodes?format=rss")!,
            htmlUrl: URL(string: "https://atp.fm")!
        ),
        OPMLOutline(
            text: "The Talk Show",
            type: "rss",
            xmlUrl: URL(string: "https://daringfireball.net/thetalkshow/rss")!
        )
    ]
)

let generator = OPMLGenerator()
let xml = generator.generate(document)
```

## Converting Between Feeds and OPML

``OPMLFeedConverter`` provides bidirectional conversion between ``PodcastFeed``
models and ``OPMLOutline`` entries.

### Exporting Feeds as OPML

```swift
let feeds: [PodcastFeed] = [feed1, feed2, feed3]
let document = OPMLFeedConverter.document(
    from: feeds,
    title: "My Subscriptions",
    ownerName: "Jane Doe"
)
let xml = OPMLGenerator().generate(document)
```

### Creating Feed Stubs from OPML

```swift
let document = try OPMLParser().parse(opmlString)
let feedStubs = OPMLFeedConverter.feeds(from: document)

for stub in feedStubs {
    // Each stub has channel title, link, and atom:link self
    print(stub.channel?.title ?? "")
}
```

## Validating OPML Documents

``OPMLValidator`` checks documents against the OPML 2.0 specification
and podcast best practices.

```swift
let validator = OPMLValidator()
let report = validator.validate(document)

if report.isValid {
    print("Document is valid")
} else {
    for error in report.errors {
        print("ERROR: \(error.message)")
    }
}

for warning in report.warnings {
    print("WARNING: \(warning.message)")
}
```

### Validation Rules

| Check | Severity |
|-------|----------|
| Unknown OPML version | Warning |
| Missing head or title | Warning |
| RSS outline without xmlUrl | Error |
| xmlUrl without type attribute | Warning |
| HTTP feed URL (non-HTTPS) | Warning |
| Duplicate feed URLs | Warning |
| Empty outlines | Warning |
| Empty text attribute | Warning |

## Nested Categories

OPML supports hierarchical outlines for organizing feeds into categories.

```swift
let document = OPMLDocument(
    head: OPMLHead(title: "Organized Subscriptions"),
    outlines: [
        OPMLOutline(text: "Technology", children: [
            OPMLOutline(text: "ATP", type: "rss",
                xmlUrl: URL(string: "https://atp.fm/rss")!),
            OPMLOutline(text: "Connected", type: "rss",
                xmlUrl: URL(string: "https://relay.fm/connected/feed")!)
        ]),
        OPMLOutline(text: "News", children: [
            OPMLOutline(text: "The Daily", type: "rss",
                xmlUrl: URL(string: "https://feeds.simplecast.com/54nAGcIl")!)
        ])
    ]
)
```

## Custom Attributes

App-specific attributes (e.g., Overcast's `overcastId`) are preserved in
``OPMLOutline/customAttributes`` for round-trip fidelity.

```swift
let outline = OPMLOutline(
    text: "My Feed",
    type: "rss",
    xmlUrl: URL(string: "https://example.com/feed.xml")!,
    customAttributes: ["overcastId": "123456"]
)
```

## CLI Commands

The `podcastfeed` CLI includes two OPML commands:

```bash
# Export feeds to OPML
podcastfeed opml-export feed1.xml feed2.xml -o subscriptions.opml

# Import and inspect an OPML file
podcastfeed opml-import subscriptions.opml
podcastfeed opml-import subscriptions.opml -f json
podcastfeed opml-import subscriptions.opml --validate
```

## Topics

### Models

- ``OPMLDocument``
- ``OPMLHead``
- ``OPMLOutline``

### Parser & Generator

- ``OPMLParser``
- ``OPMLGenerator``
- ``OPMLParserError``

### Validation

- ``OPMLValidator``
- ``OPMLValidationReport``
- ``OPMLValidationIssue``
- ``OPMLValidationSeverity``

### Feed Conversion

- ``OPMLFeedConverter``
