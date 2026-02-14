# Auditing Feeds

Score, analyze, and improve your podcast feed with actionable recommendations.

## Overview

The Feed Audit system goes beyond binary validation. While ``FeedValidator`` answers
"Is this feed compliant?", ``FeedAuditor`` answers "How good is this feed?"
with a scored report, actionable recommendations, and a cross-platform compatibility matrix.

```swift
import PodcastFeedMaker

let feed = try FeedParser().parse(xml)
let report = FeedAuditor().audit(feed)

print("Score: \(report.score)/100 (\(report.grade.rawValue))")
print("Recommendations: \(report.recommendations.count)")
```

## Scoring System

The audit evaluates 29 criteria across five weighted categories:

| Category | Weight | What It Measures |
|----------|--------|------------------|
| Metadata | 25% | Channel metadata quality (artwork, description, owner...) |
| Episodes | 25% | Episode completeness (enclosures, durations, GUIDs...) |
| Compliance | 20% | Standards conformity (PSP-1, Podcast NS 2.0, iTunes) |
| Accessibility | 15% | Transcripts, chapters, rich descriptions |
| Discoverability | 15% | Keywords, funding, social links, podroll |

The global score (0-100) maps to a letter grade:

| Grade | Score Range |
|-------|-------------|
| A+ | 95-100 |
| A | 90-94 |
| B+ | 85-89 |
| B | 80-84 |
| C+ | 75-79 |
| C | 70-74 |
| D | 60-69 |
| F | 0-59 |

## Reading Recommendations

Each recommendation has a priority level:

- **Critical** -- Blocks distribution on major platforms (e.g., missing enclosure)
- **Recommended** -- Significantly improves feed quality (e.g., missing artwork)
- **Nice to Have** -- Best practices and bonus features (e.g., podroll, funding)

Recommendations include:
- A human-readable explanation of what is missing and why it matters
- The potential score impact if the issue is fixed
- The category the recommendation belongs to

```swift
for rec in report.recommendations {
    print("[\(rec.priority.rawValue)] \(rec.message)")
    print("  Impact: +\(rec.potentialPoints) points (\(rec.category.displayName))")
}
```

## Platform Compatibility

The audit runs the existing platform validators and presents results as a matrix:

```swift
for result in report.compatibility {
    let icon: String
    switch result.status {
    case .ok: icon = "OK"
    case .warnings: icon = "\(result.warningCount) warning(s)"
    case .incompatible: icon = "\(result.errorCount) error(s)"
    }
    print("\(result.platform): \(icon)")
}
```

All five platforms are covered: Apple Podcasts, Spotify, Amazon Music, Podcast Index, and PSP-1.

## Comparing Feed Versions

Track improvement over time by comparing two feeds:

```swift
let before = try FeedParser().parse(oldXML)
let after = try FeedParser().parse(newXML)
let comparison = FeedAuditor().compare(before: before, after: after)

print("Score: \(comparison.beforeScore) -> \(comparison.afterScore) (\(comparison.scoreDelta))")
print("Resolved: \(comparison.resolvedRecommendations.count)")
print("New issues: \(comparison.newRecommendations.count)")
```

## CLI Integration

Use the `audit` command for quick checks or CI/CD gates:

```bash
# Human-readable report
podcastfeed audit feed.xml

# JSON output for automation
podcastfeed audit feed.xml --format json

# CI gate: fail if score < 80
podcastfeed audit feed.xml --min-score 80

# Compare two feed versions
podcastfeed audit old-feed.xml --compare new-feed.xml

# Focus on a single category
podcastfeed audit feed.xml --category compliance
```

## Topics

### Audit Types

- ``FeedAuditor``
- ``AuditReport``
- ``AuditGrade``
- ``AuditCategory``
- ``AuditCategoryScore``
- ``AuditCriterion``
- ``AuditCriterionResult``
- ``AuditRecommendation``
- ``PlatformCompatibilityResult``
- ``AuditComparison``
- ``AuditCategoryDelta``
