import ArgumentParser
import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("AuditCommand Tests")
struct AuditCommandTests {

    @Test("Parses source argument")
    func parsesSource() throws {
        let command = try AuditCommand.parse(["feed.xml"])
        #expect(command.source == "feed.xml")
        #expect(command.format == "text")
        #expect(command.minScore == nil)
        #expect(command.compare == nil)
        #expect(command.category == nil)
        #expect(command.noColor == false)
    }

    @Test("Parses JSON format option")
    func parsesJSONFormat() throws {
        let command = try AuditCommand.parse(["feed.xml", "--format", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses short format option")
    func parsesShortFormat() throws {
        let command = try AuditCommand.parse(["feed.xml", "-f", "json"])
        #expect(command.format == "json")
    }

    @Test("Parses min-score option")
    func parsesMinScore() throws {
        let command = try AuditCommand.parse(["feed.xml", "--min-score", "80"])
        #expect(command.minScore == 80)
    }

    @Test("Parses compare option")
    func parsesCompare() throws {
        let command = try AuditCommand.parse(["feed.xml", "--compare", "other.xml"])
        #expect(command.compare == "other.xml")
    }

    @Test("Parses category option")
    func parsesCategory() throws {
        let command = try AuditCommand.parse(["feed.xml", "--category", "compliance"])
        #expect(command.category == "compliance")
    }

    @Test("Parses no-color flag")
    func parsesNoColor() throws {
        let command = try AuditCommand.parse(["feed.xml", "--no-color"])
        #expect(command.noColor == true)
    }

    @Test("Parses all options together")
    func parsesAllOptions() throws {
        let command = try AuditCommand.parse([
            "feed.xml", "-f", "json", "--min-score", "75",
            "--compare", "new.xml", "--category", "metadata", "--no-color"
        ])
        #expect(command.source == "feed.xml")
        #expect(command.format == "json")
        #expect(command.minScore == 75)
        #expect(command.compare == "new.xml")
        #expect(command.category == "metadata")
        #expect(command.noColor == true)
    }

    // MARK: - Execution Tests

    @Test("Audit text output succeeds with valid feed")
    func auditTextSucceeds() throws {
        let path = "/tmp/pfm_audit_text_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Test Podcast</title>
                <link>https://example.com</link>
                <description>A test podcast for auditing.</description>
                <item>
                    <title>Episode 1</title>
                    <enclosure url="https://cdn.example.com/ep1.mp3" type="audio/mpeg" length="1000000"/>
                </item>
            </channel>
            </rss>
            """
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try AuditCommand.parse([path])
        try command.run()
    }

    @Test("Audit JSON output succeeds with valid feed")
    func auditJSONSucceeds() throws {
        let path = "/tmp/pfm_audit_json_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd">
            <channel>
                <title>Test Podcast</title>
                <link>https://example.com</link>
                <description>A test podcast.</description>
                <item>
                    <title>Episode 1</title>
                    <enclosure url="https://cdn.example.com/ep1.mp3" type="audio/mpeg" length="1000000"/>
                </item>
            </channel>
            </rss>
            """
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try AuditCommand.parse([path, "--format", "json"])
        try command.run()
    }

    @Test("Min-score gate fails when score is below threshold")
    func minScoreFailsBelowThreshold() throws {
        let path = "/tmp/pfm_audit_minscore_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        // Minimal feed that will score below 95
        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            <channel>
                <title>Minimal</title>
                <link>https://example.com</link>
                <description>Test</description>
            </channel>
            </rss>
            """
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try AuditCommand.parse([path, "--min-score", "95"])
        #expect(throws: ExitCode.self) {
            try command.run()
        }
    }

    @Test("Comparison mode succeeds with two valid feeds")
    func comparisonSucceeds() throws {
        let path1 = "/tmp/pfm_audit_cmp1_\(UUID()).xml"
        let path2 = "/tmp/pfm_audit_cmp2_\(UUID()).xml"
        defer {
            try? FileManager.default.removeItem(atPath: path1)
            try? FileManager.default.removeItem(atPath: path2)
        }

        let xml1 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            <channel>
                <title>Before</title>
                <link>https://example.com</link>
                <description>Before state</description>
            </channel>
            </rss>
            """
        let xml2 = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
                 xmlns:podcast="https://podcastindex.org/namespace/1.0">
            <channel>
                <title>After</title>
                <link>https://example.com</link>
                <description>After state with more metadata.</description>
                <itunes:author>Host Name</itunes:author>
                <itunes:explicit>false</itunes:explicit>
                <item>
                    <title>Episode 1</title>
                    <enclosure url="https://cdn.example.com/ep1.mp3" type="audio/mpeg" length="5000000"/>
                </item>
            </channel>
            </rss>
            """
        try xml1.write(toFile: path1, atomically: true, encoding: .utf8)
        try xml2.write(toFile: path2, atomically: true, encoding: .utf8)

        var command = try AuditCommand.parse([path1, "--compare", path2])
        try command.run()
    }

    @Test("Nonexistent file throws error")
    func nonexistentFileThrows() throws {
        #expect(throws: (any Error).self) {
            var command = try AuditCommand.parse(
                ["/tmp/nonexistent_audit_\(UUID()).xml"]
            )
            try command.run()
        }
    }

    @Test("Category filter limits output scope")
    func categoryFilterWorks() throws {
        let path = "/tmp/pfm_audit_cat_\(UUID()).xml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let xml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
            <channel>
                <title>Test</title>
                <link>https://example.com</link>
                <description>A test podcast.</description>
            </channel>
            </rss>
            """
        try xml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try AuditCommand.parse([path, "--category", "compliance"])
        try command.run()
    }
}
