import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - PodcastIndexValidationTests

@Suite("Podcast Index Validation Tests")
struct PodcastIndexValidationTests {

    private let validator = FeedValidator()

    // MARK: - Helpers

    private func baseFeed(
        locked: Locked? = Locked(isLocked: false),
        podcastGuid: PodcastGuid? = PodcastGuid(value: "abc-123"),
        funding: [Funding]? = nil,
        medium: PodcastMedium? = .podcast,
        txtRecords: [PodcastTxt] = [PodcastTxt(value: "abc", purpose: "verify")],
        value: PodcastValue? = nil
    ) throws -> PodcastFeed {
        let url = makeURL("https://example.com")
        let resolvedFunding: [Funding]
        if let funding {
            resolvedFunding = funding
        } else {
            let fundURL = makeURL("https://example.com/fund")
            resolvedFunding = [Funding(url: fundURL, message: "Support us")]
        }
        return PodcastFeed(
            channel: Channel(
                title: "Podcast",
                link: url,
                description: "desc",
                podcastGuid: podcastGuid,
                locked: locked,
                funding: resolvedFunding,
                value: value,
                medium: medium,
                txtRecords: txtRecords
            ))
    }

    // MARK: - Clean Feed

    @Test("Feed with all podcast namespace tags is clean")
    func cleanFeed() throws {
        let feed = try baseFeed()
        let report = validator.validate(feed, for: .podcastIndex)
        let warnings = report.warnings.filter {
            $0.platform == .podcastIndex
        }
        let errors = report.errors.filter { $0.platform == .podcastIndex }
        #expect(errors.isEmpty)
        #expect(warnings.isEmpty)
    }

    // MARK: - Missing Tags

    @Test("Missing podcast:locked is warning")
    func missingLocked() throws {
        let feed = try baseFeed(locked: nil)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.warnings.contains { $0.field == "channel.locked" })
    }

    @Test("Missing podcast:guid is warning")
    func missingGuid() throws {
        let feed = try baseFeed(podcastGuid: nil)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.podcastGuid"
            })
    }

    @Test("Missing podcast:funding is warning")
    func missingFunding() throws {
        let feed = try baseFeed(funding: [])
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.warnings.contains { $0.field == "channel.funding" })
    }

    @Test("Missing podcast:medium is info")
    func missingMedium() throws {
        let feed = try baseFeed(medium: nil)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.infos.contains { $0.field == "channel.medium" })
    }

    @Test("Missing podcast:txt verify is info")
    func missingTxtVerify() throws {
        let feed = try baseFeed(txtRecords: [])
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.infos.contains { $0.field == "channel.txtRecords" })
    }

    // MARK: - Value (V4V)

    @Test("Value without recipients is warning")
    func valueNoRecipients() throws {
        let value = PodcastValue(type: "lightning", method: "keysend")
        let feed = try baseFeed(value: value)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.value.recipients"
                    && $0.message.contains("valueRecipient")
            })
    }

    @Test("Value with splits not summing to 100 is warning")
    func valueSplitsMismatch() throws {
        var value = PodcastValue(type: "lightning", method: "keysend")
        value.recipients = [
            ValueRecipient(type: "node", address: "abc", split: 60),
            ValueRecipient(type: "node", address: "def", split: 30)
        ]
        let feed = try baseFeed(value: value)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.field == "channel.value.recipients"
                    && $0.message.contains("90")
            })
    }

    @Test("Value with splits summing to 100 passes")
    func valueSplitsCorrect() throws {
        var value = PodcastValue(type: "lightning", method: "keysend")
        value.recipients = [
            ValueRecipient(type: "node", address: "abc", split: 70),
            ValueRecipient(type: "node", address: "def", split: 30)
        ]
        let feed = try baseFeed(value: value)
        let report = validator.validate(feed, for: .podcastIndex)
        let splitWarnings = report.warnings.filter {
            $0.field == "channel.value.recipients"
        }
        #expect(splitWarnings.isEmpty)
    }

    @Test("No value is info (V4V encouraged)")
    func noValueInfo() throws {
        let feed = try baseFeed()
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(report.infos.contains { $0.field == "channel.value" })
    }

    // MARK: - Missing Channel

    @Test("Missing channel is error")
    func missingChannel() {
        let feed = PodcastFeed(channel: nil)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(!report.isValid)
    }

    // MARK: - Cross-Field Validation

    @Test("ValueTimeSplit with empty feedGuid generates warning")
    func timeSplitEmptyFeedGuid() throws {
        var value = PodcastValue(type: "lightning", method: "keysend")
        value.recipients = [
            ValueRecipient(type: "node", address: "abc", split: 100)
        ]
        value.timeSplits = [
            ValueTimeSplit(
                startTime: 0,
                duration: 60,
                remoteItem: RemoteItem(feedGuid: "")
            )
        ]
        let feed = try baseFeed(value: value)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.warnings.contains {
                $0.message.contains("empty feedGuid")
            })
    }

    @Test("Item with alternate enclosures generates info")
    func alternateEnclosuresInfo() {
        let url = makeURL("https://example.com")
        let fundURL = makeURL("https://example.com/fund")
        let item = Item(
            title: "Episode",
            alternateEnclosures: [
                AlternateEnclosure(
                    type: "audio/opus",
                    sources: [PodcastSource(uri: "https://example.com/ep.opus")]
                )
            ]
        )
        let channel = Channel(
            title: "Podcast",
            link: url,
            description: "desc",
            items: [item],
            podcastGuid: PodcastGuid(value: "abc"),
            locked: Locked(isLocked: false),
            funding: [
                Funding(
                    url: fundURL,
                    message: "Support"
                )
            ],
            medium: .podcast,
            txtRecords: [PodcastTxt(value: "abc", purpose: "verify")]
        )
        let feed = PodcastFeed(channel: channel)
        let report = validator.validate(feed, for: .podcastIndex)
        #expect(
            report.infos.contains {
                $0.message.contains("alternate enclosures")
            })
    }
}
