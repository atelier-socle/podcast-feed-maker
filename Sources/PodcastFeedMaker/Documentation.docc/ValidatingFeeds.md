# Validating Feeds

Check your podcast feed against platform-specific requirements.

## Overview

``FeedValidator`` checks a ``PodcastFeed`` against the submission rules of five major
podcast platforms. Each platform has its own requirements for HTTPS, artwork dimensions,
media formats, required tags, and description lengths. The validator returns a
``ValidationReport`` containing typed results at three severity levels, so you can fix
errors before submitting your feed.

## Platform Requirements

| Platform | Key Requirements |
|----------|-----------------|
| Apple Podcasts | HTTPS required for artwork and enclosures, artwork 1400-3000px JPEG/PNG, `itunes:image` required, `itunes:category` required, `itunes:explicit` required |
| Spotify | MP3 preferred, max 200 MB file size, artwork 1400-2048px square, max 4000-byte description |
| Amazon Music | Broadest format support (MP3/M4A/FLAC/OGG/ALAC), artwork 1400-3000px |
| Podcast Index | Podcast NS 2.0 tags (`podcast:locked`, `podcast:guid`, `podcast:funding`), V4V config |
| PSP-1 | `language` required, `atom:link` self required, `podcast:locked` required, `podcast:guid` required |

## Validating Against a Single Platform

Create a ``FeedValidator`` instance and call ``FeedValidator/validate(_:for:)->ValidationReport``
with one ``ValidationPlatform``. The returned ``ValidationReport`` tells you whether the
feed is valid and lists every finding.

```swift
let validator = FeedValidator()
let report = validator.validate(feed, for: .apple)

print(report.platform) // .apple
print(report.isValid)  // true if no errors
print(report.errors)   // [] when valid
```

Here is an example that catches a missing `itunes:image`:

```swift
var feed = // ... your PodcastFeed
feed.channel?.itunesImage = nil

let report = validator.validate(feed, for: .apple)
// report.errors contains a result with field "channel.itunesImage"
```

## Validating Against Multiple Platforms

Pass an array of platforms to ``FeedValidator/validate(_:for:)->[ValidationReport]`` to get one
``ValidationReport`` per platform in a single call.

```swift
let validator = FeedValidator()
let reports = validator.validate(feed, for: [.apple, .spotify, .amazon])

// One report per platform
print(reports.count) // 3

let platforms = Set(reports.map(\.platform))
// platforms == [.apple, .spotify, .amazon]
```

## Validating Against All Platforms

``FeedValidator/validateAll(_:)`` runs the feed through every platform in
all five ``ValidationPlatform`` values and returns all five reports.

```swift
let validator = FeedValidator()
let reports = validator.validateAll(feed)

print(reports.count) // 5 (apple, spotify, amazon, podcastIndex, psp1)

let platforms = Set(reports.map(\.platform))
// platforms == Set(ValidationPlatform.allCases)
```

## Severity Levels

Every finding is a ``ValidationResult`` with one of three ``ValidationSeverity`` levels.
Severity is `Comparable` -- ``ValidationSeverity/error`` is the highest.

| Severity | Meaning |
|----------|---------|
| ``ValidationSeverity/error`` | Feed will not be accepted by the platform. |
| ``ValidationSeverity/warning`` | Feed may have issues or suboptimal behavior. |
| ``ValidationSeverity/info`` | Informational recommendation. |

``ValidationReport`` provides convenience accessors to filter by severity:

```swift
let report = validator.validate(feed, for: .apple)

report.errors   // all error-level results
report.warnings // all warning-level results
report.infos    // all info-level results
report.isValid  // true when errors is empty
```

A ``ValidationResult`` carries four properties:

```swift
let result = ValidationResult(
    severity: .error,
    message: "Channel title is required",
    field: "channel.title",
    platform: .apple
)

result.severity // .error
result.message  // "Channel title is required"
result.field    // "channel.title"
result.platform // .apple (or nil for cross-cutting rules)
```

### Apple Podcasts

Apple requires HTTPS for artwork and enclosure URLs, at least one `itunes:category`, an
`itunes:explicit` value, an `itunes:image`, and at least one item with an enclosure.
Missing `itunes:author` and `itunes:owner` produce warnings. A serial show without
`itunes:season` or `itunes:episode` on its items produces an info note.

```swift
var feed = // ... your feed
feed.channel?.itunesImage = URL(string: "http://cdn.example.com/art.jpg")
let report = validator.validate(feed, for: .apple)
// error: channel.itunesImage must use HTTPS

feed.channel?.itunesAuthor = nil
let report2 = validator.validate(feed, for: .apple)
// warning: channel.itunesAuthor recommended

feed.channel?.itunesType = .serial
feed.channel?.items[0].itunesSeason = nil
feed.channel?.items[0].itunesEpisode = nil
let report3 = validator.validate(feed, for: .apple)
// info: Serial shows should include season/episode numbers
```

