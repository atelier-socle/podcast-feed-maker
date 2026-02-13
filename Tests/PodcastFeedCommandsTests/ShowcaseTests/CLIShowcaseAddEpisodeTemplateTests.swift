import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// MARK: - Shared Fixture XML

/// A well-formed podcast feed XML used across all CLI showcase tests.
/// Includes RSS 2.0, iTunes, Podcast NS 2.0, Atom, and Podlove Simple Chapters
/// namespaces to exercise the full CLI surface.
private let fixtureXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"
         xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
         xmlns:podcast="https://podcastindex.org/namespace/1.0"
         xmlns:atom="http://www.w3.org/2005/Atom"
         xmlns:psc="http://podlove.org/simple-chapters"
         xmlns:content="http://purl.org/rss/1.0/modules/content/"
         xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>CLI Showcase Podcast</title>
        <link>https://example.com</link>
        <description>A podcast for testing every CLI command.</description>
        <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        <language>en</language>
        <copyright>2026 Showcase Inc.</copyright>
        <itunes:author>Showcase Host</itunes:author>
        <itunes:category text="Technology"/>
        <itunes:explicit>false</itunes:explicit>
        <itunes:image href="https://example.com/artwork.jpg"/>
        <itunes:owner>
            <itunes:name>Showcase Host</itunes:name>
            <itunes:email>host@example.com</itunes:email>
        </itunes:owner>
        <itunes:type>episodic</itunes:type>
        <podcast:guid>aabb1122-3344-5566-7788-99aabbccddee</podcast:guid>
        <podcast:locked owner="host@example.com">yes</podcast:locked>
        <podcast:funding url="https://example.com/donate">Support the show</podcast:funding>
        <item>
            <title>Episode 1 — Pilot</title>
            <description>The first episode of the showcase podcast.</description>
            <enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
            <guid isPermaLink="false">ep-001</guid>
            <pubDate>Thu, 01 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>1800</itunes:duration>
            <itunes:episode>1</itunes:episode>
            <itunes:season>1</itunes:season>
            <itunes:episodeType>full</itunes:episodeType>
            <itunes:explicit>false</itunes:explicit>
            <psc:chapters version="1.2">
                <psc:chapter start="00:00:00.000" title="Introduction"/>
                <psc:chapter start="00:05:00.000" title="Main Topic"/>
                <psc:chapter start="00:25:00.000" title="Wrap Up"/>
            </psc:chapters>
            <content:encoded><![CDATA[<p>Rich <strong>HTML</strong> content for episode 1.</p>]]></content:encoded>
        </item>
        <item>
            <title>Episode 2 — Deep Dive</title>
            <description>A deeper exploration of the topic.</description>
            <enclosure url="https://example.com/ep2.mp3" length="60000000" type="audio/mpeg"/>
            <guid isPermaLink="false">ep-002</guid>
            <pubDate>Thu, 08 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>2400</itunes:duration>
            <itunes:episode>2</itunes:episode>
            <itunes:season>1</itunes:season>
            <itunes:episodeType>full</itunes:episodeType>
            <itunes:explicit>false</itunes:explicit>
        </item>
        <item>
            <title>Bonus — Behind the Scenes</title>
            <description>A bonus episode.</description>
            <enclosure url="https://example.com/bonus.mp3" length="20000000" type="audio/mpeg"/>
            <guid isPermaLink="false">bonus-001</guid>
            <pubDate>Thu, 15 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>600</itunes:duration>
            <itunes:episodeType>bonus</itunes:episodeType>
            <itunes:explicit>false</itunes:explicit>
        </item>
    </channel>
    </rss>
    """

// MARK: - Helpers

/// Writes the fixture XML to a temporary file and returns the path.
/// Caller is responsible for cleanup via `defer`.
private func writeFixture(suffix: String = "") -> String {
    let path = "/tmp/pfm_showcase_\(suffix)_\(UUID()).xml"
    try? fixtureXML.write(toFile: path, atomically: true, encoding: .utf8)
    return path
}

// MARK: - Add-Episode Command Showcase

@Suite("CLI Showcase — add-episode Command")
struct AddEpisodeCommandShowcaseTests {

    @Test("Parses required options")
    func parsesRequired() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "New Episode",
            "--audio", "https://example.com/new.mp3",
            "--output", "updated.xml"
        ])
        #expect(command.feed == "feed.xml")
        #expect(command.title == "New Episode")
        #expect(command.audio == "https://example.com/new.mp3")
        #expect(command.output == "updated.xml")
        #expect(command.type == "audio/mpeg")
        #expect(command.explicit == false)
    }

    @Test("Parses all optional fields")
    func parsesAllOptional() throws {
        let command = try AddEpisodeCommand.parse([
            "feed.xml",
            "--title", "Full Options",
            "--audio", "https://example.com/full.mp3",
            "--output", "out.xml",
            "--length", "75000000",
            "--duration", "3600",
            "--description", "A fully specified episode",
            "--guid", "custom-guid-abc",
            "--pub-date", "Thu, 13 Feb 2026 12:00:00 +0000",
            "--type", "audio/m4a",
            "--explicit"
        ])
        #expect(command.length == 75_000_000)
        #expect(command.duration == 3600)
        #expect(command.description == "A fully specified episode")
        #expect(command.guid == "custom-guid-abc")
        #expect(command.pubDate == "Thu, 13 Feb 2026 12:00:00 +0000")
        #expect(command.type == "audio/m4a")
        #expect(command.explicit == true)
    }

    @Test("Add episode to existing feed creates updated file")
    func addEpisodeToExistingFeed() throws {
        let feedPath = writeFixture(suffix: "add_ep_feed")
        let outputPath = "/tmp/pfm_showcase_add_ep_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Episode 4 — Added by CLI",
            "--audio", "https://example.com/ep4.mp3",
            "--length", "55000000",
            "--duration", "2100",
            "--description", "An episode added via the CLI.",
            "--guid", "ep-004-cli",
            "--output", outputPath
        ])
        try command.run()

        // Verify the output
        let xml = try String(contentsOfFile: outputPath, encoding: .utf8)
        let feed = try FeedParser().parse(xml)
        let channel = try #require(feed.channel)

        // New episode should be first (newest)
        #expect(channel.items.count == 4, "Should have 3 original + 1 new episode")
        #expect(channel.items[0].title == "Episode 4 — Added by CLI")
        #expect(channel.items[0].guid?.value == "ep-004-cli")
        #expect(channel.items[0].itunesDuration == 2100)
        #expect(channel.items[0].enclosure?.length == 55_000_000)
        #expect(channel.items[0].description == "An episode added via the CLI.")
    }

    @Test("Add episode with --explicit marks episode as explicit")
    func addExplicitEpisode() throws {
        let feedPath = writeFixture(suffix: "add_ep_explicit")
        let outputPath = "/tmp/pfm_showcase_add_ep_explicit_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Explicit Episode",
            "--audio", "https://example.com/explicit.mp3",
            "--output", outputPath,
            "--explicit"
        ])
        try command.run()

        let feed = try FeedParser().parse(try String(contentsOfFile: outputPath, encoding: .utf8))
        let newItem = try #require(feed.channel?.items.first)
        #expect(newItem.itunesExplicit == true)
    }

    @Test("Add episode with invalid audio URL throws error")
    func addEpisodeInvalidAudioURL() throws {
        let feedPath = writeFixture(suffix: "add_ep_bad_url")
        let outputPath = "/tmp/pfm_showcase_add_ep_bad_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        #expect(throws: (any Error).self) {
            var command = try AddEpisodeCommand.parse([
                feedPath,
                "--title", "Bad URL Episode",
                "--audio", "",
                "--output", outputPath
            ])
            try command.run()
        }
    }

    @Test("Add episode auto-generates GUID when not specified")
    func addEpisodeAutoGUID() throws {
        let feedPath = writeFixture(suffix: "add_ep_auto_guid")
        let outputPath = "/tmp/pfm_showcase_add_ep_auto_guid_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Auto GUID Episode",
            "--audio", "https://example.com/auto.mp3",
            "--output", outputPath
        ])
        try command.run()

        let feed = try FeedParser().parse(try String(contentsOfFile: outputPath, encoding: .utf8))
        let newItem = try #require(feed.channel?.items.first)
        #expect(newItem.guid != nil, "GUID should be auto-generated")
        #expect(newItem.guid?.isPermaLink == false)
    }

    @Test("Add episode updates lastBuildDate on the channel")
    func addEpisodeUpdatesLastBuildDate() throws {
        let feedPath = writeFixture(suffix: "add_ep_build_date")
        let outputPath = "/tmp/pfm_showcase_add_ep_build_date_out_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: feedPath)
            try? FileManager.default.removeItem(atPath: outputPath)
        }

        var command = try AddEpisodeCommand.parse([
            feedPath,
            "--title", "Build Date Episode",
            "--audio", "https://example.com/build.mp3",
            "--output", outputPath
        ])
        try command.run()

        let feed = try FeedParser().parse(try String(contentsOfFile: outputPath, encoding: .utf8))
        #expect(feed.channel?.lastBuildDate != nil, "lastBuildDate should be set")
    }
}

// MARK: - TemplateName Showcase

@Suite("CLI Showcase — TemplateName")
struct TemplateNameShowcaseTests {

    @Test("TemplateName resolves all four levels")
    func resolvesAllLevels() {
        for name in TemplateName.allCases {
            let template = name.resolve()
            _ = template.level
        }
    }

    @Test("TemplateName resolves with platform overrides")
    func resolvesWithPlatformOverrides() {
        let template = TemplateName.standard.resolve(platforms: ["apple", "spotify"])
        _ = template.level
    }

    @Test("parsePlatformNames handles all valid platform names")
    func parsePlatformNamesValid() {
        let platforms = TemplateName.parsePlatformNames([
            "apple", "spotify", "amazon", "podcastindex", "psp1"
        ])
        #expect(platforms.contains(.apple))
        #expect(platforms.contains(.spotify))
        #expect(platforms.contains(.amazon))
        #expect(platforms.contains(.podcastIndex))
        #expect(platforms.contains(.psp1))
    }

    @Test("parsePlatformNames handles 'all' keyword")
    func parsePlatformNamesAll() {
        let platforms = TemplateName.parsePlatformNames(["all"])
        #expect(platforms == Set(ValidationPlatform.allCases))
    }

    @Test("parsePlatformNames handles alternate casing and hyphens")
    func parsePlatformNamesAlternate() {
        let platforms = TemplateName.parsePlatformNames(["podcast-index", "APPLE"])
        #expect(platforms.contains(.podcastIndex))
        #expect(platforms.contains(.apple))
    }

    @Test("parsePlatformNames ignores unknown names")
    func parsePlatformNamesUnknown() {
        let platforms = TemplateName.parsePlatformNames(["unknown", "invalid"])
        #expect(platforms.isEmpty)
    }
}
