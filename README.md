# 🎙️ PodcastFeedMaker

![Swift Build](https://github.com/atelier-socle/podcast-feed-maker/actions/workflows/swift.yml/badge.svg) [![codecov](https://codecov.io/github/atelier-socle/podcast-feed-maker/branch/main/graph/badge.svg?token=FRZW6DGEP9)](https://codecov.io/github/atelier-socle/podcast-feed-maker)

**PodcastFeedMaker** is a Swift package designed to generate podcast RSS feeds in XML format. It follows the specifications of:

- [RSS 2.0](https://cyber.harvard.edu/rss/rss.html)
- [Apple Podcasts](https://help.apple.com/itc/podcasts_connect/)
- [Podcast Namespace](https://github.com/Podcastindex-org/podcast-namespace)

---

## 🚀 Overview

This library enables the structured generation of podcast feeds using Swift types. It includes models for core podcast components and extensions from iTunes and the Podcast Namespace.

### Key Components

- `Feed`: Root model representing the entire podcast feed.
- `Channel`: Represents the main container for feed metadata (title, link, description, etc.).
- `Item`: Represents a single podcast episode with media enclosures and tags.
- `Namespace`: Defines and injects XML namespaces (like `itunes`, `podcast`, `atom`, etc.).

---

## 📦 Installation

Use Swift Package Manager by adding the dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/atelier-socle/podcast-feed-maker.git", from: "0.0.1")
```

Then import where needed:

```swift
import PodcastFeedMaker
```

---

## 💡 Usage Example

```swift
let channel = Channel(
    title: "Swift Coding Podcast",
    link: URL(string: "https://swiftcoders.fm")!,
    description: "All about Swift development"
)

let item = Item(
    title: "Episode 1: Hello Feed!",
    enclosureURL: URL(string: "https://swiftcoders.fm/ep1.mp3")!,
    pubDate: Date(),
    guid: "ep1"
)

let feed = Feed(channel: channel, items: [item])
let maker = PodcastFeedMaker(feed)

do {
    let xml = try maker.xmlRepresentation()
    print(xml)
} catch {
    print("Failed to generate XML: \(error)")
}
```

---

## 🧰 Features

- Strongly typed XML feed generation.
- Supports iTunes podcast tags (author, summary, episode type, etc.).
- Podcastindex.org namespace support (transcripts, chapters, locked, etc.).
- Tag validation (RFC dates, URLs, escaped strings, booleans).
- Easily extendable via Swift’s `protocol` system.

---

## 🧑‍💻 Contributing

PodcastFeedMaker is open-source and contributions are **highly welcome**.

To contribute:

1. Fork the repository.
2. Create a new branch.
3. Submit a pull request.

The project is released under the **Apache License 2.0**.

---

## 📚 References

- [RSS 2.0 Spec](https://cyber.harvard.edu/rss/rss.html)
- [Apple Podcasts Spec](https://help.apple.com/itc/podcasts_connect/)
- [Podcast Namespace](https://github.com/Podcastindex-org/podcast-namespace)
