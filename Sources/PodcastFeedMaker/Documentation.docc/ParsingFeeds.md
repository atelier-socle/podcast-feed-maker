# Parsing Feeds

Parse podcast RSS XML into strongly-typed Swift models.

## Overview

``FeedParser`` converts RSS 2.0 XML into a fully typed ``PodcastFeed`` model, covering
all seven namespaces (RSS 2.0, iTunes, Podcast Namespace 2.0, Atom, Dublin Core, Content
Module, and Podlove Simple Chapters). The parser uses a best-effort strategy, collecting
non-fatal warnings instead of failing on the first issue, so you always get as much data
as the XML contains.

## Parsing from a String

Pass an XML string directly to ``FeedParser/parse(_:)``. The returned ``PodcastFeed``
gives you typed access to every channel and item property.

```swift
let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
        <channel>
            <title>Minimal Podcast</title>
            <link>https://example.com</link>
            <description>A minimal test feed.</description>
        </channel>
    </rss>
    """

let parser = FeedParser()
let feed = try parser.parse(xml)

let channel = feed.channel!
print(channel.title)       // "Minimal Podcast"
print(channel.link)        // https://example.com
print(channel.description) // "A minimal test feed."
```

## Parsing from Data

When you already have raw bytes (for example, from a network response), use
``FeedParser/parse(data:)`` to skip the string conversion step.

```swift
let data = xml.data(using: .utf8)!
let parser = FeedParser()
let feed = try parser.parse(data: data)

print(feed.channel?.title) // "Minimal Podcast"
```

## Parsing with Diagnostics

Use ``FeedParser/parseWithDiagnostics(_:)`` to get both the parsed feed and any
non-fatal warnings the parser encountered. The method returns a ``FeedParser/ParseResult``
containing the ``PodcastFeed`` and an array of warning strings.

```swift
let parser = FeedParser()
let result = try parser.parseWithDiagnostics(xml)

let channel = result.feed.channel!
print(channel.title)         // "Minimal Podcast"
print(result.warnings.count) // 0 for a well-formed feed
```

The `Data` variant works the same way:

```swift
let data = xml.data(using: .utf8)!
let result = try parser.parseWithDiagnostics(data: data)
print(result.feed.channel?.title) // "Minimal Podcast"
```

## Date Parsing

``DateParser`` automatically handles multiple date formats found in real-world podcast
feeds. All parsing goes through the static ``DateParser/parse(_:)`` method, which returns
an optional `Date`.

| Format | Example |
|--------|---------|
| RFC 2822 | `Mon, 10 Feb 2025 12:00:00 +0000` |
| RFC 2822 (no day) | `10 Feb 2025 12:00:00 +0000` |
| RFC 2822 (timezone) | `Mon, 10 Feb 2025 04:00:00 PST` |
| RFC 2822 (negative offset) | `Tue, 11 Mar 2025 09:30:00 -0500` |
| RFC 2822 (two-digit year) | `10 Feb 25 12:00:00 GMT` |
| ISO 8601 | `2025-02-10T12:00:00Z` |
| ISO 8601 (offset) | `2025-02-10T14:00:00+02:00` |
| ISO 8601 (date only) | `2025-02-10` |
| ISO 8601 (milliseconds) | `2025-02-10T12:00:00.123Z` |
| Long month | `February 12, 2026` |
| Slash format | `2026/02/12` |
| Day month year | `12 Feb 2026` |

```swift
let date = DateParser.parse("Mon, 10 Feb 2025 12:00:00 +0000")
// date is a valid Date representing 2025-02-10 12:00 UTC

DateParser.parse("")           // nil
DateParser.parse("not a date") // nil
```

Date formatting and parsing round-trip cleanly. ``XMLBuilder/rfc2822Date(_:)`` produces
a string that ``DateParser/parse(_:)`` can read back:

```swift
let original = Date(timeIntervalSince1970: 1_739_404_800)
let formatted = XMLBuilder.rfc2822Date(original)
let parsed = DateParser.parse(formatted)
// parsed matches original within 1-second tolerance
```

## iTunes Value Parsing

The parser normalizes common iTunes value variations into their Swift equivalents.

**`itunes:explicit`** maps `"true"` and `"yes"` to `true`, and `"false"`, `"no"`, and
`"clean"` to `false`:

```swift
// <itunes:explicit>yes</itunes:explicit>  → itunesExplicit == true
// <itunes:explicit>true</itunes:explicit> → itunesExplicit == true
// <itunes:explicit>no</itunes:explicit>   → itunesExplicit == false
// <itunes:explicit>false</itunes:explicit>→ itunesExplicit == false
```

**`itunes:duration`** accepts integer seconds, `HH:MM:SS`, or `MM:SS`:

```swift
// <itunes:duration>3600</itunes:duration>     → itunesDuration == 3600
// <itunes:duration>01:30:15</itunes:duration> → itunesDuration == 5415
// <itunes:duration>45:30</itunes:duration>    → itunesDuration == 2730
```

**`itunes:block`** uses `"yes"`/`"no"` (distinct from `itunes:explicit`):

```swift
// <itunes:block>yes</itunes:block> → itunesBlock == true
// <itunes:block>no</itunes:block>  → itunesBlock == false
```

## Unknown Element Preservation

The parser captures XML elements it does not recognize into the ``UnknownElement`` type,
stored on ``Channel/unknownElements`` and ``Item/unknownElements``. This enables
round-trip fidelity -- elements from custom namespaces survive a parse-modify-generate
cycle.

