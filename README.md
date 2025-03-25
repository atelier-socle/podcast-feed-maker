# 🎙️ PodcastFeedMaker

[![Swift Build](https://github.com/atelier-socle/podcast-feed-maker/actions/workflows/swift.yml/badge.svg)](https://github.com/atelier-socle/podcast-feed-maker/actions/workflows/swift.yml)
[![Sanity Check](https://github.com/atelier-socle/podcast-feed-maker/actions/workflows/sanity-check.yml/badge.svg)](https://github.com/atelier-socle/podcast-feed-maker/actions/workflows/sanity-check.yml)
[![codecov](https://codecov.io/github/atelier-socle/podcast-feed-maker/branch/main/graph/badge.svg?token=FRZW6DGEP9)](https://codecov.io/github/atelier-socle/podcast-feed-maker)
[![License: Apache 2.0](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

**PodcastFeedMaker** is a Swift package for generating RSS 2.0 podcast feeds. It supports specifications including Apple Podcasts, Podcast Namespace, and the Podcast Standards Project (PSP-1). It’s fully test-covered and compliant with leading podcast validators like [podba.se/validate](https://podba.se/validate). It follows the specifications of:

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

## 🚀 Features

- 🔧 Generate RSS 2.0 compliant feeds
- 🎙 Supports Apple Podcasts tags (iTunes namespace)
- 🌐 Includes Podcast Namespace (podcastindex.org)
- ✅ Fully PSP-1 compliant feed structure
- 👀 Tag validation (RFC dates, URLs, escaped strings, booleans).
- 📄 Validated by podba.se, CastFeedValidator, and others
- 💡 Uses modern Swift features (Swift 6-ready)
- 🔍 Code coverage > 95%
- 📦 Open extensibility via `[any XmlRepresentable]`
- 🧪 Full test suite using the new `@Test` API


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

## 📘 Documentation

- **DocC Catalog** auto-generated and hosted at [https://atelier-socle.github.io/podcast-feed-maker](https://atelier-socle.github.io/podcast-feed-maker)
- Developer documentation available via Xcode (⌥ + Click)
- Namespace & tag-level documentation fully included

---

## ✨ Examples

See [`Examples.md`](docs/Examples.md) for:
- ✅ Minimum compliant feed
- 🎯 Recommended PSP-1 feed
- 🛠 Complex feed with advanced tags

---

## 🧩 Tags Coverage

| Namespace | Required | Optional | Fully Supported |
|----------|----------|----------|------------------|
| RSS      | ✅        | ✅        | ✅               |
| Atom     | ✅        | ✅        | ✅               |
| iTunes   | ✅        | ✅        | ✅               |
| Podcast  | ✅        | ✅        | ✅               |
| PSC      | ❌        | ✅        | ⚠️ Planned       |

---

## 📊 Platform Support

See [`PlatformCompatibility.md`](docs/PlatformCompatibility.md) for a detailed matrix.

---

## 🧑‍💻 Contributing

PodcastFeedMaker is open-source and contributions are **highly welcome**.

To contribute:

1. Fork the repository.
2. Create a new branch.
3. Submit a pull request.

### ✅ Contribution Standards

- Use clear commit messages (feat:, fix:, chore:)
- Run all tests before PR
- Follow existing code formatting and naming
- PRs should include/update unit tests
- All public APIs must include DocC comments

### 🧪 GitHub Actions

- `swift.yml` → Build + Test + Code Coverage
- `sanity-check.yml` → Link validation, DocC generation
- `release.yml` → Creates GitHub release from semver tag
- `docc-deploy.yml` → Auto-publishes documentation on GitHub Pages

---

## 🧠 Roadmap

- [x] Full coverage of RSS + Apple + Podcast Namespace
- [x] GitHub Pages deploy for DocC
- [x] Code Coverage + CI
- [ ] Swift Macros to autogenerate `xmlRepresentation`
- [ ] Support for Podlove Simple Chapters (PSC)
- [ ] CLI tool for validating feeds
- [ ] Support for importing existing feeds

---

## 📚 References

- [RSS 2.0 Spec](https://cyber.harvard.edu/rss/rss.html)
- [Apple Podcasts Spec](https://help.apple.com/itc/podcasts_connect/)
- [Podcast Namespace](https://github.com/Podcastindex-org/podcast-namespace)

---

## 📄 License

This project is released under the [Apache License 2.0](LICENSE).  
It is free to use, distribute, and modify — whether personally or commercially.
