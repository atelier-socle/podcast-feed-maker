# Round-Trip and Diff

Parse, modify, and regenerate podcast feeds with zero data loss.

## Overview

PodcastFeedMaker is designed for round-trip fidelity. Parse an existing feed, modify it
programmatically, and regenerate the XML -- with unknown elements, CDATA sections, XML comments,
and namespace prefixes all preserved. The ``FeedDiff`` engine lets you compare two feeds and
enumerate every change.

## Parse-Generate Cycle

The simplest round-trip parses XML into a ``PodcastFeed`` model, generates XML from that model,
then parses the generated XML and verifies the result matches the original:

```swift
let parser = FeedParser()
let generator = FeedGenerator(namespaceMode: .auto)

// Step 1: Parse original XML
let feed1 = try parser.parse(xmlString)

// Step 2: Generate XML from the parsed model
let generatedXML = try generator.generate(feed1)

// Step 3: Parse the generated XML
let feed2 = try parser.parse(generatedXML)

// Step 4: Compare — zero data loss
let channel1 = feed1.channel!
let channel2 = feed2.channel!
// channel1.title == channel2.title
// channel1.link == channel2.link
// channel1.description == channel2.description
// channel1.items.count == channel2.items.count
```

This works across all seven namespaces. RSS 2.0 core fields, iTunes tags, Podcast Namespace 2.0
properties, Atom links, Dublin Core metadata, Content Module encoded HTML, and Podlove Simple
Chapters all survive the round-trip intact:

```swift
let feed1 = try parser.parse(allNamespacesXML)
let xml = try generator.generate(feed1)
let feed2 = try parser.parse(xml)

let ch1 = feed1.channel!
let ch2 = feed2.channel!

// RSS 2.0 Core
// ch1.title == ch2.title
// ch1.language == ch2.language
// ch1.copyright == ch2.copyright

// iTunes
// ch1.itunesAuthor == ch2.itunesAuthor
// ch1.itunesCategories == ch2.itunesCategories
// ch1.itunesExplicit == ch2.itunesExplicit
// ch1.itunesImage == ch2.itunesImage
// ch1.itunesOwner == ch2.itunesOwner

// Atom
// ch1.atomLinks.count == ch2.atomLinks.count

// Dublin Core
// ch1.dublinCore?.creator == ch2.dublinCore?.creator

// Podcast NS 2.0
// ch1.podcastGuid == ch2.podcastGuid
// ch1.locked == ch2.locked
// ch1.medium == ch2.medium
// ch1.funding == ch2.funding
// ch1.persons == ch2.persons

// Per-item: Podlove chapters, content:encoded, transcripts, persons
let item1 = ch1.items.first!
let item2 = ch2.items.first!
// item1.podloveChapters == item2.podloveChapters
// item1.contentEncoded == item2.contentEncoded
// item1.transcripts == item2.transcripts
```

## Parse-Modify-Generate

Parse a feed, mutate it in place, then generate and re-parse to verify the modifications are
preserved alongside the original data.

### Modifying Channel Metadata

```swift
let parser = FeedParser()
let generator = FeedGenerator(namespaceMode: .auto)

var feed = try parser.parse(xmlString)

// Modify metadata
feed.channel?.title = "Renamed Show"
feed.channel?.language = "fr"
feed.channel?.itunesAuthor = "Jean Animateur"
feed.channel?.itunesExplicit = true

// Round-trip
let xml = try generator.generate(feed)
let reparsed = try parser.parse(xml)
let ch = reparsed.channel!
// ch.title == "Renamed Show"
// ch.language == "fr"
// ch.itunesAuthor == "Jean Animateur"
// ch.itunesExplicit == true

// Unchanged fields survived
// ch.copyright == "2026 Example Inc."
// ch.podcastGuid?.value == "917393e3-1b1e-5cef-ace4-edaa54e1f3e1"
// ch.locked?.isLocked == true
```

### Adding an Episode

