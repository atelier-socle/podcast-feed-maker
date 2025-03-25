# Platform Compatibility

This document describes how `PodcastFeedMaker` aligns with podcast feed requirements across major distribution platforms.  
It includes tag expectations, required formats, support status, and limitations.

## 🔗 Spec References

- [Apple Podcasts Requirements](https://podcasters.apple.com/support/823-podcast-requirements)
- [Podcast Namespace 1.0](https://github.com/Podcastindex-org/podcast-namespace/blob/main/docs/1.0.md)
- [PSP-1 Podcast Standards Project](https://github.com/Podcast-Standards-Project/PSP-1-Podcast-RSS-Specification)
- [Google Podcasts RSS Guide](https://support.google.com/podcast-publishers/answer/9889544)
- [Spotify RSS Metadata Guide](https://podcasters.spotify.com/help/article/rss-feed-requirements)

---

## ✅ Legend

| Symbol | Meaning                 |
|--------|-------------------------|
| ✅     | Fully supported         |
| ⚠️     | Partially supported     |
| ❌     | Not supported / Missing |

## 🎯 Target Platforms

| Platform         | RSS Spec | iTunes NS | Podcast NS | Atom | Supported | Required Docs |
|------------------|----------|-----------|------------|------|-----------|----------------|
| Apple Podcasts   | ✅ RSS 2.0 | ✅ Yes     | ✅ Partial  | ✅   | ✅ Yes     | [Apple Spec](https://help.apple.com/itc/podcasts_connect/#/itcb54353390) |
| Spotify          | ✅ RSS 2.0 | ✅ Partial | ✅ Partial  | ❌   | ✅ Yes     | [Spotify Spec](https://podcasters.spotify.com/resources/specifications) |
| Amazon Music     | ✅ RSS 2.0 | ✅ Partial | ❌          | ❌   | ✅ Yes     | [Amazon Spec](https://music.amazon.com/podcasts) |
| Google Podcasts  | ✅ RSS 2.0 | ✅ Partial | ❌          | ✅   | ⚠️ Retired | [Google Archive](https://support.google.com/podcast-publishers/answer/9471433?hl=en) |
| Deezer           | ✅ RSS 2.0 | ✅ Yes     | ❌          | ❌   | ✅ Yes     | [Deezer Spec](https://support.deezer.com/hc/en-gb/articles/4409286935697) |
| Pocket Casts     | ✅ RSS 2.0 | ✅ Yes     | ✅ Partial  | ✅   | ✅ Yes     | [Pocket Casts](https://www.pocketcasts.com/submit/) |

## ✅ Fully Supported Tags

PodcastFeedMaker supports all required tags for:
- Apple Podcasts
- PSP-1 Standard
- Podcast Namespace (most common tags)

### Atom Namespace
- `<atom:link>` (required by PSP-1)

### iTunes Namespace
- `<itunes:author>`, `<itunes:image>`, `<itunes:explicit>`, `<itunes:owner>`, `<itunes:type>`, `<itunes:summary>`, `<itunes:category>`, etc.

### Podcast Namespace
- `<podcast:guid>`, `<podcast:locked>`, `<podcast:chapters>`, `<podcast:funding>`, `<podcast:license>`, `<podcast:transcript>`, `<podcast:location>`, `<podcast:soundbite>`, `<podcast:txt>`

## 🧪 Known Limitations

- Podlove Simple Chapters (PSC) is declared but not implemented.
- Full implementation of `<podcast:person>`, `<podcast:medium>`, `<podcast:trailer>` is under consideration.
- `<itunes:block>` and `<itunes:complete>` may be ignored by some platforms.

## 📍 Roadmap

Planned enhancements:

- Add macros to generate `xmlRepresentation` automatically
- Add full PSC and extended Podcast Namespace support
- Add feed-level i18n support
- Auto-validation script for common validators (Apple, podba.se)
- Support for <podcast:person>, <podcast:location>, etc.

---

Made with ❤️ for professional podcast developers.
