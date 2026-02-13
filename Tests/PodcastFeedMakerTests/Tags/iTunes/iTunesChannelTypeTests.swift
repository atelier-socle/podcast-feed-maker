import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesChannelTypeTests {

    // MARK: - Enum Cases

    @Test
    func test_episodic_rawValue() {
        #expect(ITunesShowType.episodic.rawValue == "episodic")
    }

    @Test
    func test_serial_rawValue() {
        #expect(ITunesShowType.serial.rawValue == "serial")
    }

    @Test
    func test_initFromRawValue_episodic() {
        let showType = ITunesShowType(rawValue: "episodic")
        #expect(showType == .episodic)
    }

    @Test
    func test_initFromRawValue_serial() {
        let showType = ITunesShowType(rawValue: "serial")
        #expect(showType == .serial)
    }

    @Test
    func test_initFromRawValue_invalid() {
        let showType = ITunesShowType(rawValue: "unknown")
        #expect(showType == nil)
    }

    // MARK: - CaseIterable

    @Test
    func test_allCases_containsTwoCases() {
        #expect(ITunesShowType.allCases.count == 2)
        #expect(ITunesShowType.allCases.contains(.episodic))
        #expect(ITunesShowType.allCases.contains(.serial))
    }

    // MARK: - Channel Integration

    @Test
    func test_channel_itunesType_episodic() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesType: .episodic
        )
        #expect(channel.itunesType == .episodic)
    }

    @Test
    func test_channel_itunesType_serial() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesType: .serial
        )
        #expect(channel.itunesType == .serial)
    }

    @Test
    func test_channel_itunesType_defaultsToNil() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast"
        )
        #expect(channel.itunesType == nil)
    }

    // MARK: - Equatable and Hashable

    @Test
    func test_equatable() {
        #expect(ITunesShowType.episodic == ITunesShowType.episodic)
        #expect(ITunesShowType.serial == ITunesShowType.serial)
        #expect(ITunesShowType.episodic != ITunesShowType.serial)
    }

    @Test
    func test_hashable() {
        let set: Set<ITunesShowType> = [.episodic, .serial, .episodic]
        #expect(set.count == 2)
        #expect(set.contains(.episodic))
        #expect(set.contains(.serial))
    }

    // MARK: - Sendable and Codable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(ITunesShowType.self)
    }

    @Test
    func test_codableConformance() throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(ITunesShowType.episodic)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ITunesShowType.self, from: data)
        #expect(decoded == .episodic)
    }
}
