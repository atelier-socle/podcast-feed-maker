# CLI Reference

@Metadata {
    @PageKind(article)
}

Command-line tool for generating, parsing, and validating podcast RSS feeds.

## Overview

The `podcastfeed` CLI provides ten commands for working with podcast feeds. Install via
Swift Package Manager. The CLI is built on Apple's swift-argument-parser and supports all
features of the PodcastFeedMaker library through a terminal interface.

## Installation

Build the release binary and copy it to your PATH:

```bash
swift build -c release
cp .build/release/podcastfeed /usr/local/bin/
```

## Commands

### init

Scaffold a new podcast feed from a template. Four template levels are available: `basic`,
`standard`, `advanced`, and `expert`. Output defaults to JSON; use `--format xml` for RSS XML.

```bash
podcastfeed init --template basic
podcastfeed init --template standard --format xml --output feed.xml
podcastfeed init --template expert --format xml --output feed.xml
podcastfeed init --template standard --platforms apple spotify psp1
```

| Option | Description |
|--------|-------------|
| `--template` | Template level: `basic`, `standard`, `advanced`, `expert` (required) |
| `--format` | Output format: `json` (default), `xml` |
| `--output`, `-o` | Write to file instead of stdout |
| `--platforms` | Override platform preset (e.g., `apple`, `spotify`, `psp1`) |
| `--no-color` | Disable colored output |

### generate

Generate RSS XML from a JSON feed definition. The input file must contain a ``PodcastFeed``
encoded as JSON (via `JSONEncoder`).

```bash
podcastfeed generate feed.json
podcastfeed generate feed.json --output feed.xml
podcastfeed generate feed.json --validate
podcastfeed generate feed.json --minified
podcastfeed generate feed.json --template advanced --platforms apple spotify
```

| Option | Description |
|--------|-------------|
| `--output`, `-o` | Write to file instead of stdout |
| `--pretty` | Pretty-print XML output |
| `--minified` | Minified XML output |
| `--validate` | Run validation after generation |
| `--template` | Template to validate against: `basic`, `standard`, `advanced`, `expert` |
| `--platforms` | Platform(s) to validate against |

### read

Parse and display a podcast feed in summary, JSON, or XML format.

```bash
podcastfeed read feed.xml
podcastfeed read feed.xml --format json
podcastfeed read feed.xml -f xml --verbose
```

| Option | Description |
|--------|-------------|
| `--format`, `-f` | Output format: `summary` (default), `json`, `xml` |
| `--verbose` | Show additional details |

### validate

Validate a feed against platform requirements. Supports all five platforms individually or
combined.

```bash
podcastfeed validate feed.xml --platform apple
podcastfeed validate feed.xml --platform apple spotify psp1
podcastfeed validate feed.xml --format json
podcastfeed validate feed.xml --platform apple --template expert
podcastfeed validate feed.xml --verbose
```

| Option | Description |
|--------|-------------|
| `--platform` | Platform(s): `apple`, `spotify`, `amazon`, `podcastIndex`, `psp1` |
| `--format` | Output format: `text` (default), `json` |
| `--template` | Additional template validation: `basic`, `standard`, `advanced`, `expert` |
| `--verbose` | Show all results including info-level messages |

### lint

Quick feed validation with optional strictness. Without `--strict`, warnings produce exit code 2
instead of 1.

```bash
podcastfeed lint feed.xml
podcastfeed lint feed.xml --strict
podcastfeed lint feed.xml --template standard
podcastfeed lint feed.xml --format json
podcastfeed lint feed.xml --template advanced --platforms apple spotify
```

| Option | Description |
|--------|-------------|
| `--strict` | Treat warnings as errors |
| `--template` | Template level to check against: `basic`, `standard`, `advanced`, `expert` |
| `--format` | Output format: `text` (default), `json` |
| `--platforms` | Override template platforms |
| `--no-color` | Disable colored output |

### episodes

List episodes in a feed with sorting and pagination.

