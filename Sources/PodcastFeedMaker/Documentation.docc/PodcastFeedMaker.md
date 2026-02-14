# ``PodcastFeedMaker``

@Metadata {
    @DisplayName("PodcastFeedMaker")
}

Reference-quality Swift library for generating, parsing, and validating podcast RSS feeds.

## Overview

**PodcastFeedMaker** covers the complete podcast feed lifecycle: create feeds from scratch
with a fluent builder DSL, parse existing XML feeds, validate against five major platforms,
import and export OPML subscription lists, and round-trip with zero data loss. It supports
all seven XML namespaces used in podcasting —
RSS 2.0, iTunes, Podcast Namespace 2.0 (all 30 tags), Atom, Dublin Core, Content Module,
and Podlove Simple Chapters.

Zero third-party dependencies. Pure Swift + Foundation. Linux-compatible from day one.

```swift
import PodcastFeedMaker

// Build a feed with the result builder DSL
let feed = PodcastFeed {
    Channel(
        title: "My Podcast",
        link: URL(string: "https://example.com")!,
        description: "A show about technology"
    )
    .author("Jane Host")
    .explicit(false)
    .category(.technology)
    .image("https://example.com/artwork.jpg")
    .locked(owner: "jane@example.com")
    .guid("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")

    Item(
        title: "Episode 1",
        enclosure: Enclosure.mp3(
            url: "https://cdn.example.com/episodes/ep001.mp3",
            length: 48_000_000
        )
    )
        .guid("ep-001", isPermaLink: false)
        .description("The pilot episode")
        .duration(1800)
        .episode(1)
        .season(1)
}

// Generate XML
let xml = try FeedGenerator().generate(feed)

// Validate against Apple Podcasts
let report = FeedValidator().validate(feed, for: .apple)
print("Valid: \(report.isValid)")
```

### Key Features

- **Generate** — Synchronous and streaming XML generation with configurable formatting
- **Parse** — Full-fidelity XML parsing with diagnostics and best-effort error recovery
- **Validate** — Multi-platform validation for Apple Podcasts, Spotify, Amazon Music, Podcast Index, and PSP-1
- **Builder DSL** — Result builder syntax with fluent channel and item modifiers
- **Templates** — Four expertise levels (basic through expert) with composable presets
- **Chapters** — JSON Chapters and Podlove Simple Chapters, including Codable round-trip
- **Round-trip** — Parse, modify, and regenerate feeds with zero data loss (unknown elements, CDATA, comments, namespace prefixes)
- **OPML** — Import and export podcast subscription lists (OPML 1.0 and 2.0), with validation and bidirectional feed conversion
- **Audit** — Quality scoring engine with weighted categories, actionable recommendations, and cross-platform compatibility matrix
- **CLI** — Thirteen command-line tools for feed management (`podcastfeed` executable)

### How It Works

1. **Model** — All podcast data is represented as value types (`struct` and `enum`), all `Sendable`, `Hashable`, and `Equatable`
2. **Generate** — ``FeedGenerator`` converts the model to XML; ``StreamingFeedGenerator`` yields async chunks for large catalogs
3. **Parse** — ``FeedParser`` converts XML back to the model; ``StreamingFeedParser`` yields items one at a time
4. **Validate** — ``FeedValidator`` checks the model against platform-specific rules with severity levels
5. **Modify** — Fluent builders, result builder DSL, and template factories make it easy to create and update feeds

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:GeneratingFeeds>
- <doc:ParsingFeeds>

### Validation

- <doc:ValidatingFeeds>
- <doc:AuditingFeeds>
- <doc:AuditIdentifiersReference>

### Convenience

- <doc:BuilderDSL>
- <doc:TemplatesAndPresets>

### Chapters

- <doc:ChaptersGuide>

### Round-Trip

- <doc:RoundTripAndDiff>

### OPML

- <doc:OPMLGuide>

### CLI

- <doc:CLIReference>

### Engine

- ``PodcastFeedEngine``
- ``PodcastFeedMaker``
- ``NetworkValidator``

### Feed Model

- ``PodcastFeed``
- ``Channel``
- ``Item``
- ``PodcastNamespace``

### RSS 2.0 Core

- ``Enclosure``
- ``GUID``
- ``RSSCategory``
- ``RSSCloud``
- ``RSSImage``
- ``RSSTextInput``
- ``RSSSource``
- ``SkipSchedule``

### iTunes

- ``ITunesCategory``
- ``ITunesOwner``
- ``ITunesShowType``
- ``ITunesEpisodeType``

### Atom

- ``AtomLink``

### Dublin Core

- ``DublinCore``

### Content Module

- ``ContentEncoded``

### Podcast Namespace 2.0 — Core

- ``Locked``
- ``PodcastGuid``
- ``Funding``
- ``PodcastPerson``
- ``PodcastLocation``
- ``PodcastSeason``
- ``PodcastEpisode``
- ``Transcript``
- ``ChaptersLink``
- ``Soundbite``
- ``PodcastLicense``
- ``AlternateEnclosure``
- ``PodcastSource``
- ``PodcastIntegrity``
- ``Trailer``

### Podcast Namespace 2.0 — Extended

- ``PodcastBlock``
- ``PodcastValue``
- ``ValueRecipient``
- ``ValueTimeSplit``
- ``PodcastMedium``
- ``PodcastLiveItem``
- ``ContentLink``
- ``SocialInteract``
- ``PodcastTxt``
- ``RemoteItem``
- ``Podroll``
- ``UpdateFrequency``
- ``PodcastChat``
- ``PodcastPublisher``
- ``PodcastImage``
- ``PodcastImages``

### Podlove Simple Chapters

- ``PodloveChapter``
- ``PodloveChapters``

### JSON Chapters

- ``JSONChapterList``
- ``JSONChapter``

### Round-Trip Fidelity

- ``UnknownElement``

### Validation Types

- ``ValidationPlatform``
- ``ValidationSeverity``
- ``ValidationResult``
- ``ValidationReport``
- ``ValidationRule``
- ``FeedValidator``

### Generator

- ``FeedGenerator``
- ``StreamingFeedGenerator``
- ``XMLBuilder``
- ``NamespaceResolver``
- ``GeneratorError``

### Parser

- ``FeedParser``
- ``StreamingFeedParser``
- ``DateParser``
- ``ParserError``

### Builders

- ``PodcastFeedBuilder``
- ``FeedComponent``
- ``PSP1Configuration``

### Diff

- ``FeedDiff``
- ``FeedDifference``

### OPML

- ``OPMLDocument``
- ``OPMLHead``
- ``OPMLOutline``
- ``OPMLParser``
- ``OPMLGenerator``
- ``OPMLValidator``
- ``OPMLValidationReport``
- ``OPMLValidationIssue``
- ``OPMLValidationSeverity``
- ``OPMLParserError``
- ``OPMLFeedConverter``

### Audit

- ``FeedAuditor``
- ``AuditReport``
- ``AuditGrade``
- ``AuditCategory``
- ``AuditCategoryScore``
- ``AuditCriterion``
- ``AuditCriterionResult``
- ``AuditRecommendation``
- ``AuditScoring``
- ``PlatformCompatibilityResult``
- ``AuditComparison``
- ``AuditCategoryDelta``

### Templates

- ``FeedTemplate``
- ``BasicTemplate``
- ``StandardTemplate``
- ``AdvancedTemplate``
- ``ExpertTemplate``
- ``ComposedTemplate``
- ``ExpertiseLevel``
- ``PlatformPreset``
- ``FeedTag``
- ``TemplateValidator``
- ``TemplateValidationResult``
- ``TemplateValidationReport``
