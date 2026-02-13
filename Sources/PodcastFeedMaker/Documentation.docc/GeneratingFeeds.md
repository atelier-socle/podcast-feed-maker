# Generating Feeds

Convert your podcast model to standards-compliant RSS XML.

## Overview

PodcastFeedMaker provides two generators for converting a ``PodcastFeed`` model into RSS XML. ``FeedGenerator`` produces the complete XML as a single `String`, suitable for most use cases. ``StreamingFeedGenerator`` yields XML in chunks via an `AsyncThrowingStream`, designed for large catalogs where you want to write output incrementally without holding the entire document in memory.

Both generators support pretty-printing, XML declaration control, encoding selection, namespace mode configuration, CDATA wrapping, and proper XML escaping.

## Synchronous Generation

Create a ``FeedGenerator`` instance and call its `generate(_:)` method with a ``PodcastFeed``:

```swift
let channel = Channel(
    title: "My Podcast",
    link: URL(string: "https://example.com")!,
    description: "A podcast about Swift."
)
let feed = PodcastFeed(version: "2.0", namespaces: [], channel: channel)

let generator = FeedGenerator()
let xml = try generator.generate(feed)
```

The returned string is a complete RSS 2.0 document starting with `<?xml version="1.0" encoding="UTF-8"?>` and ending with `</rss>`. All namespace declarations appear as attributes on the `<rss>` element, and the channel and item elements follow the RSS 2.0 structure.

## Pretty-Print vs Minified

Control output formatting with the `prettyPrint` parameter. Pretty-print uses tab indentation and newlines for human readability. Minified output omits all unnecessary whitespace for smaller payloads.

```swift
// Pretty-printed (default) — tabs and newlines
let prettyGenerator = FeedGenerator(prettyPrint: true)
let prettyXML = try prettyGenerator.generate(feed)
// Contains "\t<channel>" and "\t\t<title>My Podcast</title>"

// Minified — no tabs, no newlines
let minifiedGenerator = FeedGenerator(prettyPrint: false)
let minifiedXML = try minifiedGenerator.generate(feed)
// Contains "<channel><title>My Podcast</title>" on a single line
```

## XML Declaration

Control whether the XML declaration appears at the top of the output, and which encoding it advertises:

```swift
// Include declaration with UTF-8 (default behavior)
let gen1 = FeedGenerator(includeXMLDeclaration: true, encoding: "UTF-8")
let xml1 = try gen1.generate(feed)
// Starts with: <?xml version="1.0" encoding="UTF-8"?>

// Omit declaration entirely
let gen2 = FeedGenerator(includeXMLDeclaration: false)
let xml2 = try gen2.generate(feed)
// Starts directly with: <rss version="2.0" ...>

// Custom encoding
let gen3 = FeedGenerator(encoding: "ISO-8859-1")
let xml3 = try gen3.generate(feed)
// Contains: encoding="ISO-8859-1"
```

## Namespace Modes

The generator supports four namespace modes via ``FeedGenerator/NamespaceMode``, controlling which XML namespace declarations appear on the `<rss>` element.

| Mode | Description |
|------|-------------|
| `.auto` | Detects namespaces from feed content — only declares namespaces for tags actually used |
| `.feedDefined` | Uses namespaces from `PodcastFeed.namespaces` as-is |
| `.explicit([...])` | Overrides with a specific namespace list you provide |
| `.parsed` | Preserves original prefixes from parsed feeds (uses `PodcastFeed.namespacePrefixes`) |

### Auto mode

Auto mode inspects channel and item properties to determine which namespaces are needed. If your feed only uses `itunesAuthor`, only the iTunes namespace is declared:

```swift
let channel = Channel(
    title: "iTunes Only Show",
    link: URL(string: "https://example.com")!,
    description: "Only iTunes tags.",
    itunesAuthor: "Host",
    itunesExplicit: false,
    itunesImage: URL(string: "https://cdn.example.com/artwork.jpg")
)
let feed = PodcastFeed(
    version: "2.0",
    namespaces: PodcastNamespace.allStandard,
    channel: channel
)

let generator = FeedGenerator(namespaceMode: .auto)
let xml = try generator.generate(feed)
// Declares xmlns:itunes but NOT xmlns:podcast, xmlns:dc, etc.
```

### Feed-defined mode

Uses exactly the namespaces stored in the feed's `namespaces` array, regardless of content:

```swift
let feed = PodcastFeed(version: "2.0", namespaces: [.itunes, .atom], channel: channel)
let generator = FeedGenerator(namespaceMode: .feedDefined)
let xml = try generator.generate(feed)
// Declares xmlns:itunes and xmlns:atom only
```

### Explicit mode

Overrides with a specific list you provide:

```swift
let generator = FeedGenerator(namespaceMode: .explicit([.podcast, .dublinCore]))
let xml = try generator.generate(feed)
// Declares xmlns:podcast and xmlns:dc, regardless of feed.namespaces or content
```

### Parsed mode

Preserves custom prefixes captured during parsing. This is useful for round-trip scenarios where you want the regenerated XML to use the same prefix names as the original:

