# Templates and Presets

Use templates to scaffold feeds at different expertise levels and validate compliance.

## Overview

PodcastFeedMaker organizes podcast metadata into four expertise levels, from a minimal iTunes-only feed up to a full seven-namespace enterprise feed. Templates define which tags are required or recommended at each level, and the ``TemplateValidator`` checks any feed against a template to produce a structured report. Templates are composable: you can merge them, add requirements, and retarget platforms using fluent methods.

## Expertise Levels

``ExpertiseLevel`` is a `Comparable`, `CaseIterable`, `Codable` enum with four cases ordered from simplest to most complete.

| Level | Raw Value | Target Audience | Namespaces | Default Platform Preset |
|-------|-----------|-----------------|------------|-------------------------|
| ``ExpertiseLevel/basic`` | 0 | Beginners | iTunes, Atom | Major Platforms |
| ``ExpertiseLevel/standard`` | 1 | PSP-1 compliance | + Podcast NS | All |
| ``ExpertiseLevel/advanced`` | 2 | Professional | + Content, DC | All |
| ``ExpertiseLevel/expert`` | 3 | Enterprise | All 7 | All |

Because ``ExpertiseLevel`` is `Comparable`, you can compare levels directly:

```swift
ExpertiseLevel.basic < .standard   // true
ExpertiseLevel.advanced < .expert  // true
```

## Using Built-in Templates

Four concrete types conform to the ``FeedTemplate`` protocol. Each is also available as a static accessor on the protocol itself.

```swift
let basic    = BasicTemplate()       // or use .basic in generic context
let standard = StandardTemplate()    // or use .standard
let advanced = AdvancedTemplate()    // or use .advanced
let expert   = ExpertTemplate()      // or use .expert
```

Static accessors work in any context that expects `some FeedTemplate`:

```swift
func configure(_ template: some FeedTemplate) { /* ... */ }

configure(.basic)
configure(.standard)
configure(.advanced)
configure(.expert)
```

Every template defines four tag sets (`requiredChannelTags`, `recommendedChannelTags`, `requiredItemTags`, `recommendedItemTags`), a set of ``PodcastNamespace`` values, and a ``PlatformPreset``. The `allTags` computed property returns the union of all four tag sets.

Higher templates are strict supersets of lower ones: every required tag in ``BasicTemplate`` is also required in ``StandardTemplate``, and so on up to ``ExpertTemplate``.

## Factory Methods

``PodcastFeed`` provides convenience factory methods that create a feed pre-configured with a template's namespaces. An optional `configure` closure lets you apply ``Channel`` fluent modifiers.

```swift
let feed = PodcastFeed.basic(
    title: "My Show",
    link: URL(string: "https://example.com")!,
    description: "About my show"
) { channel in
    channel
        .author("Jane Doe")
        .explicit(false)
        .category(.technology)
        .image("https://cdn.example.com/art.jpg")
}
```

All four levels have a matching factory:

```swift
PodcastFeed.basic(title:link:description:configure:)
PodcastFeed.standard(title:link:description:configure:)
PodcastFeed.advanced(title:link:description:configure:)
PodcastFeed.expert(title:link:description:configure:)
```

For any ``FeedTemplate`` conforming type, use the generic factory:

```swift
let feed = PodcastFeed.template(
    StandardTemplate(),
    title: "Generic Show",
    link: URL(string: "https://example.com")!,
    description: "Using generic API"
)
```

## Platform Presets

``PlatformPreset`` maps templates to the ``ValidationPlatform`` values they target. Named presets cover common scenarios:

| Preset | Platforms |
|--------|-----------|
| `.apple` | Apple Podcasts |
| `.spotify` | Spotify |
| `.amazon` | Amazon Music |
| `.podcastIndex` | Podcast Index |
| `.psp1` | PSP-1 |
| `.majorPlatforms` | Apple + Spotify + Amazon |
| `.openEcosystem` | Podcast Index + PSP-1 |
| `.universal` | Apple + Spotify + Amazon + Podcast Index |
| `.all` | All 5 platforms |
| `.custom(Set)` | Any arbitrary combination |

Access the underlying platform set via the `platforms` property:

```swift
PlatformPreset.majorPlatforms.platforms
// Set<ValidationPlatform> containing .apple, .spotify, .amazon

let custom = PlatformPreset.custom([.apple, .podcastIndex])
custom.platforms  // [.apple, .podcastIndex]
```

``PlatformPreset`` is `Hashable`, so presets can be used as dictionary keys or set members.

## FeedTag and Minimum Level

``FeedTag`` is a `CaseIterable` enum with over 50 cases covering all seven namespaces. Each tag has two key properties:

- `minimumLevel` -- the lowest ``ExpertiseLevel`` that includes this tag
- `namespace` -- the ``PodcastNamespace`` the tag belongs to (nil for RSS 2.0 core)

```swift
FeedTag.title.minimumLevel            // .basic
FeedTag.itunesCategory.minimumLevel   // .basic
FeedTag.podcastLocked.minimumLevel    // .standard
FeedTag.podcastGuid.minimumLevel      // .standard
FeedTag.podcastTranscript.minimumLevel // .advanced
FeedTag.podcastChapters.minimumLevel  // .advanced
FeedTag.podcastValue.minimumLevel     // .expert
FeedTag.podloveChapters.minimumLevel  // .expert
FeedTag.dublinCore.minimumLevel       // .expert

FeedTag.itunesCategory.namespace      // .itunes
FeedTag.podcastLocked.namespace       // .podcast
FeedTag.atomLink.namespace            // .atom
FeedTag.contentEncoded.namespace      // .content
FeedTag.dublinCore.namespace          // .dublinCore
FeedTag.podloveChapters.namespace     // .podloveSimpleChapters
FeedTag.title.namespace               // nil (RSS 2.0 core)
```

