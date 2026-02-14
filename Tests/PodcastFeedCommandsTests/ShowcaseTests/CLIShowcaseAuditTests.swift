import ArgumentParser
import Foundation
import PodcastFeedMaker
import Testing

@testable import PodcastFeedCommands

// MARK: - Shared Fixture XML

/// A well-formed podcast feed XML for audit CLI showcase tests.
private let auditFixtureXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0"
         xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
         xmlns:podcast="https://podcastindex.org/namespace/1.0"
         xmlns:atom="http://www.w3.org/2005/Atom"
         xmlns:content="http://purl.org/rss/1.0/modules/content/">
    <channel>
        <title>Audit CLI Podcast</title>
        <link>https://example.com</link>
        <description>A podcast for testing the audit command across all categories.</description>
        <atom:link href="https://example.com/feed.xml" rel="self" type="application/rss+xml"/>
        <language>en</language>
        <copyright>2026 Audit Inc.</copyright>
        <itunes:author>Audit Host</itunes:author>
        <itunes:category text="Technology"/>
        <itunes:explicit>false</itunes:explicit>
        <itunes:image href="https://example.com/artwork.jpg"/>
        <itunes:owner>
            <itunes:name>Audit Host</itunes:name>
            <itunes:email>host@example.com</itunes:email>
        </itunes:owner>
        <itunes:type>episodic</itunes:type>
        <podcast:guid>aabb1122-3344-5566-7788-99aabbccddee</podcast:guid>
        <podcast:locked owner="host@example.com">yes</podcast:locked>
        <podcast:funding url="https://example.com/donate">Support</podcast:funding>
        <podcast:txt>podcasting2.0</podcast:txt>
        <item>
            <title>Episode 1</title>
            <description>The first episode with enough description text to pass the quality check.</description>
            <enclosure url="https://example.com/ep1.mp3" length="50000000" type="audio/mpeg"/>
            <guid isPermaLink="false">ep-001</guid>
            <pubDate>Thu, 01 Jan 2026 12:00:00 +0000</pubDate>
            <itunes:duration>1800</itunes:duration>
            <itunes:explicit>false</itunes:explicit>
            <itunes:image href="https://example.com/ep1-art.jpg"/>
            <content:encoded><![CDATA[<p>Rich content for episode 1.</p>]]></content:encoded>
        </item>
    </channel>
    </rss>
    """

/// A minimal feed that will score low.
private let minimalFixtureXML = """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
    <channel>
        <title>Minimal</title>
        <link>https://example.com</link>
        <description>Short</description>
        <item>
            <title>Ep</title>
            <enclosure url="https://example.com/ep.mp3" length="1024" type="audio/mpeg"/>
        </item>
    </channel>
    </rss>
    """

// MARK: - Helpers

private func writeAuditFixture(suffix: String = "audit") -> String {
    let path = "/tmp/pfm_showcase_audit_\(suffix)_\(UUID()).xml"
    try? auditFixtureXML.write(toFile: path, atomically: true, encoding: .utf8)
    return path
}

private func writeMinimalFixture(suffix: String = "minimal") -> String {
    let path = "/tmp/pfm_showcase_audit_\(suffix)_\(UUID()).xml"
    try? minimalFixtureXML.write(toFile: path, atomically: true, encoding: .utf8)
    return path
}

// MARK: - Audit CLI Showcase

@Suite("CLI Showcase - Audit Command")
struct AuditCLIShowcase {

    @Test("Audit command produces text output by default")
    func textOutput() throws {
        let path = writeAuditFixture(suffix: "text")
        defer { try? FileManager.default.removeItem(atPath: path) }
        var command = try AuditCommand.parse([path])
        try command.run()
    }

    @Test("Audit command produces JSON output with --format json")
    func jsonOutput() throws {
        let path = writeAuditFixture(suffix: "json")
        defer { try? FileManager.default.removeItem(atPath: path) }
        var command = try AuditCommand.parse([path, "--format", "json"])
        try command.run()
    }

    @Test("Audit --min-score fails when score is below threshold")
    func minScoreFail() throws {
        let path = writeMinimalFixture(suffix: "minfail")
        defer { try? FileManager.default.removeItem(atPath: path) }
        var command = try AuditCommand.parse([path, "--min-score", "99"])
        #expect(throws: ExitCode.self) {
            try command.run()
        }
    }

    @Test("Audit --min-score passes when score meets threshold")
    func minScorePass() throws {
        let path = writeAuditFixture(suffix: "minpass")
        defer { try? FileManager.default.removeItem(atPath: path) }
        var command = try AuditCommand.parse([path, "--min-score", "1"])
        try command.run()
    }

    @Test("Audit --compare shows evolution between two feeds")
    func compareFeeds() throws {
        let beforePath = writeMinimalFixture(suffix: "before")
        let afterPath = writeAuditFixture(suffix: "after")
        defer {
            try? FileManager.default.removeItem(atPath: beforePath)
            try? FileManager.default.removeItem(atPath: afterPath)
        }
        var command = try AuditCommand.parse([beforePath, "--compare", afterPath])
        try command.run()
    }

    @Test("Audit --category filters output to a single category")
    func categoryFilter() throws {
        let path = writeAuditFixture(suffix: "catfilter")
        defer { try? FileManager.default.removeItem(atPath: path) }
        var command = try AuditCommand.parse([path, "--category", "metadata"])
        try command.run()
    }
}
