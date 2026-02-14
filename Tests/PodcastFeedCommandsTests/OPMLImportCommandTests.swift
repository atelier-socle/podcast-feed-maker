import ArgumentParser
import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("OPMLImportCommand Tests")
struct OPMLImportCommandTests {

    @Test("Parses input argument and defaults")
    func parsesInput() throws {
        let command = try OPMLImportCommand.parse(["subscriptions.opml"])
        #expect(command.input == "subscriptions.opml")
        #expect(command.format == "list")
        #expect(command.validate == false)
    }

    @Test("Parses format option")
    func parsesFormat() throws {
        let command = try OPMLImportCommand.parse([
            "subs.opml", "-f", "json"
        ])
        #expect(command.format == "json")
    }

    @Test("Parses validate flag")
    func parsesValidate() throws {
        let command = try OPMLImportCommand.parse([
            "subs.opml", "--validate"
        ])
        #expect(command.validate == true)
    }

    @Test("Import with list format")
    func importListFormat() throws {
        let path = "/tmp/pfm_import_list_\(UUID()).opml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let opml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head><title>Test</title></head>
              <body>
                <outline text="Feed" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        try opml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try OPMLImportCommand.parse([path])
        try command.run()
    }

    @Test("Import with JSON format")
    func importJsonFormat() throws {
        let path = "/tmp/pfm_import_json_\(UUID()).opml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let opml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        try opml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try OPMLImportCommand.parse([path, "-f", "json"])
        try command.run()
    }

    @Test("Import with XML format")
    func importXmlFormat() throws {
        let path = "/tmp/pfm_import_xml_\(UUID()).opml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let opml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body>
                <outline text="Feed" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        try opml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try OPMLImportCommand.parse([path, "-f", "xml"])
        try command.run()
    }

    @Test("Import with validation")
    func importWithValidation() throws {
        let path = "/tmp/pfm_import_validate_\(UUID()).opml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let opml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <head><title>Valid</title></head>
              <body>
                <outline text="Feed" type="rss"
                  xmlUrl="https://example.com/feed.xml" />
              </body>
            </opml>
            """
        try opml.write(toFile: path, atomically: true, encoding: .utf8)

        var command = try OPMLImportCommand.parse([path, "--validate"])
        try command.run()
    }

    @Test("Import nonexistent file throws error")
    func importNonexistent() throws {
        #expect(throws: (any Error).self) {
            var command = try OPMLImportCommand.parse(
                ["/tmp/nonexistent_opml_\(UUID()).opml"]
            )
            try command.run()
        }
    }

    @Test("Import with unsupported format throws error")
    func importUnsupportedFormat() throws {
        let path = "/tmp/pfm_import_bad_fmt_\(UUID()).opml"
        defer { try? FileManager.default.removeItem(atPath: path) }

        let opml = """
            <?xml version="1.0" encoding="UTF-8"?>
            <opml version="2.0">
              <body><outline text="Feed" /></body>
            </opml>
            """
        try opml.write(toFile: path, atomically: true, encoding: .utf8)

        #expect(throws: (any Error).self) {
            var command = try OPMLImportCommand.parse([path, "-f", "yaml"])
            try command.run()
        }
    }
}