```swift
var feed = PodcastFeed(version: "2.0", namespaces: [.itunes], channel: channel)
feed.namespacePrefixes = [
    "apple": "http://www.itunes.com/dtds/podcast-1.0.dtd",
    "ns2": "https://podcastindex.org/namespace/1.0"
]

let generator = FeedGenerator(namespaceMode: .parsed)
let xml = try generator.generate(feed)
// Uses xmlns:apple="..." and xmlns:ns2="..." instead of the standard prefixes
```

## CDATA Wrapping

The generator automatically wraps `content:encoded` values in CDATA sections to preserve embedded HTML:

```swift
let item = Item(
    title: "HTML Episode",
    enclosure: Enclosure(
        url: URL(string: "https://cdn.example.com/episodes/html-ep.mp3")!,
        length: 36_000_000,
        type: "audio/mpeg"
    ),
    contentEncoded: ContentEncoded(value: "<p>Rich <em>notes</em>.</p>")
)
let channel = Channel(
    title: "My Podcast",
    link: URL(string: "https://example.com")!,
    description: "A podcast about Swift.",
    items: [item]
)
let feed = PodcastFeed(version: "2.0", namespaces: [.content], channel: channel)
let xml = try FeedGenerator().generate(feed)
// Produces: <content:encoded><![CDATA[<p>Rich <em>notes</em>.</p>]]></content:encoded>
```

For other fields like `description`, CDATA wrapping is controlled by the `cdataFields` set on each ``Item`` or ``Channel``. The parser populates this set automatically when it encounters CDATA in the source XML, enabling round-trip preservation:

```swift
let item = Item(
    title: "CDATA Description",
    description: "<b>Bold</b> text",
    enclosure: Enclosure(
        url: URL(string: "https://cdn.example.com/episodes/cdata-ep.mp3")!,
        length: 42_000_000,
        type: "audio/mpeg"
    ),
    cdataFields: ["description"]
)
// Generates: <description><![CDATA[<b>Bold</b> text]]></description>
```

## XML Escaping

``XMLBuilder`` handles XML escaping for all text content and attribute values. The five standard XML entities (`&`, `<`, `>`, `"`, `'`) are escaped. Special Unicode characters like copyright, trademark, and smart quotes are converted to numeric character references or their XML entity equivalents:

```swift
let channel = Channel(
    title: "Rock & Roll <Live> \"Special\" Edition",
    link: URL(string: "https://example.com")!,
    description: "A show about R&B music."
)
let xml = try FeedGenerator().generate(
    PodcastFeed(version: "2.0", namespaces: [], channel: channel)
)
// Title becomes: Rock &amp; Roll &lt;Live&gt; &quot;Special&quot; Edition
// Description becomes: A show about R&amp;B music.
```

The escaper is smart about existing entities: it will not double-escape `&amp;`, `&lt;`, `&#xA9;`, or other numeric character references that are already properly encoded.

## Streaming Generation

For feeds with hundreds of episodes, ``StreamingFeedGenerator`` yields XML in discrete chunks via an `AsyncThrowingStream<String, Error>`. The stream produces N+2 chunks: one header (XML declaration, `<rss>`, and channel metadata), one chunk per item, and one footer (`</channel></rss>`).

```swift
let streaming = StreamingFeedGenerator()
var assembled = ""
for try await chunk in streaming.generate(feed) {
    assembled += chunk
    // Or write each chunk directly to a file/socket
}
```

The streaming generator accepts the same configuration as ``FeedGenerator``:

```swift
let streaming = StreamingFeedGenerator(
    prettyPrint: false,
    includeXMLDeclaration: false,
    encoding: "ISO-8859-1",
    namespaceMode: .auto
)
```

The assembled output from a streaming generator is identical to what ``FeedGenerator`` would produce, and can be parsed back by ``FeedParser``:

```swift
let streaming = StreamingFeedGenerator()
var fullXML = ""
for try await chunk in streaming.generate(feed) {
    fullXML += chunk
}

let parser = FeedParser()
let parsed = try parser.parse(fullXML)
// parsed.channel?.title == feed.channel?.title
```

## Generator Errors

``GeneratorError`` covers the failure cases you may encounter:

| Case | Description |
|------|-------------|
| `.missingChannel` | The ``PodcastFeed`` has a `nil` channel |
| `.invalidURL(String, String)` | A URL field contains an invalid value (includes the field name and offending string) |
| `.encodingError(String)` | An encoding-related issue occurred (includes a descriptive message) |

All cases conform to `LocalizedError` with human-readable `errorDescription` values, and the enum conforms to `Equatable` for straightforward error assertions.

```swift
let emptyFeed = PodcastFeed(version: "2.0", namespaces: [], channel: nil)
do {
    try FeedGenerator().generate(emptyFeed)
} catch GeneratorError.missingChannel {
    // Handle missing channel
}
```

## Next Steps

- <doc:ParsingFeeds>
- <doc:ValidatingFeeds>
- <doc:RoundTripAndDiff>