## Template Validation

``TemplateValidator`` checks a ``PodcastFeed`` against any ``FeedTemplate`` and returns a ``TemplateValidationReport``.

```swift
let validator = TemplateValidator()
let report = validator.validate(feed, against: BasicTemplate())

if report.isCompliant {
    print("Feed meets basic template requirements")
} else {
    for error in report.errors {
        print("ERROR: \(error.tag) -- \(error.message)")
    }
}
```

The report separates findings into three severity levels:

- **Errors** (`report.errors`) -- required tags that are missing. A feed with errors is not compliant (`report.isCompliant == false`).
- **Warnings** (`report.warnings`) -- recommended tags that are missing. These do not prevent compliance.
- **Infos** (`report.infos`) -- tags present in the feed that belong to a higher level than the template. These carry a `suggestedLevel` property indicating which template to upgrade to.

Each ``TemplateValidationResult`` includes a `severity`, `tag`, `message`, and optional `suggestedLevel`:

```swift
let result = report.errors.first!
result.severity     // .error
result.tag          // .itunesImage
result.message      // "Required channel tag itunesImage is missing"
result.suggestedLevel  // nil (only present on .info results)
```

## Detecting Feed Level

``TemplateValidator`` can also detect the highest expertise level a feed satisfies:

```swift
let validator = TemplateValidator()
let level = validator.detectLevel(feed)
// Returns .basic, .standard, .advanced, or .expert
```

Detection checks from expert down to basic, returning the highest level where all required tags are present.

```swift
// A feed with only iTunes basics
let level = validator.detectLevel(basicFeed)  // .basic

// A PSP-1 compliant feed
let level = validator.detectLevel(psp1Feed)   // .standard (or higher)
```

## Template Composition

Templates can be combined and customized using operators and fluent methods. All composition operations return a ``ComposedTemplate``.

### Merge Operator

The `+` operator unions all tag sets and namespaces from two templates. The resulting level is the maximum of both, and the name becomes `"LHS + RHS"`.

```swift
let combined = BasicTemplate() + AdvancedTemplate()
combined.level  // .advanced (max of .basic and .advanced)
combined.name   // "Basic + Advanced"
combined.requiredChannelTags
// Union of BasicTemplate and AdvancedTemplate required channel tags
```

### Fluent Builder

Five fluent methods let you incrementally customize any template:

```swift
let template = StandardTemplate()
    .requiring(.podcastTranscript, .podcastPerson)
    .recommending(.podcastValue)
    .requiringItems(.podcastTranscript)
    .recommendingItems(.podcastSoundbite)
    .targeting(.universal)
    .named("Network Standard v2")
```

| Method | Effect |
|--------|--------|
| `.requiring(_:)` | Add required channel tags |
| `.recommending(_:)` | Add recommended channel tags |
| `.requiringItems(_:)` | Add required item tags |
| `.recommendingItems(_:)` | Add recommended item tags |
| `.targeting(_:)` | Override the platform preset |
| `.named(_:)` | Override the template name |

The `.targeting(_:)` method accepts either a ``PlatformPreset`` or individual ``ValidationPlatform`` values:

```swift
// Using a named preset
let a = StandardTemplate().targeting(.universal)

// Using individual platforms
let b = StandardTemplate().targeting(.apple, .spotify, .podcastIndex)
```

### Real-World Example

Here is a custom network template that starts from the standard level, adds transcript and person requirements, targets universal distribution, and passes validation:

```swift
let networkTemplate = StandardTemplate()
    .requiring(.podcastTranscript, .podcastPerson)
    .recommending(.podcastValue)
    .requiringItems(.podcastTranscript)
    .recommendingItems(.podcastSoundbite)
    .targeting(.universal)
    .named("Network Standard v2")

// Validate a feed against the custom template
let validator = TemplateValidator()
let report = validator.validate(feed, against: networkTemplate)
```

You can also build a ``ComposedTemplate`` directly for full control:

```swift
let custom = ComposedTemplate(
    name: "Custom",
    level: .standard,
    platformPreset: .apple,
    requiredChannelTags: [.title, .description],
    recommendedChannelTags: [.language],
    requiredItemTags: [.itemTitle],
    recommendedItemTags: [.itemGuid],
    namespaces: [.itunes]
)
```

``ComposedTemplate`` is `Hashable`, so composed templates can be compared for equality and stored in sets.

## Topics

### Expertise Levels
- ``ExpertiseLevel``

### Template Protocol and Concrete Types
- ``FeedTemplate``
- ``BasicTemplate``
- ``StandardTemplate``
- ``AdvancedTemplate``
- ``ExpertTemplate``
- ``ComposedTemplate``

### Tags
- ``FeedTag``

### Platform Presets
- ``PlatformPreset``
- ``ValidationPlatform``

### Validation
- ``TemplateValidator``
- ``TemplateValidationReport``
- ``TemplateValidationResult``

## See Also

- <doc:BuilderDSL>