```swift
var feed = try parser.parse(xmlString)

let newEpisode = Item(
    title: "New Episode",
    description: "A freshly added episode.",
    enclosure: Enclosure(
        url: URL(string: "https://example.com/new.mp3")!,
        length: 10_000_000,
        type: "audio/mpeg"
    ),
    guid: GUID(value: "new-ep-001", isPermaLink: false),
    itunesDuration: 900,
    itunesExplicit: false
)
feed.channel?.items.append(newEpisode)

let xml = try generator.generate(feed)
let reparsed = try parser.parse(xml)
let item = reparsed.channel!.items.first!
// item.title == "New Episode"
// item.guid?.value == "new-ep-001"
// item.guid?.isPermaLink == false
// item.itunesDuration == 900
// item.enclosure?.url.absoluteString == "https://example.com/new.mp3"
// item.enclosure?.length == 10_000_000
```

## What Gets Preserved

### Unknown Elements

Elements not modeled in the library are captured as ``UnknownElement`` and re-emitted during
generation. This ensures custom or future RSS extensions survive round-tripping:

```swift
// XML containing a custom <myrating> element in the channel
// and a custom <mysponsor> element in an item

let feed1 = try parser.parse(xmlWithCustomElements)
let ch1 = feed1.channel!

let channelUnknown = ch1.unknownElements.first { $0.name == "myrating" }
// channelUnknown?.textContent == "5 stars"

let item1 = ch1.items.first!
let itemUnknown = item1.unknownElements.first { $0.name == "mysponsor" }
// itemUnknown?.textContent == "ACME Corp"

// Generate and re-parse
let xml = try generator.generate(feed1)
let feed2 = try parser.parse(xml)
let ch2 = feed2.channel!

let roundTrippedChannel = ch2.unknownElements.first { $0.name == "myrating" }
// roundTrippedChannel?.textContent == "5 stars"

let item2 = ch2.items.first!
let roundTrippedItem = item2.unknownElements.first { $0.name == "mysponsor" }
// roundTrippedItem?.textContent == "ACME Corp"
```

### CDATA Sections

Fields wrapped in `<![CDATA[...]]>` are tracked in `cdataFields` and regenerated with CDATA
wrapping:

```swift
let feed1 = try parser.parse(xmlWithCDATA)
let ch1 = feed1.channel!
// ch1.cdataFields.contains("description") == true

let item1 = ch1.items.first!
// item1.cdataFields.contains("description") == true
// item1.contentEncoded?.value == "<h1>Full HTML</h1><p>Paragraph.</p>"

let xml = try generator.generate(feed1)
// xml.contains("CDATA") == true

let feed2 = try parser.parse(xml)
let item2 = feed2.channel!.items.first!
// item2.contentEncoded?.value == "<h1>Full HTML</h1><p>Paragraph.</p>"
```

### XML Comments

Comments in the feed are captured in `xmlComments` and preserved through generation:

```swift
let feed1 = try parser.parse(xmlWithComments)
let ch1 = feed1.channel!
// ch1.xmlComments is not empty — contains "Channel-level comment"

let item1 = ch1.items.first!
// item1.xmlComments is not empty — contains "Item-level comment"

let xml = try generator.generate(feed1)
// xml.contains("<!--") == true

let feed2 = try parser.parse(xml)
// feed2.channel!.xmlComments == ch1.xmlComments
// feed2.channel!.items.first!.xmlComments == item1.xmlComments
```

### Namespace Prefixes

Original namespace prefixes from parsed feeds are recorded in `namespacePrefixes` and used when
generating with `.parsed` namespace mode:

```swift
let parser = FeedParser()
let generator = FeedGenerator(namespaceMode: .parsed)

let feed = try parser.parse(xmlWithPrefixes)
// feed.namespacePrefixes is not empty

let xml = try generator.generate(feed)
// xml.contains("xmlns:itunes=") == true
// xml.contains("xmlns:podcast=") == true

let reparsed = try parser.parse(xml)
// reparsed.channel?.itunesExplicit == false
// reparsed.channel?.locked?.isLocked == true
```

## JSON Round-Trip

``PodcastFeed`` conforms to `Codable`, so you can serialize to JSON and back without data loss.
This is useful for storing feeds in databases, transmitting over APIs, or bridging to
non-XML systems:

