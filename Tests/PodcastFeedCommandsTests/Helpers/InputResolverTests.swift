import Foundation
import Testing

@testable import PodcastFeedCommands

@Suite("InputResolver Tests")
struct InputResolverTests {

    @Test("Resolves HTTPS URL")
    func resolvesHTTPS() throws {
        let result = try InputResolver.resolve("https://example.com/feed.xml")
        if case .url(let url) = result {
            #expect(url.absoluteString == "https://example.com/feed.xml")
        } else {
            Issue.record("Expected .url, got .file")
        }
    }

    @Test("Resolves HTTP URL")
    func resolvesHTTP() throws {
        let result = try InputResolver.resolve("http://example.com/feed.xml")
        if case .url(let url) = result {
            #expect(url.absoluteString == "http://example.com/feed.xml")
        } else {
            Issue.record("Expected .url, got .file")
        }
    }

    @Test("Resolves file path")
    func resolvesFile() throws {
        let result = try InputResolver.resolve("/tmp/feed.xml")
        if case .file(let path) = result {
            #expect(path == "/tmp/feed.xml")
        } else {
            Issue.record("Expected .file, got .url")
        }
    }

    @Test("Resolves relative file path")
    func resolvesRelative() throws {
        let result = try InputResolver.resolve("feed.xml")
        if case .file(let path) = result {
            #expect(path == "feed.xml")
        } else {
            Issue.record("Expected .file, got .url")
        }
    }

    @Test("Trims whitespace from source")
    func trimsWhitespace() throws {
        let result = try InputResolver.resolve("  /tmp/feed.xml  ")
        if case .file(let path) = result {
            #expect(path == "/tmp/feed.xml")
        } else {
            Issue.record("Expected .file, got .url")
        }
    }

    @Test("Resolves file:// URL")
    func resolvesFileURL() throws {
        let result = try InputResolver.resolve("file:///tmp/feed.xml")
        if case .url(let url) = result {
            #expect(url.scheme == "file")
            #expect(url.path == "/tmp/feed.xml")
        } else {
            Issue.record("Expected .url, got .file")
        }
    }

    @Test("InputError descriptions are meaningful")
    func errorDescriptions() {
        let invalidURL = InputError.invalidURL("bad://url")
        #expect(invalidURL.description.contains("Invalid URL"))

        let notFound = InputError.fileNotFound("/missing.xml")
        #expect(notFound.description.contains("File not found"))

        let readError = InputError.fileReadError(
            "/fail.xml",
            NSError(domain: "test", code: -1, userInfo: nil)
        )
        #expect(readError.description.contains("Cannot read file"))
    }
}
