import Foundation
import Testing

@testable import PodcastFeedMaker

struct ITunesOwnerTests {

    // MARK: - Init and Properties

    @Test
    func test_init_shouldStoreNameAndEmail() {
        let owner = ITunesOwner(name: "Alice Smith", email: "alice@example.com")
        #expect(owner.name == "Alice Smith")
        #expect(owner.email == "alice@example.com")
    }

    @Test
    func test_init_withSpecialCharacters() {
        let owner = ITunesOwner(name: "John & Sons", email: "john+special@example.com")
        #expect(owner.name == "John & Sons")
        #expect(owner.email == "john+special@example.com")
    }

    @Test
    func test_init_withEmptyStrings() {
        let owner = ITunesOwner(name: "", email: "")
        #expect(owner.name == "")
        #expect(owner.email == "")
    }

    // MARK: - Channel Integration

    @Test
    func test_channel_itunesOwner_shouldStoreOwner() throws {
        let owner = ITunesOwner(name: "Jane Doe", email: "jane@domain.com")
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast",
            itunesOwner: owner
        )
        #expect(channel.itunesOwner?.name == "Jane Doe")
        #expect(channel.itunesOwner?.email == "jane@domain.com")
    }

    @Test
    func test_channel_itunesOwner_defaultsToNil() throws {
        let channel = Channel(
            title: "My Podcast",
            link: try #require(URL(string: "https://example.com")),
            description: "A great podcast"
        )
        #expect(channel.itunesOwner == nil)
    }

    // MARK: - Equatable

    @Test
    func test_equatable_sameOwner() {
        let ownerA = ITunesOwner(name: "Alice", email: "a@example.com")
        let ownerB = ITunesOwner(name: "Alice", email: "a@example.com")
        #expect(ownerA == ownerB)
    }

    @Test
    func test_equatable_differentName() {
        let ownerA = ITunesOwner(name: "Alice", email: "a@example.com")
        let ownerB = ITunesOwner(name: "Bob", email: "a@example.com")
        #expect(ownerA != ownerB)
    }

    @Test
    func test_equatable_differentEmail() {
        let ownerA = ITunesOwner(name: "Alice", email: "a@example.com")
        let ownerB = ITunesOwner(name: "Alice", email: "b@example.com")
        #expect(ownerA != ownerB)
    }

    // MARK: - Hashable

    @Test
    func test_hashable() {
        let ownerA = ITunesOwner(name: "Alice", email: "a@example.com")
        let ownerB = ITunesOwner(name: "Alice", email: "a@example.com")
        let ownerC = ITunesOwner(name: "Bob", email: "b@example.com")
        let set: Set = [ownerA, ownerB, ownerC]
        #expect(set.count == 2)
        #expect(set.contains(ownerA))
        #expect(set.contains(ownerC))
    }

    // MARK: - Sendable

    @Test
    func test_sendableConformance() {
        func assertSendable<T: Sendable>(_: T.Type) {}
        assertSendable(ITunesOwner.self)
    }

    // MARK: - Codable

    @Test
    func test_codableConformance() throws {
        let owner = ITunesOwner(name: "Alice Smith", email: "alice@example.com")
        let encoder = JSONEncoder()
        let data = try encoder.encode(owner)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ITunesOwner.self, from: data)
        #expect(decoded == owner)
        #expect(decoded.name == "Alice Smith")
        #expect(decoded.email == "alice@example.com")
    }

    // MARK: - Mutability

    @Test
    func test_mutability() {
        var owner = ITunesOwner(name: "Alice", email: "alice@example.com")
        owner.name = "Bob"
        owner.email = "bob@example.com"
        #expect(owner.name == "Bob")
        #expect(owner.email == "bob@example.com")
    }
}