```swift
let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
        <channel>
            <title>Unknown Test</title>
            <link>https://example.com</link>
            <description>Testing unknown elements.</description>
            <custom:rating>5</custom:rating>
            <item>
                <title>Ep 1</title>
                <custom:score>95</custom:score>
            </item>
        </channel>
    </rss>
    """

let feed = try FeedParser().parse(xml)
let channel = feed.channel!

// Channel-level unknown element
let rating = channel.unknownElements.first { $0.name == "custom:rating" }
print(rating?.textContent) // "5"

// Item-level unknown element
let score = channel.items[0].unknownElements.first { $0.name == "custom:score" }
print(score?.textContent)  // "95"
```

The parser also preserves **CDATA tracking** (``Channel/cdataFields``,
``Item/cdataFields``) and **XML comments** (``Channel/xmlComments``,
``Item/xmlComments``) for complete round-trip fidelity.

```swift
// CDATA: the content is stored without the wrapper, but the field
// is tracked so the generator can re-wrap it.
// <description><![CDATA[A <b>bold</b> description.]]></description>
channel.description                   // "A <b>bold</b> description."
channel.cdataFields.contains("description") // true

// XML comments are preserved in order.
// <!-- Channel-level comment -->
channel.xmlComments // [" Channel-level comment "]
```

## Malformed Feed Handling

``FeedParser`` uses best-effort parsing. Non-fatal issues like unparseable dates are
silently skipped (or surfaced via ``FeedParser/parseWithDiagnostics(_:)``), and
parsing continues with the remaining elements.

```swift
let xml = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
        <channel>
            <title>Malformed Dates</title>
            <link>https://example.com</link>
            <description>Feed with bad dates.</description>
            <pubDate>not-a-real-date</pubDate>
            <item>
                <title>Good Episode</title>
                <pubDate>Mon, 10 Feb 2025 12:00:00 +0000</pubDate>
            </item>
        </channel>
    </rss>
    """

let feed = try FeedParser().parse(xml)
let channel = feed.channel!

channel.pubDate           // nil (unparseable date skipped)
channel.items[0].pubDate  // valid Date (good date parsed)
channel.items[0].title    // "Good Episode"
```

Empty items are handled gracefully. Properties that are absent simply remain `nil`:

```swift
// An <item></item> with no children produces an Item
// where title, guid, enclosure, etc. are all nil.
```

Fatal errors -- completely invalid XML or a missing `<channel>` element -- throw a
``ParserError``:

```swift
let parser = FeedParser()

// Completely invalid XML
do {
    try parser.parse("This is not XML at all <><><<")
} catch let error as ParserError {
    // ParserError.invalidXML(...)
}

// RSS element with no channel
do {
    try parser.parse("""
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0"></rss>
        """)
} catch let error as ParserError {
    // ParserError.missingChannel
}
```

## Streaming Parsing

For large feeds with hundreds or thousands of episodes, ``StreamingFeedParser`` yields
items one at a time as an `AsyncThrowingStream`. This avoids loading the entire feed
model into memory at once.

```swift
let parser = StreamingFeedParser()
var items: [Item] = []

for try await item in parser.parseItems(from: xml) {
    items.append(item)
}
// items contains each <item> as it was parsed
```

``StreamingFeedParser`` also accepts `Data`:

```swift
let data = xml.data(using: .utf8)!
let parser = StreamingFeedParser()

for try await item in parser.parseItems(from: data) {
    print(item.title ?? "Untitled")
}
```

Streamed items include all namespace data -- iTunes, Podcast NS 2.0, Dublin Core, and so
on -- just like the synchronous parser:

```swift
for try await item in parser.parseItems(from: xml) {
    print(item.itunesDuration)   // e.g., 1800
    print(item.itunesEpisode)    // e.g., 5
    print(item.itunesSeason)     // e.g., 2
    print(item.transcripts.count) // e.g., 1
}
```

If the feed is missing a `<channel>` element, the stream throws a ``ParserError``:

```swift
do {
    for try await _ in parser.parseItems(from: badXml) {
        // ...
    }
} catch let error as ParserError {
    // ParserError.missingChannel
}
```

## Parser Errors

``ParserError`` is an `Error` and `LocalizedError` enum with five cases:

| Case | Description |
|------|-------------|
| ``ParserError/invalidXML(_:)`` | The XML data could not be parsed. |
| ``ParserError/missingRSSElement`` | The root `<rss>` element was not found. |
| ``ParserError/missingChannel`` | The `<channel>` element was not found inside `<rss>`. |
| ``ParserError/encodingError(_:)`` | The data could not be decoded with the expected encoding. |
| ``ParserError/networkError(_:)`` | A network error occurred while fetching a remote feed. |

All cases provide a human-readable `errorDescription`:

```swift
ParserError.missingChannel.errorDescription
// "Missing <channel> element"

ParserError.invalidXML("unexpected EOF").errorDescription
// "Invalid XML: unexpected EOF"

ParserError.encodingError("utf-8").errorDescription
// "Encoding error: utf-8"
```

``ParserError`` is `Equatable` and `Sendable`, so it works naturally in concurrent code
and test assertions.

## Next Steps

- <doc:GeneratingFeeds>
- <doc:ValidatingFeeds>
- <doc:RoundTripAndDiff>
