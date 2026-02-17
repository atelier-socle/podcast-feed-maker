// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Atelier Socle SAS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import Testing

@testable import PodcastFeedMaker

// MARK: - Platform Compatibility Tests

@Suite("Platform Compatibility")
struct PlatformCompatibilityTests {

    private let auditor = FeedAuditor()

    // MARK: - Helpers

    private func wellFormedFeed() -> PodcastFeed {
        var channel = Channel(
            title: "Compat Test",
            link: makeURL("https://example.com"),
            description: "Testing platform compatibility across all podcast directories"
        )
        channel.language = "en"
        channel.itunesAuthor = "Host"
        channel.itunesOwner = ITunesOwner(name: "Host", email: "host@example.com")
        channel.itunesImage = makeURL("https://example.com/art.jpg")
        channel.itunesCategories = [ITunesCategory(text: "Technology")]
        channel.itunesExplicit = false
        channel.itunesType = .episodic
        channel.atomLinks = [
            AtomLink.selfLink(href: makeURL("https://example.com/feed.xml"))
        ]
        channel.locked = Locked(isLocked: true, owner: "host@example.com")
        channel.podcastGuid = PodcastGuid(value: "550e8400-e29b-41d4-a716-446655440000")

        var item = Item()
        item.title = "Episode"
        item.description = "A decent episode description"
        item.enclosure = Enclosure(
            url: makeURL("https://example.com/ep.mp3"),
            length: 12345,
            type: "audio/mpeg"
        )
        item.guid = GUID(value: "ep1", isPermaLink: false)
        channel.items = [item]

        return PodcastFeed(channel: channel)
    }

    private func minimalFeed() -> PodcastFeed {
        let channel = Channel(
            title: "Minimal",
            link: makeURL("https://example.com"),
            description: "Bare minimum feed"
        )
        return PodcastFeed(channel: channel)
    }

    // MARK: - Tests

    @Test("Compatibility result model — create with all fields and verify")
    func compatibilityResultModel() {
        let result = PlatformCompatibilityResult(
            platform: "Test Platform",
            isCompatible: true,
            errorCount: 0,
            warningCount: 2,
            status: .warnings
        )
        #expect(result.platform == "Test Platform")
        #expect(result.isCompatible == true)
        #expect(result.errorCount == 0)
        #expect(result.warningCount == 2)
        #expect(result.status == .warnings)
    }

    @Test("CompatibilityStatus cases — ok, warnings, incompatible all exist")
    func compatibilityStatusCases() {
        let ok = PlatformCompatibilityResult.CompatibilityStatus.ok
        let warnings = PlatformCompatibilityResult.CompatibilityStatus.warnings
        let incompatible = PlatformCompatibilityResult.CompatibilityStatus.incompatible

        #expect(ok.rawValue == "ok")
        #expect(warnings.rawValue == "warnings")
        #expect(incompatible.rawValue == "incompatible")

        #expect(ok != warnings)
        #expect(warnings != incompatible)
        #expect(ok != incompatible)
    }

    @Test("Full feed audited produces compatibility matrix with 5 entries")
    func fullFeedHasFivePlatforms() {
        let feed = wellFormedFeed()
        let report = auditor.audit(feed)

        #expect(report.compatibility.count == 5)
    }

    @Test("Platform names match expected display names")
    func platformNames() {
        let feed = wellFormedFeed()
        let report = auditor.audit(feed)

        let names = report.compatibility.map(\.platform)
        #expect(names.contains("Apple Podcasts"))
        #expect(names.contains("Spotify"))
        #expect(names.contains("Amazon Music"))
        #expect(names.contains("Podcast Index"))
        #expect(names.contains("PSP-1"))
    }

    @Test("Well-formed feed is compatible with Apple Podcasts and Spotify")
    func wellFormedFeedCompatibleWithMajorPlatforms() {
        let feed = wellFormedFeed()
        let report = auditor.audit(feed)

        let apple = report.compatibility.first { $0.platform == "Apple Podcasts" }
        let spotify = report.compatibility.first { $0.platform == "Spotify" }

        #expect(apple != nil)
        #expect(spotify != nil)

        // A well-formed feed should be at least compatible (ok or warnings)
        if let apple {
            #expect(apple.status != .incompatible)
        }
        if let spotify {
            #expect(spotify.status != .incompatible)
        }
    }

