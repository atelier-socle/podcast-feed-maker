import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Integration Tests

@Suite("Integration Tests")
struct IntegrationTests {

    private let engine = PodcastFeedEngine()

    // MARK: - Fixture Loading

    private func loadFixture(_ name: String) throws -> String {
        guard
            let url = Bundle.module.url(
                forResource: name, withExtension: "xml",
                subdirectory: "Fixtures"
            )
        else {
            throw ParserError.encodingError("Fixture \(name).xml not found in bundle")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    // MARK: - Apple Sample

    @Test("Apple sample parses with all key fields")
    func appleParses() throws {
        let xml = try loadFixture("apple-sample")
        let feed = try engine.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Apple Sample Podcast")
        #expect(channel.itunesAuthor == "Apple Sample Host")
        #expect(channel.itunesExplicit == false)
        #expect(channel.itunesCategories.count == 2)
        #expect(channel.itunesImage != nil)
        #expect(channel.itunesOwner?.name == "Apple Sample Host")
        #expect(channel.itunesType == .episodic)
        #expect(channel.items.count == 3)

        let ep3 = channel.items[0]
        #expect(ep3.title == "Episode 3: The Future of AI")
        #expect(ep3.itunesDuration == 2400)
        #expect(ep3.enclosure?.type == "audio/mpeg")
        #expect(ep3.guid?.value == "apple-ep-003")
    }

    @Test("Apple sample round-trips")
    func appleRoundTrip() throws {
        let xml = try loadFixture("apple-sample")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)
        #expect(feed1.channel?.itunesCategories == feed2.channel?.itunesCategories)
    }

    @Test("Apple sample passes Apple validation")
    func appleValidation() throws {
        let xml = try loadFixture("apple-sample")
        let feed = try engine.parse(xml)
        let report = engine.validate(feed, for: .apple)
        #expect(report.isValid)
    }

    // MARK: - Spotify Sample

    @Test("Spotify sample parses with MP3 enclosures")
    func spotifyParses() throws {
        let xml = try loadFixture("spotify-sample")
        let feed = try engine.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Spotify Sample Podcast")
        #expect(channel.items.count == 2)

        for item in channel.items {
            #expect(item.enclosure?.type == "audio/mpeg")
        }

        let ep1 = channel.items[0]
        #expect(ep1.podloveChapters != nil)
        #expect(ep1.podloveChapters?.chapters.count == 5)
    }

    @Test("Spotify sample round-trips")
    func spotifyRoundTrip() throws {
        let xml = try loadFixture("spotify-sample")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)
        #expect(
            feed1.channel?.items[0].podloveChapters?.chapters.count
                == feed2.channel?.items[0].podloveChapters?.chapters.count
        )
    }

    @Test("Spotify sample passes Spotify validation")
    func spotifyValidation() throws {
        let xml = try loadFixture("spotify-sample")
        let feed = try engine.parse(xml)
        let report = engine.validate(feed, for: .spotify)
        #expect(report.isValid)
    }

    // MARK: - Podcast Index Sample

    @Test("Podcast Index sample parses all NS 2.0 tags")
    func podcastIndexParses() throws {
        let xml = try loadFixture("podcast-index-sample")
        let feed = try engine.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.locked?.isLocked == true)
        #expect(channel.podcastGuid?.value == "11111111-2222-3333-4444-555555555555")
        #expect(channel.funding.count == 1)
        #expect(channel.medium == .podcast)
        #expect(channel.txtRecords.count == 2)
        #expect(channel.txtRecords.contains { $0.purpose == "verify" })
        #expect(channel.value?.type == "lightning")
        #expect(channel.value?.recipients.count == 2)

        let totalSplit = channel.value?.recipients.reduce(0) { $0 + $1.split } ?? 0
        #expect(totalSplit == 100)

        #expect(channel.persons.count == 1)
        #expect(channel.location?.name == "New York")
        #expect(channel.license?.identifier == "cc-by-4.0")
        #expect(channel.podroll != nil)
        #expect(channel.updateFrequency != nil)
        #expect(channel.podpingEnabled == true)
        #expect(channel.publisher?.name == "Example Network")

        let ep1 = channel.items[0]
        #expect(!ep1.transcripts.isEmpty)
        #expect(ep1.chaptersLink != nil)
        #expect(!ep1.soundbites.isEmpty)
        #expect(ep1.persons.count == 2)
        #expect(!ep1.alternateEnclosures.isEmpty)
        #expect(ep1.value != nil)
        #expect(!ep1.socialInteractions.isEmpty)
    }

    @Test("Podcast Index sample round-trips")
    func podcastIndexRoundTrip() throws {
        let xml = try loadFixture("podcast-index-sample")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.locked == feed2.channel?.locked)
        #expect(feed1.channel?.podcastGuid == feed2.channel?.podcastGuid)
        #expect(feed1.channel?.value == feed2.channel?.value)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)
    }

    @Test("Podcast Index sample passes Podcast Index validation")
    func podcastIndexValidation() throws {
        let xml = try loadFixture("podcast-index-sample")
        let feed = try engine.parse(xml)
        let report = engine.validate(feed, for: .podcastIndex)
        #expect(report.isValid)
    }

    // MARK: - PSP-1 Compliant

    @Test("PSP-1 sample parses with required fields")
    func psp1Parses() throws {
        let xml = try loadFixture("psp1-compliant")
        let feed = try engine.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.atomLinks.contains { $0.rel == "self" })
        #expect(channel.locked?.isLocked == true)
        #expect(channel.podcastGuid != nil)
        #expect(channel.itunesImage != nil)
        #expect(channel.items.count == 2)
    }

    @Test("PSP-1 sample round-trips")
    func psp1RoundTrip() throws {
        let xml = try loadFixture("psp1-compliant")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.locked == feed2.channel?.locked)
        #expect(feed1.channel?.podcastGuid == feed2.channel?.podcastGuid)
    }

    @Test("PSP-1 sample passes PSP-1 validation")
    func psp1Validation() throws {
        let xml = try loadFixture("psp1-compliant")
        let feed = try engine.parse(xml)
        let report = engine.validate(feed, for: .psp1)
        #expect(report.isValid)
    }

    // MARK: - Amazon Sample

    @Test("Amazon sample parses with M4A enclosures")
    func amazonParses() throws {
        let xml = try loadFixture("amazon-sample")
        let feed = try engine.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Amazon Sample Podcast")
        #expect(channel.items.count == 2)

        for item in channel.items {
            #expect(item.enclosure?.type == "audio/x-m4a")
        }
    }

    @Test("Amazon sample round-trips")
    func amazonRoundTrip() throws {
        let xml = try loadFixture("amazon-sample")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)
    }

    @Test("Amazon sample passes Amazon validation")
    func amazonValidation() throws {
        let xml = try loadFixture("amazon-sample")
        let feed = try engine.parse(xml)
        let report = engine.validate(feed, for: .amazon)
        #expect(report.isValid)
    }

    // MARK: - Podlove Chapters

    @Test("Podlove chapters sample parses NPT formats")
    func podloveChaptersParses() throws {
        let xml = try loadFixture("podlove-chapters")
        let feed = try engine.parse(xml)
        let channel = try #require(feed.channel)

        #expect(channel.title == "Podlove Chapters Demo")
        #expect(channel.language == "de")
        #expect(channel.items.count == 2)

        let ep1 = channel.items[0]
        let chapters = try #require(ep1.podloveChapters)
        #expect(chapters.version == "1.2")
        #expect(chapters.chapters.count == 6)

        // Check various NPT formats were parsed
        #expect(chapters.chapters[0].start == "00:00:00.000")
        #expect(chapters.chapters[0].title == "Intro")
        #expect(chapters.chapters[0].href != nil)
        #expect(chapters.chapters[0].image != nil)

        #expect(chapters.chapters[1].start == "00:02:30")
        #expect(chapters.chapters[5].start == "1:00:00")

        let ep2 = channel.items[1]
        #expect(ep2.podloveChapters?.chapters.count == 3)
    }

    @Test("Podlove chapters sample round-trips")
    func podloveRoundTrip() throws {
        let xml = try loadFixture("podlove-chapters")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(
            feed1.channel?.items[0].podloveChapters?.chapters.count
                == feed2.channel?.items[0].podloveChapters?.chapters.count
        )
        #expect(
            feed1.channel?.items[0].podloveChapters?.chapters[0].title
                == feed2.channel?.items[0].podloveChapters?.chapters[0].title
        )
    }

    // MARK: - Existing Fixtures

    @Test("Minimal fixture round-trips")
    func minimalRoundTrip() throws {
        let xml = try loadFixture("minimal")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.description == feed2.channel?.description)
    }

    @Test("Maximal fixture round-trips")
    func maximalRoundTrip() throws {
        let xml = try loadFixture("maximal")
        let feed1 = try engine.parse(xml)
        let regenerated = try engine.generate(feed1)
        let feed2 = try engine.parse(regenerated)

        #expect(feed1.channel?.title == feed2.channel?.title)
        #expect(feed1.channel?.items.count == feed2.channel?.items.count)
        #expect(feed1.channel?.locked == feed2.channel?.locked)
        #expect(feed1.channel?.value == feed2.channel?.value)
    }

    @Test("Malformed fixture parses gracefully")
    func malformedHandled() throws {
        let xml = try loadFixture("malformed")
        // Should not crash — may return partial result or throw
        do {
            let feed = try engine.parse(xml)
            // If parsing succeeds, it should still have some data
            _ = feed
        } catch {
            // Throwing is also acceptable for malformed input
            #expect(error is ParserError)
        }
    }

    // MARK: - Cross-Platform Validation

    @Test("Apple fixture validates across all 5 platforms")
    func appleCrossPlatform() throws {
        let xml = try loadFixture("apple-sample")
        let feed = try engine.parse(xml)
        let reports = engine.validateAll(feed)

        #expect(reports.count == 5)

        // Apple feed should pass Apple validation
        let appleReport = reports.first { $0.platform == .apple }
        #expect(appleReport?.isValid == true)
    }

    // MARK: - Full Workflow

    @Test("Parse, modify, validate, generate workflow")
    func fullWorkflow() throws {
        let xml = try loadFixture("apple-sample")
        var feed = try engine.parse(xml)

        // Modify the feed
        feed.channel?.itunesSubtitle = "Updated subtitle via workflow"
        feed.channel?.items[0].itunesDuration = 9999

        // Validate
        let report = engine.validate(feed, for: .apple)
        #expect(report.isValid)

        // Generate
        let output = try engine.generate(feed)
        #expect(output.contains("Updated subtitle via workflow"))

        // Re-parse and verify
        let reparsed = try engine.parse(output)
        #expect(reparsed.channel?.itunesSubtitle == "Updated subtitle via workflow")
        #expect(reparsed.channel?.items[0].itunesDuration == 9999)
    }
}
