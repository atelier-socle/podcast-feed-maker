import Foundation
import Testing

@testable import PodcastFeedMaker

@Suite("PlatformPreset")
struct PlatformPresetTests {

    @Test("apple preset returns single platform")
    func applePlatform() {
        #expect(PlatformPreset.apple.platforms == [.apple])
    }

    @Test("spotify preset returns single platform")
    func spotifyPlatform() {
        #expect(PlatformPreset.spotify.platforms == [.spotify])
    }

    @Test("amazon preset returns single platform")
    func amazonPlatform() {
        #expect(PlatformPreset.amazon.platforms == [.amazon])
    }

    @Test("podcastIndex preset returns single platform")
    func podcastIndexPlatform() {
        #expect(PlatformPreset.podcastIndex.platforms == [.podcastIndex])
    }

    @Test("psp1 preset returns single platform")
    func psp1Platform() {
        #expect(PlatformPreset.psp1.platforms == [.psp1])
    }

    @Test("majorPlatforms returns apple, spotify, amazon")
    func majorPlatforms() {
        let expected: Set<ValidationPlatform> = [.apple, .spotify, .amazon]
        #expect(PlatformPreset.majorPlatforms.platforms == expected)
    }

    @Test("openEcosystem returns podcastIndex, psp1")
    func openEcosystem() {
        let expected: Set<ValidationPlatform> = [.podcastIndex, .psp1]
        #expect(PlatformPreset.openEcosystem.platforms == expected)
    }

    @Test("universal returns 4 platforms")
    func universal() {
        let expected: Set<ValidationPlatform> = [.apple, .spotify, .amazon, .podcastIndex]
        #expect(PlatformPreset.universal.platforms == expected)
    }

    @Test("all returns all 5 platforms")
    func allPlatforms() {
        #expect(PlatformPreset.all.platforms == Set(ValidationPlatform.allCases))
        #expect(PlatformPreset.all.platforms.count == 5)
    }

    @Test("custom returns provided set")
    func customPreset() {
        let custom: Set<ValidationPlatform> = [.apple, .psp1]
        #expect(PlatformPreset.custom(custom).platforms == custom)
    }

    @Test("Hashable — single-case presets are distinct")
    func hashable() {
        let set: Set<PlatformPreset> = [.apple, .spotify, .amazon, .podcastIndex, .psp1]
        #expect(set.count == 5)
    }
}