### Spotify

Spotify prefers MP3 enclosures and warns on files larger than 200 MB. Descriptions
exceeding 4000 bytes trigger a warning. Podlove chapters produce an informational note
since Spotify uses its own chapter system.

```swift
var feed = // ... your feed
feed.channel?.items[0].enclosure = Enclosure(
    url: URL(string: "https://cdn.example.com/ep.m4a")!,
    length: 15_000_000,
    type: "audio/m4a"
)
let report = validator.validate(feed, for: .spotify)
// warning: enclosure.type — Spotify prefers audio/mpeg

feed.channel?.items[0].enclosure = Enclosure(
    url: URL(string: "https://cdn.example.com/ep.mp3")!,
    length: 250_000_000,
    type: "audio/mpeg"
)
let report2 = validator.validate(feed, for: .spotify)
// warning: enclosure.length exceeds 200 MB

feed.channel?.description = String(repeating: "A", count: 4500)
let report3 = validator.validate(feed, for: .spotify)
// warning: channel.description exceeds 4000 bytes
```

### Amazon Music

Amazon has the broadest format support but still requires a non-empty title, description,
and at least one item with an enclosure. Artwork, category, explicit, and per-item GUIDs
are recommended (warnings when missing).

```swift
let channel = Channel(
    title: "",
    link: URL(string: "https://example.com")!,
    description: ""
)
let feed = PodcastFeed(channel: channel)
let report = validator.validate(feed, for: .amazon)
// errors: channel.title, channel.description, channel.items
```

### Podcast Index

Podcast Index encourages full use of Podcast Namespace 2.0 tags. Missing
`podcast:locked`, `podcast:guid`, and `podcast:funding` produce warnings. Absent
`podcast:value` (Value 4 Value) produces an info note.

```swift
var feed = // ... your feed
feed.channel?.locked = nil
feed.channel?.podcastGuid = nil
feed.channel?.funding = []
feed.channel?.value = nil

let report = validator.validate(feed, for: .podcastIndex)
// warning: channel.locked
// warning: channel.podcastGuid
// warning: channel.funding
// info: channel.value — consider adding V4V support
```

### PSP-1

PSP-1 is the strictest standard. It requires `language`, `atom:link` with `rel="self"`,
`podcast:locked`, `podcast:guid`, and a GUID on every item. Leading/trailing whitespace
and titles exceeding 255 characters produce warnings.

```swift
var feed = // ... your feed
feed.channel?.language = nil
feed.channel?.atomLinks = []
feed.channel?.locked = nil
feed.channel?.podcastGuid = nil
feed.channel?.items[0].guid = nil

let report = validator.validate(feed, for: .psp1)
// errors: channel.language, channel.atomLinks, channel.locked,
//         channel.podcastGuid, items[0].guid

feed.channel?.title = "  Showcase Podcast  "
let report2 = validator.validate(feed, for: .psp1)
// warning: channel.title has leading/trailing whitespace

feed.channel?.title = String(repeating: "X", count: 300)
let report3 = validator.validate(feed, for: .psp1)
// warning: channel.title exceeds 255 characters
```

## Cross-Cutting Rules

In addition to platform-specific checks, every validation run includes cross-cutting
rules that apply universally. These results have a `nil` ``ValidationResult/platform``
value.

**Duplicate GUIDs** -- If two items share the same GUID value, a warning is produced:

```swift
var feed = // ... your feed with two items sharing guid "ep-001"
let report = validator.validate(feed, for: .apple)
// warning: "Duplicate GUID" (platform == nil)
```

**GUID / isPermaLink inconsistency** -- If `isPermaLink` is `true` but the GUID value is
not a URL, a warning is produced:

```swift
feed.channel?.items[0].guid = GUID(
    value: "not-a-url-just-an-id",
    isPermaLink: true
)
let report = validator.validate(feed, for: .apple)
// warning: isPermaLink inconsistency (platform == nil)
```

**Missing `atom:link` self** -- An informational note is emitted when no `atom:link` with
`rel="self"` is present:

```swift
feed.channel?.atomLinks = []
let report = validator.validate(feed, for: .amazon)
// info: channel.atomLinks — atom:link self recommended
```

**`itunes:complete` set to true** -- An informational note confirms the feed is marked as
complete (no new episodes expected):

```swift
feed.channel?.itunesComplete = true
let report = validator.validate(feed, for: .apple)
// info: channel.itunesComplete — feed marked as complete
```

**`itunes:new-feed-url` without HTTPS** -- A warning is produced when the migration URL
does not use HTTPS:

```swift
feed.channel?.itunesNewFeedUrl = URL(string: "http://example.com/new-feed.xml")
let report = validator.validate(feed, for: .apple)
// warning: channel.itunesNewFeedUrl should use HTTPS
```

## Next Steps

- <doc:BuilderDSL>
- <doc:TemplatesAndPresets>
- <doc:RoundTripAndDiff>