```swift
let parser = FeedParser()
let generator = FeedGenerator(namespaceMode: .auto)

// Parse XML to model
let feed1 = try parser.parse(xmlString)

// Encode to JSON
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let jsonData = try encoder.encode(feed1)

// Decode from JSON
let decoder = JSONDecoder()
let feed2 = try decoder.decode(PodcastFeed.self, from: jsonData)

// Verify model equality
// feed1.version == feed2.version
// feed1.channel?.title == feed2.channel?.title
// feed1.channel?.itunesAuthor == feed2.channel?.itunesAuthor
// feed1.channel?.podcastGuid == feed2.channel?.podcastGuid
// feed1.channel?.items.count == feed2.channel?.items.count

// Generate XML from the JSON-decoded model and parse again
let xml2 = try generator.generate(feed2)
let feed3 = try parser.parse(xml2)
// feed3.channel?.title == feed1.channel?.title
// feed3.channel?.items.first?.podloveChapters == feed1.channel?.items.first?.podloveChapters
```

## Feed Diff

``FeedDiff`` compares two ``PodcastFeed`` instances and returns an array of ``FeedDifference``
entries. Each difference reports its ``FeedDifference/ChangeType`` (`.added`, `.removed`, or
`.modified`), the dot-path to the affected field, and the old and new values.

### Detecting Channel Changes

```swift
let parser = FeedParser()

let feed1 = try parser.parse(xmlString)
var feed2 = feed1
feed2.channel?.title = "Changed Title"
feed2.channel?.language = "de"

let diff = FeedDiff()
let differences = diff.diff(feed1, feed2)

let titleChange = differences.first { $0.field == "channel.title" }
// titleChange?.changeType == .modified
// titleChange?.oldValue == "Full Namespace Show"
// titleChange?.newValue == "Changed Title"

let langChange = differences.first { $0.field == "channel.language" }
// langChange?.changeType == .modified
// langChange?.oldValue == "en"
// langChange?.newValue == "de"
```

### Detecting Episode Changes

The diff engine matches episodes by GUID (or by title as fallback) and reports added, removed,
and modified items:

```swift
var feed2 = feed1
feed2.channel?.items[0].title = "Episode 1 — Updated"

let newItem = Item(
    title: "Episode 2 — Brand New",
    enclosure: Enclosure(
        url: URL(string: "https://example.com/ep2.mp3")!,
        length: 30_000_000,
        type: "audio/mpeg"
    ),
    guid: GUID(value: "ep-002", isPermaLink: false)
)
feed2.channel?.items.append(newItem)

let diff = FeedDiff()
let differences = diff.diff(feed1, feed2)

// Detects title modification on existing episode
let titleMod = differences.first {
    $0.field.contains("ep-001") && $0.field.contains("title")
}
// titleMod?.changeType == .modified

// Detects the newly added episode
let addedEp = differences.first {
    $0.changeType == .added && $0.field.contains("Episode 2")
}
// addedEp is not nil
```

### Identical Feeds

When two feeds are structurally identical, the diff returns an empty array:

```swift
let diff = FeedDiff()
let differences = diff.diff(feed, feed)
// differences.isEmpty == true
```

## XML String Diff

``FeedDiff`` can also compare two XML strings directly, parsing both before diffing:

```swift
let xml1 = originalXML
let xml2 = originalXML.replacingOccurrences(
    of: "Minimal Show", with: "Updated Show"
)

let diff = FeedDiff()
let differences = try diff.diff(xml: xml1, xml: xml2)

let titleChange = differences.first { $0.field == "channel.title" }
// titleChange?.changeType == .modified
// titleChange?.oldValue == "Minimal Show"
// titleChange?.newValue == "Updated Show"
```

## Streaming Generator Round-Trip

The ``StreamingFeedGenerator`` (available via ``PodcastFeedEngine``) produces XML in discrete
chunks. The assembled output parses back correctly, just like synchronous generation:

```swift
let parser = FeedParser()
let feed = try parser.parse(xmlString)

let engine = PodcastFeedEngine()
let stream = engine.generateStream(feed)

var chunks: [String] = []
for try await chunk in stream {
    chunks.append(chunk)
}
// chunks.count >= 3 (header, item(s), footer)

let streamedXML = chunks.joined()
let reparsed = try parser.parse(streamedXML)
// reparsed.channel?.title == feed.channel?.title
// reparsed.channel?.items.count == feed.channel?.items.count
```

## Next Steps

- <doc:GeneratingFeeds>
- <doc:ParsingFeeds>
- <doc:ChaptersGuide>
