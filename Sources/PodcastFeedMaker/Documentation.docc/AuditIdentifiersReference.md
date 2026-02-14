# Audit Identifiers Reference

Complete reference of all audit criterion identifiers, default messages, and scoring values. Use this to build localized audit UIs in your apps.

## Overview

The ``FeedAuditor`` evaluates 29 criteria across 5 weighted categories. Each criterion has:
- A stable **identifier** (e.g., `metadata.artwork`) — use as your localization key
- A **default message** in English — the fallback text from ``AuditRecommendation/message``
- A **priority** level — how the recommendation is classified when the criterion fails
- A **point value** — maximum points this criterion contributes to the category score

### Localization Pattern

In your app, use the `criterionId` as a localization key to display audit recommendations in the user's language:

```swift
// Map criterionId to localized string
func localizedMessage(for recommendation: AuditRecommendation) -> String {
    String(localized: String.LocalizationValue(recommendation.criterionId),
           table: "AuditMessages")
}
```

Your `AuditMessages.xcstrings` file would contain entries like:
```
"metadata.artwork" = "Ajoutez une <itunes:image> carrée (1400×1400 à 3000×3000 pixels) en HTTPS";
"metadata.description" = "Rédigez une description d'au moins 100 caractères...";
```

## Metadata (25 points, weight: 25%)

| Identifier | Default Message | Priority | Points |
|------------|----------------|----------|--------|
| `metadata.artwork` | Add a \<itunes:image\> with a square image (1400x1400 to 3000x3000 pixels) hosted on HTTPS | recommended | 5 |
| `metadata.description` | Write a description of at least 100 characters that describes your podcast's content and value proposition | recommended | 4 |
| `metadata.category` | Add at least one \<itunes:category\> to help listeners discover your podcast | niceToHave | 3 |
| `metadata.language` | Add a \<language\> tag (e.g., en, fr) for proper localization on platforms | niceToHave | 3 |
| `metadata.author` | Add \<itunes:author\> with the creator or show name | niceToHave | 3 |
| `metadata.owner` | Add \<itunes:owner\> with \<itunes:name\> and \<itunes:email\> — required by Apple Podcasts | recommended | 3 |
| `metadata.link` | Add a \<link\> to your podcast's website (HTTPS preferred) | niceToHave | 2 |
| `metadata.copyright` | Add a \<copyright\> notice to protect your content | niceToHave | 2 |

## Episodes (25 points, weight: 25%)

| Identifier | Default Message | Priority | Points |
|------------|----------------|----------|--------|
| `episodes.hasEpisodes` | Your feed has no episodes. Add at least one \<item\> with an enclosure | critical | 5 |
| `episodes.enclosures` | Ensure every episode has a valid \<enclosure\> with url, type, and length attributes | critical | 5 |
| `episodes.durations` | Add \<itunes:duration\> to each episode for proper display on podcast apps | niceToHave | 4 |
| `episodes.uniqueGuids` | Each episode must have a unique \<guid\> | niceToHave | 4 |
| `episodes.descriptions` | Write meaningful descriptions (\>50 chars) for each episode | niceToHave | 4 |
| `episodes.pubDates` | Add valid RFC 822 \<pubDate\> to each episode for proper sorting | niceToHave | 3 |

## Compliance (20 points, weight: 20%)

| Identifier | Default Message | Priority | Points |
|------------|----------------|----------|--------|
| `compliance.locked` | Add \<podcast:locked\> to prevent unauthorized feed moves | recommended | 4 |
| `compliance.guid` | Add \<podcast:guid\> with a UUID v4 to guarantee feed portability across platforms | recommended | 4 |
| `compliance.atomSelf` | Add \<atom:link rel="self"\> pointing to your feed URL for autodiscovery | recommended | 3 |
| `compliance.explicit` | Set \<itunes:explicit\> to true or false — required by Apple Podcasts | recommended | 3 |
| `compliance.type` | Set \<itunes:type\> to episodic or serial for proper episode ordering | niceToHave | 3 |
| `compliance.episodeArtwork` | Add episode-level \<itunes:image\> for visual differentiation in podcast apps | niceToHave | 3 |

## Accessibility (15 points, weight: 15%)

| Identifier | Default Message | Priority | Points |
|------------|----------------|----------|--------|
| `accessibility.transcripts` | Add \<podcast:transcript\> to improve accessibility and SEO — recommended by Podcast Index | niceToHave | 5 |
| `accessibility.chapters` | Add \<podcast:chapters\> for interactive navigation within episodes | niceToHave | 4 |
| `accessibility.richDescriptions` | Use \<content:encoded\> with HTML for rich episode descriptions | niceToHave | 3 |
| `accessibility.altText` | *(Awarded by default — no spec currently supports artwork alt text)* | niceToHave | 3 |

> Note: The `accessibility.altText` criterion always awards its full 3 points because no podcast
> specification currently supports alt text on artwork. When specs add support, this criterion will
> become a real evaluation. It never generates a recommendation.

## Discoverability (15 points, weight: 15%)

| Identifier | Default Message | Priority | Points |
|------------|----------------|----------|--------|
| `discoverability.keywords` | Add keywords to improve discoverability via \<podcast:txt\> or \<itunes:keywords\> | niceToHave | 3 |
| `discoverability.funding` | Add \<podcast:funding\> to let listeners support your podcast financially | niceToHave | 3 |
| `discoverability.social` | Add \<podcast:socialInteract\> to enable comments and social engagement | niceToHave | 3 |
| `discoverability.podroll` | Add \<podcast:podroll\> to cross-promote related podcasts | niceToHave | 3 |
| `discoverability.updateFrequency` | Set \<podcast:updateFrequency\> so apps know when to check for new episodes | niceToHave | 3 |

## Priority Levels

The ``AuditRecommendation/Priority`` enum determines how urgently a recommendation should be addressed. Priority is assigned based on the failing criterion's identifier:

| Priority | Criteria | Rationale |
|----------|----------|-----------|
| **critical** | `episodes.hasEpisodes`, `episodes.enclosures` | Without episodes or enclosures, the feed cannot be distributed on any platform. These block podcast distribution entirely. |
| **recommended** | `metadata.artwork`, `metadata.description`, `metadata.owner`, `compliance.locked`, `compliance.guid`, `compliance.atomSelf`, `compliance.explicit` | These are required or strongly recommended by major platforms (Apple Podcasts, Spotify, PSP-1). Missing them degrades compatibility significantly. |
| **niceToHave** | All remaining criteria | Best practices and bonus features that improve quality, accessibility, and discoverability but are not required for basic distribution. |

## Grade Scale

The global score (0--100) maps to a letter grade via ``AuditGrade/from(score:)``:

| Grade | Score Range |
|-------|-------------|
| A+ | 95--100 |
| A | 90--94 |
| B+ | 85--89 |
| B | 80--84 |
| C+ | 75--79 |
| C | 70--74 |
| D | 60--69 |
| F | 0--59 |

## Category Weights Summary

The global score is the weighted sum of per-category percentage scores:

| Category | Weight | Max Points | Criteria Count |
|----------|--------|------------|----------------|
| Metadata | 25% | 25 | 8 |
| Episodes | 25% | 25 | 6 |
| Compliance | 20% | 20 | 6 |
| Accessibility | 15% | 15 | 4 |
| Discoverability | 15% | 15 | 5 |
| **Total** | **100%** | **100** | **29** |

## See Also

- <doc:AuditingFeeds>
- ``FeedAuditor``
- ``AuditReport``
- ``AuditRecommendation``
- ``AuditCategory``
- ``AuditCriterion``