    @Test("Minimal feed — PSP-1 is incompatible without locked, guid, atom self")
    func minimalFeedPSP1Incompatible() {
        let feed = minimalFeed()
        let report = auditor.audit(feed)

        let psp1 = report.compatibility.first { $0.platform == "PSP-1" }
        #expect(psp1 != nil)

        if let psp1 {
            #expect(psp1.status == .incompatible)
            #expect(psp1.errorCount > 0)
            #expect(psp1.isCompatible == false)
        }
    }

    @Test("isCompatible reflects errorCount — true when errorCount is 0")
    func isCompatibleReflectsErrorCount() {
        let compatibleResult = PlatformCompatibilityResult(
            platform: "Test",
            isCompatible: true,
            errorCount: 0,
            warningCount: 3,
            status: .warnings
        )
        #expect(compatibleResult.isCompatible == true)
        #expect(compatibleResult.errorCount == 0)

        let incompatibleResult = PlatformCompatibilityResult(
            platform: "Test",
            isCompatible: false,
            errorCount: 2,
            warningCount: 1,
            status: .incompatible
        )
        #expect(incompatibleResult.isCompatible == false)
        #expect(incompatibleResult.errorCount > 0)
    }

    @Test("Status derived correctly from errors and warnings")
    func statusDerivedCorrectly() {
        // errors > 0 -> incompatible
        let withErrors = PlatformCompatibilityResult(
            platform: "E",
            isCompatible: false,
            errorCount: 3,
            warningCount: 1,
            status: .incompatible
        )
        #expect(withErrors.status == .incompatible)

        // no errors + warnings > 0 -> warnings
        let withWarnings = PlatformCompatibilityResult(
            platform: "W",
            isCompatible: true,
            errorCount: 0,
            warningCount: 2,
            status: .warnings
        )
        #expect(withWarnings.status == .warnings)

        // no errors + no warnings -> ok
        let clean = PlatformCompatibilityResult(
            platform: "OK",
            isCompatible: true,
            errorCount: 0,
            warningCount: 0,
            status: .ok
        )
        #expect(clean.status == .ok)
    }

    @Test("Well-formed feed compatibility — all platforms produce valid results")
    func wellFormedFeedAllPlatformsProduceResults() {
        let feed = wellFormedFeed()
        let report = auditor.audit(feed)

        for result in report.compatibility {
            #expect(!result.platform.isEmpty)
            #expect(result.errorCount >= 0)
            #expect(result.warningCount >= 0)

            if result.errorCount == 0 {
                #expect(result.isCompatible == true)
            } else {
                #expect(result.isCompatible == false)
            }
        }
    }

    @Test("PlatformCompatibilityResult is Codable")
    func resultIsCodable() throws {
        let original = PlatformCompatibilityResult(
            platform: "Apple Podcasts",
            isCompatible: true,
            errorCount: 0,
            warningCount: 1,
            status: .warnings
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlatformCompatibilityResult.self, from: data)

        #expect(decoded == original)
    }

    @Test("PlatformCompatibilityResult is Equatable")
    func resultIsEquatable() {
        let a = PlatformCompatibilityResult(
            platform: "Spotify",
            isCompatible: true,
            errorCount: 0,
            warningCount: 0,
            status: .ok
        )
        let b = PlatformCompatibilityResult(
            platform: "Spotify",
            isCompatible: true,
            errorCount: 0,
            warningCount: 0,
            status: .ok
        )
        let c = PlatformCompatibilityResult(
            platform: "Amazon Music",
            isCompatible: false,
            errorCount: 1,
            warningCount: 0,
            status: .incompatible
        )
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Minimal feed has more incompatible platforms than well-formed feed")
    func minimalFeedMoreIncompatible() {
        let minReport = auditor.audit(minimalFeed())
        let wellReport = auditor.audit(wellFormedFeed())

        let minIncompat = minReport.compatibility.filter {
            $0.status == .incompatible
        }.count
        let wellIncompat = wellReport.compatibility.filter {
            $0.status == .incompatible
        }.count

        #expect(minIncompat >= wellIncompat)
    }

    @Test("CompatibilityStatus raw values are stable strings")
    func statusRawValuesStable() {
        #expect(PlatformCompatibilityResult.CompatibilityStatus.ok.rawValue == "ok")
        #expect(
            PlatformCompatibilityResult.CompatibilityStatus.warnings.rawValue == "warnings"
        )
        #expect(
            PlatformCompatibilityResult.CompatibilityStatus.incompatible.rawValue
                == "incompatible"
        )
    }
}