```bash
podcastfeed episodes feed.xml
podcastfeed episodes feed.xml -f json
podcastfeed episodes feed.xml --limit 10
podcastfeed episodes feed.xml -n 3
podcastfeed episodes feed.xml --sort oldest
podcastfeed episodes feed.xml --sort title
```

| Option | Description |
|--------|-------------|
| `--format`, `-f` | Output format: `text` (default), `json` |
| `--limit`, `-n` | Maximum number of episodes to show |
| `--sort` | Sort order: `newest` (default), `oldest`, `title` |

### chapters

Extract chapter information from a feed. The `--episode` option accepts a 0-based numeric index,
a GUID string, or a title substring for flexible episode selection.

```bash
podcastfeed chapters feed.xml
podcastfeed chapters feed.xml --episode 0
podcastfeed chapters feed.xml -e ep-001
podcastfeed chapters feed.xml -e pilot
podcastfeed chapters feed.xml -e 0 -f json
podcastfeed chapters feed.xml -e 0 -f psc
podcastfeed chapters feed.xml -e 0 -f json --export chapters.json
```

| Option | Description |
|--------|-------------|
| `--episode`, `-e` | Episode identifier: numeric index (0-based), GUID, or title substring |
| `--format`, `-f` | Output format: `text` (default), `json`, `psc` |
| `--export` | Export chapters to a file |
| `--no-color` | Disable colored output |

When called without `--episode`, lists all episodes that have chapters. When called with
`--episode`, shows the chapters for that specific episode.

### diff

Compare two podcast feeds and display the differences. Uses ``FeedDiff`` under the hood.

```bash
podcastfeed diff feed-v1.xml feed-v2.xml
podcastfeed diff feed-v1.xml feed-v2.xml --format json
podcastfeed diff feed-v1.xml feed-v2.xml --no-color
```

| Option | Description |
|--------|-------------|
| `--format` | Output format: `text` (default), `json` |
| `--no-color` | Disable colored output |

### convert

Convert between feed formats: XML, JSON, and Podlove Simple Chapters (PSC).

```bash
podcastfeed convert feed.xml --to json
podcastfeed convert feed.json --to xml
podcastfeed convert chapters.json --to psc
podcastfeed convert feed.xml --to json -o feed.json
```

| Option | Description |
|--------|-------------|
| `--to` | Target format: `json`, `xml`, `psc` (required) |
| `--output`, `-o` | Write to file instead of stdout |

### add-episode

Add a new episode to an existing feed. The episode is inserted at position 0 (newest first) and
the channel's `lastBuildDate` is updated automatically. A GUID is auto-generated if `--guid` is
omitted.

```bash
podcastfeed add-episode feed.xml \
    --title "New Episode" \
    --audio https://example.com/ep.mp3 \
    --output updated.xml

podcastfeed add-episode feed.xml \
    --title "Full Options" \
    --audio https://example.com/full.mp3 \
    --output out.xml \
    --length 75000000 \
    --duration 3600 \
    --description "A fully specified episode" \
    --guid custom-guid-abc \
    --pub-date "Thu, 13 Feb 2026 12:00:00 +0000" \
    --type audio/m4a \
    --explicit
```

| Option | Description |
|--------|-------------|
| `--title` | Episode title (required) |
| `--audio` | Audio file URL (required) |
| `--output`, `-o` | Output file path (required) |
| `--length` | File size in bytes for the enclosure |
| `--type` | MIME type (default: `audio/mpeg`) |
| `--duration` | Duration in seconds |
| `--description` | Episode description |
| `--guid` | Episode GUID (auto-generated if omitted) |
| `--pub-date` | Publication date in RFC 2822 or ISO 8601 (default: now) |
| `--explicit` | Mark episode as explicit |
| `--no-color` | Disable colored output |

## Global Options

These options are available on the root `podcastfeed` command:

| Option | Description |
|--------|-------------|
| `--no-color` | Disable colored output |
| `--version` | Show version |
| `-h`, `--help` | Show help |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |
| 2 | Warnings only (no errors) |

## Next Steps

- <doc:GettingStarted>
- <doc:ValidatingFeeds>
- <doc:TemplatesAndPresets>
